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

@interface RemoteAPIGGCW ()

@property (nonatomic) NSInteger threadcounter;

@end

@implementation RemoteAPIGGCW

#define IMPORTMSG_GPX   _(@"remoteapiggcw-Geocaching.com GPX Garmin data (queued)")
#define IMPORTMSG_PQ    _(@"remoteapiggcw-Geocaching.com Pocket Query data (queued)")

- (BOOL)supportsWaypointPersonalNotes { return NO; }
- (BOOL)supportsTrackablesRetrieve { return YES; }
- (BOOL)supportsTrackablesLog { return NO; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return YES; }
- (BOOL)supportsLoggingFavouritePoint { return YES; }
- (BOOL)supportsLoggingPhotos { return NO; }
- (BOOL)supportsLoggingCoordinates { return NO; }
- (BOOL)supportsLoggingTrackables { return YES; }
- (BOOL)supportsLoggingCodeword { return NO; }
- (BOOL)supportsLoggingRating { return NO; }
- (NSRange)supportsLoggingRatingRange { return NSMakeRange(0, 0); }

- (BOOL)supportsLoadWaypoint { return YES; }
- (BOOL)supportsLoadWaypointsByCodes { return NO; }
- (BOOL)supportsLoadWaypointsByBoundaryBox { return YES; }

- (BOOL)supportsListQueries { return YES; }
- (BOOL)supportsRetrieveQueries { return YES; }

#define GGCW_CHECK_STATUS(__json__, __logsection__, __failure__) { \
        }

#define GGCW_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            [callback remoteAPI_failed:iv identifier:identifier]; \
        }

