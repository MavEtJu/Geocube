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

@interface MapGoogle ()

@property (nonatomic, retain) GMSMapView *mapView;
@property (nonatomic, retain) NSMutableArray<GMSMarker *> *markers;
@property (nonatomic, retain) NSMutableArray<GCGMSCircle *> *circles;

@property (nonatomic, retain) GMSPolyline *lineMeToWaypoint;
@property (nonatomic, retain) GMSPolyline *lineTapToMe;
@property (nonatomic, retain) NSMutableArray<GMSOverlay *> *linesHistory;
@property (nonatomic, retain) GMSMutablePath *lastPathHistory;

@property (nonatomic        ) CLLocationCoordinate2D trackBL, trackTR;

@property (nonatomic, retain) dbWaypoint *wpSelected;

@property (nonatomic, retain) GMUGeometryRenderer *KMLrenderer;
@property (nonatomic, retain) NSMutableArray<GMUGeometryRenderer *> *KMLrenderers;

@property (nonatomic, retain) GMSMarker *centeredAnnotation;

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
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    if (self.staticHistory == NO)
        self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.mapView.mapStyle = currentTheme.googleMapsStyle;

    self.mapvc.view = self.mapView;

    /* Add the scale ruler */
    self.mapScaleView = [LXMapScaleView mapScaleForGC:self];
    [self.mapView addSubview:self.mapScaleView];
    [self.mapScaleView update];

    self.wpSelected = nil;

    if (self.linesHistory == nil)
        self.linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (self.lastPathHistory == nil)
        self.lastPathHistory = [GMSMutablePath path];
    if (self.staticHistory == NO)
        [self showHistory];

    self.KMLrenderers = [NSMutableArray arrayWithCapacity:3];
    [self loadKMLs];
}

- (void)removeMap
{
    self.mapView = nil;
    self.mapScaleView = nil;
}

- (void)initCamera:(CLLocationCoordinate2D)coords
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:coords zoom:15];
    if (self.staticHistory == NO)
    [self.mapView setCamera:camera];

    if (self.staticHistory == YES)
        [self moveCameraTo:self.trackBL c2:self.trackTR];
}

- (void)removeCamera
{
}

- (void)removeMarkers
{
    [self.markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        m.map = nil;
    }];
    self.markers = nil;

    [self.circles enumerateObjectsUsingBlock:^(GCGMSCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        c.map = nil;
    }];
    self.circles = nil;
}

- (GMSMarker *)makeMarker:(dbWaypoint *)wp
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude);
    marker.title = wp.wpt_name;
    marker.snippet = wp.wpt_urlname;
    marker.map = self.mapView;
    marker.groundAnchor = CGPointMake(11.0 / 35.0, 38.0 / 42.0);
    marker.infoWindowAnchor = CGPointMake(11.0 / 35.0, 3.0 / 42.0);
    marker.userData = wp;
    marker.icon = [self waypointImage:wp];
    return marker;
}

- (GCGMSCircle *)makeCircle:(dbWaypoint *)wp
{
    GCGMSCircle *circle = [GCGMSCircle circleWithPosition:CLLocationCoordinate2DMake(wp.wpt_latitude, wp.wpt_longitude) radius:wp.account.distance_minimum];
    circle.strokeWidth = configManager.mapCircleRingSize;
    circle.strokeColor = configManager.mapCircleRingColour;
    circle.fillColor = [configManager.mapCircleFillColour colorWithAlphaComponent:0.05];
    circle.map = self.mapView;
    circle.userData = wp;
    return circle;
}

- (void)placeMarkers
{
    // Remove everything from the map
    [self.markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        m.map = nil;
    }];
    self.markers = nil;

    // Add the new markers to the map
    self.markers = [NSMutableArray arrayWithCapacity:20];
    self.circles = [NSMutableArray arrayWithCapacity:20];
    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.markers addObject:[self makeMarker:wp]];

        if (self.showBoundary == YES && wp.account.distance_minimum != 0 && (wp.wpt_type.hasBoundary == YES || wp.isPhysical == YES))
            [self.circles addObject:[self makeCircle:wp]];
    }];
}

