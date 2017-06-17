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

@interface ProtocolGGCW ()
{
    RemoteAPITemplate *remoteAPI;
    NSHTTPCookie *authCookie;

    NSString *prefix;
    NSString *prefixTiles;

    NSString *uid;
}

@property (nonatomic, retain, readwrite) NSString *callback;

@end

@implementation ProtocolGGCW

enum {
    GGCW_NONE = 0,

    GGCW_TILESERVERS,
    GGCW_GGCWSERVER,
};

- (instancetype)init:(RemoteAPITemplate *)_remoteAPI
{
    self = [super init];

    prefix = @"https://www.geocaching.com";
    prefixTiles = @"https://tiles%02d.geocaching.com%@";

    remoteAPI = _remoteAPI;
    self.callback = remoteAPI.account.gca_callback_url;
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

- (void)storeCookie:(NSHTTPCookie *)cookie
{
    if (self.delegate != nil)
        [self.delegate GGCWAuthSuccessful:cookie];

    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    authCookie = [NSHTTPCookie cookieWithProperties:
                  [NSDictionary dictionaryWithObjects:@[
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
        case GGCW_TILESERVERS: {
            // Make sure that the tile server chosen is the same for every x andy coordinate.
            NSInteger ts = [[params objectForKey:@"x"] integerValue] +
                           [[params objectForKey:@"y"] integerValue];
            urlString = [NSMutableString stringWithFormat:prefixTiles, ts % 4 + 1, suffix];
            break;
        }
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

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    return [self performURLRequest:urlRequest returnRespose:nil infoViewer:iv iiDownload:iid];
}

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest returnRespose:(NSHTTPURLResponse **)returnHeader infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSDictionary *retDict = [downloadManager downloadAsynchronous:urlRequest semaphore:sem infoViewer:iv iiDownload:iid];
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

#define CHECK_ARRAY(__a__, min, __bail__) \
    if ([__a__ count] < min) \
        goto __bail__;

#define CHECK_RANGE(__r__, __bail__) \
    if (__r__.location == NSNotFound) \
        goto __bail__;

- (NSString *)viewState:(NSInteger)i
{
    if (i == 0)
        return @"__VIEWSTATE";
    return [NSString stringWithFormat:@"__VIEWSTATE%ld", (long)i];
}

// ------------------------------------------------

// Needed to get the publicGuid
- (GCDictionaryGGCW *)account_dashboard:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/account/dashboard" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    //
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    // Find the data for thea publicGuid
    /*
    <script type="text/javascript">
    var serverParameters = {
        'user:info': {
        isLoggedIn: true,
        username: "Team MavEtJu",
        userType: "Premium",
        publicGuid: "7d657fb4-351b-4321-8f39-a96fe85309a6",
        avatarUrl: "https://img.geocaching.com/avatar/abdbf2c2-efdf-4e2b-8377-9d12c0bbc802.jpg"
        },
        'app:options': {
        localRegion: "en-US"
        }
    }
     */
    NSString *re = @"//script";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *e, NSUInteger idx, BOOL *stop) {
        NSRange r = [e.content rangeOfString:@"publicGuid: \""];
        if (r.location == NSNotFound)
            return;
        NSString *s = [e.content substringFromIndex:r.location + r.length];
        r = [s rangeOfString:@"\","];
        CHECK_RANGE(r, bail);
        s = [s substringToIndex:r.location];
        uid = s;

        *stop = YES;
    bail:
        return;
    }];

    return nil;
}

- (GCDictionaryGGCW *)my_statistics:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/my/statistics.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSMutableDictionary *ds = [NSMutableDictionary dictionaryWithCapacity:4];

    NSString *re = @"//div[@class='StatisticsWrapper']/div[@id='BasicFinds']";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
    TFHppleElement *e;
    NSString *found;

    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];

    CHECK_ARRAY(e.children, 1, bail);
    e = [e.children objectAtIndex:1];
    found = e.content;
    NSRange r = [found rangeOfString:@"found "];
    CHECK_RANGE(r, bail);

    found = [found substringFromIndex:r.location + r.length];
    r = [found rangeOfString:@" "];
    CHECK_RANGE(r, bail);
    found = [found substringToIndex:r.location];

    [ds setObject:[NSNumber numberWithInteger:[found integerValue]] forKey:@"caches_found"];

bail:
    NSLog(@"");
    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:ds];
    return dict;
}

