/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@interface MapMapbox ()

@property (nonatomic        ) CLLocationCoordinate2D *historyCoords;

@property (nonatomic, retain) MGLMapView *mapView;
@property (nonatomic        ) BOOL mapLoaded;

@property (nonatomic, retain) NSMutableArray<GCMGLPointAnnotation *> *markers;
@property (nonatomic, retain) NSMutableArray<GCMGLPolygonCircleFill *> *circleFills;
@property (nonatomic, retain) NSMutableArray<GCMGLPolylineCircleEdge *> *circleLines;

@property (nonatomic        ) NSInteger currentAltitude;

@property (nonatomic, retain) GCMGLPolylineLineToMe *lineWaypointToMe;
@property (nonatomic, retain) dbWaypoint *wpSelected;

@property (nonatomic, retain) NSMutableArray<GCMGLPolylineTrack *> *linesHistory;
@property (nonatomic        ) NSInteger historyCoordsIdx;
@property (nonatomic        ) CLLocationCoordinate2D trackBL, trackTR;

@property (nonatomic, retain) SimpleKML *simpleKML;
@property (nonatomic, retain) NSMutableArray<id> *KMLfeatures;

@property (nonatomic, retain) GCMGLCenteredAnnotation *centeredAnnotation;

@end

@implementation MapMapbox

EMPTY_METHOD(mapViewDidDisappear)
EMPTY_METHOD(mapViewWillDisappear)
EMPTY_METHOD(mapViewDidAppear)
EMPTY_METHOD(mapViewWillAppear)
EMPTY_METHOD(mapViewDidLoad)

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
- (BOOL)mapHasViewTerrain
{
    return YES;
}

- (void)initMap
{
    self.historyCoords = calloc(COORDHISTORYSIZE, sizeof(CLLocationCoordinate2D));

    self.mapView = [[MGLMapView alloc] initWithFrame:CGRectZero];
    self.mapvc.view = self.mapView;
    self.mapView.showsUserHeadingIndicator = YES;

    if (self.staticHistory == NO)
        self.mapView.userTrackingMode = MGLUserTrackingModeFollow;

    self.markers = [NSMutableArray arrayWithCapacity:100];
    self.circleLines = [NSMutableArray arrayWithCapacity:100];
    self.circleFills = [NSMutableArray arrayWithCapacity:100];

    self.linesHistory = [NSMutableArray arrayWithCapacity:100];

    /* Add the scale ruler */
    self.mapScaleView = [LXMapScaleView mapScaleForGC:self];
    [self.mapView addSubview:self.mapScaleView];
    [self.mapScaleView update];

    // Add a new waypoint
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];

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
    [self removeMarkers];
    self.markers = nil;
    self.circleLines = nil;
    self.circleFills = nil;
    self.mapView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:coords fromDistance:self.currentAltitude pitch:0 heading:0];
    [self.mapView setCamera:camera];
    self.mapView.delegate = self;
    [self.mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:coord fromDistance:self.currentAltitude pitch:0 heading:0];

    if (zoom == YES) {
        NSInteger span = [self calculateSpan];
        camera.altitude = [self altitudeForSpan:span];
        self.currentAltitude = camera.altitude;
    }

    self.currentAltitude = camera.altitude;

    [self.mapView setCamera:camera];
    [self.mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    [self.mapView setCenterCoordinate:coord zoomLevel:zoomLevel animated:YES];
    [self.mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2 boundaryPercentage:10];
    MGLCoordinateBounds bbox = MGLCoordinateBoundsMake(d1, d2);
    [self.mapView setVisibleCoordinateBounds:bbox];
    [self.mapScaleView update];
}

- (void)removeCamera
{
    // Nothing
}

- (void)addLineMeToWaypoint
{
    CLLocationCoordinate2D coordinates[] = {
        LM.coords,
        CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude),
    };
    NSUInteger numberOfCoordinates = sizeof(coordinates) / sizeof(CLLocationCoordinate2D);
    self.lineWaypointToMe = [GCMGLPolylineLineToMe polylineWithCoordinates:coordinates count:numberOfCoordinates];
    [self.mapView addAnnotation:self.lineWaypointToMe];
}

