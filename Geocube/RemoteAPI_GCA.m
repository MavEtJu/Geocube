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

@interface RemoteAPI_GCA ()
{
    RemoteAPI *remoteAPI;
    NSHTTPCookie *authCookie;
}

@end

@implementation RemoteAPI_GCA

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

- (void)storeCookie:(NSHTTPCookie *)cookie
{
    if (delegate != nil)
        [delegate GCAAuthSuccessful:cookie];
}

- (NSData *)loadDataForeground:(NSString *)urlString downloadInfoItem:(InfoItemDownload *)iid
{
    NSURL *url = [NSURL URLWithString:urlString];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:req returningResponse:&response error:&error downloadInfoItem:iid];

    if (response.statusCode == 403) {   // Forbidden
        remoteAPI.account.gca_cookie_value = @"";
        [remoteAPI.account dbUpdateCookieValue];
        return nil;
    }

    if (data == nil || response.statusCode != 200)
        return nil;

    return data;
}

- (NSString *)loadJSONForeground:(NSString *)urlString downloadInfoItem:(InfoItemDownload *)iid
{
    return [[NSString alloc] initWithData:[self loadDataForeground:urlString downloadInfoItem:iid] encoding:NSUTF8StringEncoding];
}

- (NSArray *)loadPage:(NSString *)urlString downloadInfoItem:(InfoItemDownload *)iid
{
    NSURL *url = [NSURL URLWithString:urlString];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:req semaphore:sem downloadInfoItem:iid];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    error = nil;    // XXXX get rid of compiler warning for now.

    if (response.statusCode == 403) {   // Forbidden
        remoteAPI.account.gca_cookie_value = @"";
        [remoteAPI.account dbUpdateCookieValue];
        return nil;
    }

    if (data == nil || response.statusCode != 200)
        return nil;

    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    return lines;
}

- (NSArray *)loadPageForeground:(NSString *)urlString downloadInfoItem:(InfoItemDownload *)iid
{
    NSURL *url = [NSURL URLWithString:urlString];
    GCURLRequest *req = [GCURLRequest requestWithURL:url];

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:req semaphore:sem downloadInfoItem:iid];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    error = nil;    //Make it shut up

    if (response.statusCode == 403) {   // Forbidden
        remoteAPI.account.gca_cookie_value = @"";
        [remoteAPI.account dbUpdateCookieValue];
        return nil;
    }

    if (data == nil || response.statusCode != 200)
        return nil;

    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    return lines;
}

- (NSArray *)postPageForm:(NSString *)baseUrl params:(NSDictionary *)params downloadInfoItem:(InfoItemDownload *)iid
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

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:req semaphore:sem downloadInfoItem:iid];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    error = nil;    // XXXX get rid of compiler warning for now.

    if (data == nil || response.statusCode != 200)
        return nil;

    NSArray *lines = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    return lines;
}

