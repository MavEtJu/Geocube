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

@interface MapTemplate : NSObject
{
    MapViewController *mapvc;
    LXMapScaleView *mapScaleView;
    BOOL showBoundary;
}

@property (nonatomic, retain) MapViewController *mapvc;
@property (nonatomic) BOOL circlesShown;

- (void)mapViewWillAppear;
- (void)mapViewWillDisappear;
- (void)mapViewDidAppear;
- (void)mapViewDidDisappear;
- (void)mapViewDidLoad;
- (void)recalculateRects;

- (void)startActivityViewer:(NSString *)text;
- (void)stopActivityViewer;
- (void)updateActivityViewer:(NSString *)s;

- (instancetype)init:(MapViewController *)mvc;
- (UIImage *)waypointImage:(dbWaypoint *)wp;
- (NSInteger)calculateSpan;

// To be implemented by inherited classes:

- (BOOL)mapHasViewMap;
- (BOOL)mapHasViewSatellite;
- (BOOL)mapHasViewHybrid;
- (BOOL)mapHasViewTerrain;

- (void)initMap;
- (void)removeMap;
- (void)setMapType:(NSInteger)maptype;

- (void)initCamera:(CLLocationCoordinate2D)coords;
- (void)removeCamera;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom;
- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel;

- (void)updateMyPosition:(CLLocationCoordinate2D)c; /* Does not affect camera */
- (void)updateMyBearing:(CLLocationDirection)bearing;
- (void)updateMapScaleView;

- (void)showBoundaries:(BOOL)yesno;

- (void)placeMarkers;
- (void)removeMarkers;

- (void)addLineMeToWaypoint;
- (void)removeLineMeToWaypoint;

- (void)removeHistory;
- (void)addHistory;

- (void)hideWaypointInfo;
- (void)showWaypointInfo;
- (void)initWaypointInfo;
- (void)updateWaypointInfo:(dbWaypoint *)wp;
- (void)openWaypointInfo:(id)sender;

- (CLLocationCoordinate2D)currentCenter;
- (double)currentZoom;

// User related actions
- (void)openWaypointView:(NSString *)name;
- (void)openWaypointsPicker:(NSArray *)names origin:(UIView *)origin;

@end