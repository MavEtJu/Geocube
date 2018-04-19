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

#define COORDHISTORYSIZE    100

@interface MapApple ()

@property (nonatomic        ) CLLocationCoordinate2D *historyCoords;

@property (nonatomic, retain) NSMutableArray<GCWaypointAnnotation *> *markers;
@property (nonatomic, retain) NSMutableArray<GCMKCircle *> *circles;

@property (nonatomic, retain) MKPolyline *lineMeToWaypoint;
@property (nonatomic, retain) MKPolylineRenderer *viewLineMeToWaypoint;
@property (nonatomic, retain) NSMutableArray<MKPolyline *> *linesHistory;
@property (nonatomic, retain) NSMutableArray<MKPolylineRenderer *> *viewLinesHistory;

@property (nonatomic        ) NSInteger historyCoordsIdx;
@property (nonatomic        ) CLLocationCoordinate2D trackBL, trackTR;

@property (nonatomic, retain) dbWaypoint *wpSelected;
@property (nonatomic        ) BOOL modifyingMap;

@property (nonatomic, retain) SimpleKML *simpleKML;
@property (nonatomic, retain) NSMutableArray<id> *KMLfeatures;

@property (nonatomic, retain) GCMKCenteredAnnotation *centeredAnnotation;

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
    self.historyCoords = calloc(COORDHISTORYSIZE, sizeof(CLLocationCoordinate2D));
    self.mapView = [[MKMapView alloc] initWithFrame:self.mapvc.view.frame];
    self.mapView.delegate = self;
    self.mapvc.view = self.mapView;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;

    if (self.staticHistory == NO)
        self.mapView.showsUserLocation = YES;

    self.minimumAltitude = 0;

    /* Add the scale ruler */
    self.mapScaleView = [LXMapScaleView mapScaleForGC:self];
    [self.mapView addSubview:self.mapScaleView];
    [self.mapScaleView update];

    // Add a new waypoint
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];

    if (self.linesHistory == nil)
        self.linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (self.viewLinesHistory == nil)
        self.viewLinesHistory = [NSMutableArray arrayWithCapacity:100];
    self.historyCoordsIdx = 0;
    if (self.staticHistory == NO)
        [self showHistory];

    self.KMLfeatures = [NSMutableArray arrayWithCapacity:3];
    [self loadKMLs];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;

    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];

    [self.mapvc addNewWaypoint:touchMapCoordinate];
}

- (void)removeMap
{
    self.mapView = nil;
    self.mapScaleView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    /* Place camera on a view of 1500 x 1500 meters */
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coords, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:NO];
}

- (void)removeCamera
{
}

- (void)placeMarkers
{
    NSLog(@"%@/placeMarkers", [self class]);
    // Creates a marker in the center of the map.
    self.markers = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
    self.circles = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(NSObject * _Nonnull o, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([o isKindOfClass:[dbWaypoint class]] == YES) {
            dbWaypoint *wp = (dbWaypoint *)o;
            // Place a single pin
            GCWaypointAnnotation *annotation = [[GCWaypointAnnotation alloc] init];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
            [annotation setCoordinate:coord];
            annotation.waypoint = wp;

            [self.markers addObject:annotation];

            if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
                GCMKCircle *circle = [GCMKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
                circle.waypoint = wp;
                [self.circles addObject:circle];
            }
        }
    }];
    [self.mapView addAnnotations:self.markers];
    [self.mapView addOverlays:self.circles];
}

- (void)removeMarkers
{
    NSLog(@"%@/removeMarkers", [self class]);
    [self.mapView removeAnnotations:self.markers];
    self.markers = nil;

    [self.mapView removeOverlays:self.circles];
    self.circles = nil;
}