- (void)placeMarker:(dbWaypoint *)wp
{
    // Add a new marker
    __block BOOL found = NO;
    [self.markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idx, BOOL * _Nonnull stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            found = YES;
            *stop = YES;
        }
    }];
    if (found == YES)
        return;

    [self.markers addObject:[self makeMarker:wp]];

    // Add the boundary if needed
    if (self.showBoundary == YES && wp.account.distance_minimum != 0 && (wp.wpt_type.hasBoundary == YES || wp.isPhysical == YES)) {
        GCGMSCircle *circle = [self makeCircle:wp];
        circle.map = self.mapView;
        [self.circles addObject:circle];
    }
}

- (void)removeMarker:(dbWaypoint *)wp
{
    // Remove an new marker
    __block NSUInteger idx = NSNotFound;
    [self.markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            idx = idxx;
            m.map = nil;
            *stop = YES;
        }
    }];
    if (idx == NSNotFound)
        return;

    [self.markers removeObjectAtIndex:idx];

    // Remove the boundary if needed
    if (self.showBoundary == YES && wp.account.distance_minimum != 0 && wp.wpt_type.hasBoundary == YES) {
        [self.circles enumerateObjectsUsingBlock:^(GCGMSCircle * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
            if (c.userData == wp) {
                [self.circles removeObjectAtIndex:idx];
                c.map = nil;
                *stop = YES;
            }
        }];
    }
}

- (void)updateMarker:(dbWaypoint *)wp
{
    __block NSUInteger idx = NSNotFound;
    [self.markers enumerateObjectsUsingBlock:^(GMSMarker * _Nonnull m, NSUInteger idxx, BOOL * _Nonnull stop) {
        dbObject *o = (dbObject *)m.userData;
        if (wp._id == o._id) {
            idx = idxx;
            m.map = nil;
            *stop = YES;
        }
    }];
    if (idx == NSNotFound)
        return;

    [self.markers replaceObjectAtIndex:idx withObject:[self makeMarker:wp]];
}

- (void)showCenteredCoordinates:(BOOL)showIt coords:(CLLocationCoordinate2D)coords
{
    if (showIt == YES) {
        if (self.centeredAnnotation != nil)
            self.centeredAnnotation.map = nil;
        self.centeredAnnotation = nil;
    } else {
        self.centeredAnnotation = [[GMSMarker alloc] init];
        self.centeredAnnotation.position = coords;
        self.centeredAnnotation.groundAnchor = CGPointMake(0.5, 0.5);
        self.centeredAnnotation.map = self.mapView;
        self.centeredAnnotation.icon = [imageManager get:ImageMap_CenteredCoordinates];
    }
}

- (void)showBoundaries:(BOOL)yesno
{
    self.showBoundary = yesno;
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
            self.mapView.mapType = kGMSTypeNormal;
            break;
        case MAPTYPE_AERIAL:
            self.mapView.mapType = kGMSTypeSatellite;
            break;
        case MAPTYPE_TERRAIN:
            self.mapView.mapType = kGMSTypeTerrain;
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            self.mapView.mapType = kGMSTypeHybrid;
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
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
    } else {
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:coord]];
    }

    [self.mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel
{
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate setTarget:coord zoom:zoomLevel]];
    [self.mapScaleView update];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2 boundaryPercentage:10];

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:d1 coordinate:d2];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];

    [self.mapScaleView update];
}

- (void)addLineMeToWaypoint
{
    GMSMutablePath *pathMeToWaypoint = [GMSMutablePath path];
    [pathMeToWaypoint addCoordinate:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude)];
    [pathMeToWaypoint addCoordinate:LM.coords];

    self.lineMeToWaypoint = [GMSPolyline polylineWithPath:pathMeToWaypoint];
    self.lineMeToWaypoint.strokeWidth = 2.f;
    self.lineMeToWaypoint.strokeColor = configManager.mapDestinationColour;
    self.lineMeToWaypoint.map = self.mapView;
}