- (RemoteAPIResult)UserStatistics:(NSString *)username retDict:(NSDictionary **)retDict infoItem:(InfoItem *)iid
{
/* Returns:
 * waypoints_found
 * waypoints_notfound
 * waypoints_hidden
 * recommendations_given
 * recommendations_received
 */
    [self clearErrors];

    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setValue:@"" forKey:@"waypoints_found"];
    [ret setValue:@"" forKey:@"waypoints_notfound"];
    [ret setValue:@"" forKey:@"waypoints_hidden"];
    [ret setValue:@"" forKey:@"recommendations_given"];
    [ret setValue:@"" forKey:@"recommendations_received"];

    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCDictionaryGGCW *dict = [self.ggcw my_statistics:iid];
    GGCW_CHECK_STATUS(dict, @"my_statistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates codeword:(NSString *)codeword infoItem:(InfoItem *)iid
{
    GCDictionaryGGCW *params = [self.ggcw play_serverparameters_params];
    NSString *ownerReferenceCode = [[params objectForKey:@"user:info"] objectForKey:@"referenceCode"];
//  NSString *ownerUsername = [[params objectForKey:@"user:info"] objectForKey:@"username"];
//  NSString *ownerLocalRegion = [[params objectForKey:@"app:options"] objectForKey:@"localRegion"];

    GCDictionaryGGCW *tokens = [self.ggcw account_oauth_token];
    NSString *access_token = [tokens objectForKey:@"access_token"];

//  GCDictionaryGGCW *settings = [self.ggcw api_proxy_web_v1_users_settings:ownerReferenceCode accessToken:access_token];
    GCDictionaryGGCW *geocache = [self.ggcw api_proxy_web_v1_geocache:waypoint.wpt_name accessToken:access_token];
    NSString *geocache_id = [[geocache objectForKey:@"id"] stringValue];
    NSString *ownerId = [[[geocache objectForKey:@"owner"] objectForKey:@"id"] stringValue];
    NSString *geocacheType_id = [[[geocache objectForKey:@"geocacheType"] objectForKey:@"id"] stringValue];
    NSString *geocacheType_name = [[geocache objectForKey:@"geocacheType"] objectForKey:@"name"];
    NSString *geocacheState_isArchived = [[[geocache objectForKey:@"state"] objectForKey:@"isArchived"] stringValue];
    NSString *geocacheState_isAvailable = [[[geocache objectForKey:@"state"] objectForKey:@"isAvailable"] stringValue];
    NSString *geocacheState_isLocked = [[[geocache objectForKey:@"state"] objectForKey:@"isLocked"] stringValue];

    NSNumber *favpoint = [NSNumber numberWithBool:favourite];

    NSDictionary *dict = @{
                           @"geocache_id":geocache_id,
                           @"geocache_wptname":waypoint.wpt_name,
                           @"owner_referencecode":ownerReferenceCode,
                           @"owner_id":ownerId,
                           @"geocacheType_id":geocacheType_id,
                           @"geocacheType_name":geocacheType_name,
                           @"geocacheState_isArchived":geocacheState_isArchived,
                           @"geocacheState_isAvailable":geocacheState_isAvailable,
                           @"geocacheState_isLocked":geocacheState_isLocked,
                           @"log_type":logstring.logString,
                           @"log_date":dateLogged,
                           @"log_text":note,
                           @"favourite_point":favpoint,
                           };

    GCDictionaryGGCW *log = [self.ggcw api_proxy_web_v1_Geocache_GeocacheLog:waypoint.wpt_name dict:dict accessToken:access_token];

    NSString *errormsg = [log objectForKey:@"errorMessage"];
    if (errormsg == nil)
        return REMOTEAPI_OK;

    [self setAPIError:@"Unable to upload the log" error:REMOTEAPI_CREATELOG_LOGFAILED];
    return REMOTEAPI_CREATELOG_LOGFAILED;
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
    GCDictionaryGGCW *dict = [self.ggcw pocket_default:iid];
    GGCW_CHECK_STATUS(dict, @"ListQueries", REMOTEAPI_LISTQUERIES_LOADFAILED);

    NSMutableArray<NSDictionary *> *as = [NSMutableArray arrayWithCapacity:20];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary *a, BOOL * _Nonnull stop) {
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCDataZIPFile *zipfile = [self.ggcw pocket_downloadpq:_id infoItem:iid];
    GGCW_CHECK_STATUS(zipfile, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    NSString *filename = [NSString stringWithFormat:@"%@.zip", _id];
    [zipfile writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] atomically:YES];
    GCStringFilename *zipfilename = [[GCStringFilename alloc] initWithString:filename];

    InfoItem *iii = [iid.infoViewer addImport];
    [iii changeDescription:IMPORTMSG_PQ];
    [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:zipfilename group:group account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    GCStringGPX *gpx = [self.ggcw geocache_gpx:waypoint.wpt_name infoItem:iid];
    [callback remoteAPI_objectReadyToImport:identifier infoItem:iid object:gpx group:dbc.groupManualWaypoints account:self.account];
    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    /*
     * Use /play/search with the current coordinates to obtain the list of names of nearby waypoints.
     * Use /geocaching/GC1234, expect a redirect to /geocube/GC1234-foobar, obtain the GPX file from there.
     */

    [iid changeChunksTotal:1];
    [iid changeChunksCount:1];

    /* Not really a bounding box... */
    CLLocationCoordinate2D c = CLLocationCoordinate2DMake((bb.topLat + bb.bottomLat) / 2, (bb.leftLon + bb.rightLon) / 2);
    NSArray<NSString *> *wptnames = [self.ggcw play_search:c infoItem:iid];

    [iid changeChunksTotal:[wptnames count]];
    [iid changeChunksCount:1];

    [wptnames enumerateObjectsUsingBlock:^(NSString * _Nonnull wptname, NSUInteger idx, BOOL * _Nonnull stop) {
        [iid changeChunksCount:idx + 1];

        while (self.threadcounter > configManager.mapsearchGGCWNumberThreads)
            [NSThread sleepForTimeInterval:0.5];

        @synchronized(self) { self.threadcounter++; }
        NSDictionary *d = @{@"wptname":wptname,
                            @"infoitem":iid == nil ? [NSNull null] : iid,
                            @"callback":callback,
                            @"identifier":[NSNumber numberWithInteger:identifier],
                            };
        BACKGROUND(loadWaypointsByBoundingBox_BG:, d);
    }];
    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:[wptnames count]];

    return REMOTEAPI_OK;
}

- (void)loadWaypointsByBoundingBox_BG:(NSDictionary *)d
{
    NSInteger identifier = [[d objectForKey:@"identifier"] integerValue];
    InfoItem *iid = [d objectForKey:@"infoitem"];
    NSString *wptname = [d objectForKey:@"wptname"];

    if (IS_NULL(iid))
        iid = nil;

    id<RemoteAPIDownloadDelegate> callback = [d objectForKey:@"callback"];
    GCStringGPX *gpx = [self.ggcw geocache_gpx:wptname infoItem:iid];

    InfoItem *iii = [iid.infoViewer addImport];
    [callback remoteAPI_objectReadyToImport:identifier infoItem:iii object:gpx group:dbc.groupManualWaypoints account:self.account];

    @synchronized(self) { self.threadcounter--; }
}

- (RemoteAPIResult)trackablesMine:(InfoItem *)iid
{
    NSArray<NSDictionary *> *tbs = [self.ggcw track_search:iid];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iid resetBytesChunks];
    [iid changeChunksTotal:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull sto) {
        [iid resetBytes];
        [iid changeChunksCount:idx + 1];
        NSDictionary *d = [self.ggcw track_details:nil id:[tb objectForKey:@"id"] infoItem:iid];

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
        [dict setObject:[d objectForKey:@"guid"] forKey:@"guid"];
        [dict setObject:[tb objectForKey:@"name"] forKey:@"name"];
        [dict setObject:[tb objectForKey:@"id"] forKey:@"id"];
        [dict setObject:[d objectForKey:@"tbcode"] forKey:@"tbcode"];
        [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
        if ([d objectForKey:@"carrier"] != nil)
            [dict setObject:[d objectForKey:@"carrier"] forKey:@"carrier"];
        else if ([tb objectForKey:@"carrier"] != nil)
            [dict setObject:[tb objectForKey:@"carrier"] forKey:@"carrier"];
        if ([d objectForKey:@"location"] != nil)
            [dict setObject:[d objectForKey:@"location"] forKey:@"location"];
        else if ([tb objectForKey:@"location"] != nil)
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

- (RemoteAPIResult)trackablesInventory:(InfoItem *)iid
{
    NSArray<NSDictionary *>*tbs = [self.ggcw my_inventory:iid];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iid resetBytesChunks];
    [iid changeChunksTotal:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull sto) {
        [iid resetBytes];
        [iid changeChunksCount:idx + 1];
        NSDictionary *d = [self.ggcw track_details:[tb objectForKey:@"guid"] id:nil infoItem:iid];

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
        [dict setObject:[tb objectForKey:@"guid"] forKey:@"guid"];
        [dict setObject:[tb objectForKey:@"name"] forKey:@"name"];
        [dict setObject:[d objectForKey:@"id"] forKey:@"id"];
        [dict setObject:[d objectForKey:@"tbcode"] forKey:@"tbcode"];
        [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
        [dict setObject:[d objectForKey:@"carrier"] forKey:@"carrier"];
        [tbstot addObject:dict];
    }];

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:1];
    [d setObject:tbstot forKey:@"trackables"];

    GCDictionaryGGCW *dict = [[GCDictionaryGGCW alloc] initWithDictionary:d];

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dict];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackableFind:(NSString *)pin trackable:(dbTrackable **)t infoItem:(InfoItem *)iid
{
    NSDictionary *d = [self.ggcw track_details:pin infoItem:iid];

    if (d == nil)
        return REMOTEAPI_TRACKABLES_FINDFAILED;

    NSMutableArray<NSDictionary *> *tbs = [NSMutableArray arrayWithCapacity:1];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    [dict setObject:[d objectForKey:@"guid"] forKey:@"guid"];
    [dict setObject:[d objectForKey:@"name"] forKey:@"name"];
    [dict setObject:[d objectForKey:@"id"] forKey:@"id"];
    [dict setObject:[d objectForKey:@"tbcode"] forKey:@"tbcode"];
    [dict setObject:[d objectForKey:@"owner"] forKey:@"owner"];
    [dict setObject:[d objectForKey:@"pin"] forKey:@"pin"];
    [tbs addObject:dict];

    NSMutableDictionary *dd = [NSMutableDictionary dictionaryWithCapacity:1];
    [dd setObject:tbs forKey:@"trackables"];

    GCDictionaryGGCW *dictggcw = [[GCDictionaryGGCW alloc] initWithDictionary:dd];

    ImportGGCWJSON *imp = [[ImportGGCWJSON alloc] init:nil account:self.account];
    [imp parseDictionary:dictggcw];

    *t = [dbTrackable dbGetByTBCode:[d objectForKey:@"tbcode"]];
    if (IS_EMPTY((*t).pin) == YES) {
        (*t).pin = pin;
        [*t dbUpdate];
    }

    return REMOTEAPI_OK;
}

@end
