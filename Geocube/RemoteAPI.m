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

    RemoteAPI_LiveAPI *liveAPI;
    RemoteAPI_OKAPI *okapi;
    RemoteAPI_GCA *gca;
    ProtocolTemplate *protocol;

    dbAccount *account;

    NSInteger stats_found, stats_notfound;
    id authenticationDelegate;

    NSString *clientMsg;
    NSError *clientError;

    NSInteger loadWaypointsLogs, loadWaypointsWaypoints;

    NSString *errorDomain;
}

@end

@implementation RemoteAPI

@synthesize account, oabb, authenticationDelegate, delegateLoadWaypoints;
@synthesize stats_found, stats_notfound;
@synthesize error, errorMsg, errorCode;

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
    switch (account.protocol) {
        case ProtocolLiveAPI:
            liveAPI = [[RemoteAPI_LiveAPI alloc] init:self];
            liveAPI.delegate = self;
            protocol = liveAPI;
            break;
        case ProtocolOKAPI:
            okapi = [[RemoteAPI_OKAPI alloc] init:self];
            okapi.delegate = self;
            protocol = okapi;
            break;
        case ProtocolGCA:
            gca = [[RemoteAPI_GCA alloc] init:self];
            gca.delegate = self;
            protocol = gca;
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

        [browserViewController showBrowser];
        [browserViewController prepare_oauth:oabb];
        [browserViewController loadURL:url];
        return YES;
    }

    if (account.protocol == ProtocolGCA) {
        // Load http://geocaching.com.au/login/?jump=/geocube and wait for the redirect to /geocube.
        NSString *url = account.gca_authenticate_url;

        gca.delegate = self;

        [browserViewController showBrowser];
        [browserViewController prepare_gca:gca];
        [browserViewController loadURL:url];
        return YES;
    }

    return NO;
}

