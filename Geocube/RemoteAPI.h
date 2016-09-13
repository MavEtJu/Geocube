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

    REMOTEAPI_NOTPROCESSED,             // Not supported in this protocol

    REMOTEAPI_CREATELOG_LOGFAILED,      // Unable to create the log
    REMOTEAPI_CREATELOG_IMAGEFAILED,    // Unable to upload the image
    REMOTEAPI_LOADWAYPOINT_LOADFAILED,  // Unable to load the waypoint
    REMOTEAPI_LOADWAYPOINTS_LOADFAILED, // Unable to load the waypoints
    REMOTEAPI_LISTQUERIES_LOADFAILED,   // Unable to load the list of queries
};

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;

@end

@interface RemoteAPI : NSObject <GCOAuthBlackboxDelegate, RemoteAPI_GCADelegate>

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic) NSInteger stats_found, stats_notfound;
@property (nonatomic) id<RemoteAPIAuthenticationDelegate> authenticationDelegate;

@property (nonatomic, retain) NSString *errorMsg;
@property (nonatomic, retain) NSError *error;
@property (nonatomic) NSInteger errorCode;

- (instancetype)init:(dbAccount *)account;
- (BOOL)Authenticate;
- (BOOL)waypointSupportsPersonalNotes;
- (BOOL)commentSupportsPhotos;
- (BOOL)commentSupportsTrackables;
- (BOOL)commentSupportsFavouritePoint;
- (BOOL)commentSupportsRating;
- (NSRange)commentSupportsRatingRange;

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict downloadInfoItem:(DownloadInfoItem *)dii;

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables downloadInfoItem:(DownloadInfoItem *)dii;

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint downloadInfoItem:(DownloadInfoItem *)dii;
- (RemoteAPIResult)loadWaypoints:(CLLocationCoordinate2D)center retObj:(NSObject **)retObj downloadInfoItem:(DownloadInfoItem *)dii;

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note downloadInfoItem:(DownloadInfoItem *)dii;

- (RemoteAPIResult)listQueries:(NSArray **)qs downloadInfoItem:(DownloadInfoItem *)dii;
- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(DownloadInfoItem *)dii;
- (RemoteAPIResult)retrieveQuery_forcegpx:(NSString *)_id group:(dbGroup *)group retObj:(NSObject **)retObj downloadInfoItem:(DownloadInfoItem *)dii;

- (void)trackablesMine:(DownloadInfoItem *)dii;
- (void)trackablesInventory:(DownloadInfoItem *)dii;
- (dbTrackable *)trackableFind:(NSString *)code downloadInfoItem:(DownloadInfoItem *)dii;

@end
