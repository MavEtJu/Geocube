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
        marker.title = wp.name;
        marker.snippet = wp.description;
        marker.map = mapView;
        
        switch (wp.logStatus) {
            case LOGSTATUS_FOUND:
                if (wp.groundspeak.archived == YES) {
                    marker.icon = [imageLibrary getPinArchivedFound:wp.type.pin];
                    break;
                }
                if (wp.groundspeak.available == NO) {
                    marker.icon = [imageLibrary getPinDisabledFound:wp.type.pin];
                    break;
                }
                marker.icon = [imageLibrary getPinFound:wp.type.pin];
                break;
            case LOGSTATUS_NOTFOUND:
                if (wp.groundspeak.archived == YES) {
                    marker.icon = [imageLibrary getPinArchivedDNF:wp.type.pin];
                    break;
                }
                if (wp.groundspeak.available == NO) {
                    marker.icon = [imageLibrary getPinDisabledDNF:wp.type.pin];
                    break;
                }
                marker.icon = [imageLibrary getPinDNF:wp.type.pin];
                break;
            case LOGSTATUS_NOTLOGGED:
                if (wp.groundspeak.archived == YES) {
                    marker.icon = [imageLibrary getPinArchived:wp.type.pin];
                    break;
                }
                if (wp.groundspeak.available == NO) {
                    marker.icon = [imageLibrary getPinDisabled:wp.type.pin];
                    break;
                }
                /* FALL THROUGH */
            default:
                marker.icon = [imageLibrary getPinNormal:wp.type.pin];
                break;
        }

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
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
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