- (void)removeLineMeToWaypoint
{
    self.lineMeToWaypoint.map = nil;
}

- (void)addLineTapToMe:(CLLocationCoordinate2D)c
{
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:c];
    [path addCoordinate:LM.coords];

    self.lineTapToMe = [GMSPolyline polylineWithPath:path];
    self.lineTapToMe.strokeWidth = 2.f;
    self.lineTapToMe.strokeColor = configManager.mapDestinationColour;
    self.lineTapToMe.map = self.mapView;

    [self.mapvc showDistance:[MyTools niceDistance:[Coordinates coordinates2distance:c to:LM.coords]] timeout:5 unlock:NO];
}

- (void)removeLineTapToMe
{
    self.lineTapToMe.map = nil;
    self.lineTapToMe = nil;
    [self.mapvc showDistance:@"" timeout:0 unlock:YES];
}

- (void)showHistory
{
    if (self.staticHistory == YES)
        return;

    [LM.coordsHistorical enumerateObjectsUsingBlock:^(GCCoordsHistorical * _Nonnull mho, NSUInteger idx, BOOL * _Nonnull stop) {
        if (mho.restart == NO) {
            [self.lastPathHistory addCoordinate:mho.coord];
            return;
        }

#define ADDPATH(__path__, __line__) \
        GMSPolyline *__line__ = [GMSPolyline polylineWithPath:__path__]; \
        __line__.strokeWidth = 2.f; \
        __line__.strokeColor = configManager.mapTrackColour; \
        __line__.map = self.mapView;

        MAINQUEUE(
            ADDPATH(self.lastPathHistory, lineHistory)
            [self.linesHistory addObject:lineHistory];
        )

        [self.lastPathHistory removeAllCoordinates];
    }];

    if ([self.lastPathHistory count] != 0) {
        MAINQUEUE(
            ADDPATH(self.lastPathHistory, lineHistory)
            [self.linesHistory addObject:lineHistory];
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
        [self.lastPathHistory removeAllCoordinates];
    } else {
        MAINQUEUE(
            [self.linesHistory lastObject].map = nil;
            [self.linesHistory removeLastObject];
        )
    }

    [self.lastPathHistory addCoordinate:ch.coord];

    MAINQUEUE(
        ADDPATH(self.lastPathHistory, lineHistory)
        [self.linesHistory addObject:lineHistory];
    )

    if ([self.lastPathHistory count] == 200) {
        self.lastPathHistory = [GMSMutablePath path];
        [self.lastPathHistory addCoordinate:ch.coord];
        MAINQUEUE(
            ADDPATH(self.lastPathHistory, lineHistory)
            [self.linesHistory addObject:lineHistory];
        )
    }
}

- (void)removeHistory
{
    if (self.staticHistory == YES)
        return;

    for (GMSPolyline *lh in self.linesHistory) {
        lh.map = nil;
    };
    [self.linesHistory removeAllObjects];
    [self.lastPathHistory removeAllCoordinates];
}

- (void)showTrack:(dbTrack *)track
{
    NSAssert(self.staticHistory, @"Shouldn't be called for staticHistory = NO");

    if (self.linesHistory == nil)
        self.linesHistory = [NSMutableArray arrayWithCapacity:100];
    if (self.lastPathHistory == nil)
        self.lastPathHistory = [GMSMutablePath path];

    for (GMSPolyline *lh in self.linesHistory) {
        lh.map = nil;
    };
    [self.linesHistory removeAllObjects];
    [self.lastPathHistory removeAllCoordinates];

#define ADDSINGLE(__circle__, __lat__, __lon__) \
    GMSCircle *__circle__ = [GMSCircle circleWithPosition:CLLocationCoordinate2DMake(__lat__, __lon__) radius:1]; \
        __circle__.strokeWidth = 2.f; \
        __circle__.strokeColor = configManager.mapTrackColour; \
        __circle__.map = self.mapView;

#define ADDPATH(__path__, __line__) \
    GMSPolyline *__line__ = [GMSPolyline polylineWithPath:__path__]; \
        __line__.strokeWidth = 2.f; \
        __line__.strokeColor = configManager.mapTrackColour; \
        __line__.map = self.mapView;

    __block CLLocationDegrees left, right, top, bottom;
    left = 180;
    right = -180;
    top = -180;
    bottom = 180;

    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:track];

    [tes enumerateObjectsUsingBlock:^(dbTrackElement * _Nonnull te, NSUInteger idx, BOOL * _Nonnull stop) {
        bottom = MIN(bottom, te.lat);
        top = MAX(top, te.lat);
        right = MAX(right, te.lon);
        left = MIN(left, te.lon);

        if (te.restart == NO) {
            [self.lastPathHistory addCoordinate:CLLocationCoordinate2DMake(te.lat, te.lon)];
            return;
        }

        // te.restart == YES

        if ([self.lastPathHistory count] == 1) {
            ADDSINGLE(circle, te.lat, te.lon)
            [self.linesHistory addObject:circle];
        } else {
            ADDPATH(self.lastPathHistory, lineHistory)
            [self.linesHistory addObject:lineHistory];
        }

        [self.lastPathHistory removeAllCoordinates];
    }];

    if ([self.lastPathHistory count] == 1) {
        dbTrackElement *te = [tes lastObject];
        ADDSINGLE(circle, te.lat, te.lon)
        [self.linesHistory addObject:circle];
    } else if ([self.lastPathHistory count] > 1) {
        ADDPATH(self.lastPathHistory, lineHistory)
        [self.linesHistory addObject:lineHistory];
    }

    self.trackBL = CLLocationCoordinate2DMake(bottom, left);
    self.trackTR = CLLocationCoordinate2DMake(top, right);

    [self performSelector:@selector(showTrack) withObject:nil afterDelay:1];
}

