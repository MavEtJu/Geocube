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

@interface RemoteAPITemplate ()
{
    ProtocolTemplate *protocol;

    NSString *errorStringNetwork;
    NSString *errorStringAPI;
    NSString *errorStringData;
    RemoteAPIResult errorCodeNetwork;
    RemoteAPIResult errorCodeAPI;
    RemoteAPIResult errorCodeData;

    NSString *errorDomain;
}

@end

@implementation RemoteAPITemplate

@synthesize account, oabb, authenticationDelegate;
@synthesize stats_found, stats_notfound;

- (instancetype)init:(dbAccount *)_account;
{
    self = [super init];

    errorDomain = [NSString stringWithFormat:@"%@", [self class]];
    account = _account;

    oabb = [[GCOAuthBlackbox alloc] init];
    [oabb token:account.oauth_token];
    [oabb tokenSecret:account.oauth_token_secret];
    [oabb consumerKey:account.oauth_consumer_public];
    [oabb consumerSecret:account.oauth_consumer_private];

    liveAPI = nil;
    okapi = nil;
    gca = nil;
    gca2 = nil;
    ggcw = nil;
    ProtocolId pid = account.protocol_id;
    switch (pid) {
        case PROTOCOL_LIVEAPI:
            liveAPI = [[ProtocolLiveAPI alloc] init:self];
            protocol = liveAPI;
            break;
        case PROTOCOL_OKAPI:
            okapi = [[ProtocolOKAPI alloc] init:self];
            protocol = okapi;
            break;
        case PROTOCOL_GCA:
            gca = [[ProtocolGCA alloc] init:self];
            gca.delegate = self;
            protocol = gca;
            break;
        case PROTOCOL_GCA2:
            gca2 = [[ProtocolGCA2 alloc] init:self];
            protocol = gca2;
            break;
        case PROTOCOL_GGCW:
            ggcw = [[ProtocolGGCW alloc] init:self];
            protocol = ggcw;
            break;
        case PROTOCOL_NONE:
            break;
    }
    return self;
}

// ----------------------------------------

- (BOOL)Authenticate
{
    ProtocolId pid = account.protocol_id;
    switch (pid) {
        case PROTOCOL_OKAPI:
        case PROTOCOL_LIVEAPI:{
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

            [browserViewController showBrowser];
            [browserViewController prepare_oauth:oabb];
            [browserViewController loadURL:url];
            return YES;
        }

        case PROTOCOL_GCA: {
            // Load http://geocaching.com.au/login/?jump=/geocube and wait for the redirect to /geocube.
            NSString *url = account.gca_authenticate_url;

            gca.delegate = self;

            [browserViewController showBrowser];
            [browserViewController prepare_gca:gca];
            [browserViewController loadURL:url];
            return YES;
        }

        case PROTOCOL_GCA2:
            if ([gca2 authenticate:account] == YES) {
                if (authenticationDelegate != nil)
                    [authenticationDelegate remoteAPI:self success:@"Obtained cookie"];
                return YES;
            } else
                return NO;

        case PROTOCOL_GGCW: {
            // Load https://www.geocaching.com/login/?jump=/geocube and wait for the redirect to /geocube.
            NSString *url = account.gca_authenticate_url;

            ggcw.delegate = self;

            [browserViewController showBrowser];
            [browserViewController prepare_ggcw:ggcw];
            [browserViewController loadURL:url];
            return YES;
        }

        case PROTOCOL_NONE:
            return NO;
    }

    return NO;
}

