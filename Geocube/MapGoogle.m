/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface MapGoogle ()
{
    GMSMapView *mapView;
    GMSMarker *me;
    NSMutableArray<GMSMarker *> *markers;
    NSMutableArray<GCGMSCircle *> *circles;

    GMSPolyline *lineMeToWaypoint;
    NSMutableArray<GMSPolyline *> *linesHistory;
    GMSMutablePath *lastPathHistory;

    dbWaypoint *wpSelected;
}

@end

@implementation MapGoogle

- (BOOL)mapHasViewMap
{
    return YES;
}

- (BOOL)mapHasViewAerial
{
    return YES;
}

- (BOOL)mapHasViewHybridMapAerial
{
    return YES;
}

- (BOOL)mapHasViewTerrain;
{
    return YES;
}

- (void)initMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:LM.coords zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;

    self.mapvc.view = mapView;

    mapScaleView = [LXMapScaleView mapScaleForGMSMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;
    [mapScaleView update];

    wpSelected = nil;
    [self initWaypointInfo];

    linesHistory = [NSMutableArray arrayWithCapacity:100];
    lastPathHistory = [GMSMutablePath path];
    [self showHistory];
}

- (void)removeMap
{
    mapView = nil;
    mapScaleView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:coords zoom:15];
    [mapView setCamera:camera];
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

    [circles enumerateObjectsUsingBlock:^(GCGMSCircle *c, NSUInteger idx, BOOL *stop) {
        c.map = nil;
        c = nil;
    }];
    circles = nil;
}

- (GMSMarker *)makeMarker:(dbWaypoint *)wp
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = wp.coordinates;
    marker.title = wp.wpt_name;
    marker.snippet = wp.wpt_urlname;
    marker.map = mapView;
    marker.groundAnchor = CGPointMake(11.0 / 35.0, 38.0 / 42.0);
    marker.infoWindowAnchor = CGPointMake(11.0 / 35.0, 3.0 / 42.0);
    marker.userData = wp;
    marker.icon = [self waypointImage:wp];
    return marker;
}

- (GCGMSCircle *)makeCircle:(dbWaypoint *)wp
{
    GCGMSCircle *circle = [GCGMSCircle circleWithPosition:wp.coordinates radius:wp.account.distance_minimum];
    circle.strokeColor = [UIColor blueColor];
    circle.fillColor = [UIColor colorWithRed:0 green:0 blue:0.35 alpha:0.05];
    circle.map = mapView;
    circle.userData = wp;
    return circle;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idx, BOOL *stop) {
        m.map = nil;
    }];
    markers = nil;

    // Add the new markers to the map
    markers = [NSMutableArray arrayWithCapacity:20];
    circles = [NSMutableArray arrayWithCapacity:20];
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        [markers addObject:[self makeMarker:wp]];

        if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
            [circles addObject:[self makeCircle:wp]];
    }];
}

- (void)placeMarker:(dbWaypoint *)wp
{
    // Add a new marker
    __block BOOL found = NO;
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idx, BOOL *stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            found = YES;
            *stop = YES;
        }
    }];
    if (found == YES)
        return;

    [markers addObject:[self makeMarker:wp]];

    // Add the boundary if needed
    if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        GCGMSCircle *circle = [self makeCircle:wp];
        circle.map = mapView;
        [circles addObject:circle];
    }
}

- (void)removeMarker:(dbWaypoint *)wp
{
    // Remove an new marker
    __block NSUInteger idx = NSNotFound;
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idxx, BOOL *stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            idx = idxx;
            m.map = nil;
            *stop = YES;
        }
    }];
    if (idx == NSNotFound)
        return;

    [markers removeObjectAtIndex:idx];

    // Remove the boundary if needed
    if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        [circles enumerateObjectsUsingBlock:^(GCGMSCircle *c, NSUInteger idx, BOOL *stop) {
            if (c.userData == wp) {
                [circles removeObjectAtIndex:idx];
                c.map = nil;
                *stop = YES;
            }
        }];
    }
}

- (void)updateMarker:(dbWaypoint *)wp
{
    __block NSUInteger idx = NSNotFound;
    [markers enumerateObjectsUsingBlock:^(GMSMarker *m, NSUInteger idxx, BOOL *stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            idx = idxx;
            m.map = nil;
            *stop = YES;
        }
    }];
    if (idx == NSNotFound)
        return;

    [markers replaceObjectAtIndex:idx withObject:[self makeMarker:wp]];
}

