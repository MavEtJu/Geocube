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

@protocol MyConfigChangedDelegate

@optional - (void)changeMapClusters:(BOOL)enable zoomLevel:(float)zoomLevel;

@end

@interface MyConfig : NSObject

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

@property (nonatomic, readonly) BOOL mapClustersEnable;
@property (nonatomic, readonly) float mapClustersZoomLevel;

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

@property (nonatomic, readonly) BOOL downloadLogImages;
@property (nonatomic, readonly) BOOL downloadLogImagesMobile;
@property (nonatomic, readonly) BOOL downloadQueriesMobile;

@property (nonatomic, readonly) BOOL mapSearchMaximumNumberGCA;
@property (nonatomic, readonly) BOOL mapSearchMaximumDistanceGS;

- (void)addDelegate:(id)destination;
- (void)deleteDelegate:(id)destination;

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
- (void)mapClustersUpdateEnable:(BOOL)value;
- (void)mapClustersUpdateZoomLevel:(float)value;
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
- (void)downloadLogImagesUpdate:(BOOL)value;
- (void)downloadLogImagesMobileUpdate:(BOOL)value;
- (void)downloadQueriesMobileUpdate:(BOOL)value;
- (void)mapSearchMaximumNumberGCA:(NSInteger)value;
- (void)mapSearchMaximumDistanceGS:(NSInteger)value;

@end
