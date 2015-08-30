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

#import "Geocube-Prefix.pch"

@implementation GeocachingAustralia

@synthesize delegate, callback;

- (id)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    remoteAPI = _remoteAPI;
    callback = remoteAPI.account.gca_callback_url;
    if (remoteAPI.account.gca_cookie_value != nil) {
        authCookie = [NSHTTPCookie cookieWithProperties:
                      [NSDictionary
                           dictionaryWithObjects:@[
                               @"/",
                               remoteAPI.account.gca_cookie_name,
                               [MyTools urlencode:remoteAPI.account.gca_cookie_value],
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

- (void)storeCookie:(NSHTTPCookie *)cookie
{
    if (delegate != nil)
        [delegate GCAAuthSuccessful:cookie];
}

- (NSArray *)loadPage:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (data == nil || response.statusCode != 200)
        return nil;

    // <div class='floater40'>Geocaching Australia Finds</div>
    // <div class='floater60'><b>49</b> </div>
    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    return lines;
}

- (NSString *)FindValueInLine:(NSArray *)lines key:(NSString *)key
{
    __block BOOL found = NO;
    __block NSString *value = nil;

    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL *stop) {
        if (found == YES) {
            // <div class='floater60'><b>49</b> </div>
            value = [MyTools stripHTML:l];
            *stop = YES;
            return;
        }

        // <div class='floater40'>Geocaching Australia Finds</div>
        NSRange r = [l rangeOfString:key];
        if (r.location == NSNotFound)
            return;
        found = YES;
    }];

    return value;
}

- (NSDictionary *)cacher_statistic__finds:(NSString *)name
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/finds/", [MyTools urlencode:name]];
    NSArray *lines = [self loadPage:urlString];
    NSDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString *value = [self FindValueInLine:lines key:@"Geocaching Australia Finds"];
    if (value != nil)
        [ret setValue:value forKey:@"waypoints_found"];

    return ret;
}

- (NSDictionary *)cacher_statistic__hides:(NSString *)name
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/hides/", [MyTools urlencode:name]];
    NSArray *lines = [self loadPage:urlString];
    NSDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString *value = [self FindValueInLine:lines key:@"Total Geocaching Australia Hides"];
    if (value != nil)
        [ret setValue:value forKey:@"waypoints_hidden"];

    value = [self FindValueInLine:lines key:@"Recommendations on Caches Hidden"];
    if (value != nil)
        [ret setValue:value forKey:@"recommendations_received"];

    value = [self FindValueInLine:lines key:@"Recommendations Caches Hidden"];
    if (value != nil)
        [ret setValue:value forKey:@"recommendations_given"];

    return ret;
}

@end
