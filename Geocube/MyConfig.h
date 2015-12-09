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

@property (nonatomic) BOOL distanceMetric;

@property (nonatomic, retain) NSString *currentWaypoint;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger currentPageTab;

@property (nonatomic) NSId currentTrack;

@property (nonatomic) NSInteger lastImportSource;
@property (nonatomic) NSInteger lastImportGroup;
@property (nonatomic) NSInteger lastAddedGroup;

@property (nonatomic) NSInteger mapExternal;
@property (nonatomic) NSInteger mapBrand;
@property (nonatomic) UIColor  *mapTrackColour;
@property (nonatomic) UIColor  *mapDestinationColour;
@property (nonatomic) NSInteger compassType;
@property (nonatomic) NSInteger themeType;

@property (nonatomic) BOOL soundDirection;
@property (nonatomic) BOOL soundDistance;

@property (nonatomic) BOOL mapClustersEnable;
@property (nonatomic) float mapClustersZoomLevel;

@property (nonatomic, readonly, retain) UIFont *GCLabelFont;
@property (nonatomic, readonly, retain) UIFont *GCSmallFont;
@property (nonatomic, readonly, retain) UIFont *GCTextblockFont;

@property (nonatomic) BOOL dynamicmapEnable;
@property (nonatomic) NSInteger dynamicmapWalkingSpeed;
@property (nonatomic) NSInteger dynamicmapWalkingDistance;
@property (nonatomic) NSInteger dynamicmapCyclingSpeed;
@property (nonatomic) NSInteger dynamicmapCyclingDistance;
@property (nonatomic) NSInteger dynamicmapDrivingSpeed;
@property (nonatomic) NSInteger dynamicmapDrivingDistance;

- (void)addDelegate:(id)destination;
- (void)deleteDelegate:(id)destination;

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
- (void)mapClustersUpdateEnable:(BOOL)value;
- (void)mapClustersUpdateZoomLevel:(float)value;
- (void)dynamicmapEnableUpdate:(BOOL)value;
- (void)dynamicmapWalkingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapWalkingDistanceUpdate:(NSInteger)value;
- (void)dynamicmapCyclingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapCyclingDistanceUpdate:(NSInteger)value;
- (void)dynamicmapDrivingSpeedUpdate:(NSInteger)value;
- (void)dynamicmapDrivingDistanceUpdate:(NSInteger)value;

@end
