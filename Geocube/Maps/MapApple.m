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

#define COORDHISTORYSIZE    100

@interface MapApple ()
{
    GCWaypointAnnotation *me;
    NSMutableArray<GCWaypointAnnotation *> *markers;
    NSMutableArray<GCCircle *> *circles;

    MKPolyline *lineMeToWaypoint;
    MKPolylineRenderer *viewLineMeToWaypoint;
    NSMutableArray<MKPolyline *> *linesHistory;
    NSMutableArray<MKPolylineRenderer *> *viewLinesHistory;
    CLLocationCoordinate2D historyCoords[COORDHISTORYSIZE];
    NSInteger historyCoordsIdx;
    CLLocationCoordinate2D trackBL, trackTR;

    BOOL modifyingMap;
}

@end

@implementation MapApple

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
    return NO;
}

- (void)initMap
{
    mapView = [[MKMapView alloc] initWithFrame:self.mapvc.view.frame];
    if (self.staticHistory == NO)
        mapView.showsUserLocation = YES;
    mapView.delegate = self;

    self.minimumAltitude = 0;

    self.mapvc.view = mapView;

    /* Add the scale ruler */
    mapScaleView = [LXMapScaleView mapScaleForAMSMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;

    // Add a new waypoint
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [mapView addGestureRecognizer:lpgr];

    [self initWaypointInfo];
    if (linesHistory == nil)
        linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (viewLinesHistory == nil)
        viewLinesHistory = [NSMutableArray arrayWithCapacity:100];
    historyCoordsIdx = 0;
    if (self.staticHistory == NO)
        [self showHistory];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];

    [self.mapvc addNewWaypoint:touchMapCoordinate];
}

- (void)removeMap
{
    mapView = nil;
    mapScaleView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    /* Place camera on a view of 1500 x 1500 meters */
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];
}

- (void)removeCamera
{
}

- (void)placeMarkers
{
    NSLog(@"%@/placeMarkers", [self class]);
    // Creates a marker in the center of the map.
    markers = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
    circles = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(NSObject *o, NSUInteger idx, BOOL *stop) {
        if ([o isKindOfClass:[dbWaypoint class]] == YES) {
            dbWaypoint *wp = (dbWaypoint *)o;
            // Place a single pin
            GCWaypointAnnotation *annotation = [[GCWaypointAnnotation alloc] init];
            CLLocationCoordinate2D coord = wp.coordinates;
            [annotation setCoordinate:coord];
            annotation.waypoint = wp;

            [markers addObject:annotation];

            if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
                GCCircle *circle = [GCCircle circleWithCenterCoordinate:wp.coordinates radius:wp.account.distance_minimum];
                circle.waypoint = wp;
                [circles addObject:circle];
            }
        }
    }];
    [mapView addAnnotations:markers];
    [mapView addOverlays:circles];
}

- (void)removeMarkers
{
    NSLog(@"%@/removeMarkers", [self class]);
    [mapView removeAnnotations:markers];
    markers = nil;

    [mapView removeOverlays:circles];
    circles = nil;
}

- (void)placeMarker:(dbWaypoint *)wp
{
    __block BOOL found = NO;
    [markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation *m, NSUInteger idx, BOOL *stop) {
        if (wp._id == m.waypoint._id) {
            found = YES;
            *stop = YES;
        }
    }];
    if (found == YES)
        return;

    // Take care of the waypoint
    GCWaypointAnnotation *annotation = [[GCWaypointAnnotation alloc] init];
    CLLocationCoordinate2D coord = wp.coordinates;
    [annotation setCoordinate:coord];
    annotation.waypoint = wp;

    [markers addObject:annotation];
    [mapView addAnnotation:annotation];

    // Take care of the boundary circles
    if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        GCCircle *circle = [GCCircle circleWithCenterCoordinate:wp.coordinates radius:wp.account.distance_minimum];
        circle.waypoint = wp;
        [circles addObject:circle];
        [mapView addOverlay:circle];
    }
}

