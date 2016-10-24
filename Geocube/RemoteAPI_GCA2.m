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
}

@end

@implementation RemoteAPI_GCA2

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    prefix = @"http://geocaching.com.au/api/services";

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

+ (BOOL)authenticate:(dbAccount *)account
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

@end
