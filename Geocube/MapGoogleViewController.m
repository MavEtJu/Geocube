//
//  CachingsOfflineGoogleMapsViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@import GoogleMaps;

#import "Geocube-Prefix.pch"

@implementation MapGoogleViewController

- (id)init
{
    self = [super init];
    
    menuItems = @[@"Map", @"Satellite", @"Hybrid", @"Terrain"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                             longitude:151.2086
                                                                  zoom:12];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;

    self.view = mapView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadMarkers];
}

- (void)loadMarkers
{
    // Creates a marker in the center of the map.
    [self refreshCachesData:nil];
    NSEnumerator *e = [wps objectEnumerator];
    dbCache *wp;
    while ((wp = [e nextObject]) != nil) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(wp.lat_float, wp.lon_float);
        marker.icon = [imageLibrary get:wp.cache_type.icon];
        marker.title = wp.name;
        marker.snippet = wp.description;
        marker.map = mapView;
    }
    
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.Caches objectEnumerator];
    dbCache *wp;
    
    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:[Coordinates myLocation]];
        
        [_wps addObject:wp];
    }
    wps = [_wps sortedArrayUsingComparator: ^(dbCache *obj1, dbCache *obj2) {
        
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }
    
    switch (index) {
        case 0: /* Map view */
            mapView.mapType = kGMSTypeNormal;
            return;
        case 1: /* Satellite view */
            mapView.mapType = kGMSTypeSatellite;
            return;
        case 2: /* Hybrid view */
            mapView.mapType = kGMSTypeHybrid;
            return;
        case 3: /* Terrain view */
            mapView.mapType = kGMSTypeTerrain;
            return;
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end