- (void)removeMarker:(dbWaypoint *)wp
{
    // Take care of the waypoint
    __block GCWaypointAnnotation *annotiation;
    __block NSUInteger idx = NSNotFound;
    [markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation *m, NSUInteger idxx, BOOL *stop) {
        if (wp._id == m.waypoint._id) {
            annotiation = m;
            idx = idxx;
            *stop = YES;
        }
    }];
    if (annotiation == nil)
        return;

    [markers removeObjectAtIndex:idx];
    [mapView removeAnnotation:annotiation];

    // Take care of the boundary circles
    if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        [circles enumerateObjectsUsingBlock:^(GCCircle *c, NSUInteger idx, BOOL *stop) {
            if (c.waypoint._id == wp._id) {
                [mapView removeOverlay:c];
                [circles removeObject:c];
                *stop = YES;
            }
        }];
    }
}

- (void)updateMarker:(dbWaypoint *)wp
{
    // Take care of the waypoint
    __block GCWaypointAnnotation *annotiation;
    __block NSUInteger idx = NSNotFound;
    [markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation *m, NSUInteger idxx, BOOL *stop) {
        if (wp._id == m.waypoint._id) {
            annotiation = m;
            idx = idxx;
            *stop = YES;
        }
    }];
    if (annotiation == nil)
        return;

    GCWaypointAnnotation *newMarker = [[GCWaypointAnnotation alloc] init];
    CLLocationCoordinate2D coord = wp.coordinates;
    [newMarker setCoordinate:coord];
    newMarker.waypoint = wp;

    [markers replaceObjectAtIndex:idx withObject:newMarker];
    [mapView removeAnnotation:annotiation];
    [mapView addAnnotation:newMarker];

    // Take care of the boundary circles
    if (showBoundary == YES) {
        [circles enumerateObjectsUsingBlock:^(GCCircle *c, NSUInteger idx, BOOL *stop) {
            if (c.waypoint._id == wp._id) {
                [mapView removeOverlay:c];
                [circles removeObject:c];
                *stop = YES;
            }
        }];
        GCCircle *circle = [GCCircle circleWithCenterCoordinate:wp.coordinates radius:wp.account.distance_minimum];
        circle.waypoint = wp;
        [circles addObject:circle];
        [mapView addOverlay:circle];
    }
}

- (void)showBoundaries:(BOOL)yesno
{
    if (yesno == YES) {
        showBoundary = YES;
        circles = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
        [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
                GCCircle *circle = [GCCircle circleWithCenterCoordinate:wp.coordinates radius:wp.account.distance_minimum];
                circle.waypoint = wp;
                [circles addObject:circle];
            }
        }];
        [mapView addOverlays:circles];
    } else {
        showBoundary = NO;
        [mapView removeOverlays:circles];
        circles = nil;
    }
}

- (void)openWaypointInfo:(id)sender
{
    GCWaypointAnnotation *ann = [[mapView selectedAnnotations] objectAtIndex:0];
    [self openWaypointView:ann.waypoint];
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        ((MKUserLocation *)annotation).title = @"";
        return nil;
    }

    // If it is a waypoint, add an image to it.
    if ([annotation isKindOfClass:[GCWaypointAnnotation class]] == YES) {
        GCWaypointAnnotation *a = annotation;

        MKAnnotationView *dropPin = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"waypoints"];
        if (dropPin == nil)
            dropPin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"waypoints"];
        dropPin.image = [self waypointImage:a.waypoint];
        dropPin.centerOffset = CGPointMake(7, -17);
        dropPin.annotation = annotation;

        return dropPin;
    }

    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GCWaypointAnnotation class]]) {
        GCWaypointAnnotation *pa = (GCWaypointAnnotation *)view.annotation;
        [self updateWaypointInfo:pa.waypoint];
        [self showWaypointInfo];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GCWaypointAnnotation class]]) {
        [self hideWaypointInfo];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if (overlay == lineMeToWaypoint) {
        if (viewLineMeToWaypoint == nil) {
            viewLineMeToWaypoint = [[MKPolylineRenderer alloc] initWithPolyline:lineMeToWaypoint];
            viewLineMeToWaypoint.fillColor = configManager.mapDestinationColour;
            viewLineMeToWaypoint.strokeColor = configManager.mapDestinationColour;
            viewLineMeToWaypoint.lineWidth = 5;
        }

        return viewLineMeToWaypoint;
    }

    __block MKPolylineRenderer *vlHistory = nil;
    [linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
        if (overlay == lh) {
            vlHistory = [viewLinesHistory objectAtIndex:idx];
            *stop = YES;
        }
    }];
    if (vlHistory != nil)
        return vlHistory;

    __block MKCircleRenderer *circleRenderer = nil;
    [circles enumerateObjectsUsingBlock:^(GCCircle *c, NSUInteger idx, BOOL *stop) {
        if (overlay == c) {
            circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
            circleRenderer.strokeColor = [UIColor blueColor];
            circleRenderer.fillColor = [UIColor colorWithRed:0 green:0 blue:0.35 alpha:0.05];
            circleRenderer.lineWidth = 1;
            *stop = YES;
        }
    }];
    if (circleRenderer != nil)
        return circleRenderer;

    return nil;
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
    CLLocationCoordinate2D t = coord;
    mapView.centerCoordinate = coord;

    if (zoom == YES) {
        NSInteger span = [self calculateSpan];

        mapView.camera.altitude = [MapApple altitudeForSpan:span];
    }

    mapView.camera.centerCoordinate = t;
}