- (GCDictionaryGGCW *)pocket_default:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"pocket_default");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/pocket/default.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    //
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSMutableDictionary *ds = [NSMutableDictionary dictionaryWithCapacity:4];

    /*
     <table id="uxOfflinePQTable" class="PocketQueryListTable Table">
     <tr id="ctl00_ContentBody_PQDownloadList_uxDownloadPQList_ctl01_trPQDownloadRow">
     <td> <input type="checkbox" onclick="checkTopCBDL();" value="15095476" id="chk15095476" /> </td>
     <td> 1. </td>
     <td>
     <img src="/images/icons/16/bookmark_pq.png" alt="Bookmark Pocket Query" />
     <a href="/pocket/downloadpq.ashx?g=e4c29eef-f9f6-4954-9830-e886c08f8f8a&src=web">
     Great Southern Road</a>
     </td>
     <td class="AlignRight"> 30.85 KB </td>
     <td class="AlignCenter"> 20 </td>
     */
    NSString *re = @"//table[@id='uxOfflinePQTable']/tr";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *tr, NSUInteger idx, BOOL *stop) {
        TFHppleElement *e;
        NSString *guid = nil;
        NSString *name = nil;
        NSString *count = nil;
        NSString *size = nil;
        NSRange r;
        NSMutableDictionary *d;

        CHECK_ARRAY(tr.children, 10, bail);

        /*
         <td>
         <img src="/images/icons/16/bookmark_pq.png" alt="Bookmark Pocket Query" />
         <a href="/pocket/downloadpq.ashx?g=e4c29eef-f9f6-4954-9830-e886c08f8f8a&src=web">
         Great Southern Road</a>
         </td>
         */
        e = [tr.children objectAtIndex:5];
        CHECK_ARRAY(e.children, 4, bail);
        e = [e.children objectAtIndex:3];
        guid = [e.attributes objectForKey:@"href"];
        r = [guid rangeOfString:@"g="];
        CHECK_RANGE(r, bail);
        guid = [guid substringFromIndex:r.location + r.length];
        r = [guid rangeOfString:@"&"];
        CHECK_RANGE(r, bail);
        guid = [guid substringToIndex:r.location];

        CHECK_ARRAY(e.children, 1, bail);
        e = [e.children objectAtIndex:0];
        name = [e.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        /*
         <td class="AlignRight"> 30.85 KB </td>
         */
        e = [tr.children objectAtIndex:7];
        CHECK_ARRAY(e.children, 1, bail);
        e = [e.children objectAtIndex:0];
        size = [e.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        /*
         <td class="AlignCenter"> 20 </td>
         */
        e = [tr.children objectAtIndex:9];
        CHECK_ARRAY(e.children, 1, bail);
        e = [e.children objectAtIndex:0];
        count = [e.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        d = [NSMutableDictionary dictionaryWithCapacity:10];
        [d setValue:name forKey:@"name"];
        [d setValue:guid forKey:@"g"];
        [d setValue:size forKey:@"size"];
        [d setValue:count forKey:@"count"];
        [ds setObject:d forKey:name];
bail:
        NSLog(@"");
    }];

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:ds];
    return dict;
}

- (GCDataZIPFile *)pocket_downloadpq:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"pocket_downloadpq:%@", guid);

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:@"web" forKey:@"src"];
    [params setObject:guid forKey:@"g"];

    NSString *urlString = [self prepareURLString:@"/pocket/downloadpq.ashx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    GCDataZIPFile *zipdata = [[GCDataZIPFile alloc] initWithData:data];
    return zipdata;
}

- (NSDictionary *)geocache:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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
    NSData *data = [self performURLRequest:req returnRespose:&resp infoViewer:iv iiDownload:iid];

    // Expecting a 301.
    if (resp.statusCode != 301)
        return nil;
    NSString *location = [resp.allHeaderFields objectForKey:@"Location"];

    // Request the page with the data for the GPX file
    url = [NSURL URLWithString:location];
    req = [NSMutableURLRequest requestWithURL:url];
    data = [self performURLRequest:req returnRespose:&resp infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

#define GETVALUE(__string__, __varname__) \
    re = [NSString stringWithFormat:@"//input[@name='%@']", __string__]; \
    nodes = [parser searchWithXPathQuery:re]; \
    CHECK_ARRAY(nodes, 1, bail1); \
    e = [nodes objectAtIndex:0]; \
    __varname__ = [e.attributes objectForKey:@"value"]; \

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
    NSString *eventtarget = nil;
    NSString *eventargument = nil;
    NSString *viewstatefieldcount = nil;
    NSMutableArray<NSString *> *viewstates = [NSMutableArray arrayWithCapacity:3];
    NSString *viewstategenerator = nil;
    NSString *scrollpositionx = nil;
    NSString *scrollpositiony = nil;

    NSString *re;
    NSArray<TFHppleElement *> *nodes;
    TFHppleElement *e;
    GETVALUE(@"__EVENTTARGET", eventtarget);
    GETVALUE(@"__EVENTARGUMENT", eventargument);
    GETVALUE(@"__VIEWSTATEFIELDCOUNT", viewstatefieldcount);
    for (NSInteger i = 0; i < [viewstatefieldcount integerValue]; i++) {
        NSString *viewstate = nil;
        GETVALUE([self viewState:i], viewstate);
        [viewstates addObject:viewstate];
    }
    GETVALUE(@"__VIEWSTATEGENERATOR", viewstategenerator);
    GETVALUE(@"__SCROLLPOSITIONX", scrollpositionx);
    GETVALUE(@"__SCROLLPOSITIONY", scrollpositiony);
bail1:
    NSLog(@"");

    /*
     <script type="text/javascript">
     //<![CDATA[
     $(function() { ga('send', 'event', 'Geocaching', 'CacheDetailsMemberType', 'Premium'); });var isLoggedIn = true;
     [...]
     userToken = 'HIBNOFPFMBDN5ZI67KCJG5BX7L7HVAZQQJV7E32IEB6GYS7QLUIMVPKKJ4B2RZCIDUKJT7I6HS52UM6V3KTHUHADII7OKK5I7RXPDXODI64VCD6PZNQ2IYBFCKTXVADDLWJSPOOVXC7PZFZWB6PW6AFESW4BWYTWECLDXNZVTB65X5YYOJ5PBJKBTCXB3M4V6XCIXN37YGAHOTOO5WUIHVADXXNMFURURGXSMRVUHBFJBGNO27B3OCHFEB3GWX6U';
     includeAvatars = true;
     */
    __block NSString *usertoken = nil;
    re = @"//script";
    nodes = [parser searchWithXPathQuery:re];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *e, NSUInteger idx, BOOL *stop) {
        if ([e.content containsString:@"userToken = '"] == NO)
            return;

        NSString *s;

        NSRange r = [e.content rangeOfString:@"userToken = '"];
        CHECK_RANGE(r, bail);
        s = [e.content substringFromIndex:r.location + r.length];
        r = [s rangeOfString:@"'"];
        CHECK_RANGE(r, bail);
        s = [s substringToIndex:r.location];

        usertoken = s;
        *stop = YES;
    bail:
        return;
    }];

    /*
     <a href="/seek/log.aspx?ID=4658218&lcn=1" id="ctl00_ContentBody_GeoNav_logButton" class="Button&#32;LogVisit">Log a new visit</a>
     */
    NSString *href;
    NSString *gc_id;
    NSString *s;
    NSRange r;
    re = @"//a[@id='ctl00_ContentBody_GeoNav_logButton']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail2);
    e = [nodes objectAtIndex:0];
    href = [e.attributes objectForKey:@"href"];
    r = [href rangeOfString:@"ID="];
    CHECK_RANGE(r, bail2);
    s = [href substringFromIndex:r.location + r.length];
    r = [s rangeOfString:@"&"];
    CHECK_RANGE(r, bail2);
    gc_id = [s substringToIndex:r.location];

    // And save everything
