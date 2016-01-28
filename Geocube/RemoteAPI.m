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

@interface RemoteAPI ()
{
    GCOAuthBlackbox *oabb;

    LiveAPI *gs;
    OKAPI *okapi;
    GeocachingAustralia *gca;

    dbAccount *account;

    NSInteger stats_found, stats_notfound;
    id authenticationDelegate;

    NSString *clientMsg;
    NSError *clientError;
}

@end

@implementation RemoteAPI

@synthesize account, oabb, authenticationDelegate;
@synthesize stats_found, stats_notfound;
@synthesize clientError, clientMsg;

- (instancetype)init:(dbAccount *)_account;
{
    self = [super init];

    account = _account;

    oabb = [[GCOAuthBlackbox alloc] init];
    [oabb token:account.oauth_token];
    [oabb tokenSecret:account.oauth_token_secret];
    [oabb consumerKey:account.oauth_consumer_public];
    [oabb consumerSecret:account.oauth_consumer_private];

    gs = nil;
    okapi = nil;
    gca = nil;
    switch (account.protocol) {
        case ProtocolLiveAPI:
            gs = [[LiveAPI alloc] init:self];
            gs.delegate = self;
            break;
        case ProtocolOKAPI:
            okapi = [[OKAPI alloc] init:self];
            okapi.delegate = self;
            break;
        case ProtocolGCA:
            gca = [[GeocachingAustralia alloc] init:self];
            gca.delegate = self;
            break;
    }
    return self;
}