- (void)placeMarker:(dbWaypoint *)wp
{
    __block BOOL found = NO;
    [self.markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp._id == m.waypoint._id) {
            found = YES;
            *stop = YES;
        }
    }];
    if (found == YES)
        return;

    // Take care of the waypoint
    GCWaypointAnnotation *annotation = [[GCWaypointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
    [annotation setCoordinate:coord];
    annotation.waypoint = wp;

    [self.markers addObject:annotation];
    [self.mapView addAnnotation:annotation];

    // Take care of the boundary circles
    if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        GCMKCircle *circle = [GCMKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
        circle.waypoint = wp;
        [self.circles addObject:circle];
        [self.mapView addOverlay:circle];
    }
}

- (void)removeMarker:(dbWaypoint *)wp
{
    // Take care of the waypoint
    __block GCWaypointAnnotation *annotiation;
    __block NSUInteger idx = NSNotFound;
    [self.markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
        if (wp._id == m.waypoint._id) {
            annotiation = m;
            idx = idxx;
            *stop = YES;
        }
    }];
    if (annotiation == nil)
        return;

    [self.markers removeObjectAtIndex:idx];
    [self.mapView removeAnnotation:annotiation];

    // Take care of the boundary circles
    if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        [self.circles enumerateObjectsUsingBlock:^(GCMKCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
            if (c.waypoint._id == wp._id) {
                [self.mapView removeOverlay:c];
                [self.circles removeObject:c];
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
    [self.markers enumerateObjectsUsingBlock:^(GCWaypointAnnotation * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
        if (wp._id == m.waypoint._id) {
            annotiation = m;
            idx = idxx;
            *stop = YES;
        }
    }];
    if (annotiation == nil)
        return;

    GCWaypointAnnotation *newMarker = [[GCWaypointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
    [newMarker setCoordinate:coord];
    newMarker.waypoint = wp;

    [self.markers replaceObjectAtIndex:idx withObject:newMarker];
    [self.mapView removeAnnotation:annotiation];
    [self.mapView addAnnotation:newMarker];

    // Take care of the boundary circles
    if (self.showBoundary == YES) {
        [self.circles enumerateObjectsUsingBlock:^(GCMKCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
            if (c.waypoint._id == wp._id) {
                [self.mapView removeOverlay:c];
                [self.circles removeObject:c];
                *stop = YES;
            }
        }];
        GCMKCircle *circle = [GCMKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
        circle.waypoint = wp;
        [self.circles addObject:circle];
        [self.mapView addOverlay:circle];
    }
}

- (void)showCenteredCoordinates:(BOOL)showIt coords:(CLLocationCoordinate2D)coords
{
    if (showIt == YES) {
        if (self.centeredAnnotation != nil)
            [self.mapView removeAnnotation:self.centeredAnnotation];
        self.centeredAnnotation = nil;
    } else {
        self.centeredAnnotation = [[GCMKCenteredAnnotation alloc] init];
        [self.centeredAnnotation setCoordinate:coords];
        [self.mapView addAnnotation:self.centeredAnnotation];
    }
}

- (void)showBoundaries:(BOOL)yesno
{
    if (yesno == YES) {
        self.showBoundary = YES;
        self.circles = [NSMutableArray arrayWithCapacity:[self.mapvc.waypointsArray count]];
        [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
                GCMKCircle *circle = [GCMKCircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
                circle.waypoint = wp;
                [self.circles addObject:circle];
            }
        }];
        [self.mapView addOverlays:self.circles];
    } else {
        self.showBoundary = NO;
        [self.mapView removeOverlays:self.circles];
        self.circles = nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GCWaypointAnnotation class]]) {
        GCWaypointAnnotation *pa = (GCWaypointAnnotation *)view.annotation;
        self.wpSelected = pa.waypoint;
        [self.mapvc showWaypointInfo:pa.waypoint];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GCWaypointAnnotation class]]) {
        [self.mapvc removeWaypointInfo];
        self.wpSelected = nil;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]] == YES) {
        ((MKUserLocation *)annotation).title = @"";
        return nil;
    }

    // If it is a waypoint, add an image to it.
    if ([annotation isKindOfClass:[GCWaypointAnnotation class]] == YES) {
        GCWaypointAnnotation *a = annotation;

        MKAnnotationView *dropPin = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"waypoints"];
        if (dropPin == nil)
            dropPin = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"waypoints"];
        dropPin.image = [self waypointImage:a.waypoint];
        dropPin.centerOffset = CGPointMake(7, -17);
        dropPin.annotation = annotation;

        return dropPin;
    }

    // If it is a self-centered annotation, add an image to it.
    if ([annotation isKindOfClass:[GCMKCenteredAnnotation class]] == YES) {
        MKAnnotationView *center = (MKAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"centered"];
        if (center == nil)
            center = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"centered"];
        center.image = [imageManager get:ImageMap_CenteredCoordinates];
        center.annotation = annotation;

        return center;
    }

    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if (overlay == self.lineMeToWaypoint) {
        if (self.viewLineMeToWaypoint == nil) {
            self.viewLineMeToWaypoint = [[MKPolylineRenderer alloc] initWithPolyline:self.lineMeToWaypoint];
            self.viewLineMeToWaypoint.fillColor = configManager.mapDestinationColour;
            self.viewLineMeToWaypoint.strokeColor = configManager.mapDestinationColour;
            self.viewLineMeToWaypoint.lineWidth = 5;
        }

        return self.viewLineMeToWaypoint;
    }

    __block MKPolylineRenderer *vlHistory = nil;
    @synchronized(self.linesHistory) {
        [self.linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
            if (overlay == lh) {
                vlHistory = [self.viewLinesHistory objectAtIndex:idx];
                *stop = YES;
            }
        }];
    }
    if (vlHistory != nil)
        return vlHistory;

    if (overlay == self.centeredAnnotation) {
        MKCircleRenderer *circleRenderer = nil;
        circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.strokeColor = [UIColor blueColor];
        circleRenderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.85];
        circleRenderer.lineWidth = 1;
        return circleRenderer;
    }

    __block MKCircleRenderer *circleRenderer = nil;
    [self.circles enumerateObjectsUsingBlock:^(GCMKCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        if (overlay == c) {
            circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
            circleRenderer.strokeColor = configManager.mapCircleRingColour;
            circleRenderer.fillColor = [configManager.mapCircleFillColour colorWithAlphaComponent:0.05];
            circleRenderer.lineWidth = 1;
            *stop = YES;
        }
    }];
    if (circleRenderer != nil)
        return circleRenderer;

    if ([overlay isKindOfClass:[MKPolygon class]] == YES) {
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];

        // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
        polygonRenderer.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
        polygonRenderer.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
        polygonRenderer.lineWidth = 2.0;

        return polygonRenderer;
    }

    if ([overlay isKindOfClass:[MKPolyline class]] == YES) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];

        // use some sensible defaults - normally, you'd probably look for LineStyle & PolyStyle in the KML
        polylineRenderer.fillColor   = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.25];
        polylineRenderer.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75];
        polylineRenderer.lineWidth = 2.0;

        return polylineRenderer;
    }

    return nil;
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
    CLLocationCoordinate2D t = coord;
    self.mapView.centerCoordinate = coord;

    if (zoom == YES) {
        NSInteger span = [self calculateSpan];

        self.mapView.camera.altitude = [self altitudeForSpan:span];
    }

    self.mapView.camera.centerCoordinate = t;
}

