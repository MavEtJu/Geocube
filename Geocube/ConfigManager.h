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

@interface ConfigManager : NSObject

// System settings
@property (nonatomic, retain) NSString *currentWaypoint;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger currentPageTab;

@property (nonatomic) NSId currentTrack;

@property (nonatomic) NSInteger lastImportSource;
@property (nonatomic) NSInteger lastImportGroup;
@property (nonatomic) NSInteger lastAddedGroup;

@property (nonatomic) NSString *keyGMS;
@property (nonatomic) NSString *keyMapbox;
@property (nonatomic) NSString *keyGCAAPI;

// User settings
@property (nonatomic) BOOL distanceMetric;
@property (nonatomic) BOOL sendTweets;

@property (nonatomic) NSInteger mapExternal;
@property (nonatomic) NSInteger mapBrand;
@property (nonatomic) UIColor  *mapTrackColour;
@property (nonatomic) UIColor  *mapDestinationColour;
@property (nonatomic) NSInteger compassType;
@property (nonatomic) NSInteger themeType;

@property (nonatomic) BOOL soundDirection;
@property (nonatomic) BOOL soundDistance;

@property (nonatomic) BOOL keeptrackAutoRotate;
@property (nonatomic) float keeptrackTimeDeltaMin;
@property (nonatomic) float keeptrackTimeDeltaMax;
@property (nonatomic) NSInteger keeptrackDistanceDeltaMin;
@property (nonatomic) NSInteger keeptrackDistanceDeltaMax;
@property (nonatomic) NSInteger keeptrackPurgeAge;
@property (nonatomic) NSInteger keeptrackSync;

@property (nonatomic) BOOL mapClustersEnable;
@property (nonatomic) float mapClustersZoomLevel;
@property (nonatomic) BOOL mapRotateToBearing;

@property (nonatomic, retain) UIFont *GCLabelFont;
@property (nonatomic, retain) UIFont *GCSmallFont;
@property (nonatomic, retain) UIFont *GCTextblockFont;

@property (nonatomic) BOOL dynamicmapEnable;    // Not read-only
@property (nonatomic) NSInteger dynamicmapWalkingSpeed;
@property (nonatomic) NSInteger dynamicmapWalkingDistance;
@property (nonatomic) NSInteger dynamicmapCyclingSpeed;
@property (nonatomic) NSInteger dynamicmapCyclingDistance;
@property (nonatomic) NSInteger dynamicmapDrivingSpeed;
@property (nonatomic) NSInteger dynamicmapDrivingDistance;

@property (nonatomic) BOOL mapcacheEnable;
@property (nonatomic) NSInteger mapcacheMaxAge;
@property (nonatomic) NSInteger mapcacheMaxSize;

@property (nonatomic) BOOL downloadImagesLogs;
@property (nonatomic) BOOL downloadImagesWaypoints;
@property (nonatomic) BOOL downloadImagesMobile;
@property (nonatomic) BOOL downloadQueriesMobile;
@property (nonatomic) NSInteger downloadTimeoutSimple;
@property (nonatomic) NSInteger downloadTimeoutQuery;

@property (nonatomic) NSInteger mapSearchMaximumNumberGCA;
@property (nonatomic) NSInteger mapSearchMaximumDistanceGS;
@property (nonatomic) NSInteger mapSearchMaximumDistanceOKAPI;
@property (nonatomic) NSInteger mapSearchMaximumDistanceGCA;

@property (nonatomic) BOOL markasFoundDNFClearsTarget;
@property (nonatomic) BOOL markasFoundMarksAllWaypoints;
@property (nonatomic) BOOL loggingRemovesMarkedAsFoundDNF;

@property (nonatomic) BOOL compassAlwaysInPortraitMode;
@property (nonatomic) BOOL showCountryAsAbbrevation;
@property (nonatomic) BOOL showStateAsAbbrevation;
@property (nonatomic) BOOL showStateAsAbbrevationIfLocaleExists;

@property (nonatomic) NSInteger waypointListSortBy;
@property (nonatomic) BOOL refreshWaypointAfterLog;

@property (nonatomic) BOOL accountsSaveAuthenticationName;
@property (nonatomic) BOOL accountsSaveAuthenticationPassword;

@property (nonatomic) BOOL gpsAdjustmentEnable;
@property (nonatomic) NSInteger gpsAdjustmentLatitude;
@property (nonatomic) NSInteger gpsAdjustmentLongitude;

// Bitmask of:
// UIInterfaceOrientationMaskPortrait, UIInterfaceOrientationMaskPortraitUpsideDown
// UIInterfaceOrientationMaskLandscapeLeft, UIInterfaceOrientationMaskLandscapeRight
@property (nonatomic) NSInteger orientationsAllowed;