- (BOOL)Authenticate
{
    if (account.protocol == ProtocolOKAPI || account.protocol == ProtocolLiveAPI) {
        // Reset it
        oabb = [[GCOAuthBlackbox alloc] init];

        if (account.oauth_consumer_private == nil || [account.oauth_consumer_private isEqualToString:@""] == YES) {
            [self oauthtripped:@"No OAuth client information is available." error:nil];
            return NO;
        }

        [oabb URLRequestToken:account.oauth_request_url];
        [oabb URLAuthorize:account.oauth_authorize_url];
        [oabb URLAccessToken:account.oauth_access_url];
        [oabb consumerKey:account.oauth_consumer_public];
        [oabb consumerSecret:account.oauth_consumer_private];

        oabb.delegate = self;
        [oabb obtainRequestToken];
        if (oabb.token == nil) {
            [self oauthtripped:@"No request token was returned." error:nil];
            NSLog(@"%@ - token is nil after obtainRequestToken, not further authenticating", [self class]);
            return NO;
        }

        NSString *url = [NSString stringWithFormat:@"%@?oauth_token=%@", account.oauth_authorize_url, [MyTools urlEncode:oabb.token]];

        BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
        UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
        BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];

        [_AppDelegate switchController:RC_BROWSER];
        [btc makeTabViewCurrent:VC_BROWSER_BROWSER];
        [bbvc prepare_oauth:oabb];
        [bbvc loadURL:url];
        return YES;
    }

    if (account.protocol == ProtocolGCA) {
        // Load http://geocaching.com.au/login/?jump=/geocube and wait for the redirect to /geocube.
        NSString *url = account.gca_authenticate_url;

        BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
        UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
        BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];

        gca.delegate = self;

        [_AppDelegate switchController:RC_BROWSER];
        [btc makeTabViewCurrent:VC_BROWSER_BROWSER];
        [bbvc prepare_gca:gca];
        [bbvc loadURL:url];
        return YES;
    }

    return NO;
}

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie
{
    account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [account dbUpdateCookieValue];

    BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
    UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
    BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];
    [bbvc prepare_gca:nil];

    if (authenticationDelegate)
        [authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret
{
    account.oauth_token = token;
    account.oauth_token_secret = secret;
    [account dbUpdateOAuthToken];
    //oabb = nil;

    BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
    UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
    BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];
    [bbvc prepare_oauth:nil];

    if (authenticationDelegate)
        [authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthtripped:(NSString *)reason error:(NSError *)error
{
    NSLog(@"tripped: %@", reason);
    account.oauth_token = nil;
    account.oauth_token_secret = nil;
    [account dbUpdateOAuthToken];
    oabb = nil;

    BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
    UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
    BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];
    [bbvc prepare_oauth:nil];

    [_AppDelegate switchController:RC_SETTINGS];
    if (authenticationDelegate)
        [authenticationDelegate remoteAPI:self failure:@"Unable to obtain secret token." error:error];
}

- (BOOL)commentSupportsPhotos
{
    switch (account.protocol) {
        case ProtocolLiveAPI:
            return YES;
        case ProtocolOKAPI:
            return NO;
        case ProtocolGCA:
            return NO;
    }
    return NO;
}

- (BOOL)commentSupportsTrackables
{
    switch (account.protocol) {
        case ProtocolLiveAPI:
            return YES;
        case ProtocolOKAPI:
            return NO;
        case ProtocolGCA:
            return NO;
    }
    return NO;
}

- (NSArray *)logtypes:(NSString *)waypointType
{
    switch (account.protocol) {
        case ProtocolLiveAPI:
            return [gs logtypes:waypointType];
        case ProtocolOKAPI:
            return [okapi logtypes:waypointType];
        case ProtocolGCA:
            return [gca logtypes:waypointType];
    }
    return nil;
}

- (NSDictionary *)UserStatistics
{
    return [self UserStatistics:account.accountname_string];
}

- (void)getNumber:(NSDictionary *)out from:(NSDictionary *)in outKey:(NSString *)outKey inKey:(NSString *)inKey
{
    NSObject *o = [in objectForKey:inKey];
    if (o != nil) {
        NSNumber *n = [NSNumber numberWithInteger:[[in valueForKey:inKey] integerValue]];
        [out setValue:n forKey:outKey];
    }
}

- (NSDictionary *)UserStatistics:(NSString *)username
/* Returns:
 * waypoints_found
 * waypoints_notfound
 * waypoints_hidden
 * recommendations_given
 * recommendations_received
 */
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setValue:@"" forKey:@"waypoints_found"];
    [ret setValue:@"" forKey:@"waypoints_notfound"];
    [ret setValue:@"" forKey:@"waypoints_hidden"];
    [ret setValue:@"" forKey:@"recommendations_given"];
    [ret setValue:@"" forKey:@"recommendations_received"];

    if (account.protocol == ProtocolOKAPI) {
        NSDictionary *dict = [okapi services_users_byUsername:username];

        if (dict == nil)
            return nil;

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
        [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];
        return ret;
    }

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *dict1 = [gs GetYourUserProfile];
        NSDictionary *dict2 = [gs GetCacheIdsFavoritedByUser];

        if (dict1 == nil && dict2 == nil)
            ret = nil;

        NSDictionary *d = [dict1 objectForKey:@"Profile"];
        d = [d objectForKey:@"User"];
        [self getNumber:ret from:d outKey:@"waypoints_hidden" inKey:@"HideCount"];
        [self getNumber:ret from:d outKey:@"waypoints_found" inKey:@"FindCount"];

        d = [dict2 objectForKey:@"CacheCodes"];
        if (d != nil) {
            NSNumber *n = [NSNumber numberWithUnsignedInteger:[d count]];
            [ret setValue:n forKey:@"recommendations_given"];
        }

        return ret;
    }

    if (account.protocol == ProtocolGCA) {
        NSDictionary *dict1 = [gca cacher_statistic__finds:username];
        NSDictionary *dict2 = [gca cacher_statistic__hides:username];

        if ([dict1 count] == 0 && [dict2 count] == 0)
            return nil;

        [self getNumber:ret from:dict1 outKey:@"waypoints_found" inKey:@"waypoints_found"];
        [self getNumber:ret from:dict2 outKey:@"waypoints_hidden" inKey:@"waypoints_hidden"];
        [self getNumber:ret from:dict2 outKey:@"recommendatons_received" inKey:@"recommendatons_received"];
        [self getNumber:ret from:dict2 outKey:@"recommendations_given" inKey:@"recommendations_given"];

        return ret;
    }

    return nil;
}

- (NSInteger)CreateLogNote:(NSString *)logtype waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite
{
    if (account.protocol == ProtocolLiveAPI) {
        return [gs CreateFieldNoteAndPublish:logtype waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite];
    }
    if (account.protocol == ProtocolOKAPI) {
        return [okapi services_logs_submit:logtype waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite];
    }
    if (account.protocol == ProtocolGCA) {
        return [gca my_log_new:logtype waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite];
    }

    return NO;
}

