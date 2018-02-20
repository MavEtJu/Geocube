/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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
- (BOOL)supportsTrackablesRetrieve { return YES; }
- (BOOL)supportsTrackablesLog { return YES; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return YES; }
- (BOOL)supportsLoggingFavouritePoint { return YES; }
- (BOOL)supportsLoggingPhotos { return YES; }
- (BOOL)supportsLoggingCoordinates { return YES; }
- (BOOL)supportsLoggingTrackables { return YES; }
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

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict infoItem:(InfoItem *)iid
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

    [iid changeChunksTotal:2];
    [iid changeChunksCount:1];
    GCDictionaryLiveAPI *dict1 = [self.liveAPI GetYourUserProfile:iid];
    LIVEAPI_CHECK_STATUS(dict1, @"UserStatistics/profile", REMOTEAPI_USERSTATISTICS_LOADFAILED);
    [iid changeChunksCount:2];
    GCDictionaryLiveAPI *dict2 = [self.liveAPI GetCacheIdsFavoritedByUser:iid];
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

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoItem:(InfoItem *)iid
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

    GCDictionaryLiveAPI *json = [self.liveAPI CreateFieldNoteAndPublish:logstring.logString waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite imageCaption:imageCaption imageDescription:imageDescription imageData:imgdata imageFilename:image.datafile infoItem:iid];
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
        GCDictionaryLiveAPI *json = [self.liveAPI CreateTrackableLog:waypoint.wpt_name logtype:ls.logString trackable:tb note:note dateLogged:dateLogged infoItem:iid];
        LIVEAPI_CHECK_STATUS_ENUM(json, @"CreateTrackableLog", REMOTEAPI_CREATELOG_LOGFAILED);
    }];
    return errorCode;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.groupLiveImport;

    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCDictionaryLiveAPI *json = [self.liveAPI SearchForGeocaches_waypointname:waypoint.wpt_name infoItem:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    InfoItem *iii = [iid.infoViewer addImport];
    [iii changeDescription:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:json group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoItem:(InfoItem *)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];
    GCDictionaryLiveAPI *json = [self.liveAPI SearchForGeocaches_waypointnames:wpcodes infoItem:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByCodes", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    InfoItem *iii = [iid.infoViewer addImport];
    [iii changeDescription:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:json group:group account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;
    self.loadWaypointsLogs = 0;
    self.loadWaypointsWaypoints = 0;

    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:_(@"remoteapiliveapi-[LiveAPI] loadWaypointsByBoundingBox: remote API is disabled") error:REMOTEAPI_APIDISABLED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIDISABLED;
    }

    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];
    GCDictionaryLiveAPI *json = [self.liveAPI SearchForGeocaches_boundbox:bb infoItem:iid];
    LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    LIVEAPI_GET_VALUE_CB(json, NSNumber, ptotal, @"TotalMatchingCaches", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
    NSInteger total = [ptotal integerValue];
    NSInteger done = 0;
    [iid changeChunksTotal:(total / 20) + 1];
    if (total != 0) {
        GCDictionaryLiveAPI *livejson = json;
        LIVEAPI_CHECK_STATUS_CB(livejson, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
        InfoItem *iii = [iid.infoViewer addImport];
        [iii changeDescription:IMPORTMSG];
        [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:livejson group:nil account:self.account];
        chunks++;
        do {
            [iid changeChunksCount:(done / 20) + 1];
            done += 20;

            json = [self.liveAPI GetMoreGeocaches:done infoItem:iid];
            LIVEAPI_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

            if ([json objectForKey:@"Geocaches"] != nil) {
                GCDictionaryLiveAPI *livejson = json;
                InfoItem *iii = [iid.infoViewer addImport];
                [iii changeDescription:IMPORTMSG];
                [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:livejson group:nil account:self.account];
                chunks++;
            }
        } while (done < total);
    }

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoItem:(InfoItem *)iid
{
    GCDictionaryLiveAPI *json = [self.liveAPI UpdateCacheNote:note.wp_name text:note.note infoItem:iid];
    LIVEAPI_CHECK_STATUS(json, @"updatePersonalNote", REMOTEAPI_PERSONALNOTE_UPDATEFAILED);
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoItem:(InfoItem *)iid public:(BOOL)public
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    *qs = nil;
    GCDictionaryLiveAPI *json = [self.liveAPI GetPocketQueryList:iid];
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;

    NSInteger max = 0;
    NSInteger tried = 0;
    NSInteger offset = 0;
    NSInteger increase = 25;

    [iid changeChunksTotal:0];
    [iid changeChunksCount:1];
    do {
        NSLog(@"offset:%ld - max: %ld", (long)offset, (long)max);
        GCDictionaryLiveAPI *json = [self.liveAPI GetFullPocketQueryData:_id startItem:offset numItems:increase infoItem:iid];
        LIVEAPI_CHECK_STATUS_CB(json, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

        NSInteger found = 0;

        InfoItem *iii = [iid.infoViewer addImport];
        [iii changeDescription:IMPORTMSG];
        [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:json group:group account:self.account];
        chunks++;

        found += [[json objectForKey:@"Geocaches"] count];

        offset += found;
        tried += increase;
        max = [[json objectForKey:@"PQCount"] integerValue];
        [iid changeChunksTotal:1 + (max / increase)];
        [iid changeChunksCount:offset / increase];
    } while (tried < max);
    [iid changeChunksTotal:1 + (max / increase)];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesMine:(InfoItem *)iid
{
    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCDictionaryLiveAPI *json = [self.liveAPI GetOwnedTrackables:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesMine", REMOTEAPI_TRACKABLES_OWNEDLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:self.account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesInventory:(InfoItem *)iid
{
    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCDictionaryLiveAPI *json = [self.liveAPI GetUsersTrackables:iid];
    LIVEAPI_CHECK_STATUS(json, @"trackablesInventory", REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED);

    ImportLiveAPIJSON *imp = [[ImportLiveAPIJSON alloc] init:nil account:self.account];
    [imp parseDictionary:json];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableFind:(NSString *)pin trackable:(dbTrackable **)t infoItem:(InfoItem *)iid
{
    GCDictionaryLiveAPI *json = [self.liveAPI GetTrackablesByPin:pin infoItem:iid];
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

    *t = [dbTrackable dbGetByTBCode:ref];
    if ([(*t).pin isEqualToString:@""] == YES ) {
        (*t).pin = pin;
        [*t dbUpdate];
    }
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableDiscover:(NSString *)tbpin infoItem:(InfoItem *)iid
{
    dbTrackable *tb = nil;
    RemoteAPIResult r = [self trackableFind:tbpin trackable:&tb infoItem:iid];
    if (r != REMOTEAPI_OK)
        return r;
    if (tb == nil) {
        [self setAPIError:[NSString stringWithFormat:@"Unable to find '%@'", tbpin] error:REMOTEAPI_TRACKABLES_FINDFAILED];
        return REMOTEAPI_TRACKABLES_FINDFAILED;
    }

    NSString *note = @"Discovered";

    dbLogString *ls = [dbLogString dbGetByProtocolWPTypeDefault:self.account.protocol wptype:LOGSTRING_WPTYPE_TRACKABLEWAYPOINT default:LOGSTRING_DEFAULT_DISCOVER];
    GCDictionaryLiveAPI *json = [self.liveAPI CreateTrackableLog:nil logtype:ls.logString trackable:tb note:note dateLogged:[MyTools dateTimeString_YYYY_MM_DD] infoItem:iid];
    LIVEAPI_CHECK_STATUS(json, @"CreateTrackableLog", REMOTEAPI_CREATELOG_LOGFAILED);

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableGrab:(NSString *)tbpin infoItem:(InfoItem *)iid
{
    dbTrackable *tb = nil;
    RemoteAPIResult r = [self trackableFind:tbpin trackable:&tb infoItem:iid];
    if (r != REMOTEAPI_OK)
        return r;
    if (tb == nil) {
        [self setAPIError:[NSString stringWithFormat:@"Unable to find '%@'", tbpin] error:REMOTEAPI_TRACKABLES_FINDFAILED];
        return REMOTEAPI_TRACKABLES_FINDFAILED;
    }

    NSString *note = @"Grabbed";

    dbLogString *ls = [dbLogString dbGetByProtocolWPTypeDefault:self.account.protocol wptype:LOGSTRING_WPTYPE_TRACKABLEPERSON default:LOGSTRING_DEFAULT_PICKUP];
    GCDictionaryLiveAPI *json = [self.liveAPI CreateTrackableLog:nil logtype:ls.logString trackable:tb note:note dateLogged:[MyTools dateTimeString_YYYY_MM_DD] infoItem:iid];
    LIVEAPI_CHECK_STATUS(json, @"CreateTrackableLog", REMOTEAPI_CREATELOG_LOGFAILED);

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableDrop:(dbTrackable *)tb waypoint:(NSString *)wptname infoItem:(InfoItem *)iid
{
    NSString *note = @"Dropped";

    dbLogString *ls = [dbLogString dbGetByProtocolWPTypeDefault:self.account.protocol wptype:LOGSTRING_WPTYPE_TRACKABLEWAYPOINT default:LOGSTRING_DEFAULT_DROPOFF];
    GCDictionaryLiveAPI *json = [self.liveAPI CreateTrackableLog:wptname logtype:ls.logString trackable:tb note:note dateLogged:[MyTools dateTimeString_YYYY_MM_DD] infoItem:iid];
    LIVEAPI_CHECK_STATUS(json, @"CreateTrackableLog", REMOTEAPI_CREATELOG_LOGFAILED);

    return REMOTEAPI_OK;
}

@end
