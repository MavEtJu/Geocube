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

typedef NS_ENUM(NSInteger, RemoteAPIResult) {
    REMOTEAPI_OK = 0,
    REMOTEAPI_APIREFUSED,               // Couldn't connect to the API
    REMOTEAPI_APIFAILED,                // Invalid values returned
    REMOTEAPI_APIDISABLED,              // No authentication details

    REMOTEAPI_JSONINVALID,              // JSON couldn't be parsed cleanly

    REMOTEAPI_NOTPROCESSED,             // Not supported in this protocol

    REMOTEAPI_USERSTATISTICS_LOADFAILED,    // Unable to load user statistics
    REMOTEAPI_CREATELOG_LOGFAILED,          // Unable to create the log
    REMOTEAPI_CREATELOG_IMAGEFAILED,        // Unable to upload the image
    REMOTEAPI_LOADWAYPOINT_LOADFAILED,      // Unable to load the waypoint
    REMOTEAPI_LOADWAYPOINTS_LOADFAILED,     // Unable to load the waypoints
    REMOTEAPI_LISTQUERIES_LOADFAILED,       // Unable to load the list of queries
    REMOTEAPI_PERSONALNOTE_UPDATEFAILED,    // Unable to update the personal note
    REMOTEAPI_RETRIEVEQUERY_LOADFAILED,     // Unable to load the query
    REMOTEAPI_TRACKABLES_FINDFAILED,        // Unable to find the trackable
    REMOTEAPI_TRACKABLES_INVENTORYLOADFAILED,// Unable to load the trackables inventory
    REMOTEAPI_TRACKABLES_OWNEDLOADFAILED,   // Unable to load the trackables owned
};

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPITemplate *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPITemplate *)api success:(NSString *)success;

@end

@protocol RemoteAPIDownloadDelegate

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier iiImport:(InfoItemID)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account;
- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks;
- (void)remoteAPI_failed:(NSInteger)identifier;

@end

@interface RemoteAPITemplate : NSObject <GCOAuthBlackboxDelegate, ProtocolGGCWDelegate>
{
    ProtocolLiveAPI *liveAPI;
    ProtocolOKAPI *okapi;
    ProtocolGCA2 *gca2;
    ProtocolGGCW *ggcw;

    NSInteger loadWaypointsLogs, loadWaypointsWaypoints;
}

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic) NSInteger stats_found, stats_notfound;
@property (nonatomic) id<RemoteAPIAuthenticationDelegate> authenticationDelegate;

- (instancetype)init:(dbAccount *)account;
- (BOOL)Authenticate;

- (BOOL)waypointSupportsPersonalNotes;
- (BOOL)commentSupportsPhotos;
- (BOOL)commentSupportsTrackables;
- (BOOL)commentSupportsFavouritePoint;
- (BOOL)commentSupportsRating;
- (NSRange)commentSupportsRatingRange;

- (BOOL)supportsUserStatistics;
- (BOOL)supportsLoadWaypoint;
- (BOOL)supportsLoadWaypointsByCenter;
- (BOOL)supportsLoadWaypointsByCodes;
- (BOOL)supportsLoadWaypointsByBoundaryBox;
- (BOOL)supportsListQueries;
- (BOOL)supportsRetrieveQueries;
- (BOOL)supportsTrackables;
- (BOOL)supportsLogging;

// Feedback from the network error and the data interpretation
// - Network error: Connection refused, HTTP error
// - API error: A failed request (status code)
// - Data error: Interpretation of the returned data fails.
- (void)setNetworkError:(NSString *)errorString error:(RemoteAPIResult)errorCode;
- (void)setAPIError:(NSString *)errorString error:(RemoteAPIResult)errorCode;
- (void)setDataError:(NSString *)errorString error:(RemoteAPIResult)errorCode;
- (void)clearErrors;
- (RemoteAPIResult)lastErrorCode;
- (NSString *)lastNetworkError;
- (NSString *)lastAPIError;
- (NSString *)lastDataError;
- (NSString *)lastError;

- (void)getNumber:(NSDictionary *)out from:(id)in outKey:(NSString *)outKey inKey:(NSString *)inKey;

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByCenter:(CLLocationCoordinate2D)center infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
