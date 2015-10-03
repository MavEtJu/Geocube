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

    self.view  = mapView;
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
        [mapView addAnnotation:annotation];

        [markers addObject:annotation];
    }];
}

- (void)removeMarkers
{
    [markers enumerateObjectsUsingBlock:^(MKPointAnnotation *m, NSUInteger idx, BOOL *stop) {
        [mapView removeAnnotation:m];
        m = nil;
    }];
    markers = nil;
}

- (void)mapCallOutPressed:(id)sender
{
    MKPointAnnotation *ann = [[mapView selectedAnnotations] objectAtIndex:0];
    NSLog(@"%@", ann.title);
    [super openWaypointView:ann.title];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *c = NSStringFromClass([annotation class]);
    if ([c isEqualToString:@"GCPointAnnotation"] == NO)
        return nil;

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

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
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

@end