bail2:
    NSLog(@"");

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setObject:eventtarget forKey:@"__EVENTTARGET"];
    [dict setObject:eventargument forKey:@"__EVENTARGUMENT"];
    [dict setObject:viewstatefieldcount forKey:@"__VIEWSTATEFIELDCOUNT"];
    for (NSInteger i = 0; i < [viewstatefieldcount integerValue]; i++) {
        [dict setObject:[viewstates objectAtIndex:i] forKey:[self viewState:i]];
    }
    if (viewstategenerator != nil)
        [dict setObject:viewstategenerator forKey:@"__VIEWSTATEGENERATOR"];
    if (scrollpositionx != nil)
        [dict setObject:scrollpositionx forKey:@"__SCROLLPOSITIONX"];
    if (scrollpositiony != nil)
        [dict setObject:scrollpositiony forKey:@"__SCROLLPOSITIONY"];
    [dict setObject:location forKey:@"location"];
    [dict setObject:usertoken forKey:@"usertoken"];
    [dict setObject:gc_id forKey:@"gc_id"];

    return dict;
}

- (GCStringGPX *)geocache_gpx:(NSString *)wptname infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"geocache_gpx:%@", wptname);

    NSDictionary *gc = [self geocache:wptname infoViewer:iv iiDownload:iid];

    // And now request the GPX file
    NSURL *url = [NSURL URLWithString:[gc objectForKey:@"location"]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[gc objectForKey:@"location"] forHTTPHeaderField:@"Referer"];

    NSMutableString *ps = [NSMutableString stringWithFormat:@""];

    [ps appendFormat:@"%@=%@", [MyTools urlEncode:@"ctl00$ContentBody$btnGPXDL"], [MyTools urlEncode:@"GPX file"]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTTARGET"], [MyTools urlEncode:[gc objectForKey:@"__EVENTTARGET"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTARGUMENT"], [MyTools urlEncode:[gc objectForKey:@"__EVENTARGUMENT"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATEFIELDCOUNT"], [MyTools urlEncode:[gc objectForKey:@"__VIEWSTATEFIELDCOUNT"]]];
    for (NSInteger i = 0; i < [[gc objectForKey:@"__VIEWSTATEFIELDCOUNT"] integerValue]; i++) {
        [ps appendFormat:@"&%@=%@", [self viewState:i], [MyTools urlEncode:[gc objectForKey:[self viewState:i]]]];
    }
    if ([gc objectForKey:@"__VIEWSTATEGENERATOR"] != nil)
        [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATEGENERATOR"], [MyTools urlEncode:[gc objectForKey:@"__VIEWSTATEGENERATOR"]]];
    if ([gc objectForKey:@"__SCROLLPOSITIONX"] != nil)
        [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__SCROLLPOSITIONX"], [MyTools urlEncode:[gc objectForKey:@"__SCROLLPOSITIONX"]]];
    if ([gc objectForKey:@"__SCROLLPOSITIONY"] != nil)
        [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__SCROLLPOSITIONY"], [MyTools urlEncode:[gc objectForKey:@"__SCROLLPOSITIONY"]]];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    GCStringGPX *gpx = [[GCStringGPX alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return gpx;
}

- (GCDictionaryGGCW *)account_oauth_token:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)map:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:10];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    // First find the usersession data
    NSString *re = [NSString stringWithFormat:@"//script"];
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
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
        NSString *username;
        NSString *sessionToken;
        r = [s rangeOfString:@","];
        CHECK_RANGE(r, bail);
        username = [s substringWithRange:NSMakeRange(1, r.location - 2)];

        r = [s rangeOfString:@"sessionToken:"];
        CHECK_RANGE(r, bail);
        s = [s substringFromIndex:r.location + r.length + 1];
        /*
            'e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaYKLU-1ltM2d_CTr-bM3TK71F14-I0jNX-g43E74GPPt0', subscriberType: 3, enablePersonalization: true });\
         */
        r = [s rangeOfString:@","];
        CHECK_RANGE(r, bail);
        sessionToken = [s substringWithRange:NSMakeRange(0, r.location - 1)];

        // Now store it
        [json setObject:username forKey:@"usersession.username"];
        [json setObject:sessionToken forKey:@"usersession.sessionToken"];

        *stop = YES;
    bail:
        return;
    }];

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)map_info:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"map_info(x,y,z): (%ld,%ld,%ld)", (long)x, (long)y, (long)z);

    /*
     * This is the tile info requested:
     * x, y, z is the coordinates for the tile.
     * k / st is the username, sessiontoken.
     * _ is the time(NULL) * 1000.
     * callback is the label for the returned data.
     * ts is ?

    https://tiles04.geocaching.com/map.info?ts=2&x=15070&y=9841&z=14&k=wo9e&st=e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaSE7NYnMquJsMGoz5tapdJOdNLv3doYRV46MHwovgcHk0&ep=1&callback=jQuery19102689279553556684_1478429965122&_=1478429965123
     */

    NSString *jQueryCallback = [NSString stringWithFormat:@"jQuery%08d_%lu", arc4random_uniform(100000000l), (long)[MyTools millisecondsSinceEpoch]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"ep"];
    [params setObject:[NSNumber numberWithInteger:2] forKey:@"ts"];
    [params setObject:[NSNumber numberWithInteger:x] forKey:@"x"];
    [params setObject:[NSNumber numberWithInteger:y] forKey:@"y"];
    [params setObject:[NSNumber numberWithInteger:z] forKey:@"z"];
    [params setObject:remoteAPI.account.ggcw_username forKey:@"k"];
    [params setObject:remoteAPI.account.ggcw_sessiontoken forKey:@"st"];
    [params setObject:jQueryCallback forKey:@"callback"];
    [params setObject:[NSNumber numberWithLongLong:[MyTools millisecondsSinceEpoch]] forKey:@"_"];

    NSString *urlString = [self prepareURLString:@"/map.info" params:params servers:GGCW_TILESERVERS];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *urlReferer = [self prepareURLString:@"/map/" params:nil servers:GGCW_GGCWSERVER];
    [req setValue:urlReferer forHTTPHeaderField: @"Referer"];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
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