- (void)removeLineMeToWaypoint
{
    [self.mapView removeAnnotation:self.lineWaypointToMe];
    self.lineWaypointToMe = nil;
}

- (void)removeHistory
{
    if (self.staticHistory == YES)
        return;

    [self.linesHistory enumerateObjectsUsingBlock:^(MGLPolyline * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:line];
    }];
    @synchronized(self.linesHistory) {
        [self.linesHistory removeAllObjects];
    }
}

- (void)showHistory
{
    if (self.staticHistory == YES)
        return;

#define ADDPATH(__coords__, __count__) { \
    if (__count__ != 0) { \
        GCMGLPolylineTrack *l = [GCMGLPolylineTrack polylineWithCoordinates:__coords__ count:__count__]; \
        @synchronized(self.linesHistory) { \
            [self.linesHistory addObject:l]; \
        }; \
        [self.mapView addAnnotation:l]; \
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
                MGLPolyline *l = [self.linesHistory lastObject];
                [self.linesHistory removeLastObject];
                [self.mapView removeOverlay:l];
            }
        } else {
            self.historyCoordsIdx = 0;
            self.historyCoords[self.historyCoordsIdx++] = ch.coord;
        }
        ADDPATH(self.historyCoords, self.historyCoordsIdx)
    )
}

- (void)removeMarkers
{
    [self.markers enumerateObjectsUsingBlock:^(GCMGLPointAnnotation * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:a];
    }];
    [self.markers removeAllObjects];
    [self.circleLines enumerateObjectsUsingBlock:^(MGLPolyline * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeOverlay:a];
    }];
    [self.circleLines removeAllObjects];
    [self.circleFills enumerateObjectsUsingBlock:^(MGLPolygon * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeOverlay:a];
    }];
    [self.circleFills removeAllObjects];
}

- (GCMGLPointAnnotation *)makeMarker:(dbWaypoint *)wp
{
    GCMGLPointAnnotation *marker = [[GCMGLPointAnnotation alloc] init];
    marker.coordinate = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
    marker.title = wp.wpt_name;
    marker.subtitle = wp.wpt_urlname;
    marker.waypoint = wp;

    [self.markers addObject:marker];
    [self.mapView addAnnotation:marker];

    return marker;
}

- (MGLPolygon *)makeCircle:(dbWaypoint *)wp
{
    // Seen at https://github.com/mapbox/mapbox-gl-native/issues/2167
    NSUInteger degreesBetweenPoints = 9; //45 sides
    NSUInteger numberOfPoints = floor(360 / degreesBetweenPoints) + 1;
    double distRadians = wp.account.distance_minimum / 6371000.0; // earth radius in meters
    double centerLatRadians = wp.wpt_latitude * M_PI / 180;
    double centerLonRadians = wp.wpt_longitude * M_PI / 180;
    CLLocationCoordinate2D coordinates[numberOfPoints]; //array to hold all the points
    for (NSUInteger index = 0; index < numberOfPoints; index++) {
        double degrees = index * degreesBetweenPoints;
        double degreeRadians = degrees * M_PI / 180;
        double pointLatRadians = asin( sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians));
        double pointLonRadians = centerLonRadians + atan2( sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians),
                                                          cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians) );
        double pointLat = pointLatRadians * 180 / M_PI;
        double pointLon = pointLonRadians * 180 / M_PI;
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(pointLat, pointLon);
        coordinates[index] = point;
    }

    GCMGLPolylineCircleEdge *polyline = [GCMGLPolylineCircleEdge polylineWithCoordinates:coordinates count:numberOfPoints];
    [self.circleLines addObject:polyline];
    [self.mapView addOverlay:polyline];
    GCMGLPolygonCircleFill *polygon = [GCMGLPolygonCircleFill polygonWithCoordinates:coordinates count:numberOfPoints];
    [self.circleFills addObject:polygon];
    [self.mapView addOverlay:polygon];

    return polygon;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [self removeMarkers];

    // Add the new markers to the map
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [self makeMarker:wp];
        if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
            [self makeCircle:wp];
    }];
}

- (void)placeMarker:(dbWaypoint *)wp
{
    [self makeMarker:wp];
    if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
        [self makeCircle:wp];
}

