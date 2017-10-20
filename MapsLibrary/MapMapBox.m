/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface MapMapBox ()
{
    CLLocationCoordinate2D historyCoords[COORDHISTORYSIZE];
}

@property (nonatomic, retain) MGLMapView *mapView;

@property (nonatomic, retain) NSMutableArray<GCMGLPointAnnotation *> *markers;
@property (nonatomic, retain) NSMutableArray<MGLPolygon *> *circles;

@property (nonatomic        ) NSInteger currentAltitude;

@property (nonatomic, retain) MGLPolyline *lineWaypointToMe;

@property (nonatomic, retain) NSMutableArray<MGLPolyline *> *linesHistory;
@property (nonatomic        ) NSInteger historyCoordsIdx;

@end

@implementation MapMapBox

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
    self.mapView = [[MGLMapView alloc] initWithFrame:CGRectZero];
    self.mapvc.view = self.mapView;

    if (self.staticHistory == NO)
        self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
    self.currentAltitude = 1000;

    self.markers = [NSMutableArray arrayWithCapacity:100];
    self.circles = [NSMutableArray arrayWithCapacity:100];

    self.linesHistory = [NSMutableArray arrayWithCapacity:100];

    if (self.staticHistory == NO)
        [self showHistory];
}

- (void)removeMap
{
    self.markers = nil;
    self.circles = nil;
    self.mapView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:coords fromDistance:self.currentAltitude pitch:0 heading:0];
    [self.mapView setCamera:camera];
    self.mapView.delegate = self;

}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom
{
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:coord fromDistance:self.currentAltitude pitch:0 heading:0];

    if (zoom == YES) {
        NSInteger span = [self calculateSpan];
        camera.altitude = [self altitudeForSpan:span];
        self.currentAltitude = camera.altitude;
    }

    [self.mapView setCamera:camera];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    [self.mapView setCenterCoordinate:coord zoomLevel:zoomLevel animated:YES];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2 boundaryPercentage:10];
    MGLCoordinateBounds bbox = MGLCoordinateBoundsMake(d1, d2);
    [self.mapView setVisibleCoordinateBounds:bbox];
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
    self.lineWaypointToMe = [MGLPolyline polylineWithCoordinates:coordinates count:numberOfCoordinates];
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
    @synchronized (self.linesHistory) {
        [self.linesHistory removeAllObjects];
    }
}

- (void)showHistory
{
    if (self.staticHistory == YES)
        return;

#define ADDPATH(__coords__, __count__) { \
    if (__count__ != 0) { \
        MGLPolyline *l = [MGLPolyline polylineWithCoordinates:__coords__ count:__count__]; \
        @synchronized (self.linesHistory) { \
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

    historyCoords[0] = LM.coords;
    self.historyCoordsIdx = 1;
    ADDPATH(historyCoords, self.historyCoordsIdx)
}

- (void)addHistory:(GCCoordsHistorical *)ch
{
    if (self.staticHistory == YES)
        return;

    MAINQUEUE(
        if (ch.restart == NO && self.historyCoordsIdx < COORDHISTORYSIZE - 1) {
            historyCoords[self.historyCoordsIdx++] = ch.coord;
            @synchronized (self.linesHistory) {
                MGLPolyline *l = [self.linesHistory lastObject];
                [self.linesHistory removeLastObject];
                [self.mapView removeOverlay:l];
            }
        } else {
            self.historyCoordsIdx = 0;
            historyCoords[self.historyCoordsIdx++] = ch.coord;
        }
        ADDPATH(historyCoords, self.historyCoordsIdx)
    )
}

- (void)removeMarkers
{
    [self.markers enumerateObjectsUsingBlock:^(GCMGLPointAnnotation * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:a];
    }];
    [self.markers removeAllObjects];
    [self.circles enumerateObjectsUsingBlock:^(MGLPolygon * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeOverlay:a];
    }];
    [self.circles removeAllObjects];
}

- (GCMGLPointAnnotation *)makeMarker:(dbWaypoint *)wp
{
    GCMGLPointAnnotation *marker = [[GCMGLPointAnnotation alloc] init];
    marker.coordinate = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
    marker.title = wp.wpt_name;
    marker.subtitle = wp.wpt_urlname;
    marker.waypoint = wp;
    [self.mapView addAnnotation:marker];
    return marker;
}

