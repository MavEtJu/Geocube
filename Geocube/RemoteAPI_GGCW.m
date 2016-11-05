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

@interface RemoteAPI_GGCW ()
{
    RemoteAPI *remoteAPI;
    NSHTTPCookie *authCookie;

    NSString *prefix;
}

@end

@implementation RemoteAPI_GGCW

@synthesize delegate, callback;

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    prefix = @"https://www.geocaching.com";

    remoteAPI = _remoteAPI;
    callback = remoteAPI.account.gca_callback_url;
    if (remoteAPI.account.gca_cookie_value != nil) {
        authCookie = [NSHTTPCookie cookieWithProperties:
                      [NSDictionary
                       dictionaryWithObjects:@[
                                               @"/",
                                               remoteAPI.account.gca_cookie_name,
                                               [MyTools urlEncode:remoteAPI.account.gca_cookie_value],
                                               @".geocaching.com" //remoteAPI.account.url_site
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
    return YES;
}
- (BOOL)commentSupportsPhotos
{
    return YES;
}
- (BOOL)commentSupportsRating
{
    return NO;
}
- (NSRange)commentSupportsRatingRange
{
    return NSMakeRange(0, 0);
}
- (BOOL)commentSupportsTrackables
{
    return YES;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return YES;
}

- (void)storeCookie:(NSHTTPCookie *)cookie
{
    if (delegate != nil)
        [delegate GCAuthSuccessful:cookie];
}

// ------------------------------------------------

- (NSString *)prepareURLString:(NSString *)suffix params:(NSDictionary *)params
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", prefix, suffix];
    if (params != nil && [params count] != 0) {
        NSString *ps = [MyTools urlParameterJoin:params];
        [urlString appendFormat:@"&%@", ps];
    }
    return urlString;
}

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest downloadInfoItem:(InfoItemDownload *)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    NSError *error = [retDict objectForKey:@"error"];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    //  NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //  NSLog(@"retbody: %@", retbody);

    if (error != nil) {
        NSLog(@"error: %@", [error description]);
        NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"retbody: %@", retbody);
        [remoteAPI setNetworkError:[error description] error:REMOTEAPI_APIREFUSED];
        return nil;
    }
    if (response.statusCode != 200) {
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

    return data;
}

// ------------------------------------------------

- (GCDictionaryGGCW *)my_default:(NSString *)username downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"my_default:%@", username);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/my/default.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];

    //
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    // Find the data for the "Found" field.
    NSInteger iFound = 0;
    {
        NSString *re = @"//div[@id='uxCacheFind']/span[@class='statcount']";
        NSArray *nodes = [parser searchWithXPathQuery:re];
        TFHppleElement *e = [nodes objectAtIndex:0];
        TFHppleElement *child = [e.children objectAtIndex:0];
        NSString *s = child.content;
        NSString *sFound = [s stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        iFound = [sFound integerValue];
    }

    // Find the data for the "Hidden" field.
    NSInteger iHidden = 0;
    {
        NSString *re = @"//div[@id='uxCacheHide']/span[@class='statcount']";
        NSArray *nodes = [parser searchWithXPathQuery:re];
        TFHppleElement *e = [nodes objectAtIndex:0];
        TFHppleElement *child = [e.children objectAtIndex:0];
        NSString *s = child.content;
        NSString *sHidden = [s stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        iHidden = [sHidden integerValue];
    }

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];
    [d setObject:[NSNumber numberWithInteger:iFound] forKey:@"caches_found"];
    [d setObject:[NSNumber numberWithInteger:iHidden] forKey:@"caches_hidden"];

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:d];
    return dict;
}

- (GCDictionaryGGCW *)pocket_default:(InfoItemDownload *)iid
{
    NSLog(@"pocket_default");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/pocket/default.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];

    //
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSMutableDictionary *ds = [NSMutableDictionary dictionaryWithCapacity:4];

    // Find the data for the "Found" field.
    {
        NSString *re = @"//table[@id='uxOfflinePQTable']/tr/td/a";
        NSArray *nodes = [parser searchWithXPathQuery:re];
        [nodes enumerateObjectsUsingBlock:^(TFHppleElement *e, NSUInteger idx, BOOL *stop) {
            NSString *s = e.content;
            NSString *name = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *href = [e.attributes objectForKey:@"href"];
            NSLog(@"%@ - %@", name, href);

            // Get rid of non-URLs
            if ([href containsString:@"downloadpq.ashx"] == NO)
                return;

            NSMutableString *g = [NSMutableString stringWithString:href];
            NSRange r = [g rangeOfString:@"g="];
            if (r.location != NSNotFound) {
                r.length += r.location;
                r.location = 0;
                [g deleteCharactersInRange:r];
            }
            r = [g rangeOfString:@"&"];
            if (r.location != NSNotFound) {
                r.length = [g length] - r.location;
                [g deleteCharactersInRange:r];
            }

            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
            [d setValue:name forKey:@"name"];
            [d setValue:g forKey:@"g"];
#warning XXX todo
//            [d setValue:[NSNumber numberWithInteger:[MyTools secondsSinceEpochFromWindows:[pq objectForKey:@"DateLastGenerated"]]] forKey:@"DateTime"];
//            [d setValue:[pq objectForKey:@"FileSizeInBytes"] forKey:@"size"];
//            [d setValue:[pq objectForKey:@"PQCount"] forKey:@"waypointcount"];
            [ds setObject:d forKey:name];
        }];

    }

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:ds];
    return dict;

}

@end
