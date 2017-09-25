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

#import <CoreLocation/CoreLocation.h>

#import "NetworkLibrary/GCOAuthBlackbox-delegate.h"
#import "NetworkLibrary/ProtocolGGCW-delegate.h"
#import "NetworkLibrary/RemoteAPITemplate-enum.h"
#import "NetworkLibrary/RemoteAPITemplate-delegate.h"
#import "ToolsLibrary/InfoItem.h"

@class RemoteAPITemplate;
@class GCBoundingBox;
@class dbLogString;
@class dbImage;
@class dbPersonalNote;
@class dbAccount;
@class dbGroup;
@class dbWaypoint;
@class dbTrackable;
@class ProtocolLiveAPI;
@class ProtocolOKAPI;
@class ProtocolGCA2;
@class ProtocolGGCW;
@class GCOAuthBlackbox;

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

// Supported features
- (BOOL)supportsWaypointPersonalNotes;
- (BOOL)supportsTrackables;
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

- (RemoteAPIResult)UserStatistics:(NSDictionary **)retDict infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)dateLogged note:(NSString *)note favourite:(BOOL)favourite image:(dbImage *)image imageCaption:(NSString *)imageCaption imageDescription:(NSString *)imageDescription rating:(NSInteger)rating trackables:(NSArray<dbTrackable *> *)trackables coordinates:(CLLocationCoordinate2D)coordinates infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)loadWaypoint:(dbWaypoint *)waypoint infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByCodes:(NSArray<NSString *> *)wpcodes infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier group:(dbGroup *)group callback:(id<RemoteAPIDownloadDelegate>)callback;
- (RemoteAPIResult)loadWaypointsByBoundingBox:(GCBoundingBox *)bb infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)updatePersonalNote:(dbPersonalNote *)note infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

- (RemoteAPIResult)listQueries:(NSArray<NSDictionary *> **)qs infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)retrieveQuery:(NSString *)_id group:(dbGroup *)group infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid identifier:(NSInteger)identifier callback:(id<RemoteAPIDownloadDelegate>)callback;

- (RemoteAPIResult)trackablesMine:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)trackablesInventory:(InfoViewer *)iv iiDownload:(InfoItemID)iid;
- (RemoteAPIResult)trackableFind:(NSString *)code trackable:(dbTrackable **)t infoViewer:(InfoViewer *)iv iiDownload:(InfoItemID)iid;

@end