- (void)removeMarker:(dbWaypoint *)wp
{
    [self.markers enumerateObjectsUsingBlock:^(GCMGLPointAnnotation * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.waypoint._id == wp._id) {
            [self.mapView removeAnnotation:a];
            *stop = YES;
        }
    }];
    [self.circleLines enumerateObjectsUsingBlock:^(GCMGLPolylineCircleEdge * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.waypoint._id == wp._id) {
            [self.mapView removeOverlay:a];
            *stop = YES;
        }
    }];
    [self.circleFills enumerateObjectsUsingBlock:^(GCMGLPolygonCircleFill * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.waypoint._id == wp._id) {
            [self.mapView removeOverlay:a];
            *stop = YES;
        }
    }];
}

- (void)updateMarker:(dbWaypoint *)wp
{
    [self removeMarker:wp];
    [self placeMarker:wp];
}

- (void)showCenteredCoordinates:(BOOL)showIt coords:(CLLocationCoordinate2D)coords
{
    if (showIt == YES) {
        if (self.centeredAnnotation != nil)
            [self.mapView removeAnnotation:self.centeredAnnotation];
        self.centeredAnnotation = nil;
    } else {
        self.centeredAnnotation = [[GCMGLCenteredAnnotation alloc] init];
        [self.centeredAnnotation setCoordinate:coords];
        [self.mapView addAnnotation:self.centeredAnnotation];
    }
}

- (void)showTrack:(dbTrack *)track
{
    NSAssert(self.staticHistory == YES, @"Should only be called with static history");

    [self.linesHistory enumerateObjectsUsingBlock:^(MGLPolyline * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:line];
    }];
    @synchronized(self.linesHistory) {
        [self.linesHistory removeAllObjects];
    }

    if (self.linesHistory == nil)
        self.linesHistory = [NSMutableArray arrayWithCapacity:100];

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
        [self.linesHistory enumerateObjectsUsingBlock:^(GCMGLPolylineTrack * _Nonnull track, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.mapView addOverlay:track];
        }];
    }
    [self moveCameraTo:self.trackBL c2:self.trackTR];
}

- (void)removeKMLs
{
    [self.KMLfeatures enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[GCMGLPolygonKML class]] == YES) {
            [self.mapView removeOverlay:obj];
            return;
        }
        if ([obj isKindOfClass:[GCMGLPolylineKML class]] == YES) {
            [self.mapView removeOverlay:obj];
            return;
        }
        if ([obj isKindOfClass:[GCMGLPointAnnotationKML class]] == YES) {
            [self.mapView removeAnnotation:obj];
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

- (void)dealWithKMLFeature:(SimpleKMLFeature *)feature mapView:(MGLMapView *)mapview
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
        GCMGLPointAnnotationKML *annotation = [[GCMGLPointAnnotationKML alloc] init];

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
        GCMGLPolylineKML *overlayPolyline = [GCMGLPolylineKML polylineWithCoordinates:points count:i];
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
        GCMGLPolygonKML *overlayPolygon = [GCMGLPolygonKML polygonWithCoordinates:points count:[outerRing.coordinates count]];

        [self.mapView addOverlay:overlayPolygon];
        [self.KMLfeatures addObject:overlayPolygon];
        return;
    }

    NSLog(@"dealWithKMLFeature: Unknown KML feature: %@", [feature class]);
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    BOOL found = NO;
    for (UIGestureRecognizer *recognizer in self.mapView.gestureRecognizers) {
        if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            found = YES;
            break;
        }
    }

    return found;
}

#pragma -- Callbacks

- (void)mapViewDidFinishLoadingMap:(nonnull MGLMapView *)mapView
{
    if (self.mapLoaded == NO)
        [self.mapView setZoomLevel:15];
    self.mapLoaded = YES;
}

- (void)mapView:(nonnull MGLMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if ([self mapViewRegionDidChangeFromUserInteraction] == YES)
        [self.mapvc userInteractionStart];
}

