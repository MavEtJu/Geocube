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
    NSString *prefixTiles;
}

@end

@implementation RemoteAPI_GGCW

@synthesize delegate, callback;

enum {
    GGCW_NONE = 0,

    GGCW_TILESERVERS,
    GGCW_GGCWSERVER,
};

- (instancetype)init:(RemoteAPI *)_remoteAPI
{
    self = [super init];

    prefix = @"https://www.geocaching.com";
    prefixTiles = @"https://tiles%02d.geocaching.com%@";

    remoteAPI = _remoteAPI;
    callback = remoteAPI.account.gca_callback_url;
    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];

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
        [cookiemgr setCookie:authCookie];
    }


    // Set-Cookie:        Send2GPS=garmin; expires=Tue, 07-Nov-2017 11:44:23 GMT; path=/
    NSHTTPCookie *send2gps = [NSHTTPCookie cookieWithProperties:
                              [NSDictionary
                               dictionaryWithObjects:@[
                                                       @"/",
                                                       @"Send2GPS",
                                                       @"garmin",
                                                       @".geocaching.com"
                                                       ] forKeys:@[
                                                                   NSHTTPCookiePath,
                                                                   NSHTTPCookieName,
                                                                   NSHTTPCookieValue,
                                                                   NSHTTPCookieDomain
                                                                   ]
                               ]
                              ];
    [cookiemgr setCookie:send2gps];

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
    return [self prepareURLString:suffix params:params servers:GGCW_GGCWSERVER];
}

- (NSString *)prepareURLString:(NSString *)suffix params:(NSDictionary *)params servers:(NSInteger)servers
{
    NSMutableString *urlString = nil;
    switch (servers) {
        case GGCW_GGCWSERVER:
            urlString = [NSMutableString stringWithFormat:@"%@%@", prefix, suffix];
            break;
        case GGCW_TILESERVERS:
            urlString = [NSMutableString stringWithFormat:prefixTiles, 1 + arc4random_uniform(4l), suffix];
            break;
        default:
            NSAssert1(FALSE, @"Unknown server type: %ld", (long)servers);
            break;
    }
    if (params != nil && [params count] != 0) {
        NSString *ps = [MyTools urlParameterJoin:params];
        [urlString appendFormat:@"?%@", ps];
    }
    return urlString;
}

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest downloadInfoItem:(InfoItemDownload *)iid
{
    return [self performURLRequest:urlRequest returnRespose:nil downloadInfoItem:iid];
}

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest returnRespose:(NSHTTPURLResponse **)returnHeader downloadInfoItem:(InfoItemDownload *)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem downloadInfoItem:iid];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    NSData *data = [retDict objectForKey:@"data"];
    NSHTTPURLResponse *response = [retDict objectForKey:@"response"];
    if (returnHeader != nil)
        *returnHeader = response;
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
#warning XXX increase data returned
//            [d setValue:[NSNumber numberWithInteger:[MyTools secondsSinceEpochFromWindows:[pq objectForKey:@"DateLastGenerated"]]] forKey:@"DateTime"];
//            [d setValue:[pq objectForKey:@"FileSizeInBytes"] forKey:@"size"];
//            [d setValue:[pq objectForKey:@"PQCount"] forKey:@"waypointcount"];
            [ds setObject:d forKey:name];
        }];

    }

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:ds];
    return dict;

}

- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"pocket_downloadpq:%@", guid);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@"web" forKey:@"src"];
    [params setObject:guid forKey:@"g"];

    NSString *urlString = [self prepareURLString:@"/pocket/downloadpq.ashx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    GCDataZIPFile *zipdata = [[GCDataZIPFile alloc] initWithData:data];
    return zipdata;
}

- (GCStringGPX *)geocache:(NSString *)wptname downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"geocache:%@", wptname);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    /*
     * When requesting /geocache/GCxxxx, it will return a 301 response to the full URL.
     *
     */

    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/geocache/%@", wptname] params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnRespose:&resp downloadInfoItem:iid];

    // Expecting a 301.
    if (resp.statusCode != 301)
        return nil;
    NSString *location = [resp.allHeaderFields objectForKey:@"Location"];

    // Request the page with the data for the GPX file
    url = [NSURL URLWithString:location];
    req = [NSMutableURLRequest requestWithURL:url];
    data = [self performURLRequest:req returnRespose:&resp downloadInfoItem:iid];

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

