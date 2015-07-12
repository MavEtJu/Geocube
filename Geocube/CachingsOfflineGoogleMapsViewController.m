//
//  CachingsOfflineGoogleMapsViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@import GoogleMaps;

#import "Geocube-Prefix.pch"

@implementation CachingsOfflineGoogleMapsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                             longitude:151.2086
                                                                  zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    // Creates a marker in the center of the map.
    [self refreshWaypointsData:nil];
    NSEnumerator *e = [wps objectEnumerator];
    dbWaypoint *wp;
    while ((wp = [e nextObject]) != nil) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(wp.lat_float, wp.lon_float);
        switch (rand() % 3) {
            case 0:
                marker.icon = marker.icon = [imageLibrary get:ImageMap_pinBlack];
                break;
            case 1:
                marker.icon = marker.icon = [imageLibrary get:ImageMap_foundRed];
                break;
            case 2:
                marker.icon = marker.icon = [imageLibrary get:ImageMap_dnfYellow];
                break;
        }
        marker.title = wp.name;
        marker.snippet = wp.description;
        marker.map = mapView;
    }
    
    self.view = mapView;
}

- (void)refreshWaypointsData:(NSString *)searchString
{
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.Waypoints objectEnumerator];
    dbWaypoint *wp;
    
    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:[Coordinates myLocation]];
        
        [_wps addObject:wp];
    }
    wps = [_wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) {
        
        if (obj1.calculatedDistance > obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (obj1.calculatedDistance < obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    wpCount = [wps count];
}

@end