- (void)keyGMSUpdate:(NSString *)value;
- (void)keyMapboxUpdate:(NSString *)value;
- (void)keyGCAAPIUpdate:(NSString *)value;

- (void)distanceMetricUpdate:(BOOL)value;
- (void)sendTweetsUpdate:(BOOL)value;
- (void)currentWaypointUpdate:(NSString *)name;
- (void)currentPageUpdate:(NSInteger)value;
- (void)currentPageTabUpdate:(NSInteger)value;
- (void)currentTrackUpdate:(NSId)value;
- (void)lastAddedGroupUpdate:(NSInteger)value;
- (void)lastImportGroupUpdate:(NSInteger)value;
- (void)lastImportSourceUpdate:(NSInteger)value;
- (void)mapExternalUpdate:(NSInteger)value;
- (void)mapBrandUpdate:(NSInteger)value;
- (void)mapTrackColourUpdate:(NSString *)value;
- (void)mapDestinationColourUpdate:(NSString *)value;
- (void)compassTypeUpdate:(NSInteger)value;
- (void)themeTypeUpdate:(NSInteger)value;
- (void)soundDirectionUpdate:(BOOL)value;
- (void)soundDistanceUpdate:(BOOL)value;
- (void)keeptrackAutoRotateUpdate:(BOOL)value;
- (void)keeptrackTimeDeltaMinUpdate:(float)value;
- (void)keeptrackTimeDeltaMaxUpdate:(float)value;
- (void)keeptrackDistanceDeltaMinUpdate:(NSInteger)value;
- (void)keeptrackDistanceDeltaMaxUpdate:(NSInteger)value;
- (void)keeptrackPurgeAgeUpdate:(NSInteger)value;
- (void)keeptrackSync:(NSInteger)value;
- (void)mapClustersUpdateEnable:(BOOL)value;
- (void)mapClustersUpdateZoomLevel:(float)value;
- (void)mapRotateToBearingUpdate:(BOOL)value;
- (void)dynamicmapEnableUpdate:(BOOL)value;
- (void)dynamicmapWalkingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapWalkingDistanceUpdate:(NSInteger)value;
- (void)dynamicmapCyclingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapCyclingDistanceUpdate:(NSInteger)value;
- (void)dynamicmapDrivingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapDrivingDistanceUpdate:(NSInteger)value;
- (void)mapcacheEnableUpdate:(BOOL)value;
- (void)mapcacheMaxAgeUpdate:(NSInteger)value;
- (void)mapcacheMaxSizeUpdate:(NSInteger)value;
- (void)downloadImagesLogsUpdate:(BOOL)value;
- (void)downloadImagesWaypointsUpdate:(BOOL)value;
- (void)downloadImagesMobileUpdate:(BOOL)value;
- (void)downloadQueriesMobileUpdate:(BOOL)value;
- (void)downloadTimeoutSimpleUpdate:(NSInteger)value;
- (void)downloadTimeoutQueryUpdate:(NSInteger)value;
- (void)mapSearchMaximumNumberGCAUpdate:(NSInteger)value;
- (void)mapSearchMaximumDistanceGSUpdate:(NSInteger)value;
- (void)mapSearchMaximumDistanceOKAPIUpdate:(NSInteger)value;
- (void)mapSearchMaximumDistanceGCAUpdate:(NSInteger)value;
- (void)orientationsAllowedUpdate:(NSInteger)value;
- (void)markasFoundDNFClearsTargetUpdate:(BOOL)value;
- (void)markasFoundMarksAllWaypointsUpdate:(BOOL)value;
- (void)loggingRemovesMarkedAsFoundDNFUpdate:(BOOL)value;
- (void)compassAlwaysInPortraitModeUpdate:(BOOL)value;
- (void)showStateAsAbbrevationIfLocaleExistsUpdate:(BOOL)value;
- (void)showStateAsAbbrevationUpdate:(BOOL)value;
- (void)showCountryAsAbbrevationUpdate:(BOOL)value;
- (void)waypointListSortByUpdate:(NSInteger)value;
- (void)refreshWaypointAfterLogUpdate:(BOOL)value;
- (void)accountsSaveAuthenticationNameUpdate:(BOOL)value;
- (void)accountsSaveAuthenticationPasswordUpdate:(BOOL)value;
- (void)gpsAdjustmentEnableUpdate:(BOOL)value;
- (void)gpsAdjustmentLongitudeUpdate:(NSInteger)value;
- (void)gpsAdjustmentLatitudeUpdate:(NSInteger)value;

@end
