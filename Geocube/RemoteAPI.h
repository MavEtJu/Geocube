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

@protocol RemoteAPIAuthenticationDelegate

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error;
- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;

@end

@protocol RemoteAPIQueriesDownloadProgressDelegate

- (void)remoteAPIQueriesDownloadUpdate:(NSInteger)offset max:(NSInteger)max;

@end

@protocol RemoteAPILoadWaypointDownloadProgressDelegate

- (void)remoteAPILoadWaypointsImportWaypointCount:(NSInteger)count;
- (void)remoteAPILoadWaypointsImportLogsCount:(NSInteger)count;
- (void)remoteAPILoadWaypointsImportWaypointsTotal:(NSInteger)count;

@end

@interface RemoteAPI : NSObject <GCOAuthBlackboxDelegate, LiveAPIDelegate, OKAPIDelegate, GeocachingAustraliaDelegate>

@property (nonatomic, retain) id delegateQueries;
@property (nonatomic, retain) id delegateLoadWaypoints;

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic) NSInteger stats_found, stats_notfound;
@property (nonatomic) id authenticationDelegate;
@property (nonatomic, retain) NSString *clientMsg;
@property (nonatomic, retain) NSError *clientError;

- (instancetype)init:(dbAccount*)account;
- (BOOL)Authenticate;
- (BOOL)waypointSupportsPersonalNotes;
- (BOOL)commentSupportsPhotos;
- (BOOL)commentSupportsTrackables;
- (BOOL)commentSupportsFavouritePoint;
- (BOOL)commentSupportsRating;
- (NSRange)commentSupportsRatingRange;
- (NSArray *)logtypes:(NSString *)waypointType;

- (NSDictionary *)UserStatistics;
- (NSDictionary *)UserStatistics:(NSString *)username;

- (NSInteger)CreateLogNote:(NSString *)logtype waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray *)trackables;

- (BOOL)loadWaypoint:(dbWaypoint *)waypoint;
- (NSObject *)loadWaypoints:(CLLocationCoordinate2D)center;

- (BOOL)updatePersonalNote:(dbPersonalNote *)note;

- (NSArray *)listQueries;
- (NSObject *)retrieveQuery:(NSString *)_id group:(dbGroup *)group;
- (NSObject *)retrieveQuery_retry:(NSString *)_id group:(dbGroup *)group;

- (void)trackablesMine;
- (void)trackablesInventory;
- (dbTrackable *)trackableFind:(NSString *)code;

@end
