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

@interface RemoteAPIGGCW ()

@end

@implementation RemoteAPIGGCW

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

    GCDictionaryGGCW *dict = [ggcw my_default:iid];
    GGCW_CHECK_STATUS(dict, @"my_defaults", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
    [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDownload *)iid
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

    NSDictionary *dict = [ggcw geocache:waypoint.wpt_name downloadInfoItem:iid];
    NSString *gc_id = [dict objectForKey:@"gc_id"];
    dict = [ggcw seek_log__form:gc_id downloadInfoItem:iid];
    [ggcw seek_log__submit:gc_id dict:dict logstring:logstring.type dateLogged:dateLogged note:note favpoint:favourite trackables:tbs downloadInfoItem:iid];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDownload *)iid
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.Group_LiveImport;

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

- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObject downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    loadWaypointsLogs = 0;
    loadWaypointsWaypoints = 0;
    *retObject = nil;

    GCDictionaryGGCW *d = [ggcw map:iid];
    self.account.ggcw_username = [d objectForKey:@"usersession.username"];
    self.account.ggcw_sessiontoken = [d objectForKey:@"usersession.sessionToken"];
    if (self.account.ggcw_username == nil || self.account.ggcw_sessiontoken == nil) {
        [self setAPIError:@"Unknown to obtain username or session token" error:REMOTEAPI_APIFAILED];
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

    [infoViewer removeItem:iid];

    NSMutableDictionary *wpcodesall = [NSMutableDictionary dictionaryWithCapacity:100];
    [iid setChunksTotal:(ymax - ymin + 1) * (xmax - xmin + 1)];
    for (NSInteger y = ymin; y <= ymax; y++) {
        for (NSInteger x = xmin; x <= xmax; x++) {
            NSMutableDictionary *wpcodes = [NSMutableDictionary dictionaryWithCapacity:100];

            iid = [infoViewer addDownload];
            [iid setDescription:[NSString stringWithFormat:@"Tile (%ld, %ld)", (long)x, (long)y]];
            [iid setChunksTotal:0];
            [iid setChunksCount:1];
            [iid resetBytes];
            // Without requesting the map tile image the map.info returns sometimes a 204. No idea why.
            [ggcw map_png:x y:y z:ZOOM downloadInfoItem:iid];
            // Now we can (safely?) request the map info details.
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
    [callback remoteAPI_objectReadyToImport:iii object:gpxarray group:group account:self.account];

    [iv removeItem:iid];
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(InfoItemDownload *)iid
{
    NSDictionary *gc = [ggcw geocache:note.wp_name downloadInfoItem:iid];
    GCDictionaryGGCW *json = [ggcw seek_cache__details_SetUserCacheNote:gc text:note.note downloadInfoItem:iid];
    NSNumber *success = [json objectForKey:@"success"];
    if ([success boolValue] == NO)
        return REMOTEAPI_PERSONALNOTE_UPDATEFAILED;

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
    GCDictionaryGGCW *dict = [ggcw pocket_default:iid];
    GGCW_CHECK_STATUS(dict, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback
{
    *retObj = nil;

    [iid setChunksTotal:1];
    [iid setChunksCount:1];

    GCDataZIPFile *zipfile = [ggcw pocket_downloadpq:_id downloadInfoItem:iid];
    GGCW_CHECK_STATUS(zipfile, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    NSString *filename = [NSString stringWithFormat:@"%@.zip", _id];
    [zipfile writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] atomically:YES];
    GCStringFilename *zipfilename = [[GCStringFilename alloc] initWithString:filename];

    InfoItemImport *iii = [infoViewer addImport];
    [callback remoteAPI_objectReadyToImport:iii object:zipfilename group:group account:self.account];

    *retObj = zipfile;
    return REMOTEAPI_OK;

}

- (RemoteAPIResult)trackablesMine:(InfoItemDownload *)iid
{
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

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dict];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesInventory:(InfoItemDownload *)iid
{
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

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t downloadInfoItem:(InfoItemDownload *)iid
{
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
