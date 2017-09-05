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

@interface ConfigManager : NSObject

// System settings
@property (nonatomic, retain) NSString *currentWaypoint;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger currentPageTab;

@property (nonatomic, retain) dbTrack *currentTrack;

@property (nonatomic) NSInteger lastImportSource;
@property (nonatomic) NSInteger lastImportGroup;
@property (nonatomic) NSInteger lastAddedGroup;

// User settings
@property (nonatomic) BOOL distanceMetric;
@property (nonatomic) BOOL sendTweets;

@property (nonatomic) NSInteger mapExternal;
@property (nonatomic) NSString *mapBrandDefault;
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
@property (nonatomic) NSInteger keeptrackBeeperInterval;

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
@property (nonatomic) BOOL showStateAsAbbrevationIfLocalityExists;

@property (nonatomic) NSInteger waypointListSortBy;
@property (nonatomic) BOOL refreshWaypointAfterLog;

@property (nonatomic) NSInteger listSortBy;

@property (nonatomic) BOOL accountsSaveAuthenticationName;
@property (nonatomic) BOOL accountsSaveAuthenticationPassword;

@property (nonatomic) BOOL introSeen;

@property (nonatomic, retain) NSString *logTemporaryText;

@property (nonatomic) BOOL locationlessShowFound;
@property (nonatomic) NSInteger locationlessListSortBy;

@property (nonatomic, retain) NSString *opencageKey;
@property (nonatomic) BOOL opencageWifiOnly;

@property (nonatomic) NSInteger configUpdateLastTime;
@property (nonatomic) NSString *configUpdateLastVersion;

@property (nonatomic) BOOL automaticDatabaseBackup;
@property (nonatomic) NSTimeInterval automaticDatabaseBackupLast;
@property (nonatomic) NSInteger automaticDatabaseBackupPeriod;
@property (nonatomic) NSInteger automaticDatabaseBackupRotate;

@property (nonatomic) BOOL accuracyDynamicEnable;
@property (nonatomic) LM_ACCURACY accuracyDynamicAccuracyNear;
@property (nonatomic) LM_ACCURACY accuracyDynamicAccuracyMidrange;
@property (nonatomic) LM_ACCURACY accuracyDynamicAccuracyFar;
@property (nonatomic) LM_ACCURACY accuracyDynamicDeltaDNear;
@property (nonatomic) LM_ACCURACY accuracyDynamicDeltaDMidrange;
@property (nonatomic) LM_ACCURACY accuracyDynamicDeltaDFar;
@property (nonatomic) NSInteger accuracyDynamicDistanceNearToMidrange;
@property (nonatomic) NSInteger accuracyDynamicDistanceMidrangeToFar;
@property (nonatomic) LM_ACCURACY accuracyStaticAccuracyNavigating;
@property (nonatomic) LM_ACCURACY accuracyStaticAccuracyNonNavigating;
@property (nonatomic) LM_ACCURACY accuracyStaticDeltaDNavigating;
@property (nonatomic) LM_ACCURACY accuracyStaticDeltaDNonNavigating;

// Bitmask of:
// UIInterfaceOrientationMaskPortrait, UIInterfaceOrientationMaskPortraitUpsideDown
// UIInterfaceOrientationMaskLandscapeLeft, UIInterfaceOrientationMaskLandscapeRight
@property (nonatomic) NSInteger orientationsAllowed;

- (void)distanceMetricUpdate:(BOOL)value;
- (void)sendTweetsUpdate:(BOOL)value;
- (void)currentWaypointUpdate:(NSString *)name;
- (void)currentPageUpdate:(NSInteger)value;
- (void)currentPageTabUpdate:(NSInteger)value;
- (void)currentTrackUpdate:(dbTrack *)value;
- (void)lastAddedGroupUpdate:(NSInteger)value;
- (void)lastImportGroupUpdate:(NSInteger)value;
- (void)lastImportSourceUpdate:(NSInteger)value;
- (void)mapExternalUpdate:(NSInteger)value;
- (void)mapBrandDefaultUpdate:(NSString *)value;
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
- (void)keeptrackSyncUpdate:(NSInteger)value;
- (void)keeptrackBeeperIntervalUpdate:(NSInteger)value;
- (void)mapClustersEnableUpdate:(BOOL)value;
- (void)mapClustersZoomLevelUpdate:(float)value;
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
- (void)showStateAsAbbrevationIfLocalityExistsUpdate:(BOOL)value;
- (void)showStateAsAbbrevationUpdate:(BOOL)value;
- (void)showCountryAsAbbrevationUpdate:(BOOL)value;
- (void)waypointListSortByUpdate:(NSInteger)value;
- (void)refreshWaypointAfterLogUpdate:(BOOL)value;
- (void)listSortByUpdate:(NSInteger)value;
- (void)accountsSaveAuthenticationNameUpdate:(BOOL)value;
- (void)accountsSaveAuthenticationPasswordUpdate:(BOOL)value;
- (void)introSeenUpdate:(BOOL)value;
- (void)logTemporaryTextUpdate:(NSString *)value;
- (void)locationlessShowFoundUpdate:(BOOL)value;
- (void)locationlessListSortByUpdate:(NSInteger)value;
- (void)opencageKeyUpdate:(NSString *)value;
- (void)opencageWifiOnlyUpdate:(BOOL)value;
- (void)configUpdateLastTimeUpdate:(NSInteger)value;
- (void)configUpdateLastVersionUpdate:(NSString *)value;
- (void)automaticDatabaseBackupUpdate:(BOOL)value;
- (void)automaticDatabaseBackupLastUpdate:(NSTimeInterval)value;
- (void)automaticDatabaseBackupPeriodUpdate:(NSInteger)value;
- (void)automaticDatabaseBackupRotateUpdate:(NSInteger)value;
- (void)accuracyDynamicEnableUpdate:(BOOL)value;
- (void)accuracyDynamicAccuracyNearUpdate:(NSInteger)value;
- (void)accuracyDynamicDeltaDNearUpdate:(NSInteger)value;
- (void)accuracyDynamicAccuracyMidrangeUpdate:(NSInteger)value;
- (void)accuracyDynamicDeltaDMidrangeUpdate:(NSInteger)value;
- (void)accuracyDynamicAccuracyFarUpdate:(NSInteger)value;
- (void)accuracyDynamicDeltaDFarUpdate:(NSInteger)value;
- (void)accuracyDynamicDistanceNearToMidrangeUpdate:(NSInteger)value;
- (void)accuracyDynamicDistanceMidrangeToFarUpdate:(NSInteger)value;
- (void)accuracyStaticAccuracyNavigatingUpdate:(NSInteger)value;
- (void)accuracyStaticAccuracyNonNavigatingUpdate:(NSInteger)value;
- (void)accuracyStaticDeltaDNavigatingUpdate:(NSInteger)value;
- (void)accuracyStaticDeltaDNonNavigatingUpdate:(NSInteger)value;

@end
