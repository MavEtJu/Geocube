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

//enum {
//    SHOW_ONECACHE = 1,
//    SHOW_ALLCACHES,
//
//    SHOW_NEITHER = 10,
//    SHOW_CACHE,
//    SHOW_ME,
//    SHOW_BOTH,
//
//    MAPTYPE_NORMAL = 20,
//    MAPTYPE_SATELLITE,
//    MAPTYPE_HYBRID,
//    MAPTYPE_TERRAIN,
//
//    MAPBRAND_GOOGLEMAPS = 30,
//    MAPBRAND_APPLEMAPS,
//    MAPBRAND_OPENSTREETMAPS,
//};

@interface MapTemplate : NSObject
{
//    NSArray *waypointsArray;

    MapViewController *mapvc;
}

@property (nonatomic, retain) MapViewController *mapvc;

- (void)viewWillAppear;
- (void)viewWillDisappear;
- (void)viewDidAppear;
- (void)viewDidDisappear;

- (instancetype)init:(MapViewController *)mvc;
- (UIImage *)waypointImage:(dbWaypoint *)wp;
- (NSInteger)calculateSpan;

// To be implemented by inherited classes:
- (void)initMap;
- (void)removeMap;
- (void)setMapType:(NSInteger)maptype;

- (void)initCamera;
- (void)removeCamera;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord;
- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2;

- (void)updateMyPosition:(CLLocationCoordinate2D)c; /* Does not affect camera */

- (void)placeMarkers;
- (void)removeMarkers;

- (void)addLineMeToWaypoint;
- (void)removeLineMeToWaypoint;

- (void)removeHistory;
- (void)addHistory;

// User related actions
- (void)openWaypointView:(NSString *)name;
- (void)openWaypointsPicker:(NSArray *)names origin:(UIView *)origin;

@end