#define GETVALUE(__string__, __varname__) \
    NSString *__varname__ = nil; \
    { \
        NSString *re = [NSString stringWithFormat:@"//input[@name='%@']", __string__]; \
        NSArray *nodes = [parser searchWithXPathQuery:re]; \
        TFHppleElement *e = [nodes objectAtIndex:0]; \
        __varname__ = [e.attributes objectForKey:@"value"]; \
    }

    GETVALUE(@"__EVENTTARGET", eventtarget);
    GETVALUE(@"__EVENTARGUMENT", eventargument);
    GETVALUE(@"__VIEWSTATEFIELDCOUNT", viewstatefieldcount);
    GETVALUE(@"__VIEWSTATE", viewstate);
    GETVALUE(@"__VIEWSTATE1", viewstate1);
    GETVALUE(@"__VIEWSTATEGENERATOR", viewstategenerator);

    // Grab the form data
    // <input type="hidden" name="__EVENTTARGET" id="__EVENTTARGET" value="" />
    /*
     __EVENTTARGET:
     __EVENTARGUMENT:
     __VIEWSTATEFIELDCOUNT:
     __VIEWSTATE: /
     __VIEWSTATE1
     __VIEWSTATEGENERATOR:
     ctl00$ContentBody$btnGPXDL:
     */

    // And now request the GPX file
    url = [NSURL URLWithString:location];
    req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:location forHTTPHeaderField:@"Referer"];

    NSMutableString *ps = [NSMutableString stringWithFormat:@""];

    [ps appendFormat:@"%@=%@", [MyTools urlEncode:@"ctl00$ContentBody$btnGPXDL"], [MyTools urlEncode:@"GPX file"]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTTARGET"], [MyTools urlEncode:eventtarget]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTARGUMENT"], [MyTools urlEncode:eventargument]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATEFIELDCOUNT"], [MyTools urlEncode:viewstatefieldcount]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATE"], [MyTools urlEncode:viewstate]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATE1"], [MyTools urlEncode:viewstate1]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATEGENERATOR"], [MyTools urlEncode:viewstategenerator]];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    data = [self performURLRequest:req downloadInfoItem:iid];

    GCStringGPX *gpx = [[GCStringGPX alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return gpx;
}

- (GCDictionaryGGCW *)account_oauth_token:(InfoItemDownload *)iid
{
    NSLog(@"account_oauth_token:");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    /*
     * When requesting /geocache/GCxxxx, it will return a 301 response to the full URL.
     *
     */

    NSString *urlString = [self prepareURLString:@"/account/oauth/token" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)map:(InfoItemDownload *)iid
{
    NSLog(@"map");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    /*
     * When requesting /geocache/GCxxxx, it will return a 301 response to the full URL.
     *
     */

    NSString *urlString = [self prepareURLString:@"/map/" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:10];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    // First find the usersession data
    NSString *re = [NSString stringWithFormat:@"//script"];
    NSArray *nodes = [parser searchWithXPathQuery:re];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *e, NSUInteger idx, BOOL *stop) {
        NSString *s = e.content;
        NSRange r = [s rangeOfString:@"Groundspeak.UserSession"];
        if (r.location == NSNotFound)
            return;
        /*
        new Groundspeak.UserSession('wo9e', {userOptions:'XPTf', sessionToken:'e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaYKLU-1ltM2d_CTr-bM3TK71F14-I0jNX-g43E74GPPt0', subscriberType: 3, enablePersonalization: true });\
         */
        s = [s substringFromIndex:r.location + r.length + 1];
        /*
            'wo9e', {userOptions:'XPTf', sessionToken:'e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaYKLU-1ltM2d_CTr-bM3TK71F14-I0jNX-g43E74GPPt0', subscriberType: 3, enablePersonalization: true });\
         */
        r = [s rangeOfString:@","];
        NSString *username = [s substringWithRange:NSMakeRange(1, r.location - 2)];

        r = [s rangeOfString:@"sessionToken:"];
        s = [s substringFromIndex:r.location + r.length + 1];
        /*
            'e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaYKLU-1ltM2d_CTr-bM3TK71F14-I0jNX-g43E74GPPt0', subscriberType: 3, enablePersonalization: true });\
         */
        r = [s rangeOfString:@","];
        NSString *sessionToken = [s substringWithRange:NSMakeRange(0, r.location - 1)];

        // Now store it
        [json setObject:username forKey:@"usersession.username"];
        [json setObject:sessionToken forKey:@"usersession.sessionToken"];

        *stop = YES;

    }];

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)map_info:(NSInteger)x y:(NSInteger)y z:(NSInteger)z downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"map_info(x,y,z): (%ld,%ld,%ld)", x, y, z);


    /*
     * This is the tile info requested:
     * x, y, z is the coordinates for the tile.
     * k / st is the username, sessiontoken.
     * _ is the time(NULL) * 1000.
     * callback is the label for the returned data.
     * ts is ?

    https://tiles04.geocaching.com/map.info?ts=2&x=15070&y=9841&z=14&k=wo9e&st=e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaSE7NYnMquJsMGoz5tapdJOdNLv3doYRV46MHwovgcHk0&ep=1&callback=jQuery19102689279553556684_1478429965122&_=1478429965123
     */

    NSString *jQueryCallback = [NSString stringWithFormat:@"jQuery%08d", arc4random_uniform(100000000l)];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInteger:2] forKey:@"ts"];
    [params setObject:[NSNumber numberWithInteger:x] forKey:@"x"];
    [params setObject:[NSNumber numberWithInteger:y] forKey:@"y"];
    [params setObject:[NSNumber numberWithInteger:z] forKey:@"z"];
    [params setObject:remoteAPI.account.ggcw_username forKey:@"k"];
    [params setObject:remoteAPI.account.ggcw_sessiontoken forKey:@"st"];
    [params setObject:jQueryCallback forKey:@"callback"];
    [params setObject:[NSNumber numberWithInteger:[MyTools millisecondsSinceEpoch]] forKey:@"_"];

    NSString *urlString = [self prepareURLString:@"/map.info" params:params servers:GGCW_TILESERVERS];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [MyTools removeJSONWrapper:s jsonWrapper:jQueryCallback];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error != nil)
        return nil;
    if (json == nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)map_details:(NSString *)wpcode downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"map_details:%@", wpcode);

    /*
    https://tiles01.geocaching.com/map.details?i=GC41A7D&k=wo9e&st=e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaSE7NYnMquJsMGoz5tapdJOdNLv3doYRV46MHwovgcHk0&jsoncallback=jQuery19102689279553556684_1478429965124&_=1478429965131
     */

    NSString *jQueryCallback = [NSString stringWithFormat:@"jQuery%08d", arc4random_uniform(100000000l)];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:wpcode forKey:@"i"];
    [params setObject:remoteAPI.account.ggcw_username forKey:@"k"];
    [params setObject:remoteAPI.account.ggcw_sessiontoken forKey:@"st"];
    [params setObject:jQueryCallback forKey:@"jsoncallback"];
    [params setObject:[NSNumber numberWithInteger:[MyTools millisecondsSinceEpoch]] forKey:@"_"];

    NSString *urlString = [self prepareURLString:@"/map.details" params:params servers:GGCW_TILESERVERS];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    // Get JSON string without the jQueryCallback wrapper
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [MyTools removeJSONWrapper:s jsonWrapper:jQueryCallback];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error != nil)
        return nil;
    if (json == nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"seek_sendtogps:%@", guid);
    /*
 https://www.geocaching.com/seek/sendtogps.aspx?guid=2e73eec0-835c-4b71-a1be-5ef498e01038&map=true
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:guid forKey:@"guid"];
    [params setObject:@"true" forKey:@"map"];

    NSString *urlString = [self prepareURLString:@"/seek/sendtogps.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *re = @"//textarea[@id='dataString']";
    NSArray *nodes = [parser searchWithXPathQuery:re];
    TFHppleElement *e = [nodes objectAtIndex:0];

    NSString *s = e.raw;
    NSRange r = [s rangeOfString:@">"];     // Find end of <textarea ....>
    r.location++;
    r.length = [s length] - [@"</textarea>" length] - r.location;
    s = [s substringWithRange:r];

    r = [s rangeOfString:@">"];     // Find end of <?xml ....>
    r.location++;
    r.length = [s length] - r.location;
    s = [s substringWithRange:r];

    GCStringGPXGarmin *gpx = [[GCStringGPXGarmin alloc] initWithString:s];
    return gpx;
}

- (NSArray *)my_inventory:(InfoItemDownload *)iid
{
    NSLog(@"my_inventory");
    /*
     https://www.geocaching.com/my/inventory.aspx
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/my/inventory.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *re = @"//table[@class='Table NoBottomSpacing']/tbody/tr";
    NSArray *nodes = [parser searchWithXPathQuery:re];

    NSMutableArray *tbs = [NSMutableArray arrayWithCapacity:[nodes count]];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *trs, NSUInteger idx, BOOL *stop) {
        NSLog(@"trs: %ld", [trs.children count]);
        TFHppleElement *tds = [trs.children objectAtIndex:1];
        NSLog(@"tds: %ld", [tds.children count]);
        TFHppleElement *td = [tds.children objectAtIndex:1];
        /*
         <a href="/track/details.aspx?guid=93201211-b611-4502-ac7d-e5a80b722067" class="lnk">
         <img alt="" src="/images/wpttypes/sm/1893.gif"> <span>David´s Wildcoin</span></a>
         */
        NSString *href = [td.attributes objectForKey:@"href"];
        NSRange r = [href rangeOfString:@"guid="];
        NSString *guid = [href substringFromIndex:r.location + r.length];
        TFHppleElement *name = [td.children objectAtIndex:3];

        NSMutableDictionary *tb = [NSMutableDictionary dictionaryWithCapacity:3];
        [tb setObject:href forKey:@"href"];
        [tb setObject:name.content forKey:@"name"];
        [tb setObject:guid forKey:@"guid"];

        [tbs addObject:tb];

        NSLog(@"Foo");
    }];

    return tbs;
}

