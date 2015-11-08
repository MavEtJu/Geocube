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

#import "Geocube-Prefix.pch"

@implementation MapAppleViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isMovingToParentViewController)
        [myConfig addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController)
        [myConfig deleteDelegate:self];
    [super viewWillDisappear:animated];
}

- (void)initMenu
{
    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"Satellite", @"Hybrid", @"XTerrain", @"Show target", @"Follow me", @"Show both"]];
}

- (void)initMap
{
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.showsUserLocation = YES;
    mapView.delegate = self;

    /* Add the scale ruler */
    mapScaleView = [LXMapScaleView mapScaleForMapView:mapView];
    mapScaleView.position = kLXMapScalePositionBottomLeft;
    mapScaleView.style = kLXMapScaleStyleBar;

    /* Add the cluster controller */
    mapClusterController = [[CCHMapClusterController alloc] initWithMapView:mapView];
    mapClusterController.delegate = self;
    if (myConfig.mapClustersEnable == NO)
        mapClusterController.maxZoomLevelForClustering = 0;
    else
        mapClusterController.maxZoomLevelForClustering = myConfig.mapClustersZoomLevel;

    self.view = mapView;
}

- (void)removeMap
{
    mapView = nil;
    mapClusterController = nil;
    mapScaleView = nil;
}

- (void)initCamera
{
    /* Place camera on a view of 1500 x 1500 meters */
    CLLocationCoordinate2D noLocation = {0, 0};
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];
}

- (void)placeMarkers
{
    NSLog(@"%@/placeMarkers", [self class]);
    // Creates a marker in the center of the map.
    markers = [NSMutableArray arrayWithCapacity:20];
    [waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        // Place a single pin
        GCPointAnnotation *annotation = [[GCPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = wp.coordinates;
        [annotation setCoordinate:coord];

        annotation._id = wp._id;
        annotation.name = wp.name;

        [annotation setTitle:wp.name];
        [annotation setSubtitle:wp.urlname];

        [markers addObject:annotation];
    }];
    [mapClusterController addAnnotations:markers withCompletionHandler:nil];
}

- (void)removeMarkers
{
    NSLog(@"%@/removeMarkers", [self class]);
    [markers enumerateObjectsUsingBlock:^(MKPointAnnotation *m, NSUInteger idx, BOOL *stop) {
        [mapView removeAnnotation:m];
        m = nil;
    }];
    [mapClusterController removeAnnotations:markers withCompletionHandler:nil];
    markers = nil;
}

- (void)mapCallOutPressed:(id)sender
{
    CCHMapClusterAnnotation *ann = [[mapView selectedAnnotations] objectAtIndex:0];
    if ([ann.annotations count] == 1) {
        MKPointAnnotation *ann = [[mapView selectedAnnotations] objectAtIndex:0];
        NSLog(@"%@", ann.title);
        [super openWaypointView:ann.title];
    } else {
        NSMutableArray *anns = [NSMutableArray arrayWithCapacity:[ann.annotations count]];
        [ann.annotations enumerateObjectsUsingBlock:^(GCPointAnnotation *pa, BOOL * _Nonnull stop) {
            [anns addObject:pa.title];
        }];
        [super openWaypointsPicker:anns origin:self.view];
    }
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    MKPinAnnotationView *av = (MKPinAnnotationView *)[mapView viewForAnnotation:mapClusterAnnotation];

    if ([mapClusterAnnotation.annotations count] == 1) {
        __block dbWaypoint *wp = nil;
        [mapClusterAnnotation.annotations enumerateObjectsUsingBlock:^(GCPointAnnotation *pa, BOOL * _Nonnull stop) {
            wp = [dbWaypoint dbGet:pa._id];
        }];
        av.image = [self waypointImage:wp];

        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosureButton addTarget:self action:@selector(mapCallOutPressed:) forControlEvents:UIControlEventTouchUpInside];
        av.rightCalloutAccessoryView = disclosureButton;
        av.canShowCallout = YES;

    } else {
        av.image = [imageLibrary getSquareWithNumber:[mapClusterAnnotation.annotations count]];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GCPointAnnotation class]] == YES) {
        GCPointAnnotation *a = annotation;
        MKPinAnnotationView *dropPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"venues"];

        dbWaypoint *wp = [dbWaypoint dbGet:a._id];
        dropPin.image = [self waypointImage:wp];

        UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosureButton addTarget:self action:@selector(mapCallOutPressed:) forControlEvents:UIControlEventTouchUpInside];

        dropPin.rightCalloutAccessoryView = disclosureButton;
        dropPin.canShowCallout = YES;

        return dropPin;
    }

    if ([annotation isKindOfClass:[CCHMapClusterAnnotation class]] == YES) {
        static NSString *identifier = @"identifier";
        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;

        MKAnnotationView *av = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (av != nil) {
            av.annotation = annotation;
        } else {
            av = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }

        if ([clusterAnnotation.annotations count] == 1) {
            __block dbWaypoint *wp = nil;
            [clusterAnnotation.annotations enumerateObjectsUsingBlock:^(GCPointAnnotation *pa, BOOL * _Nonnull stop) {
                wp = [dbWaypoint dbGet:pa._id];
            }];
            av.image = [self waypointImage:wp];

            UIButton *disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [disclosureButton addTarget:self action:@selector(mapCallOutPressed:) forControlEvents:UIControlEventTouchUpInside];
            av.rightCalloutAccessoryView = disclosureButton;
            av.canShowCallout = YES;
        } else {
            av.image = [imageLibrary getSquareWithNumber:[clusterAnnotation.annotations count]];
        }

        return av;
    }

    return nil;
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;
    NSString *ret;

    if (numAnnotations == 1) {
        GCPointAnnotation *pa = [mapClusterAnnotation.annotations anyObject];
        ret = pa.name;
    } else {
        ret = [NSString stringWithFormat:@"%tu waypoints", numAnnotations];
    }
    return ret;
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = MIN(mapClusterAnnotation.annotations.count, 5);
    NSMutableString *ret;

    if (numAnnotations == 1) {
        GCPointAnnotation *pa = [mapClusterAnnotation.annotations anyObject];
        ret = [NSMutableString stringWithString:pa.subtitle];
    } else {
        NSArray *annotations = [mapClusterAnnotation.annotations.allObjects subarrayWithRange:NSMakeRange(0, numAnnotations)];
        NSArray *titles = [annotations valueForKey:@"title"];
        ret = [NSMutableString stringWithString:[titles componentsJoinedByString:@", "]];
        if (numAnnotations > 5)
            [ret appendString:@"..."];
    }
    return ret;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if (overlay == lineMeToWaypoint) {
        if (viewLineMeToWaypoint == nil) {
            viewLineMeToWaypoint = [[MKPolylineView alloc] initWithPolyline:lineMeToWaypoint];
            viewLineMeToWaypoint.fillColor = [UIColor redColor];
            viewLineMeToWaypoint.strokeColor = [UIColor redColor];
            viewLineMeToWaypoint.lineWidth = 5;
        }

        return viewLineMeToWaypoint;
    }

    if (overlay == lineHistory) {
        if (viewLineHistory == nil) {
            viewLineHistory = [[MKPolylineView alloc] initWithPolyline:lineHistory];
            viewLineHistory.fillColor = [UIColor redColor];
            viewLineHistory.strokeColor = [UIColor redColor];
            viewLineHistory.lineWidth = 5;
        }

        return viewLineHistory;
    }

    return nil;
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord
{
    CLLocationCoordinate2D t = coord;

    NSInteger span = [self calculateSpan];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(t, span, span);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];

    [mapView setCenterCoordinate:t animated:YES];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    CLLocationCoordinate2D d1, d2;
    [Coordinates makeNiceBoundary:c1 c2:c2 d1:&d1 d2:&d2];

    NSMutableArray *coords = [NSMutableArray arrayWithCapacity:2];
    MKPointAnnotation *annotation;

    annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:d1];
    [coords addObject:annotation];

    annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:d2];
    [coords addObject:annotation];

    [mapView showAnnotations:coords animated:YES];

    [mapView removeAnnotations:coords];
}