- (GCDictionaryGGCW *)map_png:(NSInteger)x y:(NSInteger)y z:(NSInteger)z infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"map_info(x,y,z): (%ld,%ld,%ld)", (long)x, (long)y, (long)z);

    /*
     * This is the tile info requested:
     * x, y, z is the coordinates for the tile.
     * k / st is the username, sessiontoken.
     * ts is ?

     https://tiles01.geocaching.com/map.png?ts=2&x=15071&y=9837&z=14&k=wo9e&st=e6kWt3zylUp-j41PyBHXbhF8XdK0ghbimG4xtcf4Jomq_rOa45e7fMQib5Py7jLEc64oYex-pj5HGmAUuVjMaV2Rn0ybLHXZh5v6r3w-pmUVufXUYTnzguxIfUUVjuE40&ep=1

     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:[NSNumber numberWithInteger:2] forKey:@"ts"];
    [params setObject:[NSNumber numberWithInteger:x] forKey:@"x"];
    [params setObject:[NSNumber numberWithInteger:y] forKey:@"y"];
    [params setObject:[NSNumber numberWithInteger:z] forKey:@"z"];
    [params setObject:remoteAPI.account.ggcw_username forKey:@"k"];
    [params setObject:remoteAPI.account.ggcw_sessiontoken forKey:@"st"];

    NSString *urlString = [self prepareURLString:@"/map.png" params:params servers:GGCW_TILESERVERS];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSString *urlReferer = [self prepareURLString:@"/map/" params:nil servers:GGCW_GGCWSERVER];
    [req setValue:urlReferer forHTTPHeaderField: @"Referer"];

    [self performURLRequest:req infoViewer:iv iiDownload:iid];
    return nil;
}

- (GCDictionaryGGCW *)map_details:(NSString *)wpcode infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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
    [params setObject:[NSNumber numberWithLongLong:[MyTools millisecondsSinceEpoch]] forKey:@"_"];

    NSString *urlString = [self prepareURLString:@"/map.details" params:params servers:GGCW_TILESERVERS];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
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

- (GCStringGPXGarmin *)seek_sendtogps:(NSString *)guid infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *re = @"//textarea[@id='dataString']";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
    TFHppleElement *e;
    NSString *s;
    NSRange r;
    GCStringGPXGarmin *gpx = nil;

    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];

    s = e.raw;
    r = [s rangeOfString:@">"];     // Find end of <textarea ....>
    CHECK_RANGE(r, bail);
    r.location++;
    r.length = [s length] - [@"</textarea>" length] - r.location;
    s = [s substringWithRange:r];

    r = [s rangeOfString:@">"];     // Find end of <?xml ....>
    CHECK_RANGE(r, bail);
    r.location++;
    r.length = [s length] - r.location;
    s = [s substringWithRange:r];

    gpx = [[GCStringGPXGarmin alloc] initWithString:s];
bail:
    return gpx;
}

- (NSArray<NSDictionary *> *)my_inventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"my_inventory");
    /*
     https://www.geocaching.com/my/inventory.aspx
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

    NSString *urlString = [self prepareURLString:@"/my/inventory.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSString *re = @"//table[@class='Table NoBottomSpacing']/tbody/tr";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];

    NSMutableArray<NSDictionary *> *tbs = [NSMutableArray arrayWithCapacity:[nodes count]];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *trs, NSUInteger idx, BOOL *stop) {
        TFHppleElement *tds;
        TFHppleElement *td;
        NSString *href;
        NSRange r;
        NSString *guid;
        TFHppleElement *name;
        NSMutableDictionary *tb;

        CHECK_ARRAY(trs.children, 2, bail);
        tds = [trs.children objectAtIndex:1];
        CHECK_ARRAY(tds.children, 2, bail);
        td = [tds.children objectAtIndex:1];
        /*
         <a href="/track/details.aspx?guid=93201211-b611-4502-ac7d-e5a80b722067" class="lnk">
         <img alt="" src="/images/wpttypes/sm/1893.gif"> <span>David´s Wildcoin</span></a>
         */
        href = [td.attributes objectForKey:@"href"];
        r = [href rangeOfString:@"guid="];
        CHECK_RANGE(r, bail);
        guid = [href substringFromIndex:r.location + r.length];
        name = [td.children objectAtIndex:3];

        tb = [NSMutableDictionary dictionaryWithCapacity:3];
        [tb setObject:href forKey:@"href"];
        [tb setObject:name.content forKey:@"name"];
        [tb setObject:guid forKey:@"guid"];

        [tbs addObject:tb];
    bail:
        return;
    }];

    return tbs;
}