- (void)setZoomLevel:(NSUInteger)zoomLevel
{
    [self moveCameraTo:mapView.centerCoordinate zoomLevel:zoomLevel];
    if (mapView.camera.altitude < self.minimumAltitude && modifyingMap == NO) {
        modifyingMap = YES;
        mapView.camera.altitude = self.minimumAltitude;
        modifyingMap = NO;
    }
}

- (double)currentZoom
{
    return log2(360 * ((mapView.frame.size.width / 256) / mapView.region.span.longitudeDelta));
}

+ (double)altitudeForSpan:(double)span
{
    double adjacent = span / 2;
    double height = adjacent / tan([Coordinates degrees2rad:15]);
    return height;
}

+ (double)determineAltitudeForRectangle:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 viewPort:(CGRect)viewPort
{
    // Determine the borders
    CLLocationCoordinate2D UL = CLLocationCoordinate2DMake(c1.latitude > c2.latitude ? c1.latitude : c2.latitude, c1.longitude < c2.longitude ?  c1.longitude : c2.longitude);
    CLLocationCoordinate2D UR = CLLocationCoordinate2DMake(c1.latitude > c2.latitude ? c1.latitude : c2.latitude, c1.longitude > c2.longitude ? c1.longitude : c2.longitude);
    CLLocationCoordinate2D LL = CLLocationCoordinate2DMake(c1.latitude < c2.latitude ? c1.latitude : c2.latitude, c1.longitude < c2.longitude ? c1.longitude : c2.longitude);

    CLLocationDistance dLon = MKMetersBetweenMapPoints(MKMapPointForCoordinate(UL), MKMapPointForCoordinate(UR));
    CLLocationDistance dLat = MKMetersBetweenMapPoints(MKMapPointForCoordinate(UL), MKMapPointForCoordinate(LL));

    float ratio = viewPort.size.height / viewPort.size.width;

    if (dLat > dLon) // More above each other than besides each other
        return [self altitudeForSpan:dLat];
    // More besides each other than above each other
    return [self altitudeForSpan:dLon * ratio];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    mapView.camera.centerCoordinate = coord;

    if (mapView.camera.altitude < self.minimumAltitude && modifyingMap == NO) {
        modifyingMap = YES;
        mapView.camera.altitude = self.minimumAltitude;
        modifyingMap = NO;
    }
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2 boundaryPercentage:10];

    /*
     * If the altitude needed for the camera is too low, just set the center and the minimum altitude.
     * Otherwise set the rectangle with a proper edge.
     */

    if ([MapApple determineAltitudeForRectangle:d1 c2:d2 viewPort:self.mapvc.view.frame] < self.minimumAltitude) {
        CLLocationCoordinate2D c = CLLocationCoordinate2DMake((c1.latitude + c2.latitude) / 2, (c1.longitude + c2.longitude) / 2);
        mapView.camera.centerCoordinate = c;
        mapView.camera.altitude = self.minimumAltitude;
        return;
    }

    MKMapPoint annotationPoint1 = MKMapPointForCoordinate(d1);
    MKMapPoint annotationPoint2 = MKMapPointForCoordinate(d2);
    MKMapRect pointRect1 = MKMapRectMake(annotationPoint1.x, annotationPoint1.y, 0, 0);
    MKMapRect pointRect2 = MKMapRectMake(annotationPoint2.x, annotationPoint2.y, 0, 0);
    MKMapRect zoomRect = MKMapRectUnion(pointRect1, pointRect2);

    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:NO];
}

