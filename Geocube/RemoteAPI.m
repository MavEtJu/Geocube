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

@interface RemoteAPI ()
{
    RemoteAPI_LiveAPI *liveAPI;
    RemoteAPI_OKAPI *okapi;
    RemoteAPI_GCA *gca;
    RemoteAPI_GCA2 *gca2;
    RemoteAPI_Template *protocol;

    NSString *errorStringNetwork;
    NSString *errorStringAPI;
    NSString *errorStringData;
    RemoteAPIResult errorCodeNetwork;
    RemoteAPIResult errorCodeAPI;
    RemoteAPIResult errorCodeData;

    dbAccount *account;

    NSInteger loadWaypointsLogs, loadWaypointsWaypoints;

    NSString *errorDomain;
}

@end

@implementation RemoteAPI

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
    switch (account.protocol) {
        case PROTOCOL_LIVEAPI:
            liveAPI = [[RemoteAPI_LiveAPI alloc] init:self];
            protocol = liveAPI;
            break;
        case PROTOCOL_OKAPI:
            okapi = [[RemoteAPI_OKAPI alloc] init:self];
            protocol = okapi;
            break;
        case PROTOCOL_GCA:
            gca = [[RemoteAPI_GCA alloc] init:self];
            gca.delegate = self;
            protocol = gca;
            break;
        case PROTOCOL_GCA2:
            gca2 = [[RemoteAPI_GCA2 alloc] init:self];
            protocol = gca2;
            break;
        default:
            break;
    }
    return self;
}

// ----------------------------------------

- (BOOL)Authenticate
{
    switch (account.protocol) {
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

        case PROTOCOL_NONE:
            return NO;
    }

    return NO;
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

#define GCA_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            \
            NSNumber *num = [__json__ objectForKey:@"actionstatus"]; \
            if (num == nil) { \
                NSString *s = [NSString stringWithFormat:@"[GCA] %@: No 'actionstatus' field returned", __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return REMOTEAPI_APIFAILED; \
            } \
            if ([num integerValue] != 1) { \
                NSString *s = [NSString stringWithFormat:@"[GCA] %@: 'actionstatus' was not 1 (%@)", __logsection__, [__json__ objectForKey:@"msg"]]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return __failure__; \
            } \
        }

#define GCA_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:@"[GCA] %@: No '%@' field returned", __logsection__, __field__]; \
                [self setDataError:s error:__failure__]; \
                NSLog(@"%@", s); \
                return __failure__; \
            }

#define LIVEAPI_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            NSDictionary *status = [__json__ objectForKey:@"Status"]; \
            if (status == nil) { \
                NSString *s = [NSString stringWithFormat:@"[LiveAPI] %@: No 'Status' field returned", __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return REMOTEAPI_APIFAILED; \
            } \
            NSNumber *num = [status objectForKey:@"StatusCode"]; \
            if (num == nil) { \
                NSString *s = [NSString stringWithFormat:@"[LiveAPI] %@: No 'StatusCode' field returned", __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return REMOTEAPI_APIFAILED; \
            } \
            if ([num integerValue] != 0) { \
                NSString *s = [NSString stringWithFormat:@"[LiveAPI] %@: 'actionstatus' was not 0 (%@)", __logsection__, num]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return __failure__; \
            } \
        }

#define LIVEAPI_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:@"[LiveAPI] %@: No '%@' field returned", __logsection__, __field__]; \
                [self setDataError:s error:__failure__]; \
                NSLog(@"%@", s); \
                return __failure__; \
            }

#define OKAPI_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            NSDictionary *error = [__json__ objectForKey:@"error"]; \
            if (error != nil) { \
                NSString *s = [NSString stringWithFormat:@"[OKAPI] %@: Error response: (%@)", __logsection__, [error description]]; \
                NSLog(@"%@", s); \
                [self setAPIError:s error:REMOTEAPI_APIFAILED]; \
                return REMOTEAPI_APIFAILED; \
            } \
        }

#define OKAPI_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:@"[OKAPI] %@: No '%@' field returned", __logsection__, __field__]; \
                [self setDataError:s error:__failure__]; \
                NSLog(@"%@", s); \
                return __failure__; \
            }


#define GCA2_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            NSDictionary *error = [__json__ objectForKey:@"error"]; \
            if (error != nil) { \
                NSString *s = [NSString stringWithFormat:@"[GCA2] %@: Error response: (%@)", __logsection__, [error description]]; \
                NSLog(@"%@", s); \
                [self setAPIError:s error:REMOTEAPI_APIFAILED]; \
                return REMOTEAPI_APIFAILED; \
            } \
        }