- (NSArray *)postPageMultiForm:(NSString *)baseUrl dataField:(NSString *)dataField params:(NSDictionary *)params downloadInfoItem:(InfoItemDownload *)iid
{
    NSMutableString *urlString = [NSMutableString stringWithString:baseUrl];

    NSURL *url = [NSURL URLWithString:urlString];
    GCMutableURLRequest *req = [GCMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    NSString *boundary = @"YOUR_BOUNDARY_STRING";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [req addValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    [[params allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([key isEqualToString:dataField] == YES) {
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"photo.jpg\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[NSData dataWithData:[params objectForKey:key]]];

            return;
        }

        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, [params objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [req setHTTPBody:body];

    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:req semaphore:sem downloadInfoItem:iid];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    error = nil;    // XXXX get rid of compiler warning for now.

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

// ------------------------------------------------

- (GCDictionaryGCA *)my_query_list__json:(InfoItemDownload *)iid
{
    NSLog(@"my_query_list__json");

    NSString *urlString = @"http://geocaching.com.au/my/query/list.json";
    NSData *data = [self loadDataForeground:urlString downloadInfoItem:iid];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    GCDictionaryGCA *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    return json;
}

- (NSArray *)my_query:(InfoItemDownload *)iid
{
    NSLog(@"my_query");
    // Obsolete, do not use aymore

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/query"];
    NSArray *lines = [self loadPageForeground:urlString downloadInfoItem:iid];

    NSError *e;
    NSRegularExpression *r1 = [NSRegularExpression regularExpressionWithPattern:@"<td.*queryid='(\\d+)'>(.*?)</td>" options:0 error:&e];
    NSRegularExpression *r2 = [NSRegularExpression regularExpressionWithPattern:@"Number of matching caches: (\\d+)"options:0 error:&e];

    NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];

    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *matches = [r1 matchesInString:l options:0 range:NSMakeRange(0, [l length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange rangeId = [match rangeAtIndex:1];
            NSRange rangeName = [match rangeAtIndex:2];

            NSString *_id = [l substringWithRange:rangeId];
            NSString *name = [l substringWithRange:rangeName];

            __block NSString *count = nil;

            NSLog(@"%@ - %@", _id, name);

            NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/query/count/%@", _id];
            NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
            [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *matches = [r2 matchesInString:l options:0 range:NSMakeRange(0, [l length])];
                for (NSTextCheckingResult *match in matches) {
                    NSRange countRange = [match rangeAtIndex:1];
                    count = [l substringWithRange:countRange];
                }
            }];

            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:2];
            [d setObject:_id forKey:@"Id"];
            [d setObject:name forKey:@"Name"];
            if (count != nil)
                [d setObject:count forKey:@"Count"];
            [as addObject:d];
        }
    }];

    return as;
}

- (GCDictionaryGCA *)cacher_statistic__finds:(NSString *)name downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"cacher_statistics__finds:%@", name);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/finds/", [MyTools urlEncode:name]];
    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString *value = [self FindValueInLine:lines key:@"Geocaching Australia Finds"];
    if (value != nil)
        [ret setValue:value forKey:@"waypoints_found"];

    return [[GCDictionaryGCA alloc] initWithDictionary:ret];
}

- (GCDictionaryGCA *)cacher_statistic__hides:(NSString *)name downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"cacher_statistics__hides");

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cacher/statistics/%@/hides/", [MyTools urlEncode:name]];
    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:1];

    NSString *value = [self FindValueInLine:lines key:@"Total Geocaching Australia Hides"];
    if (value != nil)
        [ret setValue:value forKey:@"waypoints_hidden"];

    value = [self FindValueInLine:lines key:@"Recommendations on Caches Hidden"];
    if (value != nil)
        [ret setValue:value forKey:@"recommendations_received"];

    value = [self FindValueInLine:lines key:@"Recommendations Caches Hidden"];
    if (value != nil)
        [ret setValue:value forKey:@"recommendations_given"];

    return [[GCDictionaryGCA alloc] initWithDictionary:ret];
}

- (GCStringGPX *)cache__gpx:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"cache__gpx:%@", wpname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cache/%@.gpx", [MyTools urlEncode:wpname]];
    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    return [GCStringGPX stringWithString:[lines componentsJoinedByString:@""]];
}

- (GCDictionaryGCA *)cache__json:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"cache__json:%@", wpname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/cache/%@.json", [MyTools urlEncode:wpname]];
    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    GCDictionaryGCA *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    return [[GCDictionaryGCA alloc] initWithDictionary:json];
}

- (GCDictionaryGCA *)my_log_new:(NSString *)logtype waypointName:(NSString *)wpname dateLogged:(NSString *)dateLogged note:(NSString *)note rating:(NSInteger)rating downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_log_new:%@", wpname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/log/new/%@", [MyTools urlEncode:wpname]];

    NSMutableDictionary *ps = [NSMutableDictionary dictionaryWithCapacity:5];
    [ps setValue:logtype forKey:@"action"];
    [ps setValue:note forKey:@"text"];

    [ps setValue:[NSString stringWithFormat:@"%ld", (long)rating] forKey:@"Overall_Experience"];

    [ps setValue:[dateLogged substringWithRange:NSMakeRange(0, 4)] forKey:@"gca_date_selector_year"];
    [ps setValue:[dateLogged substringWithRange:NSMakeRange(5, 2)] forKey:@"gca_date_selector_month"];
    [ps setValue:[dateLogged substringWithRange:NSMakeRange(8, 2)] forKey:@"gca_date_selector_day"];

    [ps setValue:@"" forKey:@"coords"];
    [ps setValue:@"" forKey:@"hints"];
    [ps setValue:@"" forKey:@"public_tags"];
    [ps setValue:@"" forKey:@"private_tags"];
    [ps setValue:@"" forKey:@"cacher"];
    [ps setValue:@"Log" forKey:@"button"];

    NSArray *lines = [self postPageForm:urlString params:ps downloadInfoItem:iid];

    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    if (json == nil)
        return nil;

    return [[GCDictionaryGCA alloc] initWithDictionary:json];
}

