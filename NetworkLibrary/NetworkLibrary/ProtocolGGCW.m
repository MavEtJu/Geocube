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

#import "ProtocolGGCW.h"

#import "Geocube-defines.h"

#import "ManagersLibrary/DownloadManager.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "ManagersLibrary/ConfigManager.h"
#import "NetworkLibrary/RemoteAPITemplate.h"
#import "DatabaseLibrary/dbAccount.h"
#import "DatabaseLibrary/dbTrackable.h"
#import "DatabaseLibrary/dbLogString.h"
#import "ToolsLibrary/MyTools.h"
#import "ContribLibrary/TFHpple/TFHpple.h"
#import "BaseObjectsLibrary/GCDictionaryObjects.h"
#import "BaseObjectsLibrary/GCStringObjects.h"
#import "BaseObjectsLibrary/GCDataObjects.h"

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
    return [self performURLRequest:urlRequest returnResponse:nil infoViewer:iv iiDownload:iid];
}

- (NSData *)performURLRequest:(NSURLRequest *)urlRequest returnResponse:(NSHTTPURLResponse **)returnHeader infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
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
        // https://www.geocaching.com/api/proxy/web/v1/Geocache/XXXX/GeocacheLog returns 422 when you enter two Found logs....
        if (!(response.statusCode == 422 && [urlRequest.URL.absoluteString containsString:@"GeocacheLog"] == YES)) {
            NSLog(@"statusCode: %ld", (long)response.statusCode);
            NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"retbody: %@", retbody);
            [remoteAPI setAPIError:[NSString stringWithFormat:_(@"protocolggcw-HTTP Response was %ld"), (long)response.statusCode] error:REMOTEAPI_APIFAILED];
            return nil;
        }
    }

    if ([data length] == 0) {
        [remoteAPI setAPIError:_(@"protocolggcw-Returned data is zero length") error:REMOTEAPI_APIFAILED];
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
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull tr, NSUInteger idx, BOOL * _Nonnull stop) {
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
    req.HTTPMethod = @"POST";

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:iv iiDownload:iid];

    // Expecting a 301.
    if (resp.statusCode != 301)
        return nil;
    NSString *location = [resp.allHeaderFields objectForKey:@"Location"];

    // Request the page with the data for the GPX file
    url = [NSURL URLWithString:location];
    req = [NSMutableURLRequest requestWithURL:url];
    data = [self performURLRequest:req returnResponse:&resp infoViewer:iv iiDownload:iid];
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
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull e, NSUInteger idx, BOOL * _Nonnull stop) {
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

    /*
     * First request /geocaching/GC1234, expect a redirect to /geocube/GC1234-foobar
     * Do it in a HEAD to prevent downloading of 200+ Kb of data just to get this redirect.
     */
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/geocache/%@", wptname] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"HEAD";

    NSHTTPURLResponse *resp = nil;
    [self performURLRequest:req returnResponse:&resp infoViewer:iv iiDownload:iid];

    NSString *loc = [[resp allHeaderFields] objectForKey:@"location"];
    if (loc == nil)
        return nil;

    // And now request the GPX file
    url = [NSURL URLWithString:loc];
    req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:loc forHTTPHeaderField:@"Referer"];

    NSMutableString *ps = [NSMutableString stringWithFormat:@""];

    [ps appendFormat:@"%@=%@", [MyTools urlEncode:@"ctl00$ContentBody$btnGPXDL"], [MyTools urlEncode:@"GPX file"]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTTARGET"], @""];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__EVENTARGUMENT"], @""];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"__VIEWSTATEFIELDCOUNT"], [MyTools urlEncode:@"0"]];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:iv iiDownload:iid];
    // When the waypoint is premium only it will return as text/html
    if ([[resp.allHeaderFields objectForKey:@"Content-Type"] isEqualToString:@"application/gpx"] == NO)
        return nil;
    if (data == nil)
        return nil;

    GCStringGPX *gpx = [[GCStringGPX alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return gpx;
}

- (NSString *)seek_cache__details_guid2wptname:(NSString *)guid
{
    /*
     * When requesting /seek/cache_details.aspx?guid=e76266c6-058d-4f2f-867e-ce3d8b004fc5,
     * it will return a 301 response to the full URL.
     *
     */
    NSDictionary *params = @{@"guid":guid};
    NSString *urlString = [self prepareURLString:@"/seek/cache_details.aspx" params:params];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"HEAD"];

    NSHTTPURLResponse *resp;
    [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];

    NSMutableString *location = [NSMutableString stringWithString:[resp.allHeaderFields objectForKey:@"location"]];
    if (location == nil)
        return nil;

    /* /geocache/GC7AYEC_het-groot-dictee-der-n */
    [location replaceOccurrencesOfString:@"^.*/geocache/" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [location length])];
    [location replaceOccurrencesOfString:@"_.*$" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [location length])];
    return location;
}