#define GCA2_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
        __type__ *__varname__ = [__json__ objectForKey:__field__]; \
        if (__varname__ == nil) { \
            NSString *s = [NSString stringWithFormat:@"[GCA2] %@: No '%@' field returned", __logsection__, __field__]; \
            [self setDataError:s error:__failure__]; \
            NSLog(@"%@", s); \
            return __failure__; \
        }

- (void)getNumber:(NSDictionary *)out from:(NSDictionary *)in outKey:(NSString *)outKey inKey:(NSString *)inKey
{
    NSObject *o = [in objectForKey:inKey];
    if (o != nil) {
        NSNumber *n = [NSNumber numberWithInteger:[[in valueForKey:inKey] integerValue]];
        [out setValue:n forKey:outKey];
    }
}

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict downloadInfoItem:(InfoItemDowload *)iid
{
    return [self UserStatistics:account.accountname_string retDict:retDict downloadInfoItem:iid];
}

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict downloadInfoItem:(InfoItemDowload *)iid
/* Returns:
 * waypoints_found
 * waypoints_notfound
 * waypoints_hidden
 * recommendations_given
 * recommendations_received
 */
{
    [self clearErrors];

    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setValue:@"" forKey:@"waypoints_found"];
    [ret setValue:@"" forKey:@"waypoints_notfound"];
    [ret setValue:@"" forKey:@"waypoints_hidden"];
    [ret setValue:@"" forKey:@"recommendations_given"];
    [ret setValue:@"" forKey:@"recommendations_received"];

    if (account.protocol == PROTOCOL_OKAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];
        GCDictionaryOKAPI *dict = [okapi services_users_byUsername:username downloadInfoItem:iid];
        OKAPI_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
        [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];
        NSDictionary *dict1 = [liveAPI GetYourUserProfile:iid];
        LIVEAPI_CHECK_STATUS(dict1, @"UserStatistics/profile", REMOTEAPI_USERSTATISTICS_LOADFAILED);
        [iid setChunksCount:2];
        NSDictionary *dict2 = [liveAPI GetCacheIdsFavoritedByUser:iid];
        LIVEAPI_CHECK_STATUS(dict2, @"UserStatistics/favourited", REMOTEAPI_USERSTATISTICS_LOADFAILED);

        if (dict1 == nil && dict2 == nil)
            return [self lastErrorCode];

        LIVEAPI_GET_VALUE(dict1, NSDictionary, d1, @"Profile", @"UserStatistics/d1", REMOTEAPI_USERSTATISTICS_LOADFAILED);
        d1 = [d1 objectForKey:@"User"];
        [self getNumber:ret from:d1 outKey:@"waypoints_hidden" inKey:@"HideCount"];
        [self getNumber:ret from:d1 outKey:@"waypoints_found" inKey:@"FindCount"];

        LIVEAPI_GET_VALUE(dict2, NSDictionary, d2, @"CacheCodes", @"UserStatistics/d2", REMOTEAPI_USERSTATISTICS_LOADFAILED);
        NSNumber *n = [NSNumber numberWithUnsignedInteger:[d2 count]];
        [ret setValue:n forKey:@"recommendations_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        NSDictionary *dict1 = [gca cacher_statistic__finds:username downloadInfoItem:iid];
        [iid setChunksCount:2];
        NSDictionary *dict2 = [gca cacher_statistic__hides:username downloadInfoItem:iid];

        if ([dict1 count] == 0 && [dict2 count] == 0)
            return [self lastErrorCode];

        [self getNumber:ret from:dict1 outKey:@"waypoints_found" inKey:@"waypoints_found"];
        [self getNumber:ret from:dict2 outKey:@"waypoints_hidden" inKey:@"waypoints_hidden"];
        [self getNumber:ret from:dict2 outKey:@"recommendatons_received" inKey:@"recommendatons_received"];
        [self getNumber:ret from:dict2 outKey:@"recommendations_given" inKey:@"recommendations_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        NSDictionary *dict = [gca2 api_services_users_by__username:username downloadInfoItem:iid];
        GCA2_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
        [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
        [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDowload *)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    if (account.protocol == PROTOCOL_LIVEAPI) {
        GCDictionaryLiveAPI *json = [liveAPI CreateFieldNoteAndPublish:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite imageCaption:imageCaption imageDescription:imageDescription imageData:imgdata imageFilename:image.datafile downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);

        [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tb.logtype == TRACKABLE_LOG_NONE)
                return;
            NSInteger dflt = 0;
            NSInteger logtype = LOGSTRING_LOGTYPE_UNKNOWN;
            NSString *note = nil;
            switch (tb.logtype) {
                case TRACKABLE_LOG_VISIT:
                    dflt = LOGSTRING_DEFAULT_VISIT;
                    logtype = LOGSTRING_LOGTYPE_TRACKABLEPERSON;
                    note = [NSString stringWithFormat:@"Visited '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    break;
                case TRACKABLE_LOG_DROPOFF:
                    dflt = LOGSTRING_DEFAULT_DROPOFF;
                    note = [NSString stringWithFormat:@"Dropped off at '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    logtype = LOGSTRING_LOGTYPE_TRACKABLEPERSON;
                    break;
                case TRACKABLE_LOG_PICKUP:
                    dflt = LOGSTRING_DEFAULT_PICKUP;
                    note = [NSString stringWithFormat:@"Picked up from '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    logtype = LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT;
                    break;
                case TRACKABLE_LOG_DISCOVER:
                    dflt = LOGSTRING_DEFAULT_DISCOVER;
                    note = [NSString stringWithFormat:@"Discovered in '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    logtype = LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT;
                    break;
                default:
                    NSAssert(NO, @"Unknown tb.logtype");
            }
            dbLogString *ls = [dbLogString dbGetByAccountLogtypeDefault:account logtype:logtype default:dflt];
            [liveAPI CreateTrackableLog:waypoint logtype:ls.type trackable:tb note:note dateLogged:dateLogged downloadInfoItem:iid];
        }];
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_OKAPI) {
        GCDictionaryOKAPI *json = [okapi services_logs_submit:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite downloadInfoItem:iid];
        OKAPI_CHECK_STATUS(json, @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);

        OKAPI_GET_VALUE(json, NSNumber, success, @"success", @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);
        if ([success boolValue] == NO) {
            NSString *s = [NSString stringWithFormat:@"[OKAPI] CreateLogNote: 'success' is not TRUE: %@", [json objectForKey:@"message"]];
            [self setDataError:s error:REMOTEAPI_CREATELOG_LOGFAILED];
            NSLog(@"%@", s);
            return REMOTEAPI_CREATELOG_LOGFAILED;
        }
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA) {
        GCDictionaryGCA *json = [gca my_log_new:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note rating:rating downloadInfoItem:iid];
        GCA_CHECK_STATUS(json, @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);

        GCA_GET_VALUE(json, NSNumber, plog_id, @"log", @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);
        NSInteger log_id = [plog_id integerValue];
        if (log_id == 0) {
            NSString *s = @"[GCA] CreateLogNote/log: 'log_id' returned was zero";
            [self setDataError:s error:REMOTEAPI_CREATELOG_LOGFAILED];
            NSLog(@"%@", s);
            return REMOTEAPI_CREATELOG_LOGFAILED;
        }

        if (image != nil) {
            json = [gca my_gallery_cache_add:waypoint.wpt_name log_id:log_id data:imgdata caption:imageCaption description:imageDescription downloadInfoItem:iid];
            GCA_CHECK_STATUS(json, @"CreateLogNote/image", REMOTEAPI_CREATELOG_IMAGEFAILED);
        }

        return REMOTEAPI_OK;
    }

    [self setDataError:@"[RemoteAPI] CreateLogNote: Unknown protocol" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDowload *)iid
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    if (account.protocol == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_waypointname:waypoint.wpt_name downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:g account:a];
        [imp parseDictionary:json];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }
    if (account.protocol == PROTOCOL_OKAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryOKAPI *json = [okapi services_caches_geocache:waypoint.wpt_name downloadInfoItem:iid];
        OKAPI_CHECK_STATUS(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *as = @[[json objectForKey:waypoint.wpt_name]];
        [d setObject:as forKey:@"waypoints"];
        GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

        ImportOKAPIJSON *imp = [[ImportOKAPIJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:d2];
        [imp parseAfter];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }
    if (account.protocol == PROTOCOL_GCA) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        GCDictionaryGCA *json = [gca cache__json:waypoint.wpt_name downloadInfoItem:iid];
        GCA_CHECK_STATUS(json, @"loadWaypoint/cache__json", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        ImportGCAJSON *imp = [[ImportGCAJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        [iid setChunksCount:2];
        json = [gca logs_cache:waypoint.wpt_name downloadInfoItem:iid];
        GCA_CHECK_STATUS(json, @"loadWaypoint/logs_cache", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        imp = [[ImportGCAJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }
    if (account.protocol == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGCA2 *json = [gca2 api_services_caches_geocache:waypoint.wpt_name downloadInfoItem:iid];
        GCA2_CHECK_STATUS(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        NSArray *as = @[[json objectForKey:waypoint.wpt_name]];
        [d setObject:as forKey:@"waypoints"];
        GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

        ImportGCA2JSON *imp = [[ImportGCA2JSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:d2];
        [imp parseAfter];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }

    [self setDataError:@"[RemoteAPI] loadWaypoint: Unknown protocol" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject downloadInfoItem:(InfoItemDowload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;

    if (account.protocol == PROTOCOL_GCA) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[GCA] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGCA *wps = [gca caches_gca:center downloadInfoItem:iid];
        GCA_CHECK_STATUS(wps, @"caches_gca", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        InfoItemImport *iii = [infoViewer addImport:NO];
        [iii setDescription:@"Geocaching Australia JSON data (queued)"];
        [iii showLogs:NO];
        [iii showTrackables:NO];
        [callback remoteAPI_objectReadyToImport:iii object:wps group:group account:account];
        NSMutableArray *logs = [NSMutableArray arrayWithCapacity:50];
        NSArray *ws = [wps objectForKey:@"geocaches"];

        [iid setChunksTotal:[ws count]];
        [iid setChunksCount:1];
        [iid resetBytes];
        [ws enumerateObjectsUsingBlock:^(NSDictionary *wp, NSUInteger idx, BOOL * _Nonnull stop) {
            [iid setChunksCount:idx + 1];
            NSString *wpname = [wp objectForKey:@"waypoint"];
            [iid resetBytes];
            NSDictionary *ls = [gca logs_cache:wpname downloadInfoItem:iid];
            NSArray *lss = [ls objectForKey:@"logs"];
            [lss enumerateObjectsUsingBlock:^(NSDictionary *l, NSUInteger idx, BOOL * _Nonnull stop) {
                [logs addObject:l];
            }];
        }];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
//        [d setObject:wps forKey:@"geocaches1"];
        [d setObject:logs forKey:@"logs"];

        GCDictionaryGCA *gcajson = [[GCDictionaryGCA alloc] initWithDictionary:d];

        iii = [infoViewer addImport];
        [iii expand:NO];
        [iii setDescription:@"Geocaching Australia GPX data (queued)"];
        [iii showWaypoints:NO];
        [iii showTrackables:NO];
        [callback remoteAPI_objectReadyToImport:iii object:gcajson group:group account:account];

        *retObject = gcajson;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA2) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[GCA2] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        NSDictionary *json = [gca2 api_services_caches_search_nearest:center downloadInfoItem:iid];
        GCA2_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        GCA2_GET_VALUE(json, NSArray, wpcodes, @"results", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        if ([wpcodes count] == 0)
            return REMOTEAPI_OK;

        [iid setChunksCount:2];
        json = [gca2 api_services_caches_geocaches:wpcodes downloadInfoItem:iid];
        OKAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableArray *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
        [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
            [wps addObject:[json objectForKey:wpcode]];
        }];
        [d setObject:wps forKey:@"waypoints"];
        GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

        ImportGCA2JSON *imp = [[ImportGCA2JSON alloc] init:group account:account];
        [imp parseBefore];
        [imp parseDictionary:d2];
        [imp parseAfter];

        [waypointManager needsRefreshAll];
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_LIVEAPI) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[LiveAPI] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:1];
        [iid setChunksCount:1];
        NSMutableArray *wps = [NSMutableArray arrayWithCapacity:200];
        NSDictionary *json = [liveAPI SearchForGeocaches_pointradius:center downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        LIVEAPI_GET_VALUE(json, NSNumber, ptotal, @"TotalMatchingCaches", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
        NSInteger total = [ptotal integerValue];
        NSInteger done = 0;
        [iid setChunksTotal:(total / 20) + 1];
        if (total != 0) {
            GCDictionaryLiveAPI *livejson = [[GCDictionaryLiveAPI alloc] initWithDictionary:json];
            LIVEAPI_CHECK_STATUS(livejson, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
            InfoItemImport *iii = [infoViewer addImport:NO];
            [iii setDescription:@"LiveAPI JSON data (queued)"];
            [callback remoteAPI_objectReadyToImport:iii object:livejson group:group account:account];
            [wps addObjectsFromArray:[json objectForKey:@"Geocaches"]];
            do {
                [iid setChunksCount:(done / 20) + 1];
                done += 20;

                json = [liveAPI GetMoreGeocaches:done downloadInfoItem:iid];
                LIVEAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

                if ([json objectForKey:@"Geocaches"] != nil) {
                    GCDictionaryLiveAPI *livejson = [[GCDictionaryLiveAPI alloc] initWithDictionary:json];
                    InfoItemImport *iii = [infoViewer addImport:NO];
                    [iii setDescription:@"LiveAPI JSON (queued)"];
                    [callback remoteAPI_objectReadyToImport:iii object:livejson group:group account:account];
                    [wps addObjectsFromArray:[json objectForKey:@"Geocaches"]];
                }
            } while (done < total);
        }

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
        [d setObject:wps forKey:@"Geocaches"];
        GCDictionaryLiveAPI *livejson = [[GCDictionaryLiveAPI alloc] initWithDictionary:d];
        *retObject = livejson;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_OKAPI) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[OKAPI] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:0];
        [iid setChunksCount:1];
        NSInteger offset = 0;
        BOOL more = NO;
        NSMutableArray *wpcodes = [NSMutableArray arrayWithCapacity:20];
        do {
            NSDictionary *json = [okapi services_caches_search_nearest:center offset:offset downloadInfoItem:iid];
            OKAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

            more = [[json objectForKey:@"more"] boolValue];
            NSArray *rets = nil;
            NSObject *vs = [json objectForKey:@"results"];
            if ([vs isKindOfClass:[NSString class]] == YES)
                rets = @[vs];
            else if ([vs isKindOfClass:[NSArray class]] == YES)
                rets = (NSArray *)vs;
            [rets enumerateObjectsUsingBlock:^(NSString *v, NSUInteger idx, BOOL * _Nonnull stop) {
                [wpcodes addObject:v];
            }];
            offset += [rets count];
        } while (more == YES);

        if ([wpcodes count] == 0)
            return REMOTEAPI_OK;
        NSDictionary *json = [okapi services_caches_geocaches:wpcodes downloadInfoItem:iid];
        OKAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

        NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:[wpcodes count]];
        [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *wpjson = [json objectForKey:wpcode];
            if (wpjson != nil)
                [wps addObject:wpjson];
        }];

        InfoItemImport *iii = [infoViewer addImport:NO];
        [iii showTrackables:NO];
        [iii setDescription:@"OKAPI JSON data (queued)"];
        GCDictionaryOKAPI *rv = [[GCDictionaryOKAPI alloc] initWithDictionary:[NSDictionary dictionaryWithObject:wps forKey:@"waypoints"]];
        [callback remoteAPI_objectReadyToImport:iii object:rv group:group account:account];
        *retObject = rv;

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(InfoItemDowload *)iid
{
    if (account.protocol == PROTOCOL_LIVEAPI) {
        NSDictionary *json = [liveAPI UpdateCacheNote:note.wp_name text:note.note downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"updatePersonalNote", REMOTEAPI_PERSONALNOTE_UPDATEFAILED);
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)listQueries:(NSArray **)qs downloadInfoItem:(InfoItemDowload *)iid
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    *qs = nil;
    if (account.protocol == PROTOCOL_LIVEAPI) {
        NSDictionary *json = [liveAPI GetPocketQueryList:iid];
        LIVEAPI_CHECK_STATUS(json, @"listQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];

        NSArray *pqs = [json objectForKey:@"PocketQueryList"];
        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"Name"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"GUID"] forKey:@"Id"];
            [d setValue:[NSNumber numberWithInteger:[MyTools secondsSinceEpochFromWindows:[pq objectForKey:@"DateLastGenerated"]]] forKey:@"DateTime"];
            [d setValue:[pq objectForKey:@"FileSizeInBytes"] forKey:@"Size"];
            [d setValue:[pq objectForKey:@"PQCount"] forKey:@"Count"];

            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA || account.protocol == PROTOCOL_GCA2) {
        NSDictionary *json;
        if (account.protocol == PROTOCOL_GCA) {
            json = [gca my_query_list__json:iid];
            GCA_CHECK_STATUS(json, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);
        }
        if (account.protocol == PROTOCOL_GCA2) {
            json = [gca2 my_query_list__json:iid];
            GCA2_CHECK_STATUS(json, @"ListQueries", REMOTEAPI_LOADWAYPOINT_LOADFAILED);
        }

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
        GCA_GET_VALUE(json, NSArray, pqs, @"queries", @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"description"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"queryid"] forKey:@"Id"];
//            [d setValue:[NSNumber numberWithInteger:[gca my_query_count:[pq objectForKey:@"queryid"]]] forKey:@"Count"];

            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDowload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;

    if (account.protocol == PROTOCOL_LIVEAPI) {
        NSMutableDictionary *result = nil;
        NSMutableArray *geocaches = [NSMutableArray arrayWithCapacity:1000];

        NSInteger max = 0;
        NSInteger tried = 0;
        NSInteger offset = 0;
        NSInteger increase = 25;

        [iid setChunksTotal:0];
        [iid setChunksCount:1];
        do {
            NSLog(@"offset:%ld - max: %ld", (long)offset, (long)max);
            NSDictionary *json = [liveAPI GetFullPocketQueryData:_id startItem:offset numItems:increase downloadInfoItem:iid];
            LIVEAPI_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

            NSInteger found = 0;
            if (result == nil)
                result = [NSMutableDictionary dictionaryWithDictionary:json];

            InfoItemImport *iii = [infoViewer addImport];
            [callback remoteAPI_objectReadyToImport:iii object:json group:group account:account];

            [geocaches addObjectsFromArray:[json objectForKey:@"Geocaches"]];
            found += [[json objectForKey:@"Geocaches"] count];

            offset += found;
            tried += increase;
            max = [[json objectForKey:@"PQCount"] integerValue];
            [iid setChunksTotal:1 + (max / increase)];
            [iid setChunksCount:offset / increase];
        } while (tried < max);
        [iid setChunksTotal:1 + (max / increase)];

        [result setObject:geocaches forKey:@"Geocaches"];

        *retObj = result;
        return REMOTEAPI_OK;
    }

    if (account.protocol == PROTOCOL_GCA || account.protocol == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        NSDictionary *json;
        if (account.protocol == PROTOCOL_GCA) {
            json = [gca my_query_json:_id downloadInfoItem:iid];
            GCA_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_LISTQUERIES_LOADFAILED);
        }
        if (account.protocol == PROTOCOL_GCA2) {
            json = [gca2 my_query_json:_id downloadInfoItem:iid];
            GCA2_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_LOADWAYPOINT_LOADFAILED);
        }

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:json group:group account:account];

        *retObj = json;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDowload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;
    if (account.protocol == PROTOCOL_GCA || account.protocol == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];
        NSString *gpx;
        if (account.protocol == PROTOCOL_GCA)
            gpx = [gca my_query_gpx:_id downloadInfoItem:iid];
        if (account.protocol == PROTOCOL_GCA2)
            gpx = [gca2 my_query_gpx:_id downloadInfoItem:iid];
        if (gpx == nil)
            return REMOTEAPI_APIFAILED;

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:gpx group:group account:account];

        *retObj = gpx;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesMine:(InfoItemDowload *)iid
{
    if (account.protocol != PROTOCOL_LIVEAPI)
        return REMOTEAPI_NOTPROCESSED;

    [iid setChunksTotal:1];
    [iid setChunksCount:1];

    NSDictionary *json = [liveAPI GetOwnedTrackables:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesMine", REMOTEAPI_TRACKABLES_OWNEDLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesInventory:(InfoItemDowload *)iid
{
    if (account.protocol != PROTOCOL_LIVEAPI)
        return REMOTEAPI_NOTPROCESSED;

    [iid setChunksTotal:1];
    [iid setChunksCount:1];

    NSDictionary *json = [liveAPI GetUsersTrackables:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesInventory", REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t downloadInfoItem:(InfoItemDowload *)iid
{
    if (account.protocol != PROTOCOL_LIVEAPI)
        return REMOTEAPI_NOTPROCESSED;

    NSDictionary *json = [liveAPI GetTrackablesByTrackingNumber:code downloadInfoItem:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackableFind", REMOTEAPI_TRACKABLES_FINDFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];

    NSArray *refs = nil;
    NSString *ref = nil;
    DICT_ARRAY_PATH(json, refs, @"Trackables.Code");
    if ([refs count] != 0)
        ref = [refs objectAtIndex:0];
    if (ref == nil)
        return REMOTEAPI_OK;

    *t = [dbTrackable dbGetByRef:ref];
    if ([(*t).code isEqualToString:@""] == YES ) {
        (*t).code = code;
        [*t dbUpdate];
    }
    return REMOTEAPI_OK;
}

@end