- (void)showBoundaries:(BOOL)yesno
{
    showBoundary = yesno;
    [self removeMarkers];
    [self placeMarkers];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    [super openWaypointView:marker.userData];
}

- (void)setMapType:(GCMapType)mapType
{
    switch (mapType) {
        case MAPTYPE_NORMAL:
            mapView.mapType = kGMSTypeNormal;
            break;
        case MAPTYPE_AERIAL:
            mapView.mapType = kGMSTypeSatellite;
            break;
        case MAPTYPE_TERRAIN:
            mapView.mapType = kGMSTypeTerrain;
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            mapView.mapType = kGMSTypeHybrid;
            break;
    }
}

- (GCMapType)mapType
{
    switch (mapView.mapType) {
        case kGMSTypeNormal:
            return MAPTYPE_NORMAL;
        case kGMSTypeSatellite:
            return MAPTYPE_AERIAL;
        case kGMSTypeTerrain:
            return MAPTYPE_TERRAIN;
        case kGMSTypeHybrid:
            return MAPTYPE_HYBRIDMAPAERIAL;

        case kGMSTypeNone:
            return -1;
    }

    return -1;
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

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    [mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:coord zoom:zoomLevel]];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2 boundaryPercentage:10];

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
    lineMeToWaypoint.strokeColor = configManager.mapDestinationColour;
    lineMeToWaypoint.map = mapView;
}

- (void)removeLineMeToWaypoint
{
    lineMeToWaypoint.map = nil;
}

- (void)showHistory
{
    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical *mho, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mho.restart == NO) {
            [lastPathHistory addCoordinate:mho.coord];
            return;
        }

#define ADDPATH(__path__, __line__) \
        GMSPolyline *__line__ = [GMSPolyline polylineWithPath:__path__]; \
        __line__.strokeWidth = 2.f; \
        __line__.strokeColor = configManager.mapTrackColour; \
        __line__.map = mapView;

        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];

        [lastPathHistory removeAllCoordinates];
    }];

    if ([lastPathHistory count] != 0) {
        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];
    }
}

- (void)addHistory:(GCCoordsHistorical *)ch
{
    /*
     * If it is not a restart, then remove the last linesHistory, add a new entry to the path and add the path to the linesHistory.
     * If it is a restart, then just clear the path and add it to the linesHistory.
     */
    if (ch.restart == YES) {
        [lastPathHistory removeAllCoordinates];
    } else {
        [linesHistory lastObject].map = nil;
        [linesHistory removeLastObject];
    }

    [lastPathHistory addCoordinate:ch.coord];

    ADDPATH(lastPathHistory, lineHistory)
    [linesHistory addObject:lineHistory];

    if ([lastPathHistory count] == 200) {
        lastPathHistory = [GMSMutablePath path];
        [lastPathHistory addCoordinate:ch.coord];
        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];
    }
}

- (void)removeHistory
{
    for (GMSPolyline *lh in linesHistory) {
        lh.map = nil;
    };
    [linesHistory removeAllObjects];
    [lastPathHistory removeAllCoordinates];
}

- (CLLocationCoordinate2D)currentCenter
{
    CGPoint point = mapView.center;
    CLLocationCoordinate2D loc;
    loc = [mapView.projection coordinateForPoint:point];
    return loc;
}

- (double)currentZoom
{
    CGFloat zoom = mapView.camera.zoom;
    return zoom;
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    GMSVisibleRegion visibleRegion;
    visibleRegion = mapView.projection.visibleRegion;

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];

    // we've got what we want, but here are NE and SW points
    *topRight = bounds.northEast;
    *bottomLeft = bounds.southWest;
}

- (void)updateMyBearing:(CLLocationDirection)bearing
{
    [mapView animateToBearing:bearing];
}

#pragma mark -- delegation from the map

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture == YES)
        [self.mapvc userInteractionStart];

    // Update the ruler
    [mapScaleView update];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(nonnull GMSCameraPosition *)position
{
    [self.mapvc userInteractionFinished];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapvc addNewWaypoint:coordinate];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    wpSelected = marker.userData;
    [self updateWaypointInfo:wpSelected];
    [self showWaypointInfo];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self hideWaypointInfo];
    wpSelected = nil;
}

- (void)openWaypointInfo:(id)sender
{
    NSLog(@"%@", wpSelected.wpt_name);
    [self openWaypointView:wpSelected];
}

@end