- (NSDictionary *)track_details:(NSString *)guid id:(NSString *)_id infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"track_details:%@", guid);
    /*
     https://www.geocaching.com/track/details.aspx?guid=93201211-b611-4502-ac7d-e5a80b722067
     https://www.geocaching.com/track/details.aspx?id=6103275
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    if (guid != nil)
        [params setObject:guid forKey:@"guid"];
    if (_id != nil)
        [params setObject:_id forKey:@"id"];

    NSString *urlString = [self prepareURLString:@"/track/details.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    /*
     <span id="ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode"
     class="CoordInfoCode">TB4HC6C</span>
     */
    NSString *re;
    NSArray<TFHppleElement *> *nodes;
    NSString *gccode;
    NSMutableDictionary *dict;
    NSString *owner;
    NSString *href;
    NSString *u;
    NSRange r;
    TFHppleElement *e;

    re = @"//span[@id='ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    gccode = [[nodes objectAtIndex:0] content];

    /*
     <h4 class="BottomSpacing">
     Tracking History (120589.7km&nbsp;) <a href="map_gm.aspx?ID=3801141" title='View Map'>View Map</a>
     </h4>
     */
    re = @"//h4[@class='BottomSpacing']/a[@title='View Map']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    u = [e.attributes objectForKey:@"href"];
    r = [u rangeOfString:@"ID="];
    CHECK_RANGE(r, bail);
    _id = [u substringFromIndex:r.location + r.length];

    /*
     <a id="ctl00_ContentBody_BugDetails_BugOwner" title="Visit&#32;User&#39;s&#32;Profile" href="https://www.geocaching.com/profile/?guid=5d41d7b7-c124-479b-965d-c7ca5d4799bb">Delta_03</a>
     */
    re = @"//a[@id='ctl00_ContentBody_BugDetails_BugOwner']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    owner = e.content;

    /*
      <a id="ctl00_ContentBody_LogLink" title="Found&#32;it?&#32;Log&#32;it!" href="log.aspx?wid=a860f59b-7c62-458b-9ddd-adc5dade167b">Add a Log Entry</a></td>
     */
    re = @"//a[@id='ctl00_ContentBody_LogLink']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    href = [e.attributes objectForKey:@"href"];
    r = [href rangeOfString:@"wid="];
    CHECK_RANGE(r, bail);
    guid = [href substringFromIndex:r.location + r.length];

    dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setObject:gccode forKey:@"gccode"];
    [dict setObject:_id forKey:@"id"];
    [dict setObject:guid forKey:@"guid"];
    [dict setObject:owner forKey:@"owner"];

bail:
    return dict;
}