- (MGLPolygon *)makeCircle:(dbWaypoint *)wp
{
    NSInteger meterRadius = 150;

    // Seen at https://github.com/mapbox/mapbox-gl-native/issues/2167
    NSUInteger degreesBetweenPoints = 8; //45 sides
    NSUInteger numberOfPoints = floor(360 / degreesBetweenPoints);
    double distRadians = meterRadius / 6371000.0; // earth radius in meters
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

    MGLPolygon *polygon = [MGLPolygon polygonWithCoordinates:coordinates count:numberOfPoints];
    [self.mapView addOverlay:polygon];
    return polygon;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [self.markers enumerateObjectsUsingBlock:^(MGLPointAnnotation * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:a];
    }];
    [self.markers removeAllObjects];
    [self.circles removeAllObjects];

    // Add the new markers to the map
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.markers addObject:[self makeMarker:wp]];

        if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
            [self.circles addObject:[self makeCircle:wp]];
    }];
}

#pragma -- Callbacks

- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)_annotation
{
    MGLAnnotationImage *annotationImage = nil;
    if ([_annotation isKindOfClass:[GCMGLPointAnnotation class]] == YES) {
        GCMGLPointAnnotation *annotation = (GCMGLPointAnnotation *)_annotation;
        annotationImage = [mapView dequeueReusableAnnotationImageWithIdentifier:[imageManager getCode:annotation.waypoint]];

        if (annotationImage == nil) {
            UIImage *image = [imageManager getPin:annotation.waypoint];

            image = [image imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, 0, image.size.height/2, 0)];
            annotationImage = [MGLAnnotationImage annotationImageWithImage:image reuseIdentifier:[imageManager getCode:annotation.waypoint]];
        }
    }

    return annotationImage;
}

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    return 1;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    if (annotation == self.lineWaypointToMe)
        return [UIColor redColor];

    __block BOOL found = NO;

    [self.circles enumerateObjectsUsingBlock:^(MGLPolygon * _Nonnull circle, NSUInteger idx, BOOL * _Nonnull stop) {
        if (circle == annotation) {
            *stop = YES;
            found = YES;
        }
    }];
    if (found == YES)
        return [UIColor blueColor];

    [self.linesHistory enumerateObjectsUsingBlock:^(MGLPolyline * _Nonnull lh, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lh == annotation) {
            *stop = YES;
            found = YES;
        }
    }];
    if (found == YES)
        return configManager.mapTrackColour;

    return [UIColor redColor];
}

- (UIColor *)mapView:(MGLMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation
{
    __block BOOL found = NO;
    [self.circles enumerateObjectsUsingBlock:^(MGLPolygon * _Nonnull circle, NSUInteger idx, BOOL * _Nonnull stop) {
        if (circle == annotation) {
            *stop = YES;
            found = YES;
        }
    }];
    if (found == YES)
        return [UIColor colorWithRed:0 green:0 blue:0.35 alpha:0.05];

    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05];
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
    return self.mapView.zoomLevel;
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    *bottomLeft = self.mapView.visibleCoordinateBounds.sw;
    *topRight = self.mapView.visibleCoordinateBounds.ne;
}

- (void)showBoundaries:(BOOL)yesno
{
    showBoundary = yesno;
    if (yesno == YES) {
        [self placeMarkers];
    } else {
        [self removeMarkers];
    }
}

- NEEDS_OVERLOADING_VOID(updateMyBearing:(CLLocationDirection)bearing)
- NEEDS_OVERLOADING_VOID(addLineTapToMe:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(removeLineTapToMe)
- NEEDS_OVERLOADING_VOID(updateMyPosition:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(showTrack:(dbTrack *)track)
- NEEDS_OVERLOADING_VOID(showTrack)
- NEEDS_OVERLOADING_VOID(placeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(removeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(updateMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(loadKML:(NSString *)file)
- NEEDS_OVERLOADING_VOID(removeKMLs)

@end