- (void)setMapType:(NSInteger)mapType
{
    switch (mapType) {
        case MAPTYPE_NORMAL:
            mapView.mapType = MKMapTypeStandard;
            break;
        case MAPTYPE_SATELLITE:
            mapView.mapType = MKMapTypeSatellite;
            break;
        case MAPTYPE_HYBRID:
            mapView.mapType = MKMapTypeHybrid;
            break;
    }
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

- (void)addHistory
{
    CLLocationCoordinate2D coordinateArray[[LM.coordsHistorical count]];

    NSInteger idx = 0;
    for (GCCoordsHistorical *mho in LM.coordsHistorical) {
        coordinateArray[idx++] = mho.coord;
    }

    lineHistory = [MKPolyline polylineWithCoordinates:coordinateArray count:[LM.coordsHistorical count]];
    [mapView addOverlay:lineHistory];
}

- (void)removeHistory
{
    [mapView removeOverlay:lineHistory];
    viewLineHistory= nil;
    lineHistory= nil;
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

    [super didSelectedMenu:menu atIndex:index];
}

#pragma mark -- delegation from the map

// From http://stackoverflow.com/questions/5556977/determine-if-mkmapview-was-dragged-moved moby
- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.view.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }

    return NO;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    BOOL mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];

    if (mapChangedFromUserInteraction)
        [super userInteraction];

    // Update the ruler
    [mapScaleView update];
}

#pragma mark -- delegation from MyConfig

- (void)changeMapClusters:(BOOL)enable zoomLevel:(float)zoomLevel
{
    if (enable == NO)
        mapClusterController.maxZoomLevelForClustering = 0;
    else
        mapClusterController.maxZoomLevelForClustering = zoomLevel;
    [self removeMarkers];
    [self placeMarkers];
}

@end
