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

@interface MapTemplate : NSObject <WaypointManagerKMLDelegate>

@property (nonatomic, retain) MapTemplateViewController *mapvc;
@property (nonatomic, retain) LXMapScaleView *mapScaleView;
@property (nonatomic        ) BOOL circlesShown;
@property (nonatomic        ) BOOL staticHistory;
@property (nonatomic        ) BOOL showBoundary;

- (void)mapViewWillAppear;
- (void)mapViewWillDisappear;
- (void)mapViewDidAppear;
- (void)mapViewDidDisappear;
- (void)mapViewDidLoad;
- (void)recalculateRects;

- (instancetype)initMapObject:(MapTemplateViewController *)mvc;
- (UIImage *)waypointImage:(dbWaypoint *)wp;
- (NSInteger)calculateSpan;
- (double)altitudeForSpan:(double)span;
- (double)determineAltitudeForRectangle:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 viewPort:(CGRect)viewPort;

// To be implemented by inherited classes:

- (BOOL)mapHasViewMap;
- (BOOL)mapHasViewAerial;
- (BOOL)mapHasViewHybridMapAerial;
- (BOOL)mapHasViewTerrain;

- (void)initMap;
- (void)removeMap;
- (void)setMapType:(GCMapType)maptype;

- (void)initCamera:(CLLocationCoordinate2D)coords;
- (void)removeCamera;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom;
- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel;
- (void)moveCameraToAll;

- (void)updateMapScaleView;

- (void)showBoundaries:(BOOL)yesno;

- (void)placeMarkers;
- (void)removeMarkers;
- (void)placeMarker:(dbWaypoint *)wp;
- (void)removeMarker:(dbWaypoint *)wp;
- (void)updateMarker:(dbWaypoint *)wp;
- (void)showCenteredCoordinates:(BOOL)showIt coords:(CLLocationCoordinate2D)coords;

- (void)addLineMeToWaypoint;
- (void)removeLineMeToWaypoint;

- (void)addLineTapToMe:(CLLocationCoordinate2D)c;
- (void)removeLineTapToMe;

- (void)removeHistory;
- (void)showHistory;
- (void)addHistory:(GCCoordsHistorical *)ch;

- (void)showTrack:(dbTrack *)track;
- (void)showTrack;

- (void)loadKMLs;
- (void)loadKML:(NSString *)file;
- (void)removeKMLs;

- (CLLocationCoordinate2D)currentCenter;
- (double)currentZoom;
- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight;

// User related actions
- (void)openWaypointView:(dbWaypoint *)wp;

@end