- (GCDictionaryGCA *)my_gallery_cache_add:(NSString *)wpname log_id:(NSInteger)log_id data:(NSData *)_data caption:(NSString *)caption description:(NSString *)description downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_gallery_cache_add:%@", wpname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/gallery/cache/add/%@", [MyTools urlEncode:wpname]];

    NSMutableDictionary *ps = [NSMutableDictionary dictionaryWithCapacity:10];
    [ps setValue:_data forKey:@"uploaded"];
    [ps setValue:wpname forKey:@"cache"];
    [ps setValue:caption forKey:@"caption"];
    [ps setValue:@"" forKey:@"cacher"];
    [ps setValue:description forKey:@"description"];
    [ps setValue:[NSNumber numberWithInteger:log_id] forKey:@"log_number"];
    [ps setValue:@"" forKey:@"swaggie"];
    [ps setValue:@"Save Image" forKey:@"button"];

    NSArray *lines = [self postPageMultiForm:urlString dataField:@"uploaded" params:ps downloadInfoItem:iid];

    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    if (json == nil)
        return nil;

    return [[GCDictionaryGCA alloc] initWithDictionary:json];
}

- (GCDictionaryGCA *)caches_gca:(CLLocationCoordinate2D)center downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"caches_gca:%@", [Coordinates NiceCoordinates:center]);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/caches/gca.json?center=%f,%f&cacher=no&limit=%ld", center.latitude, center.longitude, (long)configManager.mapSearchMaximumNumberGCA];

    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    GCDictionaryGCA *gcajson = [[GCDictionaryGCA alloc] initWithDictionary:json];

    return gcajson;
}

- (GCDictionaryGCA *)logs_cache:(NSString *)wpname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"logs_cache:%@", wpname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/logs/cache/%@.json", wpname];

    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];
    NSString *S = [lines componentsJoinedByString:@""];
    NSData *data = [S dataUsingEncoding:NSUTF8StringEncoding];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    return [[GCDictionaryGCA alloc] initWithDictionary:json];
}

- (GCDictionaryGCA *)my_query_json:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_query_json:%@", queryname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/query/json/%@", queryname];

    NSData *data = [self loadDataForeground:urlString downloadInfoItem:iid];

    if (data == nil) {
        NSLog(@"%@ - No data returned", [self class]);
        return nil;
    }

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    if (json == nil)
        return nil;

    return [[GCDictionaryGCA alloc] initWithDictionary:json];
}

- (GCStringGPX *)my_query_gpx:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_query_gpx:%@", queryname);

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/query/gpx/%@", queryname];

    NSData *data = [self loadDataForeground:urlString downloadInfoItem:iid];
    return [[GCStringGPX alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSInteger)my_query_count:(NSString *)queryname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_query_count:%@", queryname);

    __block NSInteger ret = -1;

    NSString *urlString = [NSString stringWithFormat:@"http://geocaching.com.au/my/query/count/%@", queryname];

    NSArray *lines = [self loadPage:urlString downloadInfoItem:iid];

    NSError *e = nil;
    NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:@"Number of matching caches: (\\d+)"options:0 error:&e];

    [lines enumerateObjectsUsingBlock:^(NSString *l, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *matches = [r matchesInString:l options:0 range:NSMakeRange(0, [l length])];
        for (NSTextCheckingResult *match in matches) {
            NSRange countRange = [match rangeAtIndex:1];
            ret = [[l substringWithRange:countRange] integerValue];
            *stop = YES;
        }
    }];

    return ret;
}

@end