- (void)GCAAuthSuccessful:(NSHTTPCookie *)cookie
{
    account.gca_cookie_value = [MyTools urlDecode:cookie.value];
    [account dbUpdateCookieValue];

    [browserViewController prepare_gca:nil];
    [browserViewController clearScreen];

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

- (void)alertError:(NSString *)msg code:(NSInteger)code
{
    clientMsg = msg;
    clientError = [NSError errorWithDomain:errorDomain code:code userInfo:nil];
}

- (void)getNumber:(NSDictionary *)out from:(NSDictionary *)in outKey:(NSString *)outKey inKey:(NSString *)inKey
{
    NSObject *o = [in objectForKey:inKey];
    if (o != nil) {
        NSNumber *n = [NSNumber numberWithInteger:[[in valueForKey:inKey] integerValue]];
        [out setValue:n forKey:outKey];
    }
}

- (NSInteger)UserStatistics:(NSDictionary **)retDict
{
    return [self UserStatistics:account.accountname_string retDict:retDict];
}

- (NSInteger)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict
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
        GCDictionaryOKAPI *dict = [okapi services_users_byUsername:username];

        if (dict == nil)
            return REMOTEAPI_APIFAILED;

        [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
        [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
        [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
        [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *dict1 = [liveAPI GetYourUserProfile];
        NSDictionary *dict2 = [liveAPI GetCacheIdsFavoritedByUser];

        if (dict1 == nil && dict2 == nil)
            return REMOTEAPI_APIFAILED;

        NSDictionary *d = [dict1 objectForKey:@"Profile"];
        d = [d objectForKey:@"User"];
        [self getNumber:ret from:d outKey:@"waypoints_hidden" inKey:@"HideCount"];
        [self getNumber:ret from:d outKey:@"waypoints_found" inKey:@"FindCount"];

        d = [dict2 objectForKey:@"CacheCodes"];
        if (d != nil) {
            NSNumber *n = [NSNumber numberWithUnsignedInteger:[d count]];
            [ret setValue:n forKey:@"recommendations_given"];
        }

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolGCA) {
        NSDictionary *dict1 = [gca cacher_statistic__finds:username];
        NSDictionary *dict2 = [gca cacher_statistic__hides:username];

        if ([dict1 count] == 0 && [dict2 count] == 0)
            return REMOTEAPI_APIFAILED;

        [self getNumber:ret from:dict1 outKey:@"waypoints_found" inKey:@"waypoints_found"];
        [self getNumber:ret from:dict2 outKey:@"waypoints_hidden" inKey:@"waypoints_hidden"];
        [self getNumber:ret from:dict2 outKey:@"recommendatons_received" inKey:@"recommendatons_received"];
        [self getNumber:ret from:dict2 outKey:@"recommendations_given" inKey:@"recommendations_given"];

        *retDict = ret;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [MyTools ImagesDir], image.datafile]];

    if (account.protocol == ProtocolLiveAPI) {
        GCDictionaryLiveAPI *json = [liveAPI CreateFieldNoteAndPublish:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite imageCaption:imageCaption imageDescription:imageDescription imageData:imgdata imageFilename:image.datafile];
        if (json == nil) {
            [self alertError:@"[LiveAPI] CreateLogNote/CreateFieldNoteAndPublish - json = nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [json valueForKeyPath:@"Status.StatusCode"];
        if (num == nil) {
            [self alertError:@"[LiveAPI] CreateLogNote/CreateFieldNoteAndPublish - num = nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 0) {
                NSLog(@"Return message for CreateFieldNoteAndPublish: %@", [json valueForKeyPath:@"Status.ExceptionDetails"]);
            [self alertError:@"[LiveAPI] CreateLogNote/CreateFieldNoteAndPublish - num = nil" code:REMOTEAPI_CREATELOG_LOGFAILED];
            return REMOTEAPI_CREATELOG_LOGFAILED;
        }
        [trackables enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
            if (tb.logtype == TRACKABLE_LOG_NONE)
                return;
            NSInteger dflt = 0;
            NSString *note = nil;
            switch (tb.logtype) {
                case TRACKABLE_LOG_VISIT:
                    dflt = LOGSTRING_DEFAULT_VISIT;
                    note = [NSString stringWithFormat:@"Visited '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    break;
                case TRACKABLE_LOG_DROPOFF:
                    dflt = LOGSTRING_DEFAULT_DROPOFF;
                    note = [NSString stringWithFormat:@"Dropped off at '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    break;
                case TRACKABLE_LOG_PICKUP:
                    dflt = LOGSTRING_DEFAULT_PICKUP;
                    note = [NSString stringWithFormat:@"Picked up from '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    break;
                case TRACKABLE_LOG_DISCOVER:
                    dflt = LOGSTRING_DEFAULT_DISCOVER;
                    note = [NSString stringWithFormat:@"Discovered in '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                    break;
                default:
                    NSAssert(NO, @"Unknown tb.logtype");
            }
            dbLogString *ls = [dbLogString dbGetByAccountLogtypeDefault:account logtype:LOGSTRING_LOGTYPE_TRACKABLEWAYPOINT default:dflt];
            [liveAPI CreateTrackableLog:waypoint logtype:ls.type trackable:tb note:note dateLogged:dateLogged];
        }];
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolOKAPI) {
        return [okapi services_logs_submit:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite];
    }

    if (account.protocol == ProtocolGCA) {
        GCDictionaryGCA *json = [gca my_log_new:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note rating:rating];

        if (json == nil) {
            [self alertError:@"[GCA] my_log_new/log: json == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [json objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] my_log_new/log: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] my_log_new/log: num != 1" code:REMOTEAPI_CREATELOG_LOGFAILED];
            return REMOTEAPI_CREATELOG_LOGFAILED;
        }

        NSInteger log_id = [[json objectForKey:@"log"] integerValue];
        if (log_id == 0) {
            [self alertError:@"[GCA] my_log_new/log: log_id == 0" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_CREATELOG_LOGFAILED;
        }

        if (image != nil) {
            json = [gca my_gallery_cache_add:waypoint.wpt_name log_id:log_id data:imgdata caption:imageCaption description:imageDescription];
            if (json == nil) {
                [self alertError:@"[GCA] my_log_new/image: json == nil" code:REMOTEAPI_APIFAILED];
                return REMOTEAPI_APIFAILED;
            }
            NSNumber *num = [json objectForKey:@"actionstatus"];
            if (num == nil) {
                [self alertError:@"[GCA] my_log_new/image: num == nil" code:REMOTEAPI_APIFAILED];
                return REMOTEAPI_APIFAILED;
            }
            if ([num integerValue] != 1) {
                NSLog(@"Return message for my_gallery_cache_add: %@", [json objectForKey:@"msg"]);
                [self alertError:@"[GCA] my_log_new/image: num != 1" code:REMOTEAPI_CREATELOG_IMAGEFAILED];
                return REMOTEAPI_CREATELOG_IMAGEFAILED;
            }
        }

        return REMOTEAPI_OK;
    }

    [self alertError:@"[GCA] my_log_new: Unknown protocol" code:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)loadWaypoint:(dbWaypoint *)waypoint
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [liveAPI SearchForGeocaches_waypointname:waypoint.wpt_name];
        if (json == nil)
            return REMOTEAPI_APIFAILED;

        ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:g account:a];
        [imp parseDictionary:json];

        [waypointManager needsRefresh];
        return REMOTEAPI_OK;
    }
    if (account.protocol == ProtocolOKAPI) {
        NSString *gpx = [okapi services_caches_formatters_gpx:waypoint.wpt_name];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseString:gpx];
        [imp parseAfter];

        [waypointManager needsRefresh];
        return REMOTEAPI_OK;
    }
    if (account.protocol == ProtocolGCA) {
        GCDictionaryGCA *json = [gca cache__json:waypoint.wpt_name];
        if (json == nil) {
            [self alertError:@"[GCA] loadWaypoint/cache__json: json == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [json objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] loadWaypoint/cache__json: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] loadWaypoint/cache__json: num != 1" code:REMOTEAPI_LOADWAYPOINT_LOADFAILED];
            NSLog(@"Return message for cache__json: %@", [json objectForKey:@"msg"]);
            return REMOTEAPI_LOADWAYPOINT_LOADFAILED;
        }

        ImportGCAJSON *imp = [[ImportGCAJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        json = [gca logs_cache:waypoint.wpt_name];
        if (json == nil) {
            [self alertError:@"[GCA] loadWaypoint/logs_cache: json == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        num = [json objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] loadWaypoint/logs_cache: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] loadWaypoint/logs_cache: num != 1" code:REMOTEAPI_LOADWAYPOINT_LOADFAILED];
            NSLog(@"Return message for logs_cache: %@", [json objectForKey:@"msg"]);
            return REMOTEAPI_LOADWAYPOINT_LOADFAILED;
        }
        imp = [[ImportGCAJSON alloc] init:g account:a];
        [imp parseBefore];
        [imp parseDictionary:json];
        [imp parseAfter];

        /*
        NSString *gpx = [gca cache__gpx:waypoint.wpt_name];

        ImportGPX *imp = [[ImportGPX alloc] init:g account:a];
        [imp parseBefore];
        [imp parseString:[gpx description]];
        [imp parseAfter];
         */

        [waypointManager needsRefresh];
        return REMOTEAPI_OK;
    }

    [self alertError:@"[GCA] logs_cache: Unknown protocol" code:REMOTEAPI_NOTPROCESSED];
    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;
//    [delegateLoadWaypoints remoteAPILoadWaypointsImportWaypointsTotal:0];

    if (account.protocol == ProtocolGCA) {
        if ([account canDoRemoteStuff] == NO) {
            [self alertError:@"[GCA] loadWaypoints: remote API is disabled" code:REMOTEAPI_APIDISABLED];
            return REMOTEAPI_APIDISABLED;
        }

        GCDictionaryGCA *wps = [gca caches_gca:center];
        if (wps == nil) {
            [self alertError:@"[GCA] caches_gca: wps == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [wps objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] caches_gca: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] caches_gca: num != 1" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_LOADWAYPOINTS_LOADFAILED;
        }

        NSMutableArray *logs = [NSMutableArray arrayWithCapacity:50];

        NSArray *ws = [wps objectForKey:@"geocaches"];
        [ws enumerateObjectsUsingBlock:^(NSDictionary *wp, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *wpname = [wp objectForKey:@"waypoint"];
            NSDictionary *ls = [gca logs_cache:wpname];
            NSArray *lss = [ls objectForKey:@"logs"];
            [lss enumerateObjectsUsingBlock:^(NSDictionary *l, NSUInteger idx, BOOL * _Nonnull stop) {
                [logs addObject:l];
            }];
        }];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
        [d setObject:wps forKey:@"geocaches1"];
        [d setObject:logs forKey:@"logs"];
        GCDictionaryGCA *gcajson = [[GCDictionaryGCA alloc] initWithDictionary:d];
        *retObject = gcajson;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolLiveAPI) {
        if ([account canDoRemoteStuff] == NO)
            return REMOTEAPI_APIDISABLED;

        NSMutableArray *wps = [NSMutableArray arrayWithCapacity:200];
        NSDictionary *json = [liveAPI SearchForGeocaches_pointradius:center];
        if (json == nil)
            return REMOTEAPI_APIFAILED;

        NSInteger total = [[json objectForKey:@"TotalMatchingCaches"] integerValue];
        NSInteger done = 0;
        if (total != 0) {
            [wps addObjectsFromArray:[json objectForKey:@"Geocaches"]];
            do {
                done += 20;
                json = [liveAPI GetMoreGeocaches:done];
                if ([json objectForKey:@"Geocaches"] != nil)
                    [wps addObjectsFromArray:[json objectForKey:@"Geocaches"]];
            } while (done < total);
        }

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
        [d setObject:wps forKey:@"Geocaches"];
        GCDictionaryLiveAPI *livejson = [[GCDictionaryLiveAPI alloc] initWithDictionary:d];
        *retObject = livejson;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolOKAPI) {
        if ([account canDoRemoteStuff] == NO)
            return REMOTEAPI_APIDISABLED;

        NSInteger offset = 0;
        BOOL more = NO;
        NSMutableArray *wpcodes = [NSMutableArray arrayWithCapacity:20];
        do {
            NSDictionary *json = [okapi services_caches_search_nearest:center offset:offset];
            if (json == nil)
                return REMOTEAPI_APIFAILED;
            more = [[json objectForKey:@"more"] boolValue];
            NSArray *rets = nil;
            NSObject *vs = [json objectForKey:@"results"];
            if ([vs isKindOfClass:[NSString class]] == YES)
                rets = @[rets];
            else if ([vs isKindOfClass:[NSArray class]] == YES)
                rets = (NSArray *)vs;
            [rets enumerateObjectsUsingBlock:^(NSString *v, NSUInteger idx, BOOL * _Nonnull stop) {
                [wpcodes addObject:v];
            }];
            offset += [rets count];
        } while (more == YES);

        if ([wpcodes count] == 0)
            return REMOTEAPI_OK;
        NSDictionary *json = [okapi services_caches_geocaches:wpcodes];
        if (json == nil)
            return REMOTEAPI_APIFAILED;

        NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:[wpcodes count]];
        [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *wpjson = [json objectForKey:wpcode];
            if (wpjson != nil)
                [wps addObject:wpjson];
        }];

        GCDictionaryOKAPI *rv = [[GCDictionaryOKAPI alloc] initWithDictionary:[NSDictionary dictionaryWithObject:wps forKey:@"waypoints"]];
        *retObject = rv;

        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)updatePersonalNote:(dbPersonalNote *)note
{
    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [liveAPI UpdateCacheNote:note.wp_name text:note.note];
        if (json == nil)
            return REMOTEAPI_APIFAILED;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)listQueries:(NSArray **)qs
/* Returns: array of dicts of
 * - Name
 * - Id
 * - DateTime
 * - Size
 * - Count
 */
{
    *qs = nil;
    if (account.protocol == ProtocolLiveAPI) {
        NSDictionary *json = [liveAPI GetPocketQueryList];
        if (json == nil)
            return REMOTEAPI_APIFAILED;

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];

        NSArray *pqs = [json objectForKey:@"PocketQueryList"];
        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"Name"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"GUID"] forKey:@"Id"];
            [d setValue:[NSNumber numberWithInteger:[MyTools secondsSinceEpochWindows:[pq objectForKey:@"DateLastGenerated"]]] forKey:@"DateTime"];
            [d setValue:[pq objectForKey:@"FileSizeInBytes"] forKey:@"Size"];
            [d setValue:[pq objectForKey:@"PQCount"] forKey:@"Count"];

            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolGCA) {
        /*
        NSArray *as = [gca my_query];
        if (as == nil || [as count] == 0)
            return nil;
        return as;
         */

        NSDictionary *json = [gca my_query_list__json];
        if (json == nil) {
            [self alertError:@"[GCA] ListQueries: json == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [json objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] ListQueries: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] ListQueries: num != 1" code:REMOTEAPI_LISTQUERIES_LOADFAILED];
            return REMOTEAPI_LISTQUERIES_LOADFAILED;
        }

        NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
        NSArray *pqs = [json objectForKey:@"queries"];
        [pqs enumerateObjectsUsingBlock:^(NSDictionary *pq, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

            [d setValue:[pq objectForKey:@"description"] forKey:@"Name"];
            [d setValue:[pq objectForKey:@"queryid"] forKey:@"Id"];
            [d setValue:[NSNumber numberWithInteger:[gca my_query_count:[pq objectForKey:@"queryid"]]] forKey:@"Count"];

            [as addObject:d];
        }];

        *qs = as;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj
{
    *retObj = nil;

    if (account.protocol == ProtocolLiveAPI) {
        NSMutableDictionary *result = nil;
        NSMutableArray *geocaches = [NSMutableArray arrayWithCapacity:1000];

        NSInteger max = 0;
        NSInteger tried = 0;
        NSInteger offset = 0;
        NSInteger increase = 25;

        [downloadManager resetForegroundDownload];
        [downloadManager setDescription:@"Download pocket query"];

        [self.delegateQueries remoteAPIQueriesDownloadUpdate:0 max:0];
        [downloadManager setNumberOfChunksDownload:1];
        [downloadManager setNumberOfChunksTotal:1];
        do {
            NSLog(@"offset:%ld - max: %ld", (long)offset, (long)max);
            NSDictionary *json = [liveAPI GetFullPocketQueryData:_id startItem:offset numItems:increase];
            if (json == nil)
                break;

            NSInteger found = 0;
            if (json != nil) {
                if (result == nil)
                    result = [NSMutableDictionary dictionaryWithDictionary:json];
                [geocaches addObjectsFromArray:[json objectForKey:@"Geocaches"]];
                found += [[json objectForKey:@"Geocaches"] count];
            }

            offset += found;
            tried += increase;
            max = [[json objectForKey:@"PQCount"] integerValue];
            [self.delegateQueries remoteAPIQueriesDownloadUpdate:offset max:max];
            [downloadManager setNumberOfChunksDownload:offset / increase];
            [downloadManager setNumberOfChunksTotal:max / increase];
        } while (tried < max);

        [result setObject:geocaches forKey:@"Geocaches"];

        *retObj = result;
        return REMOTEAPI_OK;
    }

    if (account.protocol == ProtocolGCA) {
        NSDictionary *json = [gca my_query_json:_id];
        if (json == nil) {
            [self alertError:@"[GCA] retrieveQuery: json == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        NSNumber *num = [json objectForKey:@"actionstatus"];
        if (num == nil) {
            [self alertError:@"[GCA] retrieveQuery: num == nil" code:REMOTEAPI_APIFAILED];
            return REMOTEAPI_APIFAILED;
        }
        if ([num integerValue] != 1) {
            [self alertError:@"[GCA] retrieveQuery: num != 1" code:REMOTEAPI_LISTQUERIES_LOADFAILED];
            return REMOTEAPI_LISTQUERIES_LOADFAILED;
        }

        *retObj = json;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (NSInteger)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj
{
    *retObj = nil;
    if (account.protocol == ProtocolGCA) {
        NSString *gpx = [gca my_query_gpx:_id];
        if (gpx == nil) {
            return REMOTEAPI_APIFAILED;
        }
        *retObj = gpx;
        return REMOTEAPI_OK;
    }

    return REMOTEAPI_NOTPROCESSED;
}

- (void)trackablesMine
{
    if (account.protocol != ProtocolLiveAPI)
        return;

    NSDictionary *json = [liveAPI GetOwnedTrackables];
    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];
}

- (void)trackablesInventory
{
    if (account.protocol != ProtocolLiveAPI)
        return;

    NSDictionary *json = [liveAPI GetUsersTrackables];
    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];
}

- (dbTrackable *)trackableFind:(NSString *)code
{
    if (account.protocol != ProtocolLiveAPI)
        return nil;

    NSDictionary *json = [liveAPI GetTrackablesByTrackingNumber:code];
    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:account];
    [imp parseDictionary:json];

    NSArray *refs = nil;
    NSString *ref = nil;
    DICT_ARRAY_PATH(json, refs, @"Trackables.Code");
    if ([refs count] != 0)
        ref = [refs objectAtIndex:0];
    if (ref == nil)
        return nil;

    dbTrackable *tb = [dbTrackable dbGetByRef:ref];
    if ([tb.code isEqualToString:@""] == YES ) {
        tb.code = code;
        [tb dbUpdate];
    }
    return tb;
}

@end