- (void)setZoomLevel:(NSUInteger)zoomLevel
{
    [self moveCameraTo:self.mapView.centerCoordinate zoomLevel:zoomLevel];
    if (self.mapView.camera.altitude < self.minimumAltitude && self.modifyingMap == NO) {
        self.modifyingMap = YES;
        self.mapView.camera.altitude = self.minimumAltitude;
        self.modifyingMap = NO;
    }
}

- (double)currentZoom
{
    return log2(360 * ((self.mapView.frame.size.width / 256) / self.mapView.region.span.longitudeDelta));
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    self.mapView.camera.centerCoordinate = coord;

    if (self.mapView.camera.altitude < self.minimumAltitude && self.modifyingMap == NO) {
        self.modifyingMap = YES;
        self.mapView.camera.altitude = self.minimumAltitude;
        self.modifyingMap = NO;
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

    if ([self determineAltitudeForRectangle:d1 c2:d2 viewPort:self.mapvc.view.frame] < self.minimumAltitude) {
        CLLocationCoordinate2D c = CLLocationCoordinate2DMake((c1.latitude + c2.latitude) / 2, (c1.longitude + c2.longitude) / 2);
        self.mapView.camera.centerCoordinate = c;
        self.mapView.camera.altitude = self.minimumAltitude;
        return;
    }

    MKMapPoint annotationPoint1 = MKMapPointForCoordinate(d1);
    MKMapPoint annotationPoint2 = MKMapPointForCoordinate(d2);
    MKMapRect pointRect1 = MKMapRectMake(annotationPoint1.x, annotationPoint1.y, 0, 0);
    MKMapRect pointRect2 = MKMapRectMake(annotationPoint2.x, annotationPoint2.y, 0, 0);
    MKMapRect zoomRect = MKMapRectUnion(pointRect1, pointRect2);

    [self.mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(30, 30, 30, 30) animated:NO];
}

- (void)setMapType:(GCMapType)mapType
{
    switch (mapType) {
        case MAPTYPE_NORMAL:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case MAPTYPE_AERIAL:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case MAPTYPE_TERRAIN:
            // Nothing, not supported here.
            break;
    }
}

- (void)addLineMeToWaypoint
{
    MAINQUEUE(
        CLLocationCoordinate2D coordinateArray[2];
        coordinateArray[0] = LM.coords;
        coordinateArray[1] = CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude);

        self.lineMeToWaypoint = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
        [self.mapView addOverlay:self.lineMeToWaypoint];
    )
}

