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

@implementation MapGoogleViewController

- (void)initMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:LM.coords zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;

    self.view = mapView;
}

- (void)initCamera
{
}

- (void)initMenu
{
    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"Satellite", @"Hybrid", @"Terrain", @"Show target", @"Follow me", @"Show both"]];
}

- (void)removeMarkers
{
    NSEnumerator *e = [markers objectEnumerator];
    GMSMarker *m;
    while ((m = [e nextObject]) != nil) {
        m.map = nil;
        m = nil;
    }
    markers = nil;
}

- (void)placeMarkers
{
    // Remove everything from the map
    NSEnumerator *e = [markers objectEnumerator];
    GMSMarker *m;
    while ((m = [e nextObject]) != nil) {
        m.map = nil;
    }

    // Add the new markers to the map
    e = [waypointsArray objectEnumerator];
    dbWaypoint *wp;
    markers = [NSMutableArray arrayWithCapacity:20];

    while ((wp = [e nextObject]) != nil) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = wp.coordinates;
        marker.icon = [imageLibrary getNormal:wp.type.pin];
        marker.title = wp.name;
        marker.snippet = wp.description;
        marker.map = mapView;
        [markers addObject:marker];
    }
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
    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:coord zoom:15];
    [mapView animateWithCameraUpdate:currentCam];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:c1 coordinate:c2];
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    switch (index) {
        case 0: /* Map view */
            [super menuMapType:MAPTYPE_NORMAL];
            return;
        case 1: /* Satellite view */
            [super menuMapType:MAPTYPE_SATELLITE];
            return;
        case 2: /* Hybrid view */
            [super menuMapType:MAPTYPE_HYBRID];
            return;
        case 3: /* Terrain view */
            [super menuMapType:MAPTYPE_TERRAIN];
            return;

        case 4: /* Show cache */
            [super menuShowWhom:SHOW_CACHE];
            return;
        case 5: /* Show Me */
            [super menuShowWhom:SHOW_ME];
            return;
        case 6: /* Show Both */
            [super menuShowWhom:SHOW_BOTH];
            return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

#pragma mark -- delegation from the map

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture == YES)
        [super userInteraction];
}

@end