- (void)setMapType:(GCMapType)mapType
{
    switch (mapType) {
        case MAPTYPE_NORMAL:
            mapView.mapType = MKMapTypeStandard;
            break;
        case MAPTYPE_AERIAL:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            mapView.mapType = MKMapTypeHybrid;
            break;
        case MAPTYPE_TERRAIN:
            // Nothing, not supported here.
            break;
    }
}

- (GCMapType)mapType
{
    switch (mapView.mapType) {
        case MKMapTypeStandard:
            return MAPTYPE_NORMAL;
        case MKMapTypeSatellite:
            return MAPTYPE_AERIAL;
        case MKMapTypeHybrid:
            return MAPTYPE_HYBRIDMAPAERIAL;

        case MKMapTypeSatelliteFlyover:
        case MKMapTypeHybridFlyover:
            return -1;
    }
    return MAPTYPE_NORMAL;
}

- (void)addLineMeToWaypoint
{
    CLLocationCoordinate2D coordinateArray[2];
    coordinateArray[0] = LM.coords;
    coordinateArray[1] = waypointManager.currentWaypoint.coordinates;

    lineMeToWaypoint = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
    [mapView addOverlay:lineMeToWaypoint];
}

- (void)removeLineMeToWaypoint
{
    [mapView removeOverlay:lineMeToWaypoint];
    viewLineMeToWaypoint = nil;
    lineMeToWaypoint = nil;
}

- (void)showHistory
{
    if (self.staticHistory == YES)
        return;

#define ADDPATH(__coords__, __count__) { \
        MKPolyline *lh = [MKPolyline polylineWithCoordinates:__coords__ count:__count__]; \
        \
        MKPolylineRenderer *vlHistory = [[MKPolylineRenderer alloc] initWithPolyline:lh]; \
        vlHistory.fillColor = configManager.mapTrackColour; \
        vlHistory.strokeColor = configManager.mapTrackColour; \
        vlHistory.lineWidth = 5; \
        \
        [viewLinesHistory addObject:vlHistory]; \
        [linesHistory addObject:lh]; \
        [mapView addOverlay:lh]; \
    }

    __block CLLocationCoordinate2D *coordinateArray = calloc([LM.coordsHistorical count], sizeof(CLLocationCoordinate2D));
    __block NSInteger counter = 0;
    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical *mho, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mho.restart == NO) {
            coordinateArray[counter++] = mho.coord;
            return;
        }

        ADDPATH(coordinateArray, counter)
        counter = 0;
    }];
    if (counter != 0)
        ADDPATH(coordinateArray, counter)

    free(coordinateArray);

    historyCoords[0] = LM.coords;
    historyCoordsIdx = 1;
    ADDPATH(historyCoords, historyCoordsIdx)
}

- (void)addHistory:(GCCoordsHistorical *)ch
{
    if (self.staticHistory == YES)
        return;

    if (ch.restart == NO && historyCoordsIdx < COORDHISTORYSIZE - 1) {
        historyCoords[historyCoordsIdx++] = ch.coord;
        [mapView removeOverlay:[linesHistory lastObject]];
        [linesHistory removeLastObject];
        [viewLinesHistory removeLastObject];
    } else {
        historyCoordsIdx = 0;
        historyCoords[historyCoordsIdx++] = ch.coord;
    }
    ADDPATH(historyCoords, historyCoordsIdx)
}

