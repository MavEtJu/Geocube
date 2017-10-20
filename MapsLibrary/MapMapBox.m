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

@interface MapMapBox () <MGLMapViewDelegate>

@property (nonatomic, retain) MGLMapView *mapView;
@property (nonatomic, retain) NSMutableArray<GCMGLPointAnnotation *> *markers;
@property (nonatomic, retain) NSMutableArray<MGLPointAnnotation *> *circles;
@property (nonatomic) NSInteger currentAltitude;
@property (nonatomic, retain) MGLPolyline *lineWaypointToMe;

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

    self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
    self.currentAltitude = 1000;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    self.markers = [NSMutableArray arrayWithCapacity:100];
    self.circles = [NSMutableArray arrayWithCapacity:100];

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

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    return 0.5f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    if (annotation == self.lineWaypointToMe)
        return [UIColor redColor];
    return [UIColor blackColor];
}

- (UIColor *)mapView:(MGLMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation
{
    return [UIColor colorWithRed:59.0f/255.0f green:178.0f/255.0f blue:208.0f/255.0f alpha:1.0f];
}


- (void)removeLineMeToWaypoint
{
    [self.mapView removeAnnotation:self.lineWaypointToMe];
    self.lineWaypointToMe = nil;
}

- (void)removeHistory
{
    // XXX
}

- (void)showHistory
{
    // XXX
}

- (void)removeMarkers
{
    [self.markers enumerateObjectsUsingBlock:^(GCMGLPointAnnotation * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView removeAnnotation:a];
    }];
    [self.markers removeAllObjects];
//    [self.circles enumerateObjectsUsingBlock:^( * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.mapView removeOverlay:a];
//    }];
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

//        if (showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES)
//            [self.circles addObject:[self makeCircle:wp]];
    }];
}

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

- (void)addHistory:(GCCoordsHistorical *)ch
{
    // XXX
}

- NEEDS_OVERLOADING_VOID(removeMap)
- NEEDS_OVERLOADING_VOID(updateMyBearing:(CLLocationDirection)bearing)
- NEEDS_OVERLOADING_VOID(showBoundaries:(BOOL)yesno)
- NEEDS_OVERLOADING_VOID(addLineTapToMe:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(removeLineTapToMe)
- NEEDS_OVERLOADING_VOID(updateMyPosition:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(showTrack:(dbTrack *)track)
- NEEDS_OVERLOADING_VOID(showTrack)
- NEEDS_OVERLOADING_GCMAPTYPE(mapType)
- NEEDS_OVERLOADING_VOID(placeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(removeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(updateMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(loadKML:(NSString *)file)
- NEEDS_OVERLOADING_VOID(removeKMLs)

@end
