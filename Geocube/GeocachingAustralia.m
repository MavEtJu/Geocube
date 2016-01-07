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

@interface GeocachingAustralia ()
{
    RemoteAPI *remoteAPI;
    id delegate;
    NSHTTPCookie *authCookie;
    NSString *callback;

    NSMutableDictionary *logtypes;
}

@end

@implementation GeocachingAustralia

@synthesize delegate, callback;

- (instancetype)init:(RemoteAPI *)_remoteAPI
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

    logtypes = [NSMutableDictionary dictionaryWithCapacity:20];
    [logtypes setObject:@"F" forKey:@"Found it"];
    [logtypes setObject:@"D" forKey:@"Did not find it"];
    [logtypes setObject:@"N" forKey:@"Noted"];
    [logtypes setObject:@"E" forKey:@"Needs archiving"];
    [logtypes setObject:@"M" forKey:@"Needs maintenance"];
    [logtypes setObject:@"C" forKey:@"Maintained"];
    [logtypes setObject:@"B" forKey:@"Published"];
    [logtypes setObject:@"I" forKey:@"Disabled"];
    [logtypes setObject:@"L" forKey:@"Enabled"];
    [logtypes setObject:@"V" forKey:@"Archived"];
    [logtypes setObject:@"U" forKey:@"Unarchived"];

    return self;
}

- (NSArray *)logtypes:(NSString *)waypointType
{
    return [logtypes allKeys];
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

    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    return lines;
}

- (NSArray *)postPage:(NSString *)baseUrl params:(NSDictionary *)params
{
    NSMutableString *urlString = [NSMutableString stringWithString:baseUrl];

    NSMutableString *ps = [NSMutableString stringWithString:@""];
    [[params allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([ps isEqualToString:@""] == NO)
            [ps appendString:@"&"];
        [ps appendFormat:@"%@=%@", [MyTools urlEncode:key], [MyTools urlEncode:[params valueForKey:key]]];
    }];

    NSURL *url = [NSURL URLWithString:urlString];
    GCMutableURLRequest *req = [GCMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (data == nil || response.statusCode != 200)
        return nil;

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
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/finds/", [MyTools urlEncode:name]];
    NSArray *lines = [self loadPage:urlString];
    NSDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString *value = [self FindValueInLine:lines key:@"Geocaching Australia Finds"];
    if (value != nil)
        [ret setValue:value forKey:@"waypoints_found"];

    return ret;
}

- (NSDictionary *)cacher_statistic__hides:(NSString *)name
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/hides/", [MyTools urlEncode:name]];
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

- (NSString *)cache_gpx:(NSString *)wpname
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cache/%@.gpx", [MyTools urlEncode:wpname]];
    NSArray *lines = [self loadPage:urlString];
    return [lines componentsJoinedByString:@""];
}

- (NSInteger)my_log_new:(NSString *)logtype waypointName:(NSString *)wpname dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/log/new/%@", [MyTools urlEncode:wpname]];

    NSMutableDictionary *ps = [NSMutableDictionary dictionaryWithCapacity:5];
    [logtypes enumerateKeysAndObjectsUsingBlock:^(NSString *lt, NSString *value, BOOL *stop) {
        if ([lt isEqualToString:logtype] == YES) {
            [ps setValue:value forKey:@"action"];
            *stop = YES;
        }
    }];
    [ps setValue:note forKey:@"text"];

    if (favourite == YES)
        [ps setValue:@"5" forKey:@"Overall Experience"];
    else
        [ps setValue:@"2" forKey:@"Overall Experience"];

    [ps setValue:[dateLogged substringWithRange:NSMakeRange(0, 4)] forKey:@"gca_date_selector_year"];
    [ps setValue:[dateLogged substringWithRange:NSMakeRange(5, 2)] forKey:@"gca_date_selector_month"];
    [ps setValue:[dateLogged substringWithRange:NSMakeRange(8, 2)] forKey:@"gca_date_selector_day"];

    [ps setValue:@"" forKey:@"coords"];
    [ps setValue:@"" forKey:@"hints"];
    [ps setValue:@"" forKey:@"public_tags"];
    [ps setValue:@"" forKey:@"private_tags"];
    [ps setValue:@"" forKey:@"cacher"];
    [ps setValue:@"Log" forKey:@"button"];

    NSArray *lines = [self postPage:urlString params:ps];

    __block BOOL found = NO;
    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL *stop) {
        NSRange r = [l rangeOfString:@"Log added"];
        if (r.location == NSNotFound)
            return;
        found = YES;
    }];
    if (found == NO)
        return 0;
    return -1;
}

- (NSDictionary *)caches_gca:(CLLocationCoordinate2D)center
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/caches/gca.json?center=%f,%f&cacher=no", center.latitude, center.longitude];

    NSArray *lines = [self loadPage:urlString];
    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    return json;
}

- (NSDictionary *)logs_cache:(NSString *)wpname
{
    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/logs/cache/%@.json", wpname];

    NSArray *lines = [self loadPage:urlString];
    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    return json;

}

@end