- (void)removeHistory
{
    if (self.staticHistory == YES)
        return;

    NSLog(@"removing %ld history", (long)[linesHistory count]);
    [linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
        [mapView removeOverlay:lh];
    }];
    [viewLinesHistory removeAllObjects];
    [linesHistory removeAllObjects];
    historyCoordsIdx = 0;
}

- (void)showTrack:(dbTrack *)track
{
    NSAssert(self.staticHistory == YES, @"Should only be called with static history");

#define ADDPATH(__coords__, __count__) { \
        MKPolyline *lh = [MKPolyline polylineWithCoordinates:__coords__ count:__count__]; \
        \
        MKPolylineRenderer *vlHistory = [[MKPolylineRenderer alloc] initWithPolyline:lh]; \
        vlHistory.fillColor = configManager.mapTrackColour; \
        vlHistory.strokeColor = configManager.mapTrackColour; \
        vlHistory.lineWidth = 5; \
        \
        [viewLinesHistory addObject:vlHistory]; \
        [linesHistory addObject:lh]; \
        [mapView addOverlay:lh]; \
    }

    if (linesHistory == nil)
        linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (viewLinesHistory == nil)
        viewLinesHistory = [NSMutableArray arrayWithCapacity:100];

    __block CLLocationDegrees left, right, top, bottom;
    left = 180;
    right = -180;
    top = -180;
    bottom = 180;

    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:track._id];

    __block CLLocationCoordinate2D *coordinateArray = calloc([tes count], sizeof(CLLocationCoordinate2D));
    __block NSInteger counter = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull te, NSUInteger idx, BOOL * _Nonnull stop) {
        bottom = MIN(bottom, te.coords.latitude);
        top = MAX(top, te.coords.latitude);
        right = MAX(right, te.coords.longitude);
        left = MIN(left, te.coords.longitude);

        if (te.restart == NO) {
            coordinateArray[counter++] = te.coords;
            return;
        }

        ADDPATH(coordinateArray, counter)
        counter = 0;
    }];
    if (counter != 0)
        ADDPATH(coordinateArray, counter)

    free(coordinateArray);

    trackBL = CLLocationCoordinate2DMake(bottom, left);
    trackTR = CLLocationCoordinate2DMake(top, right);

    [self performSelector:@selector(showTrack) withObject:nil afterDelay:1];
}

- (void)showTrack
{
    [linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
        [mapView addOverlay:lh];
    }];
    [self moveCameraTo:trackBL c2:trackTR];
}

- (CLLocationCoordinate2D)currentCenter
{
    return [mapView centerCoordinate];
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    MKCoordinateRegion cr = mapView.region;
    *bottomLeft = CLLocationCoordinate2DMake(cr.center.latitude - cr.span.latitudeDelta, cr.center.longitude - cr.span.longitudeDelta);
    *topRight = CLLocationCoordinate2DMake(cr.center.latitude + cr.span.latitudeDelta, cr.center.longitude + cr.span.longitudeDelta);
}

- (void)updateMyBearing:(CLLocationDirection)bearing
{
//    [mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

#pragma mark -- delegation from the map

// From http://stackoverflow.com/questions/5556977/determine-if-mkmapview-was-dragged-moved moby
- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    NSArray<UIView *> *views = self.mapvc.view.subviews;
    //  Look through gesture recognizers to determine whether this region change is from user interaction

    __block BOOL found = NO;
    [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[UIView class]] == NO)
             return;
        for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
            if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
                found = YES;
                *stop = YES;
                return;
            }
        }
    }];

    return found;
}

- (void)mapView:(MKMapView *)thisMapView regionWillChangeAnimated:(BOOL)animated
{
    BOOL mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];

    if (mapChangedFromUserInteraction)
        [self.mapvc userInteractionStart];

    // Update the ruler
    [mapScaleView update];
}

- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
{
    BOOL mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];

    if (mapChangedFromUserInteraction)
        [self.mapvc userInteractionFinished];

    // Constrain zoom levels
    if (self.minimumAltitude > mapView.camera.altitude && modifyingMap == NO) {
        modifyingMap = YES;
        mapView.camera.altitude = self.minimumAltitude;
        modifyingMap = NO;
    }
}

@end