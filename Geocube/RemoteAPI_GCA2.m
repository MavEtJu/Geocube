/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

@interface RemoteAPI_GCA2 ()
{
    RemoteAPI *remoteAPI;
    NSHTTPCookie *authCookie;
    NSString *prefix;
    NSString *hostpart;
    NSString *key;
}

@end

@implementation RemoteAPI_GCA2

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    prefix = @"http://geocaching.com.au/api/services";
    hostpart = @"http://geocaching.com.au";
    key = @"5809a0f637e86";

    remoteAPI = _remoteAPI;
    if (remoteAPI.account.gca_cookie_value != nil) {
        authCookie = [NSHTTPCookie cookieWithProperties:
                      [NSDictionary
                       dictionaryWithObjects:@[
                                               @"/",
                                               remoteAPI.account.gca_cookie_name,
                                               [MyTools urlEncode:remoteAPI.account.gca_cookie_value],
                                               @".geocaching.com.au" //remoteAPI.account.url_site
                                               ] forKeys:@[
                                                           NSHTTPCookiePath,
                                                           NSHTTPCookieName,
                                                           NSHTTPCookieValue,
                                                           NSHTTPCookieDomain
                                                           ]
                       ]
                      ];
        // Set-Cookie: phpbb3mysql_data=a%3A2%3A%7Bs%3A11%3A%22autologinid%22%3Bs%3A34%3A%22%24H%249bhZ2qUoKtqdqSSeZZvlBdDXIAiGbi.%22%3Bs%3A6%3A%22userid%22%3Bs%3A6%3A%22119649%22%3B%7D; expires=Mon, 28-Sep-2015 13:36:09 GMT; path=/; domain=.geocaching.com.au.
        NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookiemgr setCookie:authCookie];
    }

    return self;
}

- (BOOL)commentSupportsFavouritePoint
{
    return NO;
}
- (BOOL)commentSupportsPhotos
{
    return YES;
}
- (BOOL)commentSupportsRating
{
    return YES;
}
- (NSRange)commentSupportsRatingRange
{
    return NSMakeRange(1, 5);
}
- (BOOL)commentSupportsTrackables
{
    return NO;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return NO;
}

- (BOOL)authenticate:(dbAccount *)account
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/login/", prefix]];

    NSMutableString *ps = [NSMutableString stringWithFormat:@""];
    [ps appendFormat:@"username=%@", [MyTools urlEncode:account.authentictation_name]];
    [ps appendFormat:@"&password=%@", [MyTools urlEncode:account.authentictation_password]];

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookiemgr cookiesForURL:req.URL];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *c, NSUInteger idx, BOOL *stop) {
        if ([c.name isEqualToString:account.gca_cookie_name] == YES)
            [cookiemgr deleteCookie:c];
        if ([c.name isEqualToString:@"country_region"] == YES)
            [cookiemgr deleteCookie:c];
    }];
    account.gca_cookie_value = @"";
    [account dbUpdateCookieValue];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error downloadInfoItem:nil];

    account.gca_cookie_value = nil;
    if (error != nil) {
        [account disableRemoteAccess:[error description]];
        return NO;
    }
    if (response.statusCode != 200 && response.statusCode != 400) {
        [account disableRemoteAccess:[NSString stringWithFormat:@"statusCode != (200|400) (%ld)", response.statusCode]];
        return NO;
    }
    if (data == nil) {
        [account disableRemoteAccess:@"Data returned is empty"];
        return NO;
    }

    // Check if the authentication cookie is there, but don't complain about it yet.
    cookies = [cookiemgr cookiesForURL:req.URL];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if ([cookie.name isEqualToString:account.gca_cookie_name] == NO)
            return;

        account.gca_cookie_value = [MyTools urlDecode:cookie.value];
        [account dbUpdateCookieValue];
        *stop = YES;
    }];

    // First see if there is a proper JSON data
    error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    if (error != nil || json == nil) {
        [account disableRemoteAccess:[error description]];
        return NO;
    }

    // Maybe with an error message!
    NSDictionary *jsonError = [json objectForKey:@"error"];
    if (jsonError != nil) {
        [account disableRemoteAccess:[jsonError objectForKey:@"developer_message"]];
        return NO;
    }

    // Now check if the authentication cookie was set.
    if (account.gca_cookie_value == nil) {
        [account disableRemoteAccess:@"No authentication cookie found!"];
        return NO;
    }

    [account enableRemoteAccess];

    return YES;
}