- (NSDictionary *)track_details:(NSString *)tracker infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"track_details:%@", tracker);
    /*
    https://www.geocaching.com/track/details.aspx?tracker=PC7XXX
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:tracker forKey:@"tracker"];

    NSString *urlString = [self prepareURLString:@"/track/details.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    /*
     <h2 class="WrapFix">
     <img id="ctl00_ContentBody_BugTypeImage" class="TravelBugHeaderIcon" src="/images/wpttypes/21.gif"
     alt="Travel Bug Dog Tag"/><span id="ctl00_ContentBody_lbHeading">Scary hook</span>
     </h2>
     */
    NSString *re;
    NSArray<TFHppleElement *> *nodes;
    TFHppleElement *e;
    NSString *name;
    NSString *owner;
    NSString *gccode;
    NSString *_id;
    NSString *guid;
    NSString *href;
    NSString *s;
    NSRange r;
    NSMutableDictionary *dict = nil;

    re = @"//h2[@class='WrapFix']";
    //re = @"//h2[@class='WrapFix']/img/span[@id='ct100_ContentBody_lbHeading']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    CHECK_ARRAY(e.children, 4, bail);
    e = [e.children objectAtIndex:3];
    name = e.content;

    /*
    <a id="ctl00_ContentBody_BugDetails_BugOwner" title="Visit User's Profile"
    href="https://www.geocaching.com/profile/?guid=f0b9f4ee-4aab-406e-bafb-4cf993826f2d">Drf</a>
     */
    re = @"//a[@id='ctl00_ContentBody_BugDetails_BugOwner']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    owner = [[nodes objectAtIndex:0] content];

    /*
     <span id="ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode"
     class="CoordInfoCode">TB3MBD0</span>
     */
    re = @"//span[@id='ctl00_ContentBody_CoordInfoLinkControl1_uxCoordInfoCode']";
    nodes = [parser searchWithXPathQuery:re];
    gccode = [[nodes objectAtIndex:0] content];

    /*
     <a id="ctl00_ContentBody_WatchLink" title="Watch This Trackable Item"
     href="/my/watchlist.aspx?b=2966237">Watch This Trackable Item</a>
     */
    re = @"//a[@id='ctl00_ContentBody_WatchLink']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    s = [e.attributes objectForKey:@"href"];
    r = [s rangeOfString:@"b="];
    CHECK_RANGE(r, bail);
    _id = [s substringFromIndex:r.location + r.length];

    /*
      <a id="ctl00_ContentBody_LogLink" title="Found&#32;it?&#32;Log&#32;it!" href="log.aspx?wid=a860f59b-7c62-458b-9ddd-adc5dade167b">Add a Log Entry</a></td>
     */
    re = @"//a[@id='ctl00_ContentBody_LogLink']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    href = [e.attributes objectForKey:@"href"];
    r = [href rangeOfString:@"wid="];
    CHECK_RANGE(r, bail);
    guid = [href substringFromIndex:r.location + r.length];

    dict = [[NSMutableDictionary alloc] initWithCapacity:5];
    [dict setObject:name forKey:@"name"];
    [dict setObject:owner forKey:@"owner"];
    [dict setObject:gccode forKey:@"gccode"];
    [dict setObject:tracker forKey:@"code"];
    [dict setObject:_id forKey:@"id"];
    [dict setObject:guid forKey:@"guid"];

bail:
    return dict;
}

- (NSArray<NSDictionary *> *)track_search:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    if (uid == nil)
        [self account_dashboard:iv iiDownload:iid];

    NSLog(@"track_search:%@", uid);
    /*
     https://www.geocaching.com/track/search.aspx?o=1&uid=7d657fb4-351b-4321-8f39-a96fe85309a6
     */

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setObject:uid forKey:@"uid"];
    [params setObject:@"1" forKey:@"o"];

    NSString *urlString = [self prepareURLString:@"/track/search.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    /*
     <tr>
     <td>

     </td>
     <td>
     <img src="/images/wpttypes/sm/6429.gif" alt="" />&nbsp;<a href="https://www.geocaching.com/track/details.aspx?id=5119741">2013 NSW Geocoin</a>
     </td>
     <td>
     2016-09-27
     </td>
     <td>
     <a href="https://www.geocaching.com/profile/?guid=7d657fb4-351b-4321-8f39-a96fe85309a6">Team MavEtJu</a>
     </td>
     <td>
     <img src="/images/icons/reg_user.gif" /><a href="https://www.geocaching.com/profile/?guid=65cd3088-e22e-498f-90b0-5b03568a5d1a">lillieb05</a>
     </td>
     <td>
     26591 km
     </td>
     </tr>

     */

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSMutableArray<NSDictionary *> *tbs = [NSMutableArray arrayWithCapacity:20];
    NSString *re = @"//table[@class='Table']/tbody/tr";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement *tr, NSUInteger idx, BOOL *stop) {
        NSArray<TFHppleElement *> *tds = tr.children;
        NSMutableDictionary *dict;
        NSString *name;
        NSString *href;
        NSRange r;
        NSString *_id;
        NSString *owner;
        NSString *carrier;
        NSString *location;
        NSString *s;
        TFHppleElement *e;

        // Get TB name
        CHECK_ARRAY(tds, 4, bail);
        e = [tds objectAtIndex:3];
        CHECK_ARRAY(e.children, 4, bail);
        e = [e.children objectAtIndex:3];
        name = e.content;
        href = [e.attributes objectForKey:@"href"];
        r = [href rangeOfString:@"id="];
        CHECK_RANGE(r, bail);
        _id = [href substringFromIndex:r.location + r.length];

        // Get TB owner
        CHECK_ARRAY(tds, 8, bail);
        e = [tds objectAtIndex:7];
        CHECK_ARRAY(e.children, 2, bail);
        e = [e.children objectAtIndex:1];
        owner = e.content;

        // Get person who carries or location hidden
        carrier = nil;
        location = nil;
        CHECK_ARRAY(tds, 10, bail);
        e = [tds objectAtIndex:9];
        CHECK_ARRAY(e.children, 2, bail);
        e = [e.children objectAtIndex:1];
        s = [e.attributes objectForKey:@"class"];

        CHECK_ARRAY(tds, 10, bail);
        e = [tds objectAtIndex:9];
        CHECK_ARRAY(e.children, 3, bail);
        e = [e.children objectAtIndex:2];
        if (s != nil && [s isEqualToString:@"CacheTypeIcon"] == YES) {
            location = e.content;
        } else {
            carrier = e.content;
        }

        dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setObject:name forKey:@"name"];
        [dict setObject:owner forKey:@"owner"];
        [dict setObject:_id forKey:@"id"];
        if (location != nil)
            [dict setObject:location forKey:@"location"];
        if (carrier != nil)
            [dict setObject:carrier forKey:@"carrier"];

        [tbs addObject:dict];
    bail:
        return;
    }];

    return tbs;
}

