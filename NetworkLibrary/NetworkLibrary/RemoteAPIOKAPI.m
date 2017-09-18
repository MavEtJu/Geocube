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

#import "RemoteAPIOKAPI.h"

#import "BaseObjectsLibrary/GCDictionaryObjects.h"
#import "ToolsLibrary/InfoViewer.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "DatabaseLibrary/dbLogString.h"
#import "DatabaseLibrary/dbWaypoint.h"
#import "DatabaseLibrary/dbAccount.h"
#import "DatabaseLibrary/database-cache.h"

#import "ProtocolOKAPI.h"

@interface RemoteAPIOKAPI ()

@end

@implementation RemoteAPIOKAPI

#define IMPORTMSG   _(@"remoteapiokapi-OKAPI JSON data (queued)")

- (BOOL)supportsWaypointPersonalNotes { return NO; }
- (BOOL)supportsTrackables { return NO; }
- (BOOL)supportsUserStatistics { return YES; }

- (BOOL)supportsLogging { return YES; }
- (BOOL)supportsLoggingFavouritePoint { return NO; }
- (BOOL)supportsLoggingPhotos { return NO; }
- (BOOL)supportsLoggingCoordinates { return NO; }
- (BOOL)supportsLoggingRating { return NO; }
- (NSRange)supportsLoggingRatingRange { return NSMakeRange(0, 0); }

- (BOOL)supportsLoadWaypoint { return YES; }
- (BOOL)supportsLoadWaypointsByCodes { return YES; }
- (BOOL)supportsLoadWaypointsByBoundaryBox { return YES; }

- (BOOL)supportsListQueries { return NO; }
- (BOOL)supportsRetrieveQueries { return NO; }

#define OKAPI_CHECK_STATUS(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) \
                return [self lastErrorCode]; \
            NSDictionary *error = [__json__ objectForKey:@"error"]; \
            if (error != nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiokapi-[OKAPI] %@: Error response: (%@)"), __logsection__, [error description]]; \
                NSLog(@"%@", s); \
                [self setAPIError:s error:REMOTEAPI_APIFAILED]; \
                return REMOTEAPI_APIFAILED; \
            } \
        }

#define OKAPI_GET_VALUE(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiokapi-[OKAPI] %@: No '%@' field returned"), __logsection__, __field__]; \
                [self setDataError:s error:__failure__]; \
                NSLog(@"%@", s); \
                return __failure__; \
            }

