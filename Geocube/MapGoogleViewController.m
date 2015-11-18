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

@import GoogleMaps;

#import "Geocube-Prefix.pch"

@interface MapGoogleViewController ()
{
    GMSMapView *mapView;
    GMSMarker *me;
    NSMutableArray *markers;

    LXMapScaleView *mapScaleView;

    GMSPolyline *lineMeToWaypoint;
    GMSPolyline *lineHistory;
}

@end

@implementation MapGoogleViewController

- (void)initMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:LM.coords zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;

    mapScaleView = [LXMapScaleView mapScaleForGMSMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;
    [mapScaleView update];

    self.view = mapView;
}

- (void)removeMap
{
    mapView = nil;
    mapScaleView = nil;
}

- (void)initCamera
{
}

enum {
    menuMap,
    menuSatellite,
    menuHybrid,
    menuTerrain,
    menuShowTarget,
    menuFollowMe,
    menuShowBoth,
    menuMax
};

- (void)initMenu
{
    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMap label:@"Map"];
    [lmi addItem:menuSatellite label:@"Satellite"];
    [lmi addItem:menuHybrid label:@"Hybrid"];
    [lmi addItem:menuTerrain label:@"Terrain"];
    [lmi addItem:menuShowTarget label:@"Show target"];
    [lmi addItem:menuFollowMe label:@"Follow me"];
    [lmi addItem:menuShowBoth label:@"Show both"];
    menuItems = [lmi makeMenu];
}

- (void)removeMarkers
{
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idx, BOOL *stop) {
        m.map = nil;
        m = nil;
    }];
    markers = nil;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idx, BOOL *stop) {
        m.map = nil;
    }];

    // Add the new markers to the map
    markers = [NSMutableArray arrayWithCapacity:20];
    [waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = wp.coordinates;
        marker.title = wp.name;
        marker.snippet = wp.urlname;
        marker.map = mapView;
        marker.groundAnchor = CGPointMake(11.0 / 35.0, 38.0 / 42.0);
        marker.infoWindowAnchor = CGPointMake(11.0 / 35.0, 3.0 / 42.0);

        marker.icon = [self waypointImage:wp];
        [markers addObject:marker];
    }];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [super openWaypointView:marker.title];
}

- (void)setMapType:(NSInteger)mapType
{
    switch (mapType) {
        case MAPTYPE_NORMAL:
            mapView.mapType = kGMSTypeNormal;
            break;
        case MAPTYPE_SATELLITE:
            mapView.mapType = kGMSTypeSatellite;
            break;
        case MAPTYPE_TERRAIN:
            mapView.mapType = kGMSTypeTerrain;
            break;
        case MAPTYPE_HYBRID:
            mapView.mapType = kGMSTypeHybrid;
            break;
    }
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord
{
    CLLocationCoordinate2D d1, d2;
    NSInteger span = [self calculateSpan] / 2;

    // Obtained from http://stackoverflow.com/questions/6224671/mkcoordinateregionmakewithdistance-equivalent-in-android
    double latspan = span / 111325.0;
    double longspan = span / 111325.0 * (1 / cos([Coordinates degrees2rad:coord.latitude]));

    d1 = CLLocationCoordinate2DMake(coord.latitude - latspan, coord.longitude - longspan);
    d2 = CLLocationCoordinate2DMake(coord.latitude + latspan, coord.longitude + longspan);

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:d1 coordinate:d2];
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];

    [mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2];

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:d1 coordinate:d2];
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];

    [mapScaleView update];
}

- (void)addLineMeToWaypoint
{
    GMSMutablePath *pathMeToWaypoint = [GMSMutablePath path];
    [pathMeToWaypoint addCoordinate:waypointManager.currentWaypoint.coordinates];
    [pathMeToWaypoint addCoordinate:LM.coords];

    lineMeToWaypoint = [GMSPolyline polylineWithPath:pathMeToWaypoint];
    lineMeToWaypoint.strokeWidth = 2.f;
    lineMeToWaypoint.strokeColor = [UIColor redColor];
    lineMeToWaypoint.map = mapView;
}

- (void)removeLineMeToWaypoint
{
    lineMeToWaypoint.map = nil;
}

- (void)addHistory
{
    GMSMutablePath *pathMeToWaypoint = [GMSMutablePath path];

    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical *mho, NSUInteger idx, BOOL * _Nonnull stop) {
        [pathMeToWaypoint addCoordinate:mho.coord];
    }];

    lineHistory = [GMSPolyline polylineWithPath:pathMeToWaypoint];
    lineHistory.strokeWidth = 2.f;
    lineHistory.strokeColor = [UIColor colorWithRed:0 green:240.0/256.0 blue:240.0/256.0 alpha:1];
    lineHistory.map = mapView;
}

- (void)removeHistory
{
    lineHistory.map = nil;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuMap: /* Map view */
            [super menuMapType:MAPTYPE_NORMAL];
            return;
        case menuSatellite: /* Satellite view */
            [super menuMapType:MAPTYPE_SATELLITE];
            return;
        case menuHybrid: /* Hybrid view */
            [super menuMapType:MAPTYPE_HYBRID];
            return;
        case menuTerrain: /* Terrain view */
            [super menuMapType:MAPTYPE_TERRAIN];
            return;

        case menuShowTarget: /* Show cache */
            [super menuShowWhom:SHOW_CACHE];
            return;
        case menuFollowMe: /* Show Me */
            [super menuShowWhom:SHOW_ME];
            return;
        case menuShowBoth: /* Show Both */
            [super menuShowWhom:SHOW_BOTH];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

#pragma mark -- delegation from the map

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture == YES)
        [super userInteraction];

    // Update the ruler
    [mapScaleView update];
}

@end