- (GCDictionaryGGCW *)seek_cache__details_SetUserCacheNote:(NSDictionary *)dict text:(NSString *)text infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"seek_cache__details_SetUserCacheNote");

    NSMutableDictionary *dto = [NSMutableDictionary dictionaryWithCapacity:2];
    [dto setObject:[dict objectForKey:@"usertoken"] forKey:@"ut"];
    [dto setObject:text forKey:@"et"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:dto forKey:@"dto"];

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    if (jsonData == nil)
        NSLog(@"Got an error: %@", error);

    NSString *urlString = [self prepareURLString:@"/seek/cache_details.aspx/SetUserCacheNote" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [req setValue:[dict objectForKey:@"location"] forHTTPHeaderField:@"Referer"];

    req.HTTPBody = jsonData;

    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;
    if ([json count] == 0)
        return nil;
    NSDictionary *d = [json objectForKey:@"d"];
    if ([d objectForKey:@"success"] == [NSNumber numberWithBool:FALSE])
        return nil;

    GCDictionaryGGCW *retjson = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return retjson;
}

- (NSDictionary *)api_proxy_web_v1_geocache:(NSString *)gccode infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/api/proxy/web/v1/geocache/%@", [gccode lowercaseString]] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnRespose:&resp infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    /*
     {
         callerSpecific =     {
             favorited = 0;
         };
         geocacheType =     {
             id = 2;
             name = "Traditional Cache";
         };
         id = 5864006;
         owner =     {
             id = 8305738;
             referenceCode = PR9DJJZ;
         };
         postedCoordinates =     {
             latitude = "-34.0425";
             longitude = "151.1220166666667";
         };
         referenceCode = GC6RKRD;
     }
     */
    return json;
}

- (NSDictionary *)play_geocache_log__form:(NSString *)gccode infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSDictionary *dict = [self api_proxy_web_v1_geocache:gccode infoViewer:iv iiDownload:iid];

    NSString *s;
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:20];
    DICT_NSSTRING_PATH(dict, s, @"callerSpecific.favorited");
    [d setObject:s forKey:@"geocache[callerSpecific][favorited]"];
    DICT_NSSTRING_PATH(dict, s, @"postedCoordinates.latitude");
    [d setObject:s forKey:@"geocache[postedCoordinates][latitude]"];
    DICT_NSSTRING_PATH(dict, s, @"postedCoordinates.longitude");
    [d setObject:s forKey:@"geocache[postedCoordinates][longitude]"];
    DICT_NSSTRING_PATH(dict, s, @"owner.id");
    [d setObject:s forKey:@"geocache[owner][id]"];
    DICT_NSSTRING_PATH(dict, s, @"owner.referenceCode");
    [d setObject:s forKey:@"geocache[owner][referenceCode]"];
    DICT_NSSTRING_PATH(dict, s, @"geocacheType.id");
    [d setObject:s forKey:@"geocache[geocacheType][id]"];
    DICT_NSSTRING_PATH(dict, s, @"geocacheType.name");
    [d setObject:s forKey:@"geocache[geocacheType][name]"];
    DICT_NSSTRING_PATH(dict, s, @"id");
    [d setObject:s forKey:@"geocache[[id]"];
    DICT_NSSTRING_PATH(dict, s, @"referenceCode");
    [d setObject:s forKey:@"geocache[referenceCode]"];

    /*
+   logTextMaxLength:               4000
+   maxImages:                      1
+   ownerIsViewing:                 true
+   isWaiting:                      true

|   geocache[id]:                   6140457
|   geocache[referenceCode]:        GC72XE6
|   geocache[postedCoordinates][latitude]:-34.017967
|   geocache[postedCoordinates][longitude]:151.125933
|   geocache[callerSpecific][favorited]:false
|   geocache[owner][id]:            8305738
|   geocache[owner][referenceCode]: PR9DJJZ
|   geocache[geocacheType][id]:     2
|   geocache[geocacheType][name]:   Traditional Cache
    geocache[isEvent]:              false

    logTypes[0][value]:             46
    logTypes[0][name]:              Owner maintenance
    logTypes[0][selected]:          true
    logTypes[1][value]:             4
    logTypes[1][name]:              Write note
    logTypes[1][selected]:          false
    logTypes[2][value]:             22
    logTypes[2][name]:              Disable
    logTypes[2][selected]:          false
    logTypes[3][value]:             5
    logTypes[3][name]:              Archive
    logTypes[3][selected]:          false
    logTypes[4][value]:             47
    logTypes[4][name]:              Update coordinates
    logTypes[4][selected]:          false

+   logType:                        46
+   logDate:                        2017-06-05
+   logText:                        test
     */

//  https://www.geocaching.com/play/geocache/gc72xe6/log
//  https://www.geocaching.com/api/proxy/web/v1/geocache/gc72xe6
    return d;
}

