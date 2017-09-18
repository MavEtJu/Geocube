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

#import "RemoteAPIGGCW.h"

#import "DatabaseLibrary/dbWaypoint.h"
#import "DatabaseLibrary/dbTrackable.h"
#import "DatabaseLibrary/dbLogString.h"
#import "DatabaseLibrary/dbPersonalNote.h"
#import "DatabaseLibrary/dbAccount.h"
#import "DatabaseLibrary/dbName.h"
#import "DatabaseLibrary/DatabaseCache.h"
#import "ToolsLibrary/InfoViewer.h"
#import "ToolsLibrary/InfoItem.h"
#import "ToolsLibrary/MyTools.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "BaseObjectsLibrary/GCArrayObjects.h"
#import "BaseObjectsLibrary/GCDictionaryObjects.h"
#import "BaseObjectsLibrary/GCStringObjects.h"
#import "BaseObjectsLibrary/GCDataObjects.h"
#import "NetworkLibrary/ProtocolGGCW.h"
#import "ConvertorsLibrary/ImportGGCWJSON.h"

@interface RemoteAPIGGCW ()

@end

@implementation RemoteAPIGGCW

#define IMPORTMSG_GPX   _(@"remoteapiggcw-Geocaching.com GPX Garmin data (queued)")
#define IMPORTMSG_PQ    _(@"remoteapiggcw-Geocaching.com Pocket Query data (queued)")

- (BOOL)supportsWaypointPersonalNotes { return NO; }
- (BOOL)supportsTrackables { return NO; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return NO; }
- (BOOL)supportsLoggingFavouritePoint { return NO; }
- (BOOL)supportsLoggingPhotos { return NO; }
- (BOOL)supportsLoggingCoordinates { return NO; }
- (BOOL)supportsLoggingRating { return NO; }
- (NSRange)supportsLoggingRatingRange { return NSMakeRange(0, 0); }

- (BOOL)supportsLoadWaypoint { return YES; }
- (BOOL)supportsLoadWaypointsByCodes { return NO; }
- (BOOL)supportsLoadWaypointsByBoundaryBox { return NO; }

- (BOOL)supportsListQueries { return YES; }
- (BOOL)supportsRetrieveQueries { return YES; }

#define GGCW_CHECK_STATUS(__json__, __logsection__, __failure__) { \
        }

#define GGCW_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            [callback remoteAPI_failed:iv identifier:identifier]; \
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

    GCDictionaryGGCW *dict = [ggcw my_statistics:iv iiDownload:iid];
    GGCW_CHECK_STATUS(dict, @"my_statistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSMutableDictionary *tbs = [NSMutableDictionary dictionaryWithCapacity:[trackables count]];
    [trackables enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
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

//    NSDictionary *dict = [ggcw geocache:waypoint.wpt_name infoViewer:iv iiDownload:iid];
//    NSString *gc_id = [dict objectForKey:@"gc_id"];
    NSDictionary *dict = [ggcw play_geocache_log__form:waypoint.wpt_name infoViewer:iv iiDownload:iid];
    [ggcw play_geocache_log__submit:waypoint.wpt_name dict:dict logstring:logstring.logString dateLogged:dateLogged note:note favpoint:favourite infoViewer:iv iiDownload:iid];
    if ([trackables count] > 0)
        [ggcw api_proxy_trackable_activities:waypoint.wpt_name trackables:trackables dateLogged:dateLogged infoViewer:iv iiDownload:iid];

    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.groupLiveImport;

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCStringGPX *gpx = [ggcw geocache_gpx:waypoint.wpt_name infoViewer:iv iiDownload:iid];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG_GPX];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:gpx group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
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
    [[wpcodes allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
        [iv setChunksCount:iid count:idx + 1];
        [iv resetBytes:iid];

        GCDictionaryGGCW *d = [ggcw map_details:wpcode infoViewer:iv iiDownload:iid];
        if (d == nil) {
            [callback remoteAPI_failed:identifier];
            return;
        }
        NSArray<NSDictionary *> *data = [d objectForKey:@"data"];
        NSDictionary *dict = [data objectAtIndex:0];

        GCStringGPXGarmin *gpx = [ggcw seek_sendtogps:[dict objectForKey:@"g"] infoViewer:iv iiDownload:iid];
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
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:gpxarray group:group account:self.account];

    [iv removeItem:iid];
}

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSDictionary *gc = [ggcw geocache:note.wp_name infoViewer:iv iiDownload:iid];
    GCDictionaryGGCW *json = [ggcw seek_cache__details_SetUserCacheNote:gc text:note.note infoViewer:iv iiDownload:iid];
    NSNumber *success = [json objectForKey:@"success"];
    if ([success boolValue] == NO)
        return REMOTEAPI_PERSONALNOTE_UPDATEFAILED;

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
    GCDictionaryGGCW *dict = [ggcw pocket_default:iv iiDownload:iid];
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

- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDataZIPFile *zipfile = [ggcw pocket_downloadpq:_id infoViewer:iv iiDownload:iid];
    GGCW_CHECK_STATUS(zipfile, @"retrieveQuery", REMOTEAPI_RETRIEVEQUERY_LOADFAILED);

    NSString *filename = [NSString stringWithFormat:@"%@.zip", _id];
    [zipfile writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], filename] atomically:YES];
    GCStringFilename *zipfilename = [[GCStringFilename alloc] initWithString:filename];

    InfoItemID iii = [iv addImport];
    [iv setDescription:iii description:IMPORTMSG_PQ];
    [callback remoteAPI_objectReadyToImport:0 iiImport:iii object:zipfilename group:group account:self.account];

    [callback remoteAPI_finishedDownloads:0 numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSArray<NSDictionary *> *tbs = [ggcw track_search:iv iiDownload:iid];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iv resetBytesChunks:iid];
    [iv setChunksTotal:iid total:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull sto) {
        [iv resetBytes:iid];
        [iv setChunksCount:iid count:idx + 1];
        NSDictionary *d = [ggcw track_details:nil id:[tb objectForKey:@"id"] infoViewer:iv iiDownload:iid];

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

- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSArray<NSDictionary *>*tbs = [ggcw my_inventory:iv iiDownload:iid];
    NSMutableArray<NSDictionary *> *tbstot = [NSMutableArray arrayWithCapacity:[tbs count]];
    [iv resetBytesChunks:iid];
    [iv setChunksTotal:iid total:[tbs count]];
    [tbs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull sto) {
        [iv resetBytes:iid];
        [iv setChunksCount:iid count:idx + 1];
        NSDictionary *d = [ggcw track_details:[tb objectForKey:@"guid"] id:nil infoViewer:iv iiDownload:iid];

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

- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    NSDictionary *d = [ggcw track_details:code infoViewer:iv iiDownload:iid];

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
