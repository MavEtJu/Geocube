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

@interface RemoteAPIGCA2 ()

@end

@implementation RemoteAPIGCA2

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

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDownload *)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

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

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDownload *)iid
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

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

- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;

    if ([self.account canDoRemoteStuff] == NO) {
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
    GCA2_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];
    GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

    ImportGCA2JSON *imp = [[ImportGCA2JSON alloc] init:group account:self.account];
    [imp parseBefore];
    [imp parseDictionary:d2];
    [imp parseAfter];

    [waypointManager needsRefreshAll];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray *)wpcodes retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:@"[GCA2] loadWaypoints: remote API is disabled" error:REMOTEAPI_APIDISABLED];
        return REMOTEAPI_APIDISABLED;
    }

    [iid setChunksTotal:1];
    [iid setChunksCount:1];

    GCDictionaryGCA2 *json = [gca2 api_services_caches_geocaches:wpcodes downloadInfoItem:iid];
    GCA2_CHECK_STATUS(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];
    GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

    ImportGCA2JSON *imp = [[ImportGCA2JSON alloc] init:group account:self.account];
    [imp parseBefore];
    [imp parseDictionary:d2];
    [imp parseAfter];

    [waypointManager needsRefreshAll];
    return REMOTEAPI_OK;
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;

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
    [callback remoteAPI_objectReadyToImport:iii object:d2 group:group account:self.account];

    *retObj = json;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;
    [iid setChunksTotal:1];
    [iid setChunksCount:1];
    GCStringGPX *gpx = nil;
    if (gpx == nil)
        return REMOTEAPI_APIFAILED;

    InfoItemImport *iii = [infoViewer addImport];
    [callback remoteAPI_objectReadyToImport:iii object:gpx group:group account:self.account];

    *retObj = gpx;
    return REMOTEAPI_OK;
}

@end