- (GCDictionaryGGCW *)account_oauth_token:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSLog(@"account_oauth_token:");

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];

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
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull trs, NSUInteger idx, BOOL * _Nonnull stop) {
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
    NSString *carrier;
    NSString *location;
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
    <a id="ctl00_ContentBody_BugDetails_BugLocation" href="https://www.geocaching.com/profile/?guid=c094b3f5-603e-46da-915d-ba9314f3bbff">In the hands of Brasgordel.</a></dd>
    <a id="ctl00_ContentBody_BugDetails_BugLocation" title="Visit&#32;Listing" href="https://www.geocaching.com/seek/cache_details.aspx?guid=e76266c6-058d-4f2f-867e-ce3d8b004fc5">In Kiddies Treasure</a></dd>
     */
    re = @"//a[@id='ctl00_ContentBody_BugDetails_BugLocation']";
    nodes = [parser searchWithXPathQuery:re];
    CHECK_ARRAY(nodes, 1, bail);
    e = [nodes objectAtIndex:0];
    href = [e.attributes objectForKey:@"href"];
    if (href == nil) {
        carrier = owner;
    } else if ([href containsString:@"cache_details"] == YES) {
        NSMutableString *l = [NSMutableString stringWithString:href];
        [l replaceOccurrencesOfString:@"^.*guid=" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [href length])];
        location = [self seek_cache__details_guid2wptname:l];
    } else if ([href containsString:@"profile"] == YES) {
        NSMutableString *c = [NSMutableString stringWithString:e.content];
        [c replaceOccurrencesOfString:@"^In the hands of " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [c length])];
        [c replaceOccurrencesOfString:@"\\.$" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [c length])];
        carrier = c;
    }

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
    if (location != nil)
        [dict setObject:location forKey:@"location"];
    if (carrier != nil)
        [dict setObject:carrier forKey:@"carrier"];

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
    [nodes enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull tr, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (NSArray<NSString *> *)play_search:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    // Submit coordinates to /play/search, get the closest-by 50 caches.
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/play/search/@%@,%@?origin=%@,%@",
                                                  [MyTools strippedFloat:@"%0.6f" f:center.latitude],
                                                  [MyTools strippedFloat:@"%0.6f" f:center.longitude],
                                                  [MyTools strippedFloat:@"%0.6f" f:center.latitude],
                                                  [MyTools strippedFloat:@"%0.6f" f:center.longitude]]
                                                  params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:iv iiDownload:iid];
    if (data == nil)
        return nil;

    TFHpple *parser = [TFHpple hppleWithHTMLData:data];

    NSMutableArray<NSString *> *wptnames = [NSMutableArray arrayWithCapacity:20];

    /*
     * Grab 'data-id' attributes with the waypoint names.
     *
     * <tbody id="geocaches">
     * <tr  data-rownumber="0"   data-id="GC6BGRA" data-name="Dollars
     *
     */

    NSString *re = @"//tbody[@id='geocaches']";
    NSArray<TFHppleElement *> *nodes = [parser searchWithXPathQuery:re];

    TFHppleElement *tbody = [nodes firstObject];

    [tbody.children enumerateObjectsUsingBlock:^(TFHppleElement * _Nonnull tr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *wptname = [tr.attributes objectForKey:@"data-id"];
        if (wptname != nil)
            [wptnames addObject:wptname];
        if ([wptnames count] >= configManager.mapsearchGGCWMaximumNumber)
            *stop = YES;
    }];

    return wptnames;
}