// --------------------------------------------------------------------------

- (GCStringGPX *)performURLRequestGPX:(NSURLRequest *)urlRequest downloadInfoItem:(InfoItemDowload *)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//  NSLog(@"error: %@", [error description]);
//  NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//  NSLog(@"retbody: %@", retbody);

    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setNetworkError:[error description] error:REMOTEAPI_APIREFUSED];
        return nil;
    }
    if (response.statusCode != 400 && response.statusCode != 200) {
        NSLog(@"statusCode: %ld", (long)response.statusCode);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setAPIError:[NSString stringWithFormat:@"HTTP Response was %ld", (long)response.statusCode] error:REMOTEAPI_APIFAILED];
        return nil;
    }

    if ([data length] == 0) {
        [remoteAPI setAPIError:@"Returned data is zero length" error:REMOTEAPI_APIFAILED];
        return nil;
    }

    GCStringGPX *gpx = [[GCStringGPX alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return gpx;
}

- (GCDictionaryGCA *)performURLRequest:(NSURLRequest *)urlRequest downloadInfoItem:(InfoItemDowload *)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//  NSLog(@"error: %@", [error description]);
//  NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//  NSLog(@"retbody: %@", retbody);

    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setNetworkError:[error description] error:REMOTEAPI_APIREFUSED];
        return nil;
    }
    if (response.statusCode != 400 && response.statusCode != 200) {
        NSLog(@"statusCode: %ld", (long)response.statusCode);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setAPIError:[NSString stringWithFormat:@"HTTP Response was %ld", (long)response.statusCode] error:REMOTEAPI_APIFAILED];
        return nil;
    }

    if ([data length] == 0) {
        [remoteAPI setAPIError:@"Returned data is zero length" error:REMOTEAPI_APIFAILED];
        return nil;
    }

    GCDictionaryGCA *json = [[GCDictionaryGCA alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]];
    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setAPIError:[error description] error:REMOTEAPI_JSONINVALID];
        return nil;
    }

    NSDictionary *e = [json objectForKey:@"error"];
    if (e != nil) {
        NSLog(@"error: %@", [e objectForKey:@"developer_message"]);
        [remoteAPI setAPIError:[e objectForKey:@"developer_message"] error:REMOTEAPI_APIFAILED];
        return nil;
    }

    return json;
}

- (NSString *)prepareURLString:(NSString *)suffix params:(NSDictionary *)params
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?consumer_key=%@", prefix, suffix, key];
    if (params != nil && [params count] != 0) {
        NSString *ps = [MyTools urlParameterJoin:params];
        [urlString appendFormat:@"&%@", ps];
    }
    return urlString;
}

- (NSString *)prepareOldURLString:(NSString *)suffix params:(NSDictionary *)params
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", hostpart, suffix];
    if (params != nil && [params count] != 0) {
        NSString *ps = [MyTools urlParameterJoin:params];
        [urlString appendFormat:@"&%@", ps];
    }
    return urlString;
}

// --------------------------------------------------------------------------

- (GCDictionaryGCA *)api_services_users_byusername:(NSString *)username downloadInfoItem:(InfoItemDowload *)iid;
{
    NSLog(@"api_services_users_byusername");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[MyTools urlEncode:username] forKey:@"username"];

    NSString *urlString = [self prepareURLString:@"/users/by_username/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req downloadInfoItem:iid];
}

// Old stuff

- (GCDictionaryGCA *)my_query_list__json:(InfoItemDowload *)iid
{
    NSLog(@"my_query_list__json");

    NSString *urlString = [self prepareOldURLString:@"/my/query/list.json" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req downloadInfoItem:iid];
}

- (GCDictionaryGCA *)my_query_json:(NSString *)queryname downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"my_query_json:%@", queryname);

    NSString *urlString = [self prepareOldURLString:[NSString stringWithFormat:@"/my/query/json/%@", queryname] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req downloadInfoItem:iid];
}

- (GCStringGPX *)my_query_gpx:(NSString *)queryname downloadInfoItem:(InfoItemDowload *)iid
{
    NSLog(@"my_query_gpx:%@", queryname);

    NSString *urlString = [self prepareOldURLString:[NSString stringWithFormat:@"/my/query/gpx/%@", queryname] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequestGPX:req downloadInfoItem:iid];
}

@end
