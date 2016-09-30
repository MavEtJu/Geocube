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
@property (nonatomic, readonly, retain) NSString *currentWaypoint;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) NSInteger currentPageTab;

@property (nonatomic, readonly) NSId currentTrack;

@property (nonatomic, readonly) NSInteger lastImportSource;
@property (nonatomic, readonly) NSInteger lastImportGroup;
@property (nonatomic, readonly) NSInteger lastAddedGroup;

@property (nonatomic, readonly) NSString *keyGMS;
@property (nonatomic, readonly) NSString *keyMapbox;

// User settings
@property (nonatomic, readonly) BOOL distanceMetric;

@property (nonatomic, readonly) NSInteger mapExternal;
@property (nonatomic, readonly) NSInteger mapBrand;
@property (nonatomic, readonly) UIColor  *mapTrackColour;
@property (nonatomic, readonly) UIColor  *mapDestinationColour;
@property (nonatomic, readonly) NSInteger compassType;
@property (nonatomic, readonly) NSInteger themeType;

@property (nonatomic, readonly) BOOL soundDirection;
@property (nonatomic, readonly) BOOL soundDistance;

@property (nonatomic, readonly) BOOL keeptrackAutoRotate;
@property (nonatomic, readonly) float keeptrackTimeDeltaMin;
@property (nonatomic, readonly) float keeptrackTimeDeltaMax;
@property (nonatomic, readonly) NSInteger keeptrackDistanceDeltaMin;
@property (nonatomic, readonly) NSInteger keeptrackDistanceDeltaMax;
@property (nonatomic, readonly) NSInteger keeptrackPurgeAge;
@property (nonatomic, readonly) NSInteger keeptrackSync;

@property (nonatomic, readonly) BOOL mapClustersEnable;
@property (nonatomic, readonly) float mapClustersZoomLevel;
@property (nonatomic, readonly) BOOL mapRotateToBearing;

@property (nonatomic, readonly, retain) UIFont *GCLabelFont;
@property (nonatomic, readonly, retain) UIFont *GCSmallFont;
@property (nonatomic, readonly, retain) UIFont *GCTextblockFont;

@property (nonatomic) BOOL dynamicmapEnable;    // Not read-only
@property (nonatomic, readonly) NSInteger dynamicmapWalkingSpeed;
@property (nonatomic, readonly) NSInteger dynamicmapWalkingDistance;
@property (nonatomic, readonly) NSInteger dynamicmapCyclingSpeed;
@property (nonatomic, readonly) NSInteger dynamicmapCyclingDistance;
@property (nonatomic, readonly) NSInteger dynamicmapDrivingSpeed;
@property (nonatomic, readonly) NSInteger dynamicmapDrivingDistance;

@property (nonatomic, readonly) BOOL mapcacheEnable;
@property (nonatomic, readonly) NSInteger mapcacheMaxAge;
@property (nonatomic, readonly) NSInteger mapcacheMaxSize;

@property (nonatomic, readonly) BOOL downloadImagesLogs;
@property (nonatomic, readonly) BOOL downloadImagesWaypoints;
@property (nonatomic, readonly) BOOL downloadImagesMobile;
@property (nonatomic, readonly) BOOL downloadQueriesMobile;
@property (nonatomic, readonly) NSInteger downloadTimeoutSimple;
@property (nonatomic, readonly) NSInteger downloadTimeoutQuery;

@property (nonatomic, readonly) NSInteger mapSearchMaximumNumberGCA;
@property (nonatomic, readonly) NSInteger mapSearchMaximumDistanceGS;
@property (nonatomic, readonly) NSInteger mapSearchMaximumDistanceOKAPI;

@property (nonatomic, readonly) BOOL markasFoundDNFClearsTarget;
@property (nonatomic, readonly) BOOL markasFoundMarksAllWaypoints;
@property (nonatomic, readonly) BOOL loggingRemovesMarkedAsFoundDNF;

@property (nonatomic, readonly) BOOL compassAlwaysInPortraitMode;
@property (nonatomic, readonly) BOOL showCountryAsAbbrevation;
@property (nonatomic, readonly) BOOL showStateAsAbbrevation;
@property (nonatomic, readonly) BOOL showStateAsAbbrevationIfLocaleExists;

@property (nonatomic, readonly) NSInteger waypointListSortBy;
@property (nonatomic, readonly) BOOL refreshWaypointAfterLog;

@property (nonatomic, readonly) BOOL gpsAdjustmentEnable;
@property (nonatomic, readonly) NSInteger gpsAdjustmentLatitude;
@property (nonatomic, readonly) NSInteger gpsAdjustmentLongitude;

// Bitmask of:
// UIInterfaceOrientationMaskPortrait, UIInterfaceOrientationMaskPortraitUpsideDown
// UIInterfaceOrientationMaskLandscapeLeft, UIInterfaceOrientationMaskLandscapeRight
@property (nonatomic, readonly) NSInteger orientationsAllowed;

- (void)keyGMSUpdate:(NSString *)value;
- (void)keyMapboxUpdate:(NSString *)value;

- (void)distanceMetricUpdate:(BOOL)value;
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
- (void)gpsAdjustmentEnableUpdate:(BOOL)value;
- (void)gpsAdjustmentLongitudeUpdate:(NSInteger)value;
- (void)gpsAdjustmentLatitudeUpdate:(NSInteger)value;

@end
