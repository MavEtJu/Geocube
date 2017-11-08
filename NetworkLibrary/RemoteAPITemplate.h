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

@interface RemoteAPITemplate : NSObject <GCOAuthBlackboxDelegate, ProtocolGGCWDelegate>

@property (nonatomic, retain) ProtocolLiveAPI *liveAPI;
@property (nonatomic, retain) ProtocolOKAPI *okapi;
@property (nonatomic, retain) ProtocolGCA2 *gca2;
@property (nonatomic, retain) ProtocolGGCW *ggcw;

@property (nonatomic        ) NSInteger loadWaypointsLogs, loadWaypointsWaypoints;

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) GCOAuthBlackbox *oabb;
@property (nonatomic        ) NSInteger stats_found, stats_notfound;
@property (nonatomic        ) id<RemoteAPIAuthenticationDelegate> authenticationDelegate;

- (instancetype)init:(dbAccount *)account;
- (BOOL)Authenticate;

// Supported features
- (BOOL)supportsWaypointPersonalNotes;
- (BOOL)supportsTrackablesLog;
- (BOOL)supportsTrackablesRetrieve;
- (BOOL)supportsUserStatistics;

- (BOOL)supportsLogging;
- (BOOL)supportsLoggingFavouritePoint;
- (BOOL)supportsLoggingPhotos;
- (BOOL)supportsLoggingCoordinates;
- (BOOL)supportsLoggingTrackables;
- (BOOL)supportsLoggingRating;
- (NSRange)supportsLoggingRatingRange;

- (BOOL)supportsLoadWaypoint;
- (BOOL)supportsLoadWaypointsByCodes;
- (BOOL)supportsLoadWaypointsByBoundaryBox;

- (BOOL)supportsListQueries;
- (BOOL)supportsRetrieveQueries;

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

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict infoItem:(InfoItem *)iid;

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoItem:(InfoItem *)iid;

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoItem:(InfoItem *)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoItem:(InfoItem *)iid;

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoItem:(InfoItem *)iid public:(BOOL)public;
- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoItem:(InfoItem *)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)trackablesMine:(InfoItem *)iid;
- (RemoteAPIResult)trackablesInventory:(InfoItem *)iid;
- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoItem:(InfoItem *)iid;
- (RemoteAPIResult)trackableDrop:(dbTrackable *)trackable waypoint:(NSString *)wptname infoItem:(InfoItem *)iid;
- (RemoteAPIResult)trackableGrab:(NSString *)tbpin infoItem:(InfoItem *)iid;
- (RemoteAPIResult)trackableDiscover:(NSString *)tbpin infoItem:(InfoItem *)iid;

@end
