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

@implementation RemoteAPI

@synthesize account, oabb, authenticationDelegate;
@synthesize stats_found, stats_notfound;
@synthesize clientError, clientMsg;

- (id)init:(dbAccount *)_account;
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
    return [self UserStatistics:account.accountname];
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
        [ret setValue:[dict valueForKey:@"caches_found"] forKey:@"waypoints_found"];
        [ret setValue:[dict valueForKey:@"caches_notfound"] forKey:@"waypoints_notfound"];
        [ret setValue:[dict valueForKey:@"caches_hidden"] forKey:@"waypoints_hidden"];
        [ret setValue:[dict valueForKey:@"rcmds_given"] forKey:@"recommendations_given"];
        return ret;
    }

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *dict = [gs GetYourUserProfile];

        NSDictionary *d = [dict objectForKey:@"Profile"];
        d = [d objectForKey:@"User"];
        [ret setValue:[d valueForKey:@"FindCount"] forKey:@"waypoints_found"];
        [ret setValue:[d valueForKey:@"HideCount"] forKey:@"waypoints_hidden"];

        dict = [gs GetCacheIdsFavoritedByUser];
        d = [dict objectForKey:@"CacheCodes"];
        NSNumber *n = [NSNumber numberWithUnsignedInteger:[d count]];
        [ret setValue:n forKey:@"recommendations_given"];

        return ret;
    }

    if (account.protocol == ProtocolGCA) {
        NSDictionary *dict = [gca cacher_statistic__finds:username];
        NSNumber *found = [NSNumber numberWithInteger:[[dict valueForKey:@"waypoints_found"] integerValue]];
        [ret setValue:found forKey:@"waypoints_found"];

        dict = [gca cacher_statistic__hides:username];
        NSNumber *hidden = [NSNumber numberWithInteger:[[dict valueForKey:@"waypoints_hidden"] integerValue]];
        NSNumber *rcmd_received = [NSNumber numberWithInteger:[[dict valueForKey:@"recommendations_received"] integerValue]];
        NSNumber *rcmd_given = [NSNumber numberWithInteger:[[dict valueForKey:@"recommendations_given"] integerValue]];
        [ret setValue:hidden forKey:@"waypoints_hidden"];
        [ret setValue:rcmd_received forKey:@"recommendations_received"];
        [ret setValue:rcmd_given forKey:@"recommendations_given"];

        return ret;
    }

    return nil;
}

- (NSInteger)CreateLogNote:(NSString *)logtype waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite
{
    if (account.protocol == ProtocolLiveAPI) {
        return [gs CreateFieldNoteAndPublish:logtype waypointName:waypoint.name dateLogged:dateLogged note:note favourite:favourite];
    }
    if (account.protocol == ProtocolOKAPI) {
        return [okapi services_logs_submit:logtype waypointName:waypoint.name dateLogged:dateLogged note:note favourite:favourite];
    }

    return NO;
}

- (BOOL)updateWaypoint:(dbWaypoint *)waypoint
{
    NSArray *groups = [dbGroup dbAllByWaypoint:waypoint._id];
    dbAccount *a = waypoint.account;

    __block dbGroup *g = nil;
    [groups enumerateObjectsUsingBlock:^(dbGroup *group, NSUInteger idx, BOOL *stop) {
        if (group.usergroup == YES) {
            g = group;
            *stop = YES;
        }
    }];

    if (account.protocol == ProtocolLiveAPI) {
        //NSDictionary *json = [gs SearchForGeocaches:waypoint.name];
        NSString *s = [NSString stringWithFormat:@"%@/a.json", [MyTools DataDistributionDirectory]];
        NSData *data = [NSData dataWithContentsOfFile:s];
        NSError *error;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        ImportGPXJSON *imp = [[ImportGPXJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        return YES;
    }
    if (account.protocol == ProtocolOKAPI) {
        NSString *gpx = [okapi services_caches_formatters_gpx:waypoint.name];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseString:gpx];
        [imp parseAfter];

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

@end