- (NSString *)play_geocache_log__submit:(NSString *)gccode dict:(NSDictionary *)dict logstring:(NSString *)logstring_type dateLogged:(NSString *)dateLogged note:(NSString *)note favpoint:(BOOL)favpoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/api/proxy/web/v1/geocache/%@/GeocacheLog", gccode] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    note = [note stringByReplacingOccurrencesOfString:@"\x0a" withString:@"\x0d\x0a"];

    /*
    https://www.geocaching.com/api/proxy/web/v1/Geocache/GC72XE6/GeocacheLog

    logTextMaxLength:               4000
    maxImages:                      1
    geocache[id]:                   6140457
    geocache[referenceCode]:        GC72XE6
    geocache[postedCoordinates][latitude]:-34.017967
    geocache[postedCoordinates][longitude]:151.125933
    geocache[callerSpecific][favorited]:false
    geocache[owner][id]:            8305738
    geocache[owner][referenceCode]: PR9DJJZ
    geocache[geocacheType][id]:     2
    geocache[geocacheType][name]:   Traditional Cache
    geocache[isEvent]:              false
    logTypes[0][value]:             46
    logTypes[0][name]:              Owner maintenance
    logTypes[0][selected]:          true
    logTypes[1][value]:             4
    logTypes[1][name]:              Write note
    logTypes[1][selected]:          false
    logTypes[2][value]:             22
    logTypes[2][name]:              Disable
    logTypes[2][selected]:          false
    logTypes[3][value]:             5
    logTypes[3][name]:              Archive
    logTypes[3][selected]:          false
    logTypes[4][value]:             47
    logTypes[4][name]:              Update coordinates
    logTypes[4][selected]:          false
    logType:                        46
    ownerIsViewing:                 true
    logDate:                        2017-06-05
    logText:                        test
    isWaiting:                      true
     */

    dateLogged = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:[MyTools secondsSinceEpochFromISO8601:dateLogged]];

    NSMutableString *s = [NSMutableString stringWithString:@""];
    [s appendFormat:@"%@=%@", @"logTextMaxLength", [MyTools urlEncode:@"4000"]];
    [s appendFormat:@"&%@=%@", @"maxImages", [MyTools urlEncode:@"1"]];
    [s appendFormat:@"&%@=%@", @"ownerIsViewing", [MyTools urlEncode:@"false"]];
    [s appendFormat:@"&%@=%@", @"logDate", [MyTools urlEncode:dateLogged]];
    [s appendFormat:@"&%@=%@", @"logText", [MyTools urlEncode:note]];
    [s appendFormat:@"&%@=%@", @"isWaiting", [MyTools urlEncode:@"true"]];
    [s appendFormat:@"&%@=%@", @"logType", [MyTools urlEncode:logstring_type]];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        [s appendFormat:@"&%@=%@", key, [MyTools urlEncode:value]];
    }];

    req.HTTPBody = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    NSString *ss = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([ss containsString:@"View Geocache Log"] == NO)
        return nil;

    return ss;
}

- (NSDictionary *)api_proxy_trackable_activities:(NSString *)gccode trackables:(NSArray<dbTrackable *> *)tbs dateLogged:(NSString *)dateLogged infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSString *urlString = [self prepareURLString:@"/api/proxy/trackable/activities" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    dateLogged = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:[MyTools secondsSinceEpochFromISO8601:dateLogged]];

    /*
    [
     {
         "date": "2017-06-05",
         "geocache": {
             "gcCode": "GC72CQY"
         },
         "logType": {
             "id": "75"
         },
         "referenceCode": "TB6C0CY"
     },
     {
         "date": "2017-06-05",
         "geocache": {
             "gcCode": "GC72CQY"
         },
         "logType": {
             "id": "75"
         },
         "referenceCode": "TB71MQR"
     }
     ]
    */

    NSMutableArray<NSDictionary *> *json = [NSMutableArray arrayWithCapacity:10];
    [tbs enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tb.logtype == TRACKABLE_LOG_NONE)
            return;
        NSInteger dflt = 0;
        NSInteger logtype = LOGSTRING_LOGTYPE_UNKNOWN;
        NSString *note = nil;
        switch (tb.logtype) {
            case TRACKABLE_LOG_VISIT:
                dflt = LOGSTRING_DEFAULT_VISIT;
                logtype = LOGSTRING_LOGTYPE_TRACKABLEPERSON;
                note = [NSString stringWithFormat:@"Visited '%@'", gccode];
                break;
            case TRACKABLE_LOG_DROPOFF:
                dflt = LOGSTRING_DEFAULT_DROPOFF;
                note = [NSString stringWithFormat:@"Dropped off at '%@'", gccode];
                logtype = LOGSTRING_LOGTYPE_TRACKABLEPERSON;
                break;
            case TRACKABLE_LOG_PICKUP:
                dflt = LOGSTRING_DEFAULT_PICKUP;
                note = [NSString stringWithFormat:@"Picked up from '%@'", gccode];
                logtype = LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT;
                break;
            case TRACKABLE_LOG_DISCOVER:
                dflt = LOGSTRING_DEFAULT_DISCOVER;
                note = [NSString stringWithFormat:@"Discovered in '%@'", gccode];
                logtype = LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT;
                break;
            default:
                NSAssert(NO, @"Unknown tb.logtype");
        }
        dbLogString *ls = [dbLogString dbGetByProtocolLogtypeDefault:remoteAPI.account.protocol logtype:logtype default:dflt];

        NSMutableDictionary *tbjson = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableDictionary *j = [NSMutableDictionary dictionaryWithCapacity:10];
        [j setObject:gccode forKey:@"gcCode"];
        [tbjson setObject:j forKey:@"geocache"];
        [j removeAllObjects];
        [j setObject:ls forKey:@"id"];
        [tbjson setObject:j forKey:@"geocache"];
        [tbjson setObject:tb.ref forKey:@"referenceCode"];
        [tbjson setObject:dateLogged forKey:@"date"];
        [json addObject:tbjson];
    }];

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error];

    req.HTTPBody = body;
    NSData *data = [self performURLRequest:req infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    return nil;
}

@end