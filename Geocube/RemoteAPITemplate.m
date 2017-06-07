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

- (instancetype)init:(dbAccount *)account;
{
    self = [super init];

    errorDomain = [NSString stringWithFormat:@"%@", [self class]];
    self.account = account;

    self.oabb = [[GCOAuthBlackbox alloc] init];
    [self.oabb token:self.account.oauth_token];
    [self.oabb tokenSecret:self.account.oauth_token_secret];
    [self.oabb consumerKey:self.account.oauth_consumer_public];
    [self.oabb consumerSecret:self.account.oauth_consumer_private];

    liveAPI = nil;
    okapi = nil;
    gca2 = nil;
    ggcw = nil;
    ProtocolId pid = (ProtocolId)self.account.protocol_id;
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
            NSAssert(FALSE, @"Obsolete protocol: PROTOCOL_GCA");
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
    ProtocolId pid = (ProtocolId)self.account.protocol_id;
    switch (pid) {
        case PROTOCOL_OKAPI:
        case PROTOCOL_LIVEAPI:{
            // Reset it
            self.oabb = [[GCOAuthBlackbox alloc] init];

            if (self.account.oauth_consumer_private == nil || [self.account.oauth_consumer_private isEqualToString:@""] == YES) {
                [self oauthtripped:@"No OAuth client information is available." error:nil];
                return NO;
            }

            [self.oabb URLRequestToken:self.account.oauth_request_url];
            [self.oabb URLAuthorize:self.account.oauth_authorize_url];
            [self.oabb URLAccessToken:self.account.oauth_access_url];
            [self.oabb consumerKey:self.account.oauth_consumer_public];
            [self.oabb consumerSecret:self.account.oauth_consumer_private];

            self.oabb.delegate = self;
            [self.oabb obtainRequestToken];
            if (self.oabb.token == nil) {
                [self oauthtripped:@"No request token was returned." error:nil];
                NSLog(@"%@ - token is nil after obtainRequestToken, not further authenticating", [self class]);
                return NO;
            }

            NSString *url = [NSString stringWithFormat:@"%@?oauth_token=%@", self.account.oauth_authorize_url, [MyTools urlEncode:self.oabb.token]];

            [browserViewController showBrowser];
            [browserViewController prepare_oauth:self.oabb];
            [browserViewController loadURL:url];
            return YES;
        }

        case PROTOCOL_GCA: {
            NSAssert(FALSE, @"Obsolete protocol: PROTOCOL_GCA");
            return YES;
        }

        case PROTOCOL_GCA2:
            if ([gca2 authenticate:self.account] == YES) {
                if (self.authenticationDelegate != nil)
                    [self.authenticationDelegate remoteAPI:self success:@"Obtained cookie"];
                return YES;
            } else
                return NO;

        case PROTOCOL_GGCW: {
            // Load https://www.geocaching.com/login/?jump=/geocube and wait for the redirect to /geocube.
            NSString *url = self.account.gca_authenticate_url;

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

- (void)GGCWAuthSuccessful:(NSHTTPCookie *)cookie
{
    self.account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [self.account dbUpdateCookieValue];

    [browserViewController prepare_ggcw:nil];
    [browserViewController clearScreen];

    if (self.authenticationDelegate != nil)
        [self.authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie
{
    self.account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [self.account dbUpdateCookieValue];

    [browserViewController clearScreen];

    if (self.authenticationDelegate != nil)
        [self.authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret
{
    self.account.oauth_token = token;
    self.account.oauth_token_secret = secret;
    [self.account dbUpdateOAuthToken];
    //oabb = nil;

    [browserViewController prepare_oauth:nil];
    [browserViewController clearScreen];

    if (self.authenticationDelegate)
        [self.authenticationDelegate remoteAPI:self success:@"Obtained requestToken"];

    [_AppDelegate switchController:RC_SETTINGS];
}

- (void)oauthtripped:(NSString *)reason error:(NSError *)_error
{
    NSLog(@"tripped: %@", reason);
    self.account.oauth_token = nil;
    self.account.oauth_token_secret = nil;
    [self.account dbUpdateOAuthToken];
    self.oabb = nil;

    [browserViewController prepare_oauth:nil];
    [browserViewController clearScreen];

    [_AppDelegate switchController:RC_SETTINGS];
    if (self.authenticationDelegate)
        [self.authenticationDelegate remoteAPI:self failure:@"Unable to obtain secret token." error:_error];
}

// ----------------------------------------

- NEEDS_OVERLOADING_BOOL(commentSupportsFavouritePoint)
- NEEDS_OVERLOADING_BOOL(commentSupportsPhotos)
- NEEDS_OVERLOADING_BOOL(commentSupportsRating)
- NEEDS_OVERLOADING_BOOL(commentSupportsTrackables)
- NEEDS_OVERLOADING_BOOL(waypointSupportsPersonalNotes)
- NEEDS_OVERLOADING_NSRANGE(commentSupportsRatingRange)
- NEEDS_OVERLOADING_BOOL(supportsUserStatistics)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypoint)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypointsByCenter)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypointsByCodes)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypointsByBoundaryBox)
- NEEDS_OVERLOADING_BOOL(supportsListQueries)
- NEEDS_OVERLOADING_BOOL(supportsRetrieveQueries)
- NEEDS_OVERLOADING_BOOL(supportsTrackables)
- NEEDS_OVERLOADING_BOOL(supportsLogging)

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

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    return [self UserStatistics:self.account.accountname_string retDict:retDict infoViewer:iv iiDownload:iid];
}

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
/* Returns:
 * waypoints_found
 * waypoints_notfound
 * waypoints_hidden
 * recommendations_given
 * recommendations_received
 */
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByCenter:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *>**)qs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

@end
