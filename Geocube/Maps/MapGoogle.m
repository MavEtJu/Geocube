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
    NSMutableArray<GMSMarker *> *markers;
    NSMutableArray<GCGMSCircle *> *circles;

    GMSPolyline *lineMeToWaypoint;
    GMSPolyline *lineTapToMe;
    NSMutableArray<GMSPolyline *> *linesHistory;
    GMSMutablePath *lastPathHistory;

    CLLocationCoordinate2D trackBL, trackTR;

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
    if (self.staticHistory == NO)
        mapView.myLocationEnabled = YES;
    mapView.delegate = self;

    self.mapvc.view = mapView;

    mapScaleView = [LXMapScaleView mapScaleForGMSMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;
    [mapScaleView update];

    wpSelected = nil;

    if (linesHistory == nil)
        linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (lastPathHistory == nil)
        lastPathHistory = [GMSMutablePath path];
    if (self.staticHistory == NO)
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
    if (self.staticHistory == NO)
    [mapView setCamera:camera];

    if (self.staticHistory == YES)
        [self moveCameraTo:trackBL c2:trackTR];
}

- (void)removeCamera
{
}

- (void)removeMarkers
{
    [markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        m.map = nil;
        m = nil;
    }];
    markers = nil;

    [circles enumerateObjectsUsingBlock:^(GCGMSCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        c.map = nil;
        c = nil;
    }];
    circles = nil;
}

- (GMSMarker *)makeMarker:(dbWaypoint *)wp
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
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
    GCGMSCircle *circle = [GCGMSCircle circleWithPosition:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
    circle.strokeColor = [UIColor blueColor];
    circle.fillColor = [UIColor colorWithRed:0 green:0 blue:0.35 alpha:0.05];
    circle.map = mapView;
    circle.userData = wp;
    return circle;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        m.map = nil;
    }];
    markers = nil;

    // Add the new markers to the map
    markers = [NSMutableArray arrayWithCapacity:20];
    circles = [NSMutableArray arrayWithCapacity:20];
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [markers addObject:[self makeMarker:wp]];

        if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
            [circles addObject:[self makeCircle:wp]];
    }];
}

- (void)placeMarker:(dbWaypoint *)wp
{
    // Add a new marker
    __block BOOL found = NO;
    [markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
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
        [circles enumerateObjectsUsingBlock:^(GCGMSCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
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
    [pathMeToWaypoint addCoordinate:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude)];
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

- (void)addLineTapToMe:(CLLocationCoordinate2D)c
{
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:c];
    [path addCoordinate:LM.coords];

    lineTapToMe = [GMSPolyline polylineWithPath:path];
    lineTapToMe.strokeWidth = 2.f;
    lineTapToMe.strokeColor = configManager.mapDestinationColour;
    lineTapToMe.map = mapView;

    [self.mapvc showDistance:[MyTools niceDistance:[Coordinates coordinates2distance:c to:LM.coords]] timeout:5 unlock:NO];
}

- (void)removeLineTapToMe
{
    lineTapToMe.map = nil;
    lineTapToMe = nil;
    [self.mapvc showDistance:@"" timeout:0 unlock:YES];
}

- (void)showHistory
{
    if (self.staticHistory == YES)
        return;

    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical * _Nonnull mho, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mho.restart == NO) {
            [lastPathHistory addCoordinate:mho.coord];
            return;
        }

#define ADDPATH(__path__, __line__) \
        GMSPolyline *__line__ = [GMSPolyline polylineWithPath:__path__]; \
        __line__.strokeWidth = 2.f; \
        __line__.strokeColor = configManager.mapTrackColour; \
        __line__.map = mapView;

        MAINQUEUE(
            ADDPATH(lastPathHistory, lineHistory)
            [linesHistory addObject:lineHistory];
        )

        [lastPathHistory removeAllCoordinates];
    }];

    if ([lastPathHistory count] != 0) {
        MAINQUEUE(
            ADDPATH(lastPathHistory, lineHistory)
            [linesHistory addObject:lineHistory];
        )
    }
}

- (void)addHistory:(GCCoordsHistorical *)ch
{
    if (self.staticHistory == YES)
        return;

    /*
     * If it is not a restart, then remove the last linesHistory, add a new entry to the path and add the path to the linesHistory.
     * If it is a restart, then just clear the path and add it to the linesHistory.
     */
    if (ch.restart == YES) {
        [lastPathHistory removeAllCoordinates];
    } else {
        MAINQUEUE(
            [linesHistory lastObject].map = nil;
            [linesHistory removeLastObject];
        )
    }

    [lastPathHistory addCoordinate:ch.coord];

    MAINQUEUE(
        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];
    )

    if ([lastPathHistory count] == 200) {
        lastPathHistory = [GMSMutablePath path];
        [lastPathHistory addCoordinate:ch.coord];
        MAINQUEUE(
            ADDPATH(lastPathHistory, lineHistory)
            [linesHistory addObject:lineHistory];
        )
    }
}

- (void)removeHistory
{
    if (self.staticHistory == YES)
        return;

    for (GMSPolyline *lh in linesHistory) {
        lh.map = nil;
    };
    [linesHistory removeAllObjects];
    [lastPathHistory removeAllCoordinates];
}

- (void)showTrack:(dbTrack *)track
{
    NSAssert(self.staticHistory, @"Shouldn't be called for staticHistory = NO");

    if (linesHistory == nil)
        linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (lastPathHistory == nil)
        lastPathHistory = [GMSMutablePath path];

    for (GMSPolyline *lh in linesHistory) {
        lh.map = nil;
    };
    [linesHistory removeAllObjects];
    [lastPathHistory removeAllCoordinates];

#define ADDPATH(__path__, __line__) \
    GMSPolyline *__line__ = [GMSPolyline polylineWithPath:__path__]; \
        __line__.strokeWidth = 2.f; \
        __line__.strokeColor = configManager.mapTrackColour; \
        __line__.map = mapView;

    __block CLLocationDegrees left, right, top, bottom;
    left = 180;
    right = -180;
    top = -180;
    bottom = 180;

    [[dbTrackElement dbAllByTrack:track] enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull te, NSUInteger idx, BOOL * _Nonnull stop) {
        bottom = MIN(bottom, te.lat);
        top = MAX(top, te.lat);
        right = MAX(right, te.lon);
        left = MIN(left, te.lon);

        if (te.restart == NO) {
            [lastPathHistory addCoordinate:CLLocationCoordinate2DMake(te.lat, te.lon)];
            return;
        }

        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];

        [lastPathHistory removeAllCoordinates];
    }];

    if ([lastPathHistory count] != 0) {
        ADDPATH(lastPathHistory, lineHistory)
        [linesHistory addObject:lineHistory];
    }

    trackBL = CLLocationCoordinate2DMake(bottom, left);
    trackTR = CLLocationCoordinate2DMake(top, right);

    [self performSelector:@selector(showTrack) withObject:nil afterDelay:1];
}

- (void)showTrack
{
    [linesHistory enumerateObjectsUsingBlock:^(GMSPolyline * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        line.map = mapView;
    }];
    [self moveCameraTo:trackBL c2:trackTR];
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
    if (lineTapToMe != nil)
        [self removeLineTapToMe];

    wpSelected = marker.userData;
    [self.mapvc showWaypointInfo:wpSelected];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (wpSelected != nil) {
        [self.mapvc removeWaypointInfo];
        wpSelected = nil;
        return;
    }

    if (lineTapToMe != nil) {
        [self removeLineTapToMe];
        return;
    }

    [self addLineTapToMe:coordinate];
}

@end