- (void)removeLineMeToWaypoint
{
    MAINQUEUE(
        [self.mapView removeOverlay:self.lineMeToWaypoint];
        self.viewLineMeToWaypoint = nil;
        self.lineMeToWaypoint = nil;
    )
}

- (void)addLineTapToMe:(CLLocationCoordinate2D)c;
{
    /* Not supported on Apple Maps as there is no way to determine if a tap was made on a non-populated area or for a sequence which started later. */
}

- (void)removeLineTapToMe
{
    /* Not supported on Apple Maps */
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
        @synchronized(self.linesHistory) { \
            [self.viewLinesHistory addObject:vlHistory]; \
            [self.linesHistory addObject:lh]; \
            [self.mapView addOverlay:lh]; \
        } \
    }

    __block CLLocationCoordinate2D *coordinateArray = calloc([LM.coordsHistorical count], sizeof(CLLocationCoordinate2D));
    __block NSInteger counter = 0;
    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical * _Nonnull mho, NSUInteger idx, BOOL * _Nonnull stop) {
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

    self.historyCoords[0] = LM.coords;
    self.historyCoordsIdx = 1;
    ADDPATH(self.historyCoords, self.historyCoordsIdx)
}

- (void)addHistory:(GCCoordsHistorical *)ch
{
    if (self.staticHistory == YES)
        return;

    MAINQUEUE(
        if (ch.restart == NO && self.historyCoordsIdx < COORDHISTORYSIZE - 1) {
            self.historyCoords[self.historyCoordsIdx++] = ch.coord;
            @synchronized(self.linesHistory) {
                [self.mapView removeOverlay:[self.linesHistory lastObject]];
                [self.linesHistory removeLastObject];
                [self.viewLinesHistory removeLastObject];
            }
        } else {
            self.historyCoordsIdx = 0;
            self.historyCoords[self.historyCoordsIdx++] = ch.coord;
        }
        ADDPATH(self.historyCoords, self.historyCoordsIdx)
    )
}