- (void)GCAuthSuccessful:(NSHTTPCookie *)cookie
{
    account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [account dbUpdateCookieValue];

    [browserViewController prepare_ggcw:nil];
    [browserViewController clearScreen];

    if (authenticationDelegate != nil)
        [authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie
{
    account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [account dbUpdateCookieValue];

    [browserViewController prepare_gca:nil];
    [browserViewController clearScreen];

    if (authenticationDelegate != nil)
        [authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret
{
    account.oauth_token = token;
    account.oauth_token_secret = secret;
    [account dbUpdateOAuthToken];
    //oabb = nil;

    [browserViewController prepare_oauth:nil];
    [browserViewController clearScreen];

    if (authenticationDelegate)
        [authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthtripped:(NSString *)reason error:(NSError *)_error
{
    NSLog(@"tripped: %@", reason);
    account.oauth_token = nil;
    account.oauth_token_secret = nil;
    [account dbUpdateOAuthToken];
    oabb = nil;

    [browserViewController prepare_oauth:nil];
    [browserViewController clearScreen];

    [_AppDelegate switchController:RC_SETTINGS];
    if (authenticationDelegate)
        [authenticationDelegate remoteAPI:self failure:@"Unable to obtain secret token." error:_error];
}

// ----------------------------------------

- (BOOL)commentSupportsPhotos
{
    return [protocol commentSupportsPhotos];
}

- (BOOL)commentSupportsTrackables
{
    return [protocol commentSupportsTrackables];
}

- (BOOL)commentSupportsRating
{
    return [protocol commentSupportsRating];
}

- (NSRange)commentSupportsRatingRange
{
    return [protocol commentSupportsRatingRange];
}

- (BOOL)commentSupportsFavouritePoint
{
    return [protocol commentSupportsFavouritePoint];
}

- (BOOL)waypointSupportsPersonalNotes
{
    return [protocol waypointSupportsPersonalNotes];
}

// ----------------------------------------

- (void)clearErrors
{
    errorStringNetwork = nil;
    errorStringAPI = nil;
    errorStringData = nil;
    errorCodeNetwork = REMOTEAPI_OK;
    errorCodeAPI = REMOTEAPI_OK;
    errorCodeData = REMOTEAPI_OK;
}

- (void)setNetworkError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    errorStringNetwork = errorString;
    errorCodeNetwork = errorCode;
}

- (void)setAPIError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    errorStringAPI = errorString;
    errorCodeAPI = errorCode;
}

- (void)setDataError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    errorStringData = errorString;
    errorCodeData = errorCode;
}

- (RemoteAPIResult)lastErrorCode
{
    if (errorCodeNetwork != REMOTEAPI_OK)
        return errorCodeNetwork;
    if (errorCodeAPI != REMOTEAPI_OK)
        return errorCodeAPI;
    if (errorCodeData != REMOTEAPI_OK)
        return errorCodeData;
    return REMOTEAPI_OK;
}

- (NSString *)lastNetworkError
{
    return errorStringNetwork;
}

- (NSString *)lastAPIError
{
    return errorStringAPI;
}

- (NSString *)lastDataError
{
    return errorStringData;
}

- (NSString *)lastError
{
    if (errorStringNetwork != nil)
        return errorStringNetwork;
    if (errorStringAPI != nil)
        return errorStringAPI;
    if (errorStringData != nil)
        return errorStringData;
    return @"No error";
}

// ----------------------------------------

- (void)getNumber:(NSDictionary *)out from:(id)in outKey:(NSString *)outKey inKey:(NSString *)inKey
{
    NSObject *o = nil;
    if ([in isKindOfClass:[NSDictionary class]] == YES)
        o = [(NSDictionary *)in objectForKey:inKey];
    else if ([in isKindOfClass:[GCDictionaryGCA class]] == YES)
        o = [(GCDictionaryGCA *)in objectForKey:inKey];
    else if ([in isKindOfClass:[GCDictionaryGCA2 class]] == YES)
        o = [(GCDictionaryGCA2 *)in objectForKey:inKey];
    else if ([in isKindOfClass:[GCDictionaryGGCW class]] == YES)
        o = [(GCDictionaryGGCW *)in objectForKey:inKey];
    else if ([in isKindOfClass:[GCDictionaryLiveAPI class]] == YES)
        o = [(GCDictionaryLiveAPI *)in objectForKey:inKey];
    else if ([in isKindOfClass:[GCDictionaryOKAPI class]] == YES)
        o = [(GCDictionaryOKAPI *)in objectForKey:inKey];
    else
        NSAssert1(FALSE, @"Unknown class: %@", [in class]);
    if (o != nil) {
        NSNumber *n = [NSNumber numberWithInteger:[[in valueForKey:inKey] integerValue]];
        [out setValue:n forKey:outKey];
    }
}

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict downloadInfoItem:(InfoItemDownload *)iid
{
    return [self UserStatistics:account.accountname_string retDict:retDict downloadInfoItem:iid];
}

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict downloadInfoItem:(InfoItemDownload *)iid
/* Returns:
 * waypoints_found
 * waypoints_notfound
 * waypoints_hidden
 * recommendations_given
 * recommendations_received
 */
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray *)wpcodes retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)listQueries:(NSArray **)qs downloadInfoItem:(InfoItemDownload *)iid
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesMine:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesInventory:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t downloadInfoItem:(InfoItemDownload *)iid
{
    return REMOTEAPI_NOTPROCESSED;
}

@end