#define OKAPI_CHECK_STATUS_CB(__json__, __logsection__, __failure__) { \
            if (__json__ == nil) { \
                [callback remoteAPI_failed:identifier]; \
                return [self lastErrorCode]; \
            } \
            NSDictionary *error = [__json__ objectForKey:@"error"]; \
            if (error != nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiokapi-[OKAPI] %@: Error response: (%@)"), __logsection__, [error description]]; \
                NSLog(@"%@", s); \
                [self setAPIError:s error:REMOTEAPI_APIFAILED]; \
                [callback remoteAPI_failed:identifier]; \
                return REMOTEAPI_APIFAILED; \
            } \
        }

#define OKAPI_GET_VALUE_CB(__json__, __type__, __varname__, __field__, __logsection__, __failure__) \
            __type__ *__varname__ = [__json__ objectForKey:__field__]; \
            if (__varname__ == nil) { \
                NSString *s = [NSString stringWithFormat:_(@"remoteapiokapi-[OKAPI] %@: No '%@' field returned"), __logsection__, __field__]; \
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
    GCDictionaryOKAPI *dict = [okapi services_users_byUsername:username infoViewer:iv iiDownload:iid];
    OKAPI_CHECK_STATUS(dict, @"UserStatistics", REMOTEAPI_USERSTATISTICS_LOADFAILED);

    [self getNumber:ret from:dict outKey:@"waypoints_found" inKey:@"caches_found"];
    [self getNumber:ret from:dict outKey:@"waypoints_notfound" inKey:@"caches_notfound"];
    [self getNumber:ret from:dict outKey:@"waypoints_hidden" inKey:@"caches_hidden"];
    [self getNumber:ret from:dict outKey:@"recommendations_given" inKey:@"rcmds_given"];

    *retDict = ret;
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid
{
    GCDictionaryOKAPI *json = [okapi services_logs_submit:logstring.logString waypointName:waypoint.wpt_name dateLogged:dateLogged note:note favourite:favourite infoViewer:iv iiDownload:iid];
    OKAPI_CHECK_STATUS(json, @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);

    OKAPI_GET_VALUE(json, NSNumber, success, @"success", @"CreateLogNote", REMOTEAPI_CREATELOG_LOGFAILED);
    if ([success boolValue] == NO) {
        NSString *s = [NSString stringWithFormat:_(@"remoteapiokapi-[OKAPI] CreateLogNote: 'success' is not TRUE: %@"), [json objectForKey:@"message"]];
        [self setDataError:s error:REMOTEAPI_CREATELOG_LOGFAILED];
        NSLog(@"%@", s);
        return REMOTEAPI_CREATELOG_LOGFAILED;
    }
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    dbAccount *a = waypoint.account;
    dbGroup *g = dbc.groupLiveImport;

    [iv setChunksTotal:iid total:1];
    [iv setChunksCount:iid count:1];

    GCDictionaryOKAPI *json = [okapi services_caches_geocache:waypoint.wpt_name infoViewer:iv iiDownload:iid];
    OKAPI_CHECK_STATUS_CB(json, @"loadWaypoint", REMOTEAPI_LOADWAYPOINT_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSArray<NSDictionary *> *as = @[[json objectForKey:waypoint.wpt_name]];
    [d setObject:as forKey:@"waypoints"];
    GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:d2 group:g account:a];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback
{
    if ([self.account canDoRemoteStuff] == NO) {
        [self setAPIError:_(@"remoteapiokapi-[OKAPI] loadWaypointsByBoundingBox: remote API is disabled") error:REMOTEAPI_APIDISABLED];
        [callback remoteAPI_failed:identifier];
        return REMOTEAPI_APIDISABLED;
    }

    [iv setChunksTotal:iid total:2];
    [iv setChunksCount:iid count:1];

    GCDictionaryOKAPI *json = [okapi services_caches_search_bbox:bb infoViewer:iv iiDownload:iid];
    OKAPI_CHECK_STATUS_CB(json, @"loadWaypointsByBoundingBox", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    OKAPI_GET_VALUE_CB(json, NSArray, wpcodes, @"results", @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);
    if ([wpcodes count] == 0) {
        [callback remoteAPI_finishedDownloads:identifier numberOfChunks:0];
        return REMOTEAPI_OK;
    }

    [iv setChunksCount:iid count:2];
    json = [okapi services_caches_geocaches:wpcodes infoViewer:iv iiDownload:iid];
    OKAPI_CHECK_STATUS_CB(json, @"loadWaypoints", REMOTEAPI_LOADWAYPOINTS_LOADFAILED);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
    NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:[wpcodes count]];
    [wpcodes enumerateObjectsUsingBlock:^(NSString * _Nonnull wpcode, NSUInteger idx, BOOL * _Nonnull stop) {
        [wps addObject:[json objectForKey:wpcode]];
    }];
    [d setObject:wps forKey:@"waypoints"];

    GCDictionaryOKAPI *d2 = [[GCDictionaryOKAPI alloc] initWithDictionary:d];

    InfoItemID iii = [iv addImport:NO];
    [iv setDescription:iii description:IMPORTMSG];
    [callback remoteAPI_objectReadyToImport:identifier iiImport:iii object:d2 group:nil account:self.account];

    [callback remoteAPI_finishedDownloads:identifier numberOfChunks:1];
    return REMOTEAPI_OK;
}

@end
