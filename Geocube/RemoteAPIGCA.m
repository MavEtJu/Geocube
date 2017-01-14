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

@interface RemoteAPIGCA ()

@end

@implementation RemoteAPIGCA

- (BOOL)commentSupportsFavouritePoint
{
    return NO;
}
- (BOOL)commentSupportsPhotos
{
    return YES;
}
- (BOOL)commentSupportsRating
{
    return YES;
}
- (NSRange)commentSupportsRatingRange
{
    return NSMakeRange(1, 5);
}
- (BOOL)commentSupportsTrackables
{
    return NO;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return NO;
}

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

    [iv setChunksTotal:ivi total:2];
    [iv setChunksCount:ivi count:1];

    GCDictionaryGCA *dict1 = [gca cacher_statistic__finds:username infoViewer:iv ivi:ivi];
    [iv setChunksCount:ivi count:2];
    GCDictionaryGCA *dict2 = [gca cacher_statistic__hides:username infoViewer:iv ivi:ivi];

    if ([dict1 count] == 0 && [dict2 count] == 0)
        return [self lastErrorCode];

    [self getNumber:ret from:dict1 outKey:@"waypoints_found" inKey:@"waypoints_found"];
    [self getNumber:ret from:dict2 outKey:@"waypoints_hidden" inKey:@"waypoints_hidden"];
    [self getNumber:ret from:dict2 outKey:@"recommendatons_received" inKey:@"recommendatons_received"];
    [self getNumber:ret from:dict2 outKey:@"recommendations_given" inKey:@"recommendations_given"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    GCDictionaryGCA *json = [gca my_log_new:logstring.type waypointName:waypoint.wpt_name dateLogged:dateLogged note:note rating:rating infoViewer:iv ivi:ivi];
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
        json = [gca my_gallery_cache_add:waypoint.wpt_name log_id:log_id data:imgdata caption:imageCaption description:imageDescription infoViewer:iv ivi:ivi];
        GCA_CHECK_STATUS(json, @"CreateLogNote/image", REMOTEAPI_CREATELOG_IMAGEFAILED);
    }

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    [iv setChunksTotal:ivi total:2];
    [iv setChunksCount:ivi count:1];

    GCDictionaryGCA *json = [gca cache__json:waypoint.wpt_name infoViewer:iv ivi:ivi];
    GCA_CHECK_STATUS(json, @"loadWaypoint/cache__json", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    ImportGCAJSON *imp = [[ImportGCAJSON alloc] init:g account:a];
    [imp parseBefore];
    [imp parseDictionary:json];
    [imp parseAfter];

    [iv setChunksCount:ivi count:2];
    json = [gca logs_cache:waypoint.wpt_name infoViewer:iv ivi:ivi];
    GCA_CHECK_STATUS(json, @"loadWaypoint/logs_cache", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    imp = [[ImportGCAJSON alloc] init:g account:a];
    [imp parseBefore];
    [imp parseDictionary:json];
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
        [self setAPIError:@"[GCA] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];

    GCDictionaryGCA *wps = [gca caches_gca:center infoViewer:iv ivi:ivi];
    GCA_CHECK_STATUS(wps, @"caches_gca", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:@"Geocaching Australia JSON data (queued)"];
    [iv showLogs:iii yesno:NO];
    [iv showTrackables:iii yesno:NO];
    [callback remoteAPI_objectReadyToImport:iv ivi:iii object:wps group:group account:self.account];
    NSMutableArray *logs = [NSMutableArray arrayWithCapacity:50];
    NSArray *ws = [wps objectForKey:@"geocaches"];

    [iv setChunksTotal:ivi total:[ws count]];
    [iv setChunksCount:ivi count:1];
    [iv resetBytes:ivi];
    [ws enumerateObjectsUsingBlock:^(NSDictionary *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [iv setChunksCount:ivi count:idx + 1];
        NSString *wpname = [wp objectForKey:@"waypoint"];
        [iv resetBytes:ivi];
        GCDictionaryGCA *ls = [gca logs_cache:wpname infoViewer:iv ivi:ivi];
        NSArray *lss = [ls objectForKey:@"logs"];
        [lss enumerateObjectsUsingBlock:^(NSDictionary *l, NSUInteger idx, BOOL * _Nonnull stop) {
            [logs addObject:l];
        }];
    }];

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
    //        [d setObject:wps forKey:@"geocaches1"];
    [d setObject:logs forKey:@"logs"];

    GCDictionaryGCA *gcajson = [[GCDictionaryGCA alloc] initWithDictionary:d];

    iii = [iv addImport];
    [iv expand:iii yesno:NO];
    [iv setDescription:iii description:@"Geocaching Australia GPX data (queued)"];
    [iv showWaypoints:iii yesno:NO];
    [iv showTrackables:iii yesno:NO];
    [callback remoteAPI_objectReadyToImport:iv ivi:iii object:gcajson group:group account:self.account];

    *retObject = gcajson;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)listQueries:(NSArray **)qs infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    GCDictionaryGCA *json = [gca my_query_list__json:iv ivi:ivi];
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;

    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];

    GCDictionaryGCA *json = [gca my_query_json:_id infoViewer:iv ivi:ivi];
    GCA_CHECK_STATUS(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    InfoItemID iii = [iv addImport];
    [callback remoteAPI_objectReadyToImport:iv ivi:iii object:json group:group account:self.account];

    *retObj = json;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;
    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];
    GCStringGPX *gpx = nil;
    gpx = [gca my_query_gpx:_id infoViewer:iv ivi:ivi];
    if (gpx == nil)
        return REMOTEAPI_APIFAILED;

    InfoItemID iii = [iv addImport];
    [callback remoteAPI_objectReadyToImport:iv ivi:iii object:gpx group:group account:self.account];

    *retObj = gpx;
    return REMOTEAPI_OK;
}

@end
