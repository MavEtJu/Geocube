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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation MapAppleViewController

- (void)initMenu
{
    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"Satellite", @"Hybrid", @"XTerrain", @"Show target", @"Show me", @"Show both"]];
}

- (void)initMap
{
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.showsUserLocation = YES;
    mapView.delegate = self;

    self.view  = mapView;
}

- (void)initCamera
{
    /* Place camera on a view of 1500 x 1500 meters */
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:NO];
}

- (void)placeMarkers
{
    NSEnumerator *e = [markers objectEnumerator];
    MKPointAnnotation *m;
    while ((m = [e nextObject]) != nil) {
        [mapView removeAnnotation:m];
    }

    // Creates a marker in the center of the map.
    e = [cachesArray objectEnumerator];
    dbCache *cache;
    markers = [NSMutableArray arrayWithCapacity:20];
    while ((cache = [e nextObject]) != nil) {
        // Place a single pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = cache.coordinates;
        [annotation setCoordinate:coord];

        [annotation setTitle:cache.name]; //You can set the subtitle too
        [mapView addAnnotation:annotation];

        [markers addObject:annotation];

    }
}

- (void)moveCameraTo:(CLLocationCoordinate2D)coord
{
    CLLocationCoordinate2D t = coord;
//    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(t, 1500, 1500);
//    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
//    [mapView setRegion:adjustedRegion animated:NO];

    [mapView setCenterCoordinate:t animated:YES];
}

- (void)moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2
{
    NSMutableArray *coords = [NSMutableArray arrayWithCapacity:2];
    MKPointAnnotation *annotation;

    annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:c1];
    [coords addObject:annotation];

    annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:c2];
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

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
}

@end
