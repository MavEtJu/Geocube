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

@interface MapGoogle ()
{
    GMSMapView *mapView;
    GMSMarker *me;
    NSMutableArray *markers;

    LXMapScaleView *mapScaleView;

    GMSPolyline *lineMeToWaypoint;
    GMSPolyline *lineHistory;
}

@end

@implementation MapGoogle

- (BOOL)mapHasViewMap
{
    return YES;
}

- (BOOL)mapHasViewSatellite
{
    return YES;
}

- (BOOL)mapHasViewHybrid
{
    return YES;
}

- (BOOL)mapHasViewTerrain;
{
    return YES;
}

- (void)mapViewWillAppear
{
    if (self.mapvc.isMovingToParentViewController)
        [myConfig addDelegate:self];
}

- (void)mapViewWillDisappear
{
    if (self.mapvc.isMovingFromParentViewController)
        [myConfig deleteDelegate:self];
}

- (void)startActivityViewer:(NSString *)text
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:mapView withLabel:text];
    }];
}

- (void)stopActivityViewer
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
    }];
}

- (void)initMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:LM.coords zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;

    mapvc.view = mapView;

    mapScaleView = [LXMapScaleView mapScaleForGMSMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;
    [mapScaleView update];
}

- (void)removeMap
{
    mapView = nil;
    mapScaleView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
}

- (void)removeCamera
{
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
    [mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = wp.coordinates;
        marker.title = wp.wpt_name;
        marker.snippet = wp.wpt_urlname;
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

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
    CLLocationCoordinate2D d1, d2;

    if (zoom == YES) {
        NSInteger span = [self calculateSpan] / 2;

        // Obtained from http://stackoverflow.com/questions/6224671/mkcoordinateregionmakewithdistance-equivalent-in-android
        double latspan = span / 111325.0;
        double longspan = span / 111325.0 * (1 / cos([Coordinates degrees2rad:coord.latitude]));

        d1 = CLLocationCoordinate2DMake(coord.latitude - latspan, coord.longitude - longspan);
        d2 = CLLocationCoordinate2DMake(coord.latitude + latspan, coord.longitude + longspan);

        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:d1 coordinate:d2];
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
    } else {
        [mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:coord]];
    }

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
    lineMeToWaypoint.strokeColor = myConfig.mapDestinationColour;
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
    lineHistory.strokeColor = myConfig.mapTrackColour;
    lineHistory.map = mapView;
}

- (void)removeHistory
{
    lineHistory.map = nil;
}

- (CLLocationCoordinate2D)currentCenter
{
    CGPoint point = mapView.center;
    return [mapView.projection coordinateForPoint:point];
}

- (void)updateMyBearing:(CLLocationDirection)bearing
{
    [mapView animateToBearing:bearing];
}

#pragma mark -- delegation from the map

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture == YES)
        [mapvc userInteraction];

    // Update the ruler
    [mapScaleView update];
}

@end
