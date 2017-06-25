/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface ProtocolGCA2 ()
{
    RemoteAPITemplate *remoteAPI;
    NSHTTPCookie *authCookie;
    NSString *prefix;
    NSString *hostpart;
    NSString *key;
}

@end

@implementation ProtocolGCA2

- (instancetype)init:(RemoteAPITemplate *)_remoteAPI
{
    self = [super init];

    prefix = @"http://geocaching.com.au/api/services";
    hostpart = @"http://geocaching.com.au";
    key = keyManager.gca_api;

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
    NSArray<NSHTTPCookie *> *cookies = [cookiemgr cookiesForURL:req.URL];
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
    NSData *data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error infoViewer:nil iiDownload:0];

    account.gca_cookie_value = nil;
    if (error != nil) {
        [account disableRemoteAccess:[error description]];
        return NO;
    }
    if (response.statusCode != 200 && response.statusCode != 400) {
        [account disableRemoteAccess:[NSString stringWithFormat:@"statusCode != (200|400) (%ld)", (long)response.statusCode]];
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

- (GCStringGPX *)performURLRequestGPX:(NSURLRequest *)urlRequest infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem infoViewer:iv iiDownload:iid];

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

- (GCDictionaryGCA2 *)performURLRequest:(NSURLRequest *)urlRequest infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem infoViewer:iv iiDownload:iid];

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

    NSObject *d = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([d isKindOfClass:[NSDictionary class]] == NO) {
        [remoteAPI setAPIError:[error description] error:REMOTEAPI_JSONINVALID];
        return nil;
    }
    GCDictionaryGCA2 *json = [[GCDictionaryGCA2 alloc] initWithDictionary:d];
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
    if (key == nil || [key isEqualToString:@""] == YES)
        key = keyManager.gca_api;
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@?consumer_key=%@", prefix, suffix, key];
    if (params != nil && [params count] != 0) {
        NSString *ps = [MyTools urlParameterJoin:params];
        [urlString appendFormat:@"&%@", ps];
    }
    return urlString;
}

- (GCDictionaryGCA2 *)api_services_users_by__username:(NSString *)username infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_users_by__username:%@", username);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[MyTools urlEncode:username] forKey:@"username"];

    NSString *urlString = [self prepareURLString:@"/users/by_username/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_caches_geocache:%@", wptname);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[MyTools urlEncode:wptname] forKey:@"cache_code"];
    [params setObject:@"all" forKey:@"lpc"];
    [params setObject:@"0" forKey:@"my_location"];

    NSString *urlString = [self prepareURLString:@"/caches/geocache/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    return [self api_services_caches_geocaches:wps logs:30 infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_geocaches:(NSArray<NSString *> *)wps logs:(NSInteger)numlogs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_caches_geocaches:%ld", (long)[wps count]);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[MyTools urlEncode:[wps componentsJoinedByString:@"|"]] forKey:@"cache_codes"];
    [params setObject:[NSNumber numberWithInteger:numlogs] forKey:@"lpc"];

    NSString *urlString = [self prepareURLString:@"/caches/geocaches/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_search_nearest:(CLLocationCoordinate2D)coords infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_caches_search_nearest:%@", [Coordinates niceCoordinates:coords]);

    float radius = configManager.mapSearchMaximumDistanceGCA / 1000;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *c = [NSString stringWithFormat:@"%f|%f", coords.latitude, coords.longitude];
    [params setObject:[MyTools urlEncode:c] forKey:@"center"];
    [params setObject:[NSNumber numberWithFloat:radius] forKey:@"radius"];
    [params setObject:[MyTools urlEncode:@"Temporarily unavailable|Available"] forKey:@"status"];

    NSString *urlString = [self prepareURLString:@"/search/nearest/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_search_bbox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_search_bbox:%@", [bb description]);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *c = [NSString stringWithFormat:@"%f|%f|%f|%f", bb.bottomLat, bb.leftLon, bb.topLat, bb.rightLon];
    [params setObject:[MyTools urlEncode:c] forKey:@"bbox"];
    [params setObject:[MyTools urlEncode:@"Temporarily unavailable|Available"] forKey:@"status"];

    NSString *urlString = [self prepareURLString:@"/search/bbox/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_logs_submit:(dbWaypoint *)wp logtype:(NSString *)logtype comment:(NSString *)comment when:(NSString *)dateLogged rating:(NSInteger)rating recommended:(BOOL)recommended coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_logs_submit:%@", wp.wpt_name);

    NSMutableString *ps = [NSMutableString stringWithFormat:@""];
    if (key == nil || [key isEqualToString:@""] == YES)
        key = keyManager.gca_api;
    [ps appendFormat:@"consumer_key=%@", [MyTools urlEncode:key]];
    [ps appendFormat:@"&cache_code=%@", [MyTools urlEncode:wp.wpt_name]];
    [ps appendFormat:@"&logtype=%@", [MyTools urlEncode:logtype]];
    [ps appendFormat:@"&comment=%@", [MyTools urlEncode:comment]];
    [ps appendFormat:@"&when=%@", [MyTools urlEncode:dateLogged]];
    if (coordinates.latitude != 0 && coordinates.longitude != 0)
        [ps appendFormat:@"&coordinates=%@", [MyTools urlEncode:[NSString stringWithFormat:@"%f %f", coordinates.latitude, coordinates.latitude]]];

    NSString *urlString = [self prepareURLString:@"/logs/submit" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_logs_images_add:(NSNumber *)logid data:(NSData *)imgdata caption:(NSString *)imageCaption description:(NSString *)imageDescription infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_logs_images_add:%ld", (long)logid);

    NSString *urlString = [self prepareURLString:@"/logs/images/add" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];

    NSString *boundary = @"YOUR_BOUNDARY_STRING";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
    if (key == nil || [key isEqualToString:@""] == YES)
        key = keyManager.gca_api;
    [params setObject:key forKey:@"consumer_key"];
    [params setObject:logid forKey:@"log_uuid"];
    [params setObject:imageCaption forKey:@"caption"];
    [params setObject:imageDescription forKey:@"description"];
    [params setObject:imgdata forKey:@"image"];

    NSMutableData *body = [NSMutableData data];
    [[params allKeys] enumerateObjectsUsingBlock:^(NSString *k, NSUInteger idx, BOOL *stop) {
        if ([k isEqualToString:@"image"] == YES) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"photo.jpg\"\r\n", k] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:[params objectForKey:k]]];

            return;
        }

        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", k, [params objectForKey:k]] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    req.HTTPBody = body;

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_query_list:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_caches_query_list");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/caches/query/list/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

- (GCDictionaryGCA2 *)api_services_caches_query_geocaches:(NSString *)queryId infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"api_services_caches_query_geocaches:%@", queryId);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:queryId forKey:@"query"];

    NSString *urlString = [self prepareURLString:@"/caches/query/geocaches/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    return [self performURLRequest:req infoViewer:iv iiDownload:iid];
}

@end