- (BOOL)updateWaypoint:(dbWaypoint *)waypoint
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [gs SearchForGeocaches_waypointname:waypoint.wpt_name];
        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        [waypointManager needsRefresh];
        return YES;
    }
    if (account.protocol == ProtocolOKAPI) {
        NSString *gpx = [okapi services_caches_formatters_gpx:waypoint.wpt_name];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseString:gpx];
        [imp parseAfter];

        [waypointManager needsRefresh];
        return YES;
    }
    if (account.protocol == ProtocolGCA) {
        NSString *gpx = [gca cache_gpx:waypoint.wpt_name];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseString:gpx];
        [imp parseAfter];

        [waypointManager needsRefresh];
        return YES;
    }

    return NO;
}

- (NSDictionary *)GSGetGeocacheDataTypes
{
    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *dict = [gs GetGeocacheDataTypes];
        return dict;
    }

    return nil;
}

- (void)alertError:(NSString *)msg error:(NSError *)error
{
    clientMsg = msg;
    clientError = error;
}

- (BOOL)loadWaypoints:(CLLocationCoordinate2D)center
{
    if (account.protocol == ProtocolGCA) {
        NSDictionary *json = [gca caches_gca:center];
        ImportGCAJSON *i = [[ImportGCAJSON alloc] init:dbc.Group_LiveImport account:account];
        [i parseBefore_cache];
        [i parseData_cache:json];
        [i parseAfter_cache];

        [i.namesImported enumerateObjectsUsingBlock:^(NSString *wpname, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *json = [gca logs_cache:wpname];
            [i parseBefore_logs];
            [i parseData_logs:json];
            [i parseAfter_logs];
        }];

        [dbWaypoint dbUpdateLogStatus];
        [waypointManager needsRefresh];
        return YES;
    }

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [gs SearchForGeocaches_pointradius:center];

        NSInteger total = [[json objectForKey:@"TotalMatchingCaches"] integerValue];;
        NSInteger done = 0;
        if (total != 0) {
            do {
                ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:dbc.Group_LiveImport account:account];
                [imp parseBefore];
                [imp parseDictionary:json];
                [imp parseAfter];

                done += 20;
                json = [gs GetMoreGeocaches:done];
            } while (done < total);
        }

        [dbWaypoint dbUpdateLogStatus];
        [waypointManager needsRefresh];
        return YES;
    }

    return NO;
}

- (NSArray *)listQueries
/* Returns: array of dicts of
 * - Name
 * - Id
 * - DateTime
 * - Size
 */
{
    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [gs GetPocketQueryList];

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];

        NSArray *pqs = [json objectForKey:@"PocketQueryList"];
        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"Name"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"GUID"] forKey:@"Id"];
            [d setValue:[NSNumber numberWithInteger:[MyTools secondsSinceEpochWindows:[pq objectForKey:@"DateLastGenerated"]]] forKey:@"DateTime"];
            [d setValue:[pq objectForKey:@"FileSizeInBytes"] forKey:@"Size"];

            [as addObject:d];
        }];

        return as;
    }

    return nil;
}

- (BOOL)retrieveQuery:(NSString *)_id group:(dbGroup *)group
{

    if (account.protocol == ProtocolLiveAPI) {

//        NSDictionary *json = [gs GetPocketQueryZippedFile:_id];
//        NSString *s = [json objectForKey:@"ZippedFile"];
//        NSData *d = [[NSData alloc] initWithBase64EncodedString:s options:0];
//        [d writeToFile:[NSString stringWithFormat:@"%@/foo", [MyTools FilesDir]] atomically:NO];
//        return nil;

        NSMutableDictionary *result = nil;
        NSMutableArray *geocaches = [NSMutableArray arrayWithCapacity:1000];;

        NSInteger max = 0;
        NSInteger offset = 0;
        NSInteger increase = 25;

        [self.delegateQueries remoteAPIQueriesDownloadUpdate:0 max:0];
        do {
            NSLog(@"offset:%ld - max: %ld", (long)offset, (long)max);
            NSDictionary *json = [gs GetFullPocketQueryData:_id startItem:offset numItems:increase];

            if (json != nil) {
                if (result == nil)
                    result = [NSMutableDictionary dictionaryWithDictionary:json];
                [geocaches addObjectsFromArray:[json objectForKey:@"Geocaches"]];
            }

            offset += increase;
            max = [[json objectForKey:@"PQCount"] integerValue];
            [self.delegateQueries remoteAPIQueriesDownloadUpdate:offset max:max];
        } while (offset < max);

        [result setObject:geocaches forKey:@"Geocaches"];

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:group account:account];
        [imp parseBefore];
        [imp parseDictionary:result];
        [imp parseAfter];

        [waypointManager needsRefresh];
        return YES;
    }

    return NO;
}

@end
