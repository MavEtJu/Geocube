/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface RemoteAPIOKAPI ()

@end

@implementation RemoteAPIOKAPI

- (BOOL)commentSupportsFavouritePoint
{
    return NO;
}
- (BOOL)commentSupportsPhotos
{
    return NO;
}
- (BOOL)commentSupportsRating
{
    return NO;
}
- (BOOL)commentSupportsTrackables
{
    return NO;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return NO;
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

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
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

    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];
    GCDictionaryOKAPI *dict = [okapi services_users_byUsername:username infoViewer:iv ivi:ivi];
    OKAPI_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
    [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
    [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
    [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    GCDictionaryOKAPI *json = [okapi services_logs_submit:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite infoViewer:iv ivi:ivi];
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

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];

    GCDictionaryOKAPI *json = [okapi services_caches_geocache:waypoint.wpt_name infoViewer:iv ivi:ivi];
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

- (RemoteAPIResult)loadWaypointsByCenter:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;

    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:@"[OKAPI] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:ivi total:0];
    [iv setChunksCount:ivi count:1];
    NSInteger offset = 0;
    BOOL more = NO;
    NSMutableArray *wpcodes = [NSMutableArray arrayWithCapacity:20];
    do {
        GCDictionaryOKAPI *json = [okapi services_caches_search_nearest:center offset:offset infoViewer:iv ivi:ivi];
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
    GCDictionaryOKAPI *json = [okapi services_caches_geocaches:wpcodes infoViewer:iv ivi:ivi];
    OKAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *wpjson = [json objectForKey:wpcode];
        if (wpjson != nil)
            [wps addObject:wpjson];
    }];

    InfoItemID iii = [iv addImport:NO];
    [iv showTrackables:iii yesno:NO];
    [iv setDescription:iii description:@"OKAPI JSON data (queued)"];
    GCDictionaryOKAPI *rv = [[GCDictionaryOKAPI alloc] initWithDictionary:[NSDictionary dictionaryWithObject:wps forKey:@"waypoints"]];
    [callback remoteAPI_objectReadyToImport:iv ivi:ivi object:rv group:group account:self.account];
    *retObject = rv;

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb retObj:(NSObject **)retObj infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi callback:(id<RemoteAPILoadWaypointsByBoundingBoxDelegate>)callback
{
    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:@"[OKAPI] loadWaypointsByBoundingBox: remote API is disabled" error:REMOTEAPI_APIDISABLED];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:ivi total:2];
    [iv setChunksCount:ivi count:1];

    GCDictionaryOKAPI *json = [okapi services_caches_search_bbox:bb infoViewer:iv ivi:ivi];
    OKAPI_CHECK_STATUS(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    OKAPI_GET_VALUE(json, NSArray, wpcodes, @"results", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
    if ([wpcodes count] == 0)
        return REMOTEAPI_OK;

    [iv setChunksCount:ivi count:2];
    json = [okapi services_caches_geocaches:wpcodes infoViewer:iv ivi:ivi];
    OKAPI_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];

    GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];
    [callback remoteAPI_loadWaypointsByBoundingBox_returned:iv ivi:ivi object:d2 account:self.account];

    [waypointManager needsRefreshAll];
    return REMOTEAPI_OK;
}

@end