- (void)removeHistory
{
    if (self.staticHistory == YES)
        return;

    MAINQUEUE(
        @synchronized(self.linesHistory) {
            NSLog(@"removing %ld history", (long)[self.linesHistory count]);
            [self.linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.mapView removeOverlay:lh];
            }];
            [self.viewLinesHistory removeAllObjects];
            [self.linesHistory removeAllObjects];
        }
        self.historyCoordsIdx = 0;
    )
}

- (void)showTrack:(dbTrack *)track
{
    NSAssert(self.staticHistory == YES, @"Should only be called with static history");

    if (self.linesHistory == nil)
        self.linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (self.viewLinesHistory == nil)
        self.viewLinesHistory = [NSMutableArray arrayWithCapacity:100];

    __block CLLocationDegrees left, right, top, bottom;
    left = 180;
    right = -180;
    top = -180;
    bottom = 180;

    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:track];

    __block CLLocationCoordinate2D *coordinateArray = calloc([tes count], sizeof(CLLocationCoordinate2D));
    __block NSInteger counter = 0;
    [tes enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull te, NSUInteger idx, BOOL * _Nonnull stop) {
        bottom = MIN(bottom, te.lat);
        top = MAX(top, te.lat);
        right = MAX(right, te.lon);
        left = MIN(left, te.lon);

        if (te.restart == NO) {
            coordinateArray[counter++] = CLLocationCoordinate2DMake(te.lat, te.lon);
            return;
        }

        ADDPATH(coordinateArray, counter)
        counter = 0;
    }];
    if (counter != 0)
        ADDPATH(coordinateArray, counter)

    free(coordinateArray);

    self.trackBL = CLLocationCoordinate2DMake(bottom, left);
    self.trackTR = CLLocationCoordinate2DMake(top, right);

    [self performSelector:@selector(showTrack) withObject:nil afterDelay:1];
}

- (void)showTrack
{
    @synchronized(self.linesHistory) {
        [self.linesHistory enumerateObjectsUsingBlock:^(MKPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.mapView addOverlay:lh];
        }];
    }
    [self moveCameraTo:self.trackBL c2:self.trackTR];
}

- (void)removeKMLs
{
    [self.KMLfeatures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MKPointAnnotation class]] == YES) {
            [self.mapView removeAnnotation:obj];
            return;
        }
        if ([obj isKindOfClass:[MKPolygon class]] == YES) {
            [self.mapView removeOverlay:obj];
            return;
        }
        NSLog(@"removeKMLs: Unknown KML feature: %@", [obj class]);
    }];
}

- (void)loadKML:(NSString *)path
{
    NSError *e = nil;
    SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:path error:&e];

    // look for a document feature in it per the KML spec
    //
    if (kml.feature != nil && [kml.feature isKindOfClass:[SimpleKMLDocument class]] == YES) {
        for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
            [self dealWithKMLFeature:feature mapView:self.mapView];
        }
    }
}

