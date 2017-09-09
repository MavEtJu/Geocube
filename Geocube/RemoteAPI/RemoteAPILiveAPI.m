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

@interface RemoteAPILiveAPI ()

@end

@implementation RemoteAPILiveAPI

#define IMPORTMSG   _(@"remoteapiliveapi-LiveAPI JSON data (queued)")

- (BOOL)supportsWaypointPersonalNotes { return YES; }
- (BOOL)supportsTrackables { return YES; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return YES; }
- (BOOL)supportsLoggingFavouritePoint { return YES; }
- (BOOL)supportsLoggingPhotos { return YES; }
- (BOOL)supportsLoggingCoordinates { return YES; }
- (BOOL)supportsLoggingRating { return NO; }
- (NSRange)supportsLoggingRatingRange { return NSMakeRange(0, 0); }

- (BOOL)supportsLoadWaypoint { return YES; }
- (BOOL)supportsLoadWaypointsByCodes { return YES; }
- (BOOL)supportsLoadWaypointsByBoundaryBox { return YES; }

- (BOOL)supportsListQueries { return YES; }
- (BOOL)supportsRetrieveQueries { return YES; }

#define LIVEAPI_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            NSDictionary *status = [__json__ objectForKey:@"Status"]; \
            if (status == nil) \
                if ([__json__ objectForKey:@"StatusCode"] != nil) \
                    status = [__json__ _dict]; \
            if (status == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No 'Status' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return REMOTEAPI_APIFAILED; \
            } \
            NSNumber *num = [status objectForKey:@"StatusCode"]; \
            if (num == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-LiveAPI] %@: No 'StatusCode' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return REMOTEAPI_APIFAILED; \
            } \
            if ([num integerValue] != 0) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: 'actionstatus' was not 0 (%@)"), __logsection__, num]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                return __failure__; \
            } \
        }

#define LIVEAPI_CHECK_STATUS_ENUM(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) { \
                errorCode = [self lastErrorCode]; \
                *stop = YES; \
                return; \
            } \
            NSDictionary *status = [__json__ objectForKey:@"Status"]; \
            if (status == nil) \
                if ([__json__ objectForKey:@"StatusCode"] != nil) \
                    status = [__json__ _dict]; \
            if (status == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No 'Status' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                errorCode = REMOTEAPI_APIFAILED; \
                *stop = YES; \
                return; \
            } \
            NSNumber *num = [status objectForKey:@"StatusCode"]; \
            if (num == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No 'StatusCode' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                errorCode = REMOTEAPI_APIFAILED; \
                *stop = YES; \
                return; \
            } \
            if ([num integerValue] != 0) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: 'actionstatus' was not 0 (%@)"), __logsection__, num]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                errorCode = __failure__; \
                *stop = YES; \
                return; \
            } \
        }

#define LIVEAPI_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No '%@' field returned"), __logsection__, __field__]; \
                [self setDataError:s error:__failure__]; \
                NSLog(@"%@", s); \
                return __failure__; \
            }

#define LIVEAPI_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) { \
                [callback remoteAPI_failed:identifier]; \
                return [self lastErrorCode]; \
            } \
            NSDictionary *status = [__json__ objectForKey:@"Status"]; \
            if (status == nil) \
                if ([__json__ objectForKey:@"StatusCode"] != nil) \
                    status = [__json__ _dict]; \
            if (status == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No 'Status' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                [callback remoteAPI_failed:identifier]; \
                return REMOTEAPI_APIFAILED; \
            } \
            NSNumber *num = [status objectForKey:@"StatusCode"]; \
            if (num == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No 'StatusCode' field returned"), __logsection__]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                [callback remoteAPI_failed:identifier]; \
                return REMOTEAPI_APIFAILED; \
            } \
            if ([num integerValue] != 0) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: 'actionstatus' was not 0 (%@)"), __logsection__, num]; \
                NSLog(@"%@", s); \
                [self setDataError:s error:__failure__]; \
                [callback remoteAPI_failed:identifier]; \
                return __failure__; \
            } \
        }

