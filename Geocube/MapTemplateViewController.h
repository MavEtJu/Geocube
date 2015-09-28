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

enum {
    SHOW_ONECACHE = 1,
    SHOW_ALLCACHES,

    SHOW_NEITHER = 10,
    SHOW_CACHE,
    SHOW_ME,
    SHOW_BOTH,

    MAPTYPE_NORMAL = 20,
    MAPTYPE_SATELLITE,
    MAPTYPE_HYBRID,
    MAPTYPE_TERRAIN,
};

@interface MapTemplateViewController : GCViewController<GCLocationManagerDelegate> {
    NSArray *waypointsArray;
    NSInteger waypointCount;

    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */

    CLLocationCoordinate2D meLocation;
}

- (instancetype)init:(NSInteger)type;
- (void)refreshWaypointsData;
- (UIImage *)waypointImage:(dbWaypoint *)wp;
- (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2;
- (NSInteger)calculateSpan;
//- (void)whichWaypointsToShow:(NSInteger)type whichWaypoint:(dbWaypoint *)wp;

// To be implemented by inherited classes:
- (void)initMap;
- (void)initCamera;
- (void)initMenu;
- (void)placeMarkers;
- (void)removeMarkers;
- (void)moveCameraTo:(CLLocationCoordinate2D)coord;
- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2;
- (void)updateMyPosition:(CLLocationCoordinate2D)c; /* Does not affect camera */
- (void)setMapType:(NSInteger)maptype;

// Menu related features
- (void)menuShowWhom:(NSInteger)whom;
- (void)menuMapType:(NSInteger)maptype;

// User related actions
- (void)userInteraction;
- (void)openWaypointView:(NSString *)name;

@end
