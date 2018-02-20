/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

#define PROTO_NR(__type__, __name__) \
    @property (nonatomic, retain) __type__ __name__; \
    - (void)__name__ ## Update:(__type__)value;

#define PROTO_N3(__type__, __name__, __type2__) \
    @property (nonatomic, retain) __type__ __name__; \
    - (void)__name__ ## Update:(__type2__)value;

#define PROTO_N(__type__, __name__) \
    @property (nonatomic) __type__ __name__; \
    - (void)__name__ ## Update:(__type__)value;

// System settings

PROTO_NR(NSString *, currentWaypoint);
PROTO_N (NSInteger, currentPage);
PROTO_N (NSInteger, currentPageTab);
PROTO_NR(dbTrack *, currentTrack);
PROTO_N (NSInteger, lastImportSource);
PROTO_N (NSInteger, lastImportGroup);
PROTO_N (NSInteger, lastAddedGroup);

// User settings

PROTO_N (BOOL, distanceMetric);
PROTO_N (NSInteger, mapExternal);
PROTO_NR(NSString *, mapBrandDefault);
PROTO_N3(UIColor *, mapTrackColour, NSString *);
PROTO_N3(UIColor *, mapDestinationColour, NSString *);
PROTO_N3(UIColor *, mapCircleRingColour, NSString *);
PROTO_N3(UIColor *, mapCircleFillColour, NSString *);
PROTO_N (NSInteger, compassType);
PROTO_N (NSInteger, themeType);
PROTO_N (BOOL, soundDirection);
PROTO_N (BOOL, soundDistance);
PROTO_N (BOOL, keeptrackEnable);
PROTO_N (BOOL, keeptrackMemoryOnly);
PROTO_N (BOOL, keeptrackAutoRotate);
PROTO_N (float, keeptrackTimeDeltaMin);
PROTO_N (float, keeptrackTimeDeltaMax);
PROTO_N (NSInteger, keeptrackDistanceDeltaMin);
PROTO_N (NSInteger, keeptrackDistanceDeltaMax);
PROTO_N (NSInteger, keeptrackPurgeAge);
PROTO_N (NSInteger, keeptrackSync);
PROTO_N (NSInteger, keeptrackBeeperInterval);
PROTO_N (BOOL, dynamicmapEnable);
PROTO_N (NSInteger, dynamicmapWalkingSpeed);
PROTO_N (NSInteger, dynamicmapWalkingDistance);
PROTO_N (NSInteger, dynamicmapCyclingSpeed);
PROTO_N (NSInteger, dynamicmapCyclingDistance);
PROTO_N (NSInteger, dynamicmapDrivingSpeed);
PROTO_N (NSInteger, dynamicmapDrivingDistance);
PROTO_N (BOOL, mapcacheEnable);
PROTO_N (NSInteger, mapcacheMaxAge);
PROTO_N (NSInteger, mapcacheMaxSize);
PROTO_N (BOOL, downloadImagesLogs);
PROTO_N (BOOL, downloadImagesWaypoints);
PROTO_N (BOOL, downloadImagesMobile);
PROTO_N (BOOL, downloadQueriesMobile);
PROTO_N (NSInteger, downloadTimeoutSimple);
PROTO_N (NSInteger, downloadTimeoutQuery);
PROTO_N (BOOL, markasFoundDNFClearsTarget);
PROTO_N (BOOL, markasFoundMarksAllWaypoints);
PROTO_N (BOOL, loggingRemovesMarkedAsFoundDNF);
PROTO_N (BOOL, loggingGGCWOfferFavourites);
PROTO_N (BOOL, compassAlwaysInPortraitMode);
PROTO_N (BOOL, showCountryAsAbbrevation);
PROTO_N (BOOL, showStateAsAbbrevation);
PROTO_N (BOOL, showStateAsAbbrevationIfLocalityExists);
PROTO_N (NSInteger, waypointListSortBy);
PROTO_N (BOOL, refreshWaypointAfterLog);
PROTO_N (NSInteger, listSortBy);
PROTO_N (BOOL, accountsSaveAuthenticationName);
PROTO_N (BOOL, accountsSaveAuthenticationPassword);
PROTO_N (BOOL, introSeen);
PROTO_NR(NSString *, logTemporaryText);
PROTO_N (BOOL, locationlessShowFound);
PROTO_N (NSInteger, locationlessListSortBy);
PROTO_N (BOOL, opencageEnable);
PROTO_NR(NSString *, opencageKey);
PROTO_N (BOOL, opencageWifiOnly);
PROTO_NR(NSString *, mapboxKey);
PROTO_N (NSInteger, configUpdateLastTime);
PROTO_NR(NSString *, configUpdateLastVersion);
PROTO_N (BOOL, automaticDatabaseBackup);
PROTO_N (NSTimeInterval, automaticDatabaseBackupLast);
PROTO_N (NSInteger, automaticDatabaseBackupPeriod);
PROTO_N (NSInteger, automaticDatabaseBackupRotate);
PROTO_N (BOOL, accuracyDynamicEnable);
PROTO_N (LM_ACCURACY, accuracyDynamicAccuracyNear);
PROTO_N (LM_ACCURACY, accuracyDynamicAccuracyMidrange);
PROTO_N (LM_ACCURACY, accuracyDynamicAccuracyFar);
PROTO_N (NSInteger, accuracyDynamicDeltaDNear);
PROTO_N (NSInteger, accuracyDynamicDeltaDMidrange);
PROTO_N (NSInteger, accuracyDynamicDeltaDFar);
PROTO_N (NSInteger, accuracyDynamicDistanceNearToMidrange);
PROTO_N (NSInteger, accuracyDynamicDistanceMidrangeToFar);
PROTO_N (LM_ACCURACY, accuracyStaticAccuracyNavigating);
PROTO_N (LM_ACCURACY, accuracyStaticAccuracyNonNavigating);
PROTO_N (NSInteger, accuracyStaticDeltaDNavigating);
PROTO_N (NSInteger, accuracyStaticDeltaDNonNavigating);
PROTO_N (BOOL, speedEnable);
PROTO_N (NSInteger, speedSamples);
PROTO_N (NSInteger, speedMinimum);
PROTO_N (NSInteger, mapsearchGGCWMaximumNumber)
PROTO_N (NSInteger, mapsearchGGCWNumberThreads)
PROTO_N (NSInteger, fontSmallTextSize)
PROTO_N (NSInteger, fontNormalTextSize)

// Bitmask of:
// UIInterfaceOrientationMaskPortrait, UIInterfaceOrientationMaskPortraitUpsideDown
// UIInterfaceOrientationMaskLandscapeLeft, UIInterfaceOrientationMaskLandscapeRight
PROTO_N (NSInteger, orientationsAllowed);

@end

extern ConfigManager *configManager;