- (void)showTrack
{
    [self.linesHistory enumerateObjectsUsingBlock:^(GMSOverlay * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        line.map = self.mapView;
    }];
    [self moveCameraTo:self.trackBL c2:self.trackTR];
}

- (void)removeKMLs
{
    [self.KMLrenderers enumerateObjectsUsingBlock:^(GMUGeometryRenderer * _Nonnull renderer, NSUInteger idx, BOOL * _Nonnull stop) {
        [renderer clear];
    }];
}

- (void)loadKML:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    GMUKMLParser *parser = [[GMUKMLParser alloc] initWithURL:url];
    [parser parse];
    GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:self.mapView
                                                                  geometries:parser.placemarks
                                                                      styles:parser.styles];
    [renderer render];
    [self.KMLrenderers addObject:renderer];
}

- (CLLocationCoordinate2D)currentCenter
{
    CGPoint point = self.mapView.center;
    CLLocationCoordinate2D loc;
    loc = [self.mapView.projection coordinateForPoint:point];
    return loc;
}

- (double)currentZoom
{
    CGFloat zoom = self.mapView.camera.zoom;
    return zoom;
}

- (void)currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight
{
    GMSVisibleRegion visibleRegion;
    visibleRegion = self.mapView.projection.visibleRegion;

    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];

    // we've got what we want, but here are NE and SW points
    *topRight = bounds.northEast;
    *bottomLeft = bounds.southWest;
}

#pragma mark -- delegation from the map

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if (gesture == YES)
        [self.mapvc userInteractionStart];

    // Update the ruler
    [self.mapScaleView update];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(nonnull GMSCameraPosition *)position
{
    [self.mapvc userInteractionFinished];
    [self.mapScaleView update];
}

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.mapvc addNewWaypoint:coordinate];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if (self.lineTapToMe != nil)
        [self removeLineTapToMe];

    self.wpSelected = marker.userData;
    [self.mapvc showWaypointInfo:self.wpSelected];
    return YES;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.wpSelected != nil) {
        [self.mapvc removeWaypointInfo];
        self.wpSelected = nil;
        return;
    }

    if (self.lineTapToMe != nil) {
        [self removeLineTapToMe];
        return;
    }

    [self addLineTapToMe:coordinate];
}

@end
