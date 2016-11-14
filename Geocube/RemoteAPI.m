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
    RemoteAPI_GGCW *ggcw;
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
    ggcw = nil;
    ProtocolId pid = account.protocol_id;
    switch (pid) {
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
        case PROTOCOL_GGCW:
            ggcw = [[RemoteAPI_GGCW alloc] init:self];
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
            if (status == nil) \
                if ([__json__ objectForKey:@"StatusCode"] != nil) \
                    status = [__json__ _dict]; \
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

#define GGCW_CHECK_STATUS(__json__, __logsection__, __failure__) { \
        }

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
    [self clearErrors];

    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setValue:@"" forKey:@"waypoints_found"];
    [ret setValue:@"" forKey:@"waypoints_notfound"];
    [ret setValue:@"" forKey:@"waypoints_hidden"];
    [ret setValue:@"" forKey:@"recommendations_given"];
    [ret setValue:@"" forKey:@"recommendations_received"];

    if (account.protocol_id == PROTOCOL_OKAPI) {
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

    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];
        GCDictionaryLiveAPI *dict1 = [liveAPI GetYourUserProfile:iid];
        LIVEAPI_CHECK_STATUS(dict1, @"UserStatistics/profile", REMOTEAPI_USERSTATISTICS_LOADFAILED);
        [iid setChunksCount:2];
        GCDictionaryLiveAPI *dict2 = [liveAPI GetCacheIdsFavoritedByUser:iid];
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

    if (account.protocol_id == PROTOCOL_GCA) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        GCDictionaryGCA *dict1 = [gca cacher_statistic__finds:username downloadInfoItem:iid];
        [iid setChunksCount:2];
        GCDictionaryGCA *dict2 = [gca cacher_statistic__hides:username downloadInfoItem:iid];

        if ([dict1 count] == 0 && [dict2 count] == 0)
            return [self lastErrorCode];

        [self getNumber:ret from:dict1 outKey:@"waypoints_found" inKey:@"waypoints_found"];
        [self getNumber:ret from:dict2 outKey:@"waypoints_hidden" inKey:@"waypoints_hidden"];
        [self getNumber:ret from:dict2 outKey:@"recommendatons_received" inKey:@"recommendatons_received"];
        [self getNumber:ret from:dict2 outKey:@"recommendations_given" inKey:@"recommendations_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGCA2 *dict = [gca2 api_services_users_by__username:username downloadInfoItem:iid];
        GCA2_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
        [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
        [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGGCW *dict = [ggcw my_default:iid];
        GGCW_CHECK_STATUS(dict, @"my_defaults", REMOTEAPI_USERSTATISTICS_LOADFAILED);

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDownload *)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    if (account.protocol_id == PROTOCOL_LIVEAPI) {
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
            dbLogString *ls = [dbLogString dbGetByProtocolLogtypeDefault:account.protocol logtype:logtype default:dflt];
            [liveAPI CreateTrackableLog:waypoint logtype:ls.type trackable:tb note:note dateLogged:dateLogged downloadInfoItem:iid];
        }];
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_OKAPI) {
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

    if (account.protocol_id == PROTOCOL_GCA) {
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

    if (account.protocol_id == PROTOCOL_GCA2) {
        NSMutableString *n = [NSMutableString stringWithString:note];
        if (rating != 0)
            [n appendFormat:@"\n*Overall Experience: %ld*\n", (long)rating];
        if (favourite == YES)
            [n appendFormat:@"\n*Recommended*\n"];
        GCDictionaryGCA2 *json = [gca2 api_services_logs_submit:waypoint logtype:logstring.type comment:n when:dateLogged rating:rating recommended:favourite downloadInfoItem:iid];
        GCA2_CHECK_STATUS(json, @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);

        GCA2_GET_VALUE(json, NSDictionary, data, @"data", @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);
        GCA2_GET_VALUE(data, NSNumber, logid, @"log_uuid", @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);

        if (image != nil) {
            json = [gca2 api_services_logs_images_add:logid data:imgdata caption:imageCaption description:imageDescription downloadInfoItem:iid];
            GCA2_CHECK_STATUS(json, @"CreateLogNote/image", REMOTEAPI_CREATELOG_IMAGEFAILED);
        }

        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {

        NSMutableDictionary *tbs = [NSMutableDictionary dictionaryWithCapacity:[trackables count]];
        [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tb.logtype == TRACKABLE_LOG_NONE)
                return;
            NSString *note = nil;
            switch (tb.logtype) {
                case TRACKABLE_LOG_VISIT:
                    note = @"Visited";
                    break;
                case TRACKABLE_LOG_DROPOFF:
                    note = @"DroppedOff";
                    break;
                default:
                    note = nil;
                    break;
            }
            if (note == nil)
                return;
            [tbs setObject:note forKey:[NSNumber numberWithInteger:tb.gc_id]];
        }];

        NSDictionary *dict = [ggcw geocache:waypoint.wpt_name downloadInfoItem:iid];
        NSString *gc_id = [dict objectForKey:@"gc_id"];
        dict = [ggcw seek_log__form:gc_id downloadInfoItem:iid];
        [ggcw seek_log__submit:gc_id dict:dict logstring:logstring.type dateLogged:dateLogged note:note favpoint:favourite trackables:tbs downloadInfoItem:iid];

        return REMOTEAPI_OK;
    }

    [self setDataError:@"[RemoteAPI] CreateLogNote: Unknown protocol" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDownload *)iid
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_waypointname:waypoint.wpt_name downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:g account:a];
        [imp parseDictionary:json];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_OKAPI) {
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

    if (account.protocol_id == PROTOCOL_GCA) {
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

    if (account.protocol_id == PROTOCOL_GCA2) {
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

    if (account.protocol_id == PROTOCOL_GGCW) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCStringGPX *gpx = [ggcw geocache_gpx:waypoint.wpt_name downloadInfoItem:iid];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseGPX:gpx];
        [imp parseAfter];

        [waypointManager needsRefreshUpdate:waypoint];
        return REMOTEAPI_OK;
    }

    [self setDataError:@"[RemoteAPI] loadWaypoint: Unknown protocol" error:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;

    if (account.protocol_id == PROTOCOL_GCA) {
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
            GCDictionaryGCA *ls = [gca logs_cache:wpname downloadInfoItem:iid];
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

    if (account.protocol_id == PROTOCOL_GCA2) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[GCA2] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        GCDictionaryGCA2 *json = [gca2 api_services_caches_search_nearest:center downloadInfoItem:iid];
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

    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[LiveAPI] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:1];
        [iid setChunksCount:1];
        NSMutableArray *wps = [NSMutableArray arrayWithCapacity:200];
        GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_pointradius:center downloadInfoItem:iid];
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

    if (account.protocol_id == PROTOCOL_OKAPI) {
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
            GCDictionaryOKAPI *json = [okapi services_caches_search_nearest:center offset:offset downloadInfoItem:iid];
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
        GCDictionaryOKAPI *json = [okapi services_caches_geocaches:wpcodes downloadInfoItem:iid];
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

    if (account.protocol_id == PROTOCOL_GGCW) {
        if (account.ggcw_username == nil) {
            GCDictionaryGGCW *d = [ggcw map:iid];
            account.ggcw_username = [d objectForKey:@"usersession.username"];
            account.ggcw_sessiontoken = [d objectForKey:@"usersession.sessionToken"];
        }

        CLLocationCoordinate2D ct = [Coordinates location:center bearing:0 * M_PI/2 distance:configManager.mapSearchMaximumDistanceGS];
        CLLocationCoordinate2D cr = [Coordinates location:center bearing:1 * M_PI/2 distance:configManager.mapSearchMaximumDistanceGS];
        CLLocationCoordinate2D cb = [Coordinates location:center bearing:2 * M_PI/2 distance:configManager.mapSearchMaximumDistanceGS];
        CLLocationCoordinate2D cl = [Coordinates location:center bearing:3 * M_PI/2 distance:configManager.mapSearchMaximumDistanceGS];

#define ZOOM    14
        NSInteger xmin = [Coordinates longitudeToTile:cl.longitude zoom:ZOOM];
        NSInteger ymax = [Coordinates latitudeToTile:cb.latitude zoom:ZOOM];
        NSInteger xmax = [Coordinates longitudeToTile:cr.longitude zoom:ZOOM];
        NSInteger ymin = [Coordinates latitudeToTile:ct.latitude zoom:ZOOM];

        /*
        // cx is the number of degrees in a single pixel of the 64 parts of a map tile.
        CLLocationCoordinate2D cdiff = CLLocationCoordinate2DMake(
                                       (ct.latitude - cb.latitude) / ((ymax - ymin + 1) * 64),
                                       (cr.longitude - cl.longitude) / ((xmax - xmin + 1) * 64)
                                                               );
         */

        InfoViewer *infoViewer = iid.infoViewer;
        [infoViewer removeItem:iid];

        NSMutableDictionary *wpcodesall = [NSMutableDictionary dictionaryWithCapacity:100];
        [iid setChunksTotal:(ymax - ymin + 1) * (xmax - xmin + 1)];
        for (NSInteger y = ymin; y <= ymax; y++) {
            for (NSInteger x = xmin; x <= xmax; x++) {
                NSMutableDictionary *wpcodes = [NSMutableDictionary dictionaryWithCapacity:100];

                iid = [infoViewer addDownload];
                [iid setDescription:[NSString stringWithFormat:@"Tile (%ld, %ld)", x, y]];
                [iid setChunksTotal:0];
                [iid setChunksCount:1];
                [iid resetBytes];
                GCDictionaryGGCW *d = [ggcw map_info:x y:y z:ZOOM downloadInfoItem:iid];

                NSDictionary *alldata = [d objectForKey:@"data"];
                [alldata enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *wps, BOOL *stop) {
                    NSDictionary *wpdata = [wps objectAtIndex:0];
                    // Don't look at the same object twice
                    NSString *wpdatai = [wpdata objectForKey:@"i"];
                    if ([wpcodesall objectForKey:wpdatai] != nil)
                        return;

                    [wpcodes setObject:wpdata forKey:wpdatai];
                    [wpcodesall setObject:@"0" forKey:wpdatai];
                }];

                [wpcodes setObject:group forKey:@"group"];
                [wpcodes setObject:iid forKey:@"iid"];
                [wpcodes setObject:callback forKey:@"callback"];
                [self performSelectorInBackground:@selector(loadWaypoints_GGCWBackground:) withObject:wpcodes];

            }
        }

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (void)loadWaypoints_GGCWBackground:(NSMutableDictionary *)wpcodes
{
    id<RemoteAPIRetrieveQueryDelegate> callback = [wpcodes objectForKey:@"callback"];
    InfoItemDownload *iid = [wpcodes objectForKey:@"iid"];
    dbGroup *group = [wpcodes objectForKey:@"group"];
    [wpcodes removeObjectForKey:@"iid"];
    [wpcodes removeObjectForKey:@"callback"];
    [wpcodes removeObjectForKey:@"group"];

    GCMutableArray *gpxarray = [[GCMutableArray alloc] initWithCapacity:[wpcodes count]];

    InfoViewer *iv = iid.infoViewer;
    [iid setChunksTotal:[wpcodes count]];
    [[wpcodes allKeys] enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
        [iid setChunksCount:idx + 1];
        [iid resetBytes];

        GCDictionaryGGCW *d = [ggcw map_details:wpcode downloadInfoItem:iid];
        if (d == nil)
            return;
        NSArray *data = [d objectForKey:@"data"];
        NSDictionary *dict = [data objectAtIndex:0];

        GCStringGPXGarmin *gpx = [ggcw seek_sendtogps:[dict objectForKey:@"g"] downloadInfoItem:iid];
        if (gpx == nil)
            return;

        [gpxarray addObject:gpx];
    }];

    if ([gpxarray count] == 0) {
        [iv removeItem:iid];
        return;
    }

    InfoItemImport *iii = [iv addImport:NO];
    [iii setDescription:@"Geocaching.com GPX Garmin data (queued)"];
    [callback remoteAPI_objectReadyToImport:iii object:gpxarray group:group account:account];

    [iv removeItem:iid];
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray *)wpcodes retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    if (account.protocol_id == PROTOCOL_GCA2) {
        if ([account canDoRemoteStuff] == NO) {
            [self setAPIError:@"[GCA2] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGCA2 *json = [gca2 api_services_caches_geocaches:wpcodes downloadInfoItem:iid];
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

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(InfoItemDownload *)iid
{
    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        GCDictionaryLiveAPI *json = [liveAPI UpdateCacheNote:note.wp_name text:note.note downloadInfoItem:iid];
        LIVEAPI_CHECK_STATUS(json, @"updatePersonalNote", REMOTEAPI_PERSONALNOTE_UPDATEFAILED);
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        NSDictionary *gc = [ggcw geocache:note.wp_name downloadInfoItem:iid];
        GCDictionaryGGCW *json = [ggcw seek_cache__details_SetUserCacheNote:gc text:note.note downloadInfoItem:iid];
        NSNumber *success = [json objectForKey:@"success"];
        if ([success boolValue] == NO)
            return REMOTEAPI_PERSONALNOTE_UPDATEFAILED;

        return REMOTEAPI_OK;
    }

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

    *qs = nil;
    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        GCDictionaryLiveAPI *json = [liveAPI GetPocketQueryList:iid];
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

    if (account.protocol_id == PROTOCOL_GCA) {
        GCDictionaryGCA *json = [gca my_query_list__json:iid];
        GCA_CHECK_STATUS(json, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

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

    if (account.protocol_id == PROTOCOL_GCA2) {
        GCDictionaryGCA2 *json = [gca2 api_services_caches_query_list:iid];
        GCA2_CHECK_STATUS(json, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
        GCA2_GET_VALUE(json, NSArray, pqs, @"queries", @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"description"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"queryid"] forKey:@"Id"];

            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        GCDictionaryGGCW *dict = [ggcw pocket_default:iid];
        GGCW_CHECK_STATUS(dict, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
        [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *a, BOOL *stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
            [d setValue:[a objectForKey:@"name"] forKey:@"Name"];
            [d setValue:[a objectForKey:@"g"] forKey:@"Id"];
            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;

    if (account.protocol_id == PROTOCOL_LIVEAPI) {
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
            GCDictionaryLiveAPI *json = [liveAPI GetFullPocketQueryData:_id startItem:offset numItems:increase downloadInfoItem:iid];
            LIVEAPI_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

            NSInteger found = 0;
            if (result == nil)
                result = [NSMutableDictionary dictionaryWithDictionary:[json _dict]];

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

    if (account.protocol_id == PROTOCOL_GCA) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryGCA *json = [gca my_query_json:_id downloadInfoItem:iid];
        GCA_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:json group:group account:account];

        *retObj = json;
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GCA2) {
        [iid setChunksTotal:2];
        [iid setChunksCount:1];

        GCDictionaryGCA2 *json = [gca2 api_services_caches_query_geocaches:_id downloadInfoItem:iid];
        GCA2_CHECK_STATUS(json, @"retrieveQuery/query", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        GCA2_GET_VALUE(json, NSArray, wps, @"geocaches", @"retrieveQuery/query", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSMutableArray *wpcodes = [NSMutableArray arrayWithCapacity:[wps count]];
        [wps enumerateObjectsUsingBlock:^(NSDictionary *wp, NSUInteger idx, BOOL *stop) {
            [wpcodes addObject:[wp objectForKey:@"waypoint"]];
        }];

        [iid setChunksCount:2];

        json = [gca2 api_services_caches_geocaches:wpcodes downloadInfoItem:iid];
        GCA2_CHECK_STATUS(json, @"retrieveQuery/geocaches", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableArray *_wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
        [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
            [_wps addObject:[json objectForKey:wpcode]];
        }];
        [d setObject:_wps forKey:@"waypoints"];

        GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:d2 group:group account:account];

        *retObj = json;
        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDataZIPFile *zipfile = [ggcw pocket_downloadpq:_id downloadInfoItem:iid];
        GGCW_CHECK_STATUS(zipfile, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSString *filename = [NSString stringWithFormat:@"%@.zip", _id];
        [zipfile writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] atomically:YES];
        GCStringFilename *zipfilename = [[GCStringFilename alloc] initWithString:filename];

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:zipfilename group:group account:account];

        *retObj = zipfile;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;
    if (account.protocol_id == PROTOCOL_GCA || account.protocol_id == PROTOCOL_GCA2) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];
        GCStringGPX *gpx = nil;
        if (account.protocol_id == PROTOCOL_GCA)
            gpx = [gca my_query_gpx:_id downloadInfoItem:iid];
        if (gpx == nil)
            return REMOTEAPI_APIFAILED;

        InfoItemImport *iii = [infoViewer addImport];
        [callback remoteAPI_objectReadyToImport:iii object:gpx group:group account:account];

        *retObj = gpx;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesMine:(InfoItemDownload *)iid
{
    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryLiveAPI *json = [liveAPI GetOwnedTrackables:iid];
        LIVEAPI_CHECK_STATUS(json, @"trackablesMine", REMOTEAPI_TRACKABLES_OWNEDLOADFAILED);

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
        [imp parseDictionary:json];

        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        NSArray *tbs = [ggcw track_search:iid];
        NSMutableArray *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
        [iid resetBytesChunks];
        [iid setChunksTotal:[tbs count]];
        [tbs enumerateObjectsUsingBlock:^(NSDictionary *tb, NSUInteger idx, BOOL *sto) {
            [iid resetBytes];
            [iid setChunksCount:idx + 1];
            NSDictionary *d = [ggcw track_details:nil id:[tb objectForKey:@"id"] downloadInfoItem:iid];

            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
            [dict setObject:[d objectForKey:@"guid"] forKey:@"guid"];
            [dict setObject:[tb objectForKey:@"name"] forKey:@"name"];
            [dict setObject:[tb objectForKey:@"id"] forKey:@"id"];
            [dict setObject:[d objectForKey:@"gccode"] forKey:@"gccode"];
            [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
            if ([tb objectForKey:@"carrier"] != nil)
                [dict setObject:[tb objectForKey:@"carrier"] forKey:@"carrier"];
            if ([tb objectForKey:@"location"] != nil)
                [dict setObject:[tb objectForKey:@"location"] forKey:@"location"];
            [tbstot addObject:dict];
        }];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
        [d setObject:tbstot forKey:@"trackables"];

        GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:d];

        ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:account];
        [imp parseDictionary:dict];

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackablesInventory:(InfoItemDownload *)iid
{
    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        [iid setChunksTotal:1];
        [iid setChunksCount:1];

        GCDictionaryLiveAPI *json = [liveAPI GetUsersTrackables:iid];
        LIVEAPI_CHECK_STATUS(json, @"trackablesInventory", REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED);

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
        [imp parseDictionary:json];

        return REMOTEAPI_OK;
    }

    if (account.protocol_id == PROTOCOL_GGCW) {
        NSArray *tbs = [ggcw my_inventory:iid];
        NSMutableArray *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
        [iid resetBytesChunks];
        [iid setChunksTotal:[tbs count]];
        [tbs enumerateObjectsUsingBlock:^(NSDictionary *tb, NSUInteger idx, BOOL *sto) {
            [iid resetBytes];
            [iid setChunksCount:idx + 1];
            NSDictionary *d = [ggcw track_details:[tb objectForKey:@"guid"] id:nil downloadInfoItem:iid];

            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
            [dict setObject:[tb objectForKey:@"guid"] forKey:@"guid"];
            [dict setObject:[tb objectForKey:@"name"] forKey:@"name"];
            [dict setObject:[d objectForKey:@"id"] forKey:@"id"];
            [dict setObject:[d objectForKey:@"gccode"] forKey:@"gccode"];
            [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
            [dict setObject:[NSNumber numberWithInteger:account.accountname._id] forKey:@"carrier_id"];
            [tbstot addObject:dict];
        }];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
        [d setObject:tbstot forKey:@"trackables"];

        GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:d];

        ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:account];
        [imp parseDictionary:dict];

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t downloadInfoItem:(InfoItemDownload *)iid
{
    if (account.protocol_id == PROTOCOL_LIVEAPI) {
        GCDictionaryLiveAPI *json = [liveAPI GetTrackablesByTrackingNumber:code downloadInfoItem:iid];
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

    if (account.protocol_id == PROTOCOL_GGCW) {
        NSDictionary *d = [ggcw track_details:code downloadInfoItem:iid];

        NSMutableArray *tbs = [NSMutableArray arrayWithCapacity:1];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
        [dict setObject:[d objectForKey:@"guid"] forKey:@"guid"];
        [dict setObject:[d objectForKey:@"name"] forKey:@"name"];
        [dict setObject:[d objectForKey:@"id"] forKey:@"id"];
        [dict setObject:[d objectForKey:@"gccode"] forKey:@"gccode"];
        [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
        [dict setObject:[d objectForKey:@"code"] forKey:@"code"];
        [tbs addObject:dict];

        NSMutableDictionary *dd = [NSMutableDictionary dictionaryWithCapacity:1];
        [dd setObject:tbs forKey:@"trackables"];

        GCDictionaryGGCW *dictggcw = [[GCDictionaryGGCW alloc] initWithDictionary:dd];

        ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:account];
        [imp parseDictionary:dictggcw];

        *t = [dbTrackable dbGetByRef:[d objectForKey:@"gccode"]];
        if ([(*t).code isEqualToString:@""] == YES ) {
            (*t).code = code;
            [*t dbUpdate];
        }

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

@end