- (GCDictionaryGGCW *)play_serverparameters_params
{
    NSString *urlString = [self prepareURLString:@"/play/serverparameters/params" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];
    if (data == nil)
        return nil;

    /*
    var serverParameters = {
        "user:info": {
            "username": "DirkieQuirkie",
            "referenceCode": "PRD5XPG",
            "userType": "Basic",
            "isLoggedIn": true,
            "dateFormat": "d. M. yyyy",
            "unitSetName": "Metric",
            "roles": [
                "Public",
                "Basic"
            ]
        },
        "app:options": {
            "localRegion": "en-US",
            "endpoints": null,
            "coordInfoUrl": "https://coord.info",
            "paymentUrl": "https://payments.geocaching.com"
        }
    };
    */

    NSString *s = @"var serverParameters = ";
    data = [data subdataWithRange:NSMakeRange([s length], [data length] - [s length])];
    data = [data subdataWithRange:NSMakeRange(0, [data length] - 1)];

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)account_oauth_token
{
    NSString *urlString = [self prepareURLString:@"/account/oauth/token" params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)api_proxy_web_v1_users_settings:(NSString *)referenceCode accessToken:(NSString *)accessToken
{
    // https://www.geocaching.com/api/proxy/web/v1/users/PRD5XPG/settings/
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/api/proxy/web/v1/users/%@/settings/", referenceCode] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [req setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)api_proxy_web_v1_geocache:(NSString *)wptname accessToken:(NSString *)accessToken
{
    // https://www.geocaching.com/api/proxy/web/v1/users/PRD5XPG/settings/
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/api/proxy/web/v1/geocache/%@", [wptname lowercaseString]] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [req setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}

- (GCDictionaryGGCW *)api_proxy_web_v1_Geocache_GeocacheLog:(NSString *)wptname dict:(NSDictionary *)dict accessToken:(NSString *)accessToken
{
    // https://www.geocaching.com/api/proxy/web/v1/Geocache/GC5F521/GeocacheLog
    NSString *urlString = [self prepareURLString:[NSString stringWithFormat:@"/api/proxy/web/v1/Geocache/%@/GeocacheLog", wptname] params:nil];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    [req setHTTPMethod:@"POST"];

    NSMutableString *ps = [NSMutableString stringWithString:@""];
    /*
     dict:
     geocache_id
     geocache_wptname
     owner_referencecode
     owner_id
     geocacheType_id
     geocacheType_name
     geocacheState_isArchived
     geocacheState_isAvailable
     geocacheState_isLocked

     req:
     logTextMaxLength:               4000
     maxImages:                      1
   | geocache[id]:                   4658218
   | geocache[referenceCode]:        GC5F521
     geocache[postedCoordinates][latitude]:-34.045667
     geocache[postedCoordinates][longitude]:151.12505
     geocache[callerSpecific][favorited]:false
     geocache[owner][id]:            8305738
     geocache[owner][referenceCode]: PR9DJJZ
     geocache[geocacheType][id]:     2
     geocache[geocacheType][name]:   Traditional Cache
     geocache[state][isArchived]:    false
     geocache[state][isAvailable]:   true
     geocache[state][isLocked]:      false
     geocache[isEvent]:              false
     logTypes[0][value]:             2
     logTypes[0][name]:              Found It
     logTypes[0][selected]:          true
     logTypes[1][value]:             3
     logTypes[1][name]:              Didn't Find It
     logTypes[1][selected]:          false
     logTypes[2][value]:             4
     logTypes[2][name]:              Write note
     logTypes[2][selected]:          false
   | logType:                        2
     ownerIsViewing:                 false
   | logDate:                        2017-09-22
   | logText:                        Foo
     isWaiting:                      true
   | usedFavoritePoint:              true
    */
    [ps appendFormat:@"%@=%@",  [MyTools urlEncode:@"geocache[id]"], [MyTools urlEncode:[dict objectForKey:@"geocache_id"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"geocache[referenceCode]"], [MyTools urlEncode:[dict objectForKey:@"geocache_wptname"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"logType"], [MyTools urlEncode:[dict objectForKey:@"log_type"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"logDate"], [MyTools urlEncode:[dict objectForKey:@"log_date"]]];
    [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"logText"], [MyTools urlEncode:[dict objectForKey:@"log_text"]]];
    if ([[dict objectForKey:@"favourite_point"] boolValue] == YES)
        [ps appendFormat:@"&%@=%@", [MyTools urlEncode:@"usedFavoritePoint"], [MyTools urlEncode:@"true"]];
    req.HTTPBody = [ps dataUsingEncoding:NSUTF8StringEncoding];

    NSHTTPURLResponse *resp = nil;
    NSData *data = [self performURLRequest:req returnResponse:&resp infoViewer:nil iiDownload:0];
    if (data == nil)
        return nil;

    NSError *error = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil)
        return nil;

    GCDictionaryGGCW *d = [[GCDictionaryGGCW alloc] initWithDictionary:json];
    return d;
}


@end
