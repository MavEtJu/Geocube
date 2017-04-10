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

@interface RemoteAPIGGCW ()

@end

@implementation RemoteAPIGGCW

#define IMPORTMSG_GPX   @"Geocaching.com GPX Garmin data (queued)"
#define IMPORTMSG_PQ    @"Geocaching.com Pocket Query data (queued)"


- (BOOL)commentSupportsFavouritePoint
{
    return YES;
}
- (BOOL)commentSupportsPhotos
{
    return NO;
}
- (BOOL)commentSupportsRating
{
    return NO;
}
- (NSRange)commentSupportsRatingRange
{
    return NSMakeRange(0, 0);
}
- (BOOL)commentSupportsTrackables
{
    return YES;
}
- (BOOL)waypointSupportsPersonalNotes
{
    return YES;
}

#define GGCW_CHECK_STATUS(__json__, __logsection__, __failure__) { \
        }

#define GGCW_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            [callback remoteAPI_failed:iv identifier:identifier]; \
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

    GCDictionaryGGCW *dict = [ggcw my_default:iv ivi:ivi];
    GGCW_CHECK_STATUS(dict, @"my_defaults", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
    [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSData *imgdata = nil;
    if (image != nil)
        imgdata = [NSData dataWithContentsOfFile:[MyTools ImageFile:image.datafile]];

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
        [tbs setObject:note forKey:[NSNumber numberWithLongLong:tb.gc_id]];
    }];

    NSDictionary *dict = [ggcw geocache:waypoint.wpt_name infoViewer:iv ivi:ivi];
    NSString *gc_id = [dict objectForKey:@"gc_id"];
    dict = [ggcw seek_log__form:gc_id infoViewer:iv ivi:ivi];
    [ggcw seek_log__submit:gc_id dict:dict logstring:logstring.type dateLogged:dateLogged note:note favpoint:favourite trackables:tbs infoViewer:iv ivi:ivi];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];

    GCStringGPX *gpx = [ggcw geocache_gpx:waypoint.wpt_name infoViewer:iv ivi:ivi];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG_GPX];
    [callback remoteAPI_objectReadyToImport:identifier ivi:iii object:gpx group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByCenter:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback
{
    NSInteger chunks = 0;
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;

    GCDictionaryGGCW *d = [ggcw map:iv ivi:ivi];
    self.account.ggcw_username = [d objectForKey:@"usersession.username"];
    self.account.ggcw_sessiontoken = [d objectForKey:@"usersession.sessionToken"];
    if (self.account.ggcw_username == nil || self.account.ggcw_sessiontoken == nil) {
        [self setAPIError:@"Unknown to obtain username or session token" error:REMOTEAPI_APIFAILED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIFAILED;
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

    [iv removeItem:ivi];

    NSMutableDictionary *wpcodesall = [NSMutableDictionary dictionaryWithCapacity:100];
    [iv setChunksTotal:ivi total:(ymax - ymin + 1) * (xmax - xmin + 1)];
    for (NSInteger y = ymin; y <= ymax; y++) {
        for (NSInteger x = xmin; x <= xmax; x++) {
            NSMutableDictionary *wpcodes = [NSMutableDictionary dictionaryWithCapacity:100];

            InfoItemID iid = [iv addDownload];
            [iv setDescription:iid description:[NSString stringWithFormat:@"Tile (%ld, %ld)", (long)x, (long)y]];
            [iv setChunksTotal:iid total:0];
            [iv setChunksCount:iid count:1];
            [iv resetBytes:iid];
            // Without requesting the map tile image the map.info returns sometimes a 204. No idea why.
            [ggcw map_png:x y:y z:ZOOM infoViewer:iv ivi:iid];
            // Now we can (safely?) request the map info details.
            GCDictionaryGGCW *d = [ggcw map_info:x y:y z:ZOOM infoViewer:iv ivi:iid];

            NSDictionary *alldata = [d objectForKey:@"data"];
            [alldata enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<NSDictionary *> *wps, BOOL *stop) {
                NSDictionary *wpdata = [wps objectAtIndex:0];
                // Don't look at the same object twice
                NSString *wpdatai = [wpdata objectForKey:@"i"];
                if ([wpcodesall objectForKey:wpdatai] != nil) {
                    [callback remoteAPI_failed:identifier];
                    return;
                }

                [wpcodes setObject:wpdata forKey:wpdatai];
                [wpcodesall setObject:@"0" forKey:wpdatai];
            }];

            [wpcodes setObject:group forKey:@"group"];
            [wpcodes setObject:iv forKey:@"iv"];
            [wpcodes setObject:[NSNumber numberWithInteger:iid] forKey:@"iid"];
            [wpcodes setObject:callback forKey:@"callback"];
            [wpcodes setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
            [self performSelectorInBackground:@selector(loadWaypoints_GGCWBackground:) withObject:wpcodes];
            chunks++;
        }
    }

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:chunks];
    return REMOTEAPI_OK;
}

- (void)loadWaypoints_GGCWBackground:(NSMutableDictionary *)wpcodes
{
    id<RemoteAPIDownloadDelegate> callback = [wpcodes objectForKey:@"callback"];
    InfoItemID iid = [[wpcodes objectForKey:@"iid"] integerValue];
    InfoViewer *iv = [wpcodes objectForKey:@"iv"];
    dbGroup *group = [wpcodes objectForKey:@"group"];
    NSInteger identifier = [[wpcodes objectForKey:@"identifier"] integerValue];
    [wpcodes removeObjectForKey:@"iid"];
    [wpcodes removeObjectForKey:@"iv"];
    [wpcodes removeObjectForKey:@"callback"];
    [wpcodes removeObjectForKey:@"group"];
    [wpcodes removeObjectForKey:@"identifier"];

    GCMutableArray *gpxarray = [[GCMutableArray alloc] initWithCapacity:[wpcodes count]];

    [iv setChunksTotal:iid total:[wpcodes count]];
    [[wpcodes allKeys] enumerateObjectsUsingBlock:^(NSString *wpcode, NSUInteger idx, BOOL *stop) {
        [iv setChunksCount:iid count:idx + 1];
        [iv resetBytes:iid];

        GCDictionaryGGCW *d = [ggcw map_details:wpcode infoViewer:iv ivi:iid];
        if (d == nil) {
            [callback remoteAPI_failed:identifier];
            return;
        }
        NSArray<NSDictionary *> *data = [d objectForKey:@"data"];
        NSDictionary *dict = [data objectAtIndex:0];

        GCStringGPXGarmin *gpx = [ggcw seek_sendtogps:[dict objectForKey:@"g"] infoViewer:iv ivi:iid];
        if (gpx == nil) {
            [callback remoteAPI_failed:identifier];
            return;
        }

        [gpxarray addObject:gpx];
    }];

    if ([gpxarray count] == 0) {
        [iv removeItem:iid];
        [callback remoteAPI_finishedDownloads:identifier numberOfChunks:0];
        return;
    }

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG_GPX];
    [callback remoteAPI_objectReadyToImport:identifier ivi:iii object:gpxarray group:group account:self.account];

    [iv removeItem:iid];
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSDictionary *gc = [ggcw geocache:note.wp_name infoViewer:iv ivi:ivi];
    GCDictionaryGGCW *json = [ggcw seek_cache__details_SetUserCacheNote:gc text:note.note infoViewer:iv ivi:ivi];
    NSNumber *success = [json objectForKey:@"success"];
    if ([success boolValue] == NO)
        return REMOTEAPI_PERSONALNOTE_UPDATEFAILED;

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    /* Returns: array of dicts of
     * - Name
     * - Id
     * - DateTime
     * - Size
     * - Count
     */

    *qs = nil;
    GCDictionaryGGCW *dict = [ggcw pocket_default:iv ivi:ivi];
    GGCW_CHECK_STATUS(dict, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    NSMutableArray<NSDictionary *> *as = [NSMutableArray arrayWithCapacity:20];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *a, BOOL *stop) {
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
        [d setValue:[a objectForKey:@"name"] forKey:@"Name"];
        [d setValue:[a objectForKey:@"g"] forKey:@"Id"];
        [d setValue:[a objectForKey:@"count"] forKey:@"Count"];

        NSString *ssize = [a objectForKey:@"size"];
        NSInteger nsize = [ssize integerValue];
        NSRange r = [ssize rangeOfString:@"KB"];
        if (r.location != NSNotFound)
            nsize *= 1024;
        r = [ssize rangeOfString:@"MB"];
        if (r.location != NSNotFound)
            nsize *= 1024 * 1024;

        [d setValue:[NSNumber numberWithInteger:nsize] forKey:@"Size"];
        [as addObject:d];
    }];

    *qs = as;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iv setChunksTotal:ivi total:1];
    [iv setChunksCount:ivi count:1];

    GCDataZIPFile *zipfile = [ggcw pocket_downloadpq:_id infoViewer:iv ivi:ivi];
    GGCW_CHECK_STATUS(zipfile, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    NSString *filename = [NSString stringWithFormat:@"%@.zip", _id];
    [zipfile writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] atomically:YES];
    GCStringFilename *zipfilename = [[GCStringFilename alloc] initWithString:filename];

    InfoItemID iii = [iv addImport];
    [iv setDescription:iii description:IMPORTMSG_PQ];
    [callback remoteAPI_objectReadyToImport:0 ivi:iii object:zipfilename group:group account:self.account];

    [callback remoteAPI_finishedDownloads:0 numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSArray<NSDictionary *> *tbs = [ggcw track_search:iv ivi:ivi];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iv resetBytesChunks:ivi];
    [iv setChunksTotal:ivi total:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary *tb, NSUInteger idx, BOOL *sto) {
        [iv resetBytes:ivi];
        [iv setChunksCount:ivi count:idx + 1];
        NSDictionary *d = [ggcw track_details:nil id:[tb objectForKey:@"id"] infoViewer:iv ivi:ivi];

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

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dict];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSArray<NSDictionary *>*tbs = [ggcw my_inventory:iv ivi:ivi];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iv resetBytesChunks:ivi];
    [iv setChunksTotal:ivi total:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary *tb, NSUInteger idx, BOOL *sto) {
        [iv resetBytes:ivi];
        [iv setChunksCount:ivi count:idx + 1];
        NSDictionary *d = [ggcw track_details:[tb objectForKey:@"guid"] id:nil infoViewer:iv ivi:ivi];

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
        [dict setObject:[tb objectForKey:@"guid"] forKey:@"guid"];
        [dict setObject:[tb objectForKey:@"name"] forKey:@"name"];
        [dict setObject:[d objectForKey:@"id"] forKey:@"id"];
        [dict setObject:[d objectForKey:@"gccode"] forKey:@"gccode"];
        [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
        [dict setObject:[NSNumber numberWithLongLong:self.account.accountname._id] forKey:@"carrier_id"];
        [tbstot addObject:dict];
    }];

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
    [d setObject:tbstot forKey:@"trackables"];

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:d];

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dict];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi
{
    NSDictionary *d = [ggcw track_details:code infoViewer:iv ivi:ivi];

    NSMutableArray<NSDictionary *> *tbs = [NSMutableArray arrayWithCapacity:1];
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

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dictggcw];

    *t = [dbTrackable dbGetByRef:[d objectForKey:@"gccode"]];
    if ([(*t).code isEqualToString:@""] == YES ) {
        (*t).code = code;
        [*t dbUpdate];
    }

    return REMOTEAPI_OK;
}

@end
