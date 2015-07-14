//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapAppleViewController

- (id)init
{
    self = [super init];
    
    menuItems = @[@"Map", @"Satellite", @"Hybrid"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.mapType = MKMapTypeStandard;
    
    CLLocationCoordinate2D center;
    center.latitude = [Coordinates myLocation_Lat];
    center.longitude = [Coordinates myLocation_Lon];
    mapView.centerCoordinate = center;
    
    self.view  = mapView;
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
        // Place a single pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wp.lat_float, wp.lon_float);
        [annotation setCoordinate:coord];
        
        [annotation setTitle:wp.name]; //You can set the subtitle too
        [mapView addAnnotation:annotation];
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
            mapView.mapType = MKMapTypeStandard;
            return;
        case 1: /* Satellite view */
            mapView.mapType = MKMapTypeSatellite;
            return;
        case 2: /* Hybrid view */
            mapView.mapType = MKMapTypeHybrid;
            return;
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
