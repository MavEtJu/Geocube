/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;

@end

@protocol RemoteAPIRetrieveQueryDelegate

- (void)remoteAPI_objectReadyToImport:(InfoItemImport *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account;

@end

@interface RemoteAPI : NSObject <GCOAuthBlackboxDelegate, ProtocolGCADelegate, ProtocolGGCWDelegate>
{
    ProtocolGCA *gca;
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

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict downloadInfoItem:(InfoItemDownload *)iid;

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(InfoItemDownload *)iid;

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(InfoItemDownload *)iid;
- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByCodes:(NSArray *)wpcodes retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer group:(dbGroup *)group callback:(id<RemoteAPIRetrieveQueryDelegate>)callback;

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(InfoItemDownload *)iid;

- (RemoteAPIResult)listQueries:(NSArray **)qs downloadInfoItem:(InfoItemDownload *)iid;
- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoViewer callback:(id<RemoteAPIRetrieveQueryDelegate>)callback;
- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(InfoItemDownload *)iid infoViewer:(InfoViewer *)infoVIewr callback:(id<RemoteAPIRetrieveQueryDelegate>)callback;

- (RemoteAPIResult)trackablesMine:(InfoItemDownload *)iid;
- (RemoteAPIResult)trackablesInventory:(InfoItemDownload *)iid;
- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t downloadInfoItem:(InfoItemDownload *)iid;

@end
