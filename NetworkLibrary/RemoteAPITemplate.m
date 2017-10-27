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

@property (nonatomic, retain) ProtocolTemplate *protocol;

@property (nonatomic, retain) NSString *errorStringNetwork;
@property (nonatomic, retain) NSString *errorStringAPI;
@property (nonatomic, retain) NSString *errorStringData;
@property (nonatomic        ) RemoteAPIResult errorCodeNetwork;
@property (nonatomic        ) RemoteAPIResult errorCodeAPI;
@property (nonatomic        ) RemoteAPIResult errorCodeData;

@property (nonatomic, retain) NSString *errorDomain;

@end

@implementation RemoteAPITemplate

- NEEDS_OVERLOADING_BOOL(supportsWaypointPersonalNotes)
- NEEDS_OVERLOADING_BOOL(supportsTrackablesRetrieve)
- NEEDS_OVERLOADING_BOOL(supportsTrackablesLog)
- NEEDS_OVERLOADING_BOOL(supportsUserStatistics)
- NEEDS_OVERLOADING_BOOL(supportsLogging)
- NEEDS_OVERLOADING_BOOL(supportsLoggingFavouritePoint)
- NEEDS_OVERLOADING_BOOL(supportsLoggingPhotos)
- NEEDS_OVERLOADING_BOOL(supportsLoggingCoordinates)
- NEEDS_OVERLOADING_BOOL(supportsLoggingTrackables)
- NEEDS_OVERLOADING_BOOL(supportsLoggingRating)
- NEEDS_OVERLOADING_NSRANGE(supportsLoggingRatingRange)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypoint)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypointsByCodes)
- NEEDS_OVERLOADING_BOOL(supportsLoadWaypointsByBoundaryBox)
- NEEDS_OVERLOADING_BOOL(supportsListQueries)
- NEEDS_OVERLOADING_BOOL(supportsRetrieveQueries)

- (instancetype)init:(dbAccount *)account;
{
    self = [super init];

    self.errorDomain = [NSString stringWithFormat:@"%@", [self class]];
    self.account = account;

    self.oabb = [[GCOAuthBlackbox alloc] init];
    [self.oabb token:self.account.oauth_token];
    [self.oabb tokenSecret:self.account.oauth_token_secret];
    [self.oabb consumerKey:self.account.oauth_consumer_public];
    [self.oabb consumerSecret:self.account.oauth_consumer_private];

    self.liveAPI = nil;
    self.okapi = nil;
    self.gca2 = nil;
    self.ggcw = nil;
    ProtocolId pid = (ProtocolId)self.account.protocol._id;
    switch (pid) {
        case PROTOCOL_LIVEAPI:
            self.liveAPI = [[ProtocolLiveAPI alloc] init:self];
            self.protocol = self.liveAPI;
            break;
        case PROTOCOL_OKAPI:
            self.okapi = [[ProtocolOKAPI alloc] init:self];
            self.protocol = self.okapi;
            break;
        case PROTOCOL_GCA:
            NSAssert(FALSE, @"Obsolete protocol: PROTOCOL_GCA");
            break;
        case PROTOCOL_GCA2:
            self.gca2 = [[ProtocolGCA2 alloc] init:self];
            self.protocol = self.gca2;
            break;
        case PROTOCOL_GGCW:
            self.ggcw = [[ProtocolGGCW alloc] init:self];
            self.protocol = self.ggcw;
            break;
        case PROTOCOL_NONE:
            break;
    }
    return self;
}

// ----------------------------------------

- (BOOL)Authenticate
{
    ProtocolId pid = (ProtocolId)self.account.protocol._id;
    switch (pid) {
        case PROTOCOL_OKAPI:
        case PROTOCOL_LIVEAPI:{
            // Reset it
            self.oabb = [[GCOAuthBlackbox alloc] init];

            if (IS_EMPTY(self.account.oauth_consumer_private) == YES) {
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
            if ([self.gca2 authenticate:self.account] == YES) {
                if (self.authenticationDelegate != nil)
                    [self.authenticationDelegate remoteAPI:self success:@"Obtained cookie"];
                return YES;
            } else
                return NO;

        case PROTOCOL_GGCW: {
            // Load https://www.geocaching.com/login/?jump=/geocube and wait for the redirect to /geocube.
            NSString *url = self.account.gca_authenticate_url;

            self.ggcw.delegate = self;

            [browserViewController showBrowser];
            [browserViewController prepare_ggcw:self.ggcw];
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

- (void)oauthtripped:(NSString *)reason error:(NSError *)error
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
        [self.authenticationDelegate remoteAPI:self failure:@"Unable to obtain secret token." error:error];
}

// ----------------------------------------

- (void)clearErrors
{
    self.errorStringNetwork = nil;
    self.errorStringAPI = nil;
    self.errorStringData = nil;
    self.errorCodeNetwork = REMOTEAPI_OK;
    self.errorCodeAPI = REMOTEAPI_OK;
    self.errorCodeData = REMOTEAPI_OK;
}

- (void)setNetworkError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    self.errorStringNetwork = errorString;
    self.errorCodeNetwork = errorCode;
}

- (void)setAPIError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    self.errorStringAPI = errorString;
    self.errorCodeAPI = errorCode;
}

- (void)setDataError:(NSString *)errorString error:(RemoteAPIResult)errorCode
{
    self.errorStringData = errorString;
    self.errorCodeData = errorCode;
}

- (RemoteAPIResult)lastErrorCode
{
    if (self.errorCodeNetwork != REMOTEAPI_OK)
        return self.errorCodeNetwork;
    if (self.errorCodeAPI != REMOTEAPI_OK)
        return self.errorCodeAPI;
    if (self.errorCodeData != REMOTEAPI_OK)
        return self.errorCodeData;
    return REMOTEAPI_OK;
}

- (NSString *)lastNetworkError
{
    return self.errorStringNetwork;
}

- (NSString *)lastAPIError
{
    return self.errorStringAPI;
}

- (NSString *)lastDataError
{
    return self.errorStringData;
}

- (NSString *)lastError
{
    if (self.errorStringNetwork != nil)
        return self.errorStringNetwork;
    if (self.errorStringAPI != nil)
        return self.errorStringAPI;
    if (self.errorStringData != nil)
        return self.errorStringData;
    return @"No error";
}

// ----------------------------------------

- (void)getNumber:(NSDictionary *)out from:(id)in outKey:(NSString *)outKey inKey:(NSString *)inKey
{
    NSObject *o = nil;
    if (in == nil)
        o = nil;
    else if ([in isKindOfClass:[NSDictionary class]] == YES)
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

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict infoItem:(InfoItem2 *)iid
{
    return [self UserStatistics:self.account.accountname.name retDict:retDict infoItem:iid];
}

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict infoItem:(InfoItem2 *)iid
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

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoItem:(InfoItem2 *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoItem:(InfoItem2 *)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoItem:(InfoItem2 *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *>**)qs infoItem:(InfoItem2 *)iid public:(BOOL)public
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoItem:(InfoItem2 *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesMine:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesInventory:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableDrop:(dbTrackable *)trackable waypoint:(NSString *)wptname infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableGrab:(NSString *)tbpin infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableDiscover:(NSString *)tbpin infoItem:(InfoItem2 *)iid
{
    [self setAPIError:@"Not implemented" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

@end