- (void)mapView:(nonnull MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.mapLoaded == YES)
        self.currentAltitude = mapView.camera.altitude;
    [self.mapScaleView update];
}

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation_
{
    MGLAnnotationImage *annotationImage = nil;

    // A waypoint
    if ([annotation_ isKindOfClass:[GCMGLPointAnnotation class]] == YES) {
        GCMGLPointAnnotation *annotation = (GCMGLPointAnnotation *)annotation_;
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:[imageManager getCode:annotation.waypoint]];

        if (annotationImage == nil) {
            UIImage *image = [imageManager getPin:annotation.waypoint];

            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:[imageManager getCode:annotation.waypoint]];
        }
        return annotationImage;
    }

    // centered self
    if ([annotation_ isKindOfClass:[GCMGLCenteredAnnotation class]] == YES) {
        UIImage *image = [imageManager get:ImageMap_CenteredCoordinates];
        annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:@"centered"];

        return annotationImage;
    }

    return nil;
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(nonnull MGLPolyline *)annotation
{
    if ([annotation isKindOfClass:[GCMGLPolylineCircleEdge class]] == YES)
        return 3;

    if ([annotation isKindOfClass:[GCMGLPolylineLineToMe class]] == YES)
        return 3;

    if ([annotation isKindOfClass:[GCMGLPolylineTrack class]] == YES)
        return 3;

    return 100;
}

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    if ([annotation isKindOfClass:[GCMGLPolygonCircleFill class]] == YES)
        return 0.05;

    return 1;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    if (annotation == self.lineWaypointToMe)
        return [UIColor redColor];

    if ([annotation isKindOfClass:[GCMGLPolygonCircleFill class]] == YES)
        return configManager.mapCircleFillColour;

    if ([annotation isKindOfClass:[GCMGLPolylineCircleEdge class]] == YES)
        return configManager.mapCircleRingColour;

    if ([annotation isKindOfClass:[GCMGLPolylineTrack class]] == YES)
        return configManager.mapTrackColour;

    return [UIColor whiteColor];
}

- (UIColor *)mapView:(MGLMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation
{
    if ([annotation isKindOfClass:[GCMGLPolygonCircleFill class]] == YES)
        return configManager.mapCircleFillColour;

    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05];
}

/*
 * Touch a marker for the waypoint info window
 */

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation
{
    // Do not show popout for markers
    if ([annotation isKindOfClass:[GCMGLPointAnnotation class]] == YES)
        return NO;
    return NO;
}

- (void)mapView:(__unused MGLMapView *)mapView didSelectAnnotation:(nonnull id<MGLAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GCMGLPointAnnotation class]] == YES) {
        GCMGLPointAnnotation *pa = (GCMGLPointAnnotation *)annotation;
        self.wpSelected = pa.waypoint;
        [self.mapvc showWaypointInfo:pa.waypoint];
    }
}

- (void)mapView:(MGLMapView *)mapView didDeselectAnnotation:(nonnull id<MGLAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GCMGLPointAnnotation class]] == YES)
        [self.mapvc removeWaypointInfo];
    [mapView deselectAnnotation:annotation animated:YES];
}

- (void)setMapType:(GCMapType)mapType
{
    NSURL *styleURL = nil;
    switch (mapType) {
        case MAPTYPE_NORMAL:
            styleURL = [MGLStyle streetsStyleURL];
            break;
        case MAPTYPE_TERRAIN:
            styleURL = [MGLStyle outdoorsStyleURL];
            break;
        case MAPTYPE_AERIAL:
            styleURL = [MGLStyle satelliteStyleURL];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            styleURL = [MGLStyle satelliteStreetsStyleURL];
            break;
    }

    self.mapView.styleURL = styleURL;
}

- (CLLocationCoordinate2D)currentCenter
{
    return self.mapView.centerCoordinate;
}

- (double)currentZoom
{
    return self.mapView.zoomLevel + 1;
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    *bottomLeft = self.mapView.visibleCoordinateBounds.sw;
    *topRight = self.mapView.visibleCoordinateBounds.ne;
}

- (void)showBoundaries:(BOOL)yesno
{
    self.showBoundary = yesno;
    if (yesno == YES) {
        [self placeMarkers];
    } else {
        [self removeMarkers];
    }
}

- NEEDS_OVERLOADING_VOID(addLineTapToMe:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(removeLineTapToMe)

@end