- (NSDictionary *)track_details:(NSString *)guid downloadInfoItem:(InfoItemDownload *)iid
{
    NSLog(@"track_details:%@", guid);
    /*
     https://www.geocaching.com/track/details.aspx?guid=93201211-b611-4502-ac7d-e5a80b722067
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:guid forKey:@"guid"];

    NSString *urlString = [self prepareURLString:@"/track/details.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req downloadInfoItem:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    /*
     <span id="ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode"
     class="CoordInfoCode">TB4HC6C</span>
     */
    NSString *re = @"//span[@id='ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode']";
    NSArray *nodes = [parser searchWithXPathQuery:re];
    NSString *gccode = [[nodes objectAtIndex:0] content];

    /*
     <h4 class="BottomSpacing">
     Tracking History (120589.7km&nbsp;) <a href="map_gm.aspx?ID=3801141" title='View Map'>View Map</a>
     </h4>
     */
    re = @"//h4[@class='BottomSpacing']/a[@title='View Map']";
    nodes = [parser searchWithXPathQuery:re];
    TFHppleElement *e = [nodes objectAtIndex:0];
    NSString *u = [e.attributes objectForKey:@"href"];
    NSRange r = [u rangeOfString:@"ID="];
    NSString *_id = [u substringFromIndex:r.location + r.length];

    /*
     <a id="ctl00_ContentBody_BugDetails_BugOwner" title="Visit&#32;User&#39;s&#32;Profile" href="https://www.geocaching.com/profile/?guid=5d41d7b7-c124-479b-965d-c7ca5d4799bb">Delta_03</a>
     */
    re = @"//a[@id='ctl00_ContentBody_BugDetails_BugOwner']";
    nodes = [parser searchWithXPathQuery:re];
    e = [nodes objectAtIndex:0];
    NSString *owner = e.content;

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:gccode forKey:@"gccode"];
    [dict setObject:_id forKey:@"id"];
    [dict setObject:owner forKey:@"owner"];

    return dict;
}

@end
