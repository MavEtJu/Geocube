/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

#define IMPORTMSG   _(@"remoteapigca2-Geocaching Australia JSON data (queued)")

- (BOOL)supportsWaypointPersonalNotes { return NO; }
- (BOOL)supportsTrackablesRetrieve { return NO; }
- (BOOL)supportsTrackablesLog { return NO; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return YES; }
- (BOOL)supportsLoggingFavouritePoint { return NO; }
- (BOOL)supportsLoggingPhotos { return YES; }
- (BOOL)supportsLoggingCoordinates { return YES; }
- (BOOL)supportsLoggingTrackables { return NO; }
- (BOOL)supportsLoggingRating { return YES; }
- (NSRange)supportsLoggingRatingRange { return NSMakeRange(1, 5); }

- (BOOL)supportsLoadWaypoint { return YES; }
- (BOOL)supportsLoadWaypointsByCodes { return YES; }
- (BOOL)supportsLoadWaypointsByBoundaryBox { return YES; }

- (BOOL)supportsListQueries { return YES; }
- (BOOL)supportsRetrieveQueries { return YES; }

#define GCA2_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) { \
                return [self lastErrorCode]; \
            } \
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

#define GCA2_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) { \
                [callback remoteAPI_failed:identifier]; \
                return [self lastErrorCode]; \
            } \
            NSDictionary *error = [__json__ objectForKey:@"error"]; \
            if (error != nil) { \
                NSString *s = [NSString stringWithFormat:@"[GCA2] %@: Error response: (%@)", __logsection__, [error description]]; \
                NSLog(@"%@", s); \
                [self setAPIError:s error:REMOTEAPI_APIFAILED]; \
                [callback remoteAPI_failed:identifier]; \
                return REMOTEAPI_APIFAILED; \
            } \
        }

#define GCA2_GET_VALUE_CB(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
        __type__ *__varname__ = [__json__ objectForKey:__field__]; \
        if (__varname__ == nil) { \
            NSString *s = [NSString stringWithFormat:@"[GCA2] %@: No '%@' field returned", __logsection__, __field__]; \
            [self setDataError:s error:__failure__]; \
            NSLog(@"%@", s); \
            [callback remoteAPI_failed:identifier]; \
            return __failure__; \
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
    [self clearErrors];

    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setValue:@"" forKey:@"waypoints_found"];
    [ret setValue:@"" forKey:@"waypoints_notfound"];
    [ret setValue:@"" forKey:@"waypoints_hidden"];
    [ret setValue:@"" forKey:@"recommendations_given"];
    [ret setValue:@"" forKey:@"recommendations_received"];

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryGCA2 *dict = [self.gca2 api_services_users_by__username:username infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
    [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
    [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
    [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    NSMutableString *n = [NSMutableString stringWithString:note];
    if (rating != 0)
        [n appendFormat:@"\n*Overall Experience: %ld*\n", (long)rating];
    if (favourite == YES)
        [n appendFormat:@"\n*Recommended*\n"];
    GCDictionaryGCA2 *json = [self.gca2 api_services_logs_submit:waypoint logtype:logstring.logString comment:n when:dateLogged rating:rating recommended:favourite coordinates:coordinates infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS(json, @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);

    GCA2_GET_VALUE(json, NSDictionary, data, @"data", @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);
    GCA2_GET_VALUE(data, NSNumber, logid, @"log_uuid", @"CreateLogNote/log", REMOTEAPI_CREATELOG_LOGFAILED);

    if (image != nil) {
        json = [self.gca2 api_services_logs_images_add:logid data:imgdata caption:imageCaption description:imageDescription infoViewer:iv iiDownload:iid];
        GCA2_CHECK_STATUS(json, @"CreateLogNote/image", REMOTEAPI_CREATELOG_IMAGEFAILED);
    }

    return REMOTEAPI_OK;
 }

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.groupLiveImport;

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryGCA2 *json = [self.gca2 api_services_caches_geocache:waypoint.wpt_name infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS_CB(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray<NSDictionary *> *as = @[[json objectForKey:waypoint.wpt_name]];
    [d setObject:as forKey:@"waypoints"];
    GCDictionaryGCA2 *d2 = [[GCDictionaryGCA2 alloc] initWithDictionary:d];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:d2 group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:_(@"remoteapigca2-[GCA2] loadWaypointsByCodes: remote API is disabled") error:REMOTEAPI_APIDISABLED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryGCA2 *json = [self.gca2 api_services_caches_geocaches:wpcodes infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS_CB(json, @"loadWaypointsByCodes", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString * _Nonnull wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];
    GCDictionaryGCA2 *d2 = [[GCDictionaryGCA2 alloc] initWithDictionary:d];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:d2 group:group account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:_(@"remoteapigca2-[GCA2] loadWaypointsByBoundingBox: remote API is disabled") error:REMOTEAPI_APIDISABLED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:iid total:2];
    [iv setChunksCount:iid count:1];

    GCDictionaryGCA2 *json = [self.gca2 api_services_search_bbox:bb infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    GCA2_GET_VALUE_CB(json, NSArray, wpcodes, @"results", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
    if ([wpcodes count] == 0) {
        [callback remoteAPI_finishedDownloads:identifier numberOfChunks:0];
        return REMOTEAPI_OK;
    }

    [iv setChunksCount:iid count:2];
    json = [self.gca2 api_services_caches_geocaches:wpcodes logs:30 infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS_CB(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString * _Nonnull wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];
    GCDictionaryGCA2 *d2 = [[GCDictionaryGCA2 alloc] initWithDictionary:d];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:d2 group:nil account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid public:(BOOL)public
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    *qs = nil;
    GCDictionaryGCA2 *json = [self.gca2 api_services_caches_query_list:iv iiDownload:iid public:public];
    GCA2_CHECK_STATUS(json, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    NSMutableArray<NSDictionary *> *as = [NSMutableArray arrayWithCapacity:20];
    GCA2_GET_VALUE(json, NSArray, pqs, @"queries", @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    [pqs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull pq, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:4];

        [d setValue:[pq objectForKey:@"description"] forKey:@"Name"];
        [d setValue:[pq objectForKey:@"queryid"] forKey:@"Id"];

        [as addObject:d];
    }];

    *qs = as;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;
    [iv setChunksTotal:iid total:2];

    // Download the query
    [iv setChunksCount:iid count:1];

    GCDictionaryGCA2 *json = [self.gca2 api_services_caches_query_geocaches:_id infoViewer:iv iiDownload:iid];
    GCA2_CHECK_STATUS_CB(json, @"retrieveQuery/query", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    GCA2_GET_VALUE_CB(json, NSArray, wps, @"geocaches", @"retrieveQuery/query", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    // Find the chunks...
    NSMutableArray<NSArray <NSString *>*> *wpchunks = [NSMutableArray arrayWithCapacity:1 + [wps count] / 100];
    __block NSMutableArray<NSString *> *wpcodes = [NSMutableArray arrayWithCapacity:100];
    [wps enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 100 == 0 && [wpcodes count] != 0) {
            [wpchunks addObject:wpcodes];
            wpcodes = [NSMutableArray arrayWithCapacity:100];
        }
        [wpcodes addObject:[wp objectForKey:@"waypoint"]];
    }];
    if ([wpcodes count] != 0)
        [wpchunks addObject:wpcodes];

    // Download the waypoint information
    [iv setChunksTotal:iid total:1 + [wpchunks count]];

    NSEnumerator *eWpchunk = [wpchunks objectEnumerator];
    wpcodes = nil;
    NSUInteger idx = 0;
    while ((wpcodes = [eWpchunk nextObject]) != nil) {

        [iv setChunksCount:iid count:1 + ++idx];

        GCDictionaryGCA2 *json = [self.gca2 api_services_caches_geocaches:wpcodes infoViewer:iv iiDownload:iid];
        GCA2_CHECK_STATUS_CB(json, @"retrieveQuery/geocaches", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        NSMutableArray<NSDictionary *> *_wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
        [wpcodes enumerateObjectsUsingBlock:^(NSString * _Nonnull wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
            [_wps addObject:[json objectForKey:wpcode]];
        }];
        [d setObject:_wps forKey:@"waypoints"];

        GCDictionaryGCA2 *d2 = [[GCDictionaryGCA2 alloc] initWithDictionary:d];

        InfoItemID iii = [iv addImport];
        [iv setDescription:iii description:IMPORTMSG];
        [callback remoteAPI_objectReadyToImport:0 iiImport:iii object:d2 group:group account:self.account];
        chunks++;
    }

    [callback remoteAPI_finishedDownloads:0 numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

@end