#define LIVEAPI_GET_VALUE_CB(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiliveapi-[LiveAPI] %@: No '%@' field returned"), __logsection__, __field__]; \
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

    [iv setChunksTotal:iid total:2];
    [iv setChunksCount:iid count:1];
    GCDictionaryLiveAPI *dict1 = [liveAPI GetYourUserProfile:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(dict1, @"UserStatistics/profile", REMOTEAPI_USERSTATISTICS_LOADFAILED);
    [iv setChunksCount:iid count:2];
    GCDictionaryLiveAPI *dict2 = [liveAPI GetCacheIdsFavoritedByUser:iv iiDownload:iid];
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

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    GCDictionaryLiveAPI *json = [liveAPI CreateFieldNoteAndPublish:logstring.logString waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite imageCaption:imageCaption imageDescription:imageDescription imageData:imgdata imageFilename:image.datafile infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);

    __block NSInteger errorCode = REMOTEAPI_OK;
    [trackables enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tb.logtype == TRACKABLE_LOG_NONE)
            return;
        LogStringDefault dflt = 0;
        LogStringWPType wptype = LOGSTRING_WPTYPE_UNKNOWN;
        NSString *note = nil;
        switch (tb.logtype) {
            case TRACKABLE_LOG_VISIT:
                dflt = LOGSTRING_DEFAULT_VISIT;
                wptype = LOGSTRING_WPTYPE_TRACKABLEPERSON;
                note = [NSString stringWithFormat:@"Visited '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                break;
            case TRACKABLE_LOG_DROPOFF:
                dflt = LOGSTRING_DEFAULT_DROPOFF;
                note = [NSString stringWithFormat:@"Dropped off at '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                wptype = LOGSTRING_WPTYPE_TRACKABLEPERSON;
                break;
            case TRACKABLE_LOG_PICKUP:
                dflt = LOGSTRING_DEFAULT_PICKUP;
                note = [NSString stringWithFormat:@"Picked up from '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                wptype = LOGSTRING_WPTYPE_TRACKABLEWAYPOINT;
                break;
            case TRACKABLE_LOG_DISCOVER:
                dflt = LOGSTRING_DEFAULT_DISCOVER;
                note = [NSString stringWithFormat:@"Discovered in '%@' (%@)", waypoint.wpt_urlname, waypoint.wpt_name];
                wptype = LOGSTRING_WPTYPE_TRACKABLEWAYPOINT;
                break;
            default:
                NSAssert(NO, @"Unknown tb.logtype");
        }
        dbLogString *ls = [dbLogString dbGetByProtocolWPTypeDefault:self.account.protocol wptype:wptype default:dflt];
        GCDictionaryLiveAPI *json = [liveAPI CreateTrackableLog:waypoint logtype:ls.logString trackable:tb note:note dateLogged:dateLogged infoViewer:iv iiDownload:iid];
        LIVEAPI_CHECK_STATUS_ENUM(json, @"CreateTrackableLog", REMOTEAPI_CREATELOG_LOGFAILED);
    }];
    return errorCode;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.groupLiveImport;

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_waypointname:waypoint.wpt_name infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:json group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];
    GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_waypointnames:wpcodes infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByCodes", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:json group:group account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;

    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:_(@"remoteapiliveapi-[LiveAPI] loadWaypointsByBoundingBox: remote API is disabled") error:REMOTEAPI_APIDISABLED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];
    GCDictionaryLiveAPI *json = [liveAPI SearchForGeocaches_boundbox:bb infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    LIVEAPI_GET_VALUE_CB(json, NSNumber, ptotal, @"TotalMatchingCaches", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
    NSInteger total = [ptotal integerValue];
    NSInteger done = 0;
    [iv setChunksTotal:iid total:(total / 20) + 1];
    if (total != 0) {
        GCDictionaryLiveAPI *livejson = json;
        LIVEAPI_CHECK_STATUS_CB(livejson, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
        InfoItemID iii = [iv addImport:NO];
        [iv setDescription:iii description:IMPORTMSG];
        [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:livejson group:nil account:self.account];
        chunks++;
        do {
            [iv setChunksCount:iid count:(done / 20) + 1];
            done += 20;

            json = [liveAPI GetMoreGeocaches:done infoViewer:iv iiDownload:iid];
            LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

            if ([json objectForKey:@"Geocaches"] != nil) {
                GCDictionaryLiveAPI *livejson = json;
                InfoItemID iii = [iv addImport:NO];
                [iv setDescription:iii description:IMPORTMSG];
                [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:livejson group:nil account:self.account];
                chunks++;
            }
        } while (done < total);
    }

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    GCDictionaryLiveAPI *json = [liveAPI UpdateCacheNote:note.wp_name text:note.note infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"updatePersonalNote", REMOTEAPI_PERSONALNOTE_UPDATEFAILED);
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    *qs = nil;
    GCDictionaryLiveAPI *json = [liveAPI GetPocketQueryList:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"listQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    NSMutableArray<NSDictionary *> *as = [NSMutableArray arrayWithCapacity:20];

    NSArray<NSDictionary *> *pqs = [json objectForKey:@"PocketQueryList"];
    [pqs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull pq, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;

    NSInteger max = 0;
    NSInteger tried = 0;
    NSInteger offset = 0;
    NSInteger increase = 25;

    [iv setChunksTotal:iid total:0];
    [iv setChunksCount:iid count:1];
    do {
        NSLog(@"offset:%ld - max: %ld", (long)offset, (long)max);
        GCDictionaryLiveAPI *json = [liveAPI GetFullPocketQueryData:_id startItem:offset numItems:increase infoViewer:iv iiDownload:iid];
        LIVEAPI_CHECK_STATUS_CB(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSInteger found = 0;

        InfoItemID iii = [iv addImport:NO];
        [iv setDescription:iii description:IMPORTMSG];
        [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:json group:group account:self.account];
        chunks++;

        found += [[json objectForKey:@"Geocaches"] count];

        offset += found;
        tried += increase;
        max = [[json objectForKey:@"PQCount"] integerValue];
        [iv setChunksTotal:iid total:1 + (max / increase)];
        [iv setChunksCount:iid count:offset / increase];
    } while (tried < max);
    [iv setChunksTotal:iid total:1 + (max / increase)];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryLiveAPI *json = [liveAPI GetOwnedTrackables:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesMine", REMOTEAPI_TRACKABLES_OWNEDLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:self.account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryLiveAPI *json = [liveAPI GetUsersTrackables:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesInventory", REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:self.account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    GCDictionaryLiveAPI *json = [liveAPI GetTrackablesByTrackingNumber:code infoViewer:iv iiDownload:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackableFind", REMOTEAPI_TRACKABLES_FINDFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:self.account];
    [imp parseDictionary:json];

    NSArray<NSString *> *refs = nil;
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