- (void)dealWithKMLFeature:(SimpleKMLFeature *)feature mapView:(MKMapView *)mapview
{
    if ([feature isKindOfClass:[SimpleKMLFolder class]] == YES) {
        NSLog(@"reloadKMLFiles: SimpleKMLFolder");

        NSArray<SimpleKMLObject *> *entries = ((SimpleKMLFolder *)feature).entries;
        NSLog(@"children: %lu", (unsigned long)[entries count]);
        for (SimpleKMLFeature *entry in entries)
            [self dealWithKMLFeature:entry mapView:mapview];
        return;
    }

    if ([feature isKindOfClass:[SimpleKMLPlacemark class]] == YES && ((SimpleKMLPlacemark *)feature).point != nil) {
        SimpleKMLPoint *point = ((SimpleKMLPlacemark *)feature).point;
        NSLog(@"reloadKMLFiles: SimpleKMLPoint");

        // create a normal point annotation for it
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];

        annotation.coordinate = point.coordinate;
        annotation.title      = feature.name;

        [self.mapView addAnnotation:annotation];
        [self.KMLfeatures addObject:annotation];
        return;
    }

    // line
    if ([feature isKindOfClass:[SimpleKMLPlacemark class]] == YES && ((SimpleKMLPlacemark *)feature).lineString != nil) {
        SimpleKMLLineString *lines = (SimpleKMLLineString *)((SimpleKMLPlacemark *)feature).lineString;
        NSLog(@"reloadKMLFiles: SimpleKMLLineString");

        NSArray<CLLocation *> *coords = lines.coordinates;

        CLLocationCoordinate2D *points = calloc([coords count], sizeof(CLLocationCoordinate2D));
        __block NSUInteger i = 0;
        [coords enumerateObjectsUsingBlock:^(CLLocation * _Nonnull coordinate, NSUInteger idx, BOOL * _Nonnull stop) {
            points[i++] = coordinate.coordinate;
        }];
        MKPolyline *overlayPolyline = [MKPolyline polylineWithCoordinates:points count:i];
        free(points);

        [self.mapView addOverlay:overlayPolyline];
        [self.KMLfeatures addObject:overlayPolyline];
        return;
    }

    // otherwise, see if we have any placemark features with a polygon
    if ([feature isKindOfClass:[SimpleKMLPlacemark class]] == YES && ((SimpleKMLPlacemark *)feature).polygon != nil) {
        SimpleKMLPolygon *polygon = (SimpleKMLPolygon *)((SimpleKMLPlacemark *)feature).polygon;
        NSLog(@"reloadKMLFiles: SimpleKMLPolygon");

        SimpleKMLLinearRing *outerRing = polygon.outerBoundary;

        CLLocationCoordinate2D points[[outerRing.coordinates count]];
        NSUInteger i = 0;

        for (CLLocation *coordinate in outerRing.coordinates)
            points[i++] = coordinate.coordinate;

        // create a polygon annotation for it
        MKPolygon *overlayPolygon = [MKPolygon polygonWithCoordinates:points count:[outerRing.coordinates count]];

        [self.mapView addOverlay:overlayPolygon];
        [self.KMLfeatures addObject:overlayPolygon];
        return;
    }

    NSLog(@"dealWithKMLFeature: Unknown KML feature: %@", [feature class]);
}

- (CLLocationCoordinate2D)currentCenter
{
    return [self.mapView centerCoordinate];
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    MKCoordinateRegion cr = self.mapView.region;
    *bottomLeft = CLLocationCoordinate2DMake(cr.center.latitude - cr.span.latitudeDelta, cr.center.longitude - cr.span.longitudeDelta);
    *topRight = CLLocationCoordinate2DMake(cr.center.latitude + cr.span.latitudeDelta, cr.center.longitude + cr.span.longitudeDelta);
}

#pragma mark -- delegation from the map

// From http://stackoverflow.com/questions/5556977/determine-if-mkmapview-was-dragged-moved moby
- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    NSArray<UIView *> *views = self.mapvc.view.subviews;
    //  Look through gesture recognizers to determine whether this region change is from user interaction

    __block BOOL found = NO;
    [views enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
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
    if ([self mapViewRegionDidChangeFromUserInteraction] == YES)
        [self.mapvc userInteractionStart];

    // Update the ruler
    [self.mapScaleView update];
}

- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
{
    if ([self mapViewRegionDidChangeFromUserInteraction] == YES)
        [self.mapvc userInteractionStart];

    // Constrain zoom levels
    if (self.minimumAltitude > self.mapView.camera.altitude && self.modifyingMap == NO) {
        self.modifyingMap = YES;
        self.mapView.camera.altitude = self.minimumAltitude;
        self.modifyingMap = NO;
    }

    [self.mapScaleView update];
}

@end
