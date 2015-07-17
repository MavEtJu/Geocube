//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapAppleViewController

- (id)init:(NSInteger)_type
{
    self = [super init];
    [self whichCachesToSnow:_type whichCache:nil];

    menuItems = @[@"Map", @"Satellite", @"Hybrid",
                  @"Show cache", @"Show me", @"Show both"
                  ];

    type = SHOW_ALLCACHES;
    thatCache = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    /* Create map */
    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.mapType = MKMapTypeStandard;

    /* Zoom in */
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;

    /* Center around here */
    CLLocationCoordinate2D center;
    center.latitude = [Coordinates myLocation_Lat];
    center.longitude = [Coordinates myLocation_Lon];
    mapView.centerCoordinate = center;

    /* Me */
    me = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([Coordinates myLocation_Lat], [Coordinates myLocation_Lon]);
    [me setCoordinate:coord];
    [me setTitle:@"*"]; //You can set the subtitle too
    [mapView addAnnotation:me];

    self.view  = mapView;
}

- (void)loadMarkers
{
    // Creates a marker in the center of the map.
    [self refreshCachesData:nil];
    NSEnumerator *e = [caches objectEnumerator];
    dbCache *cache;
    while ((cache = [e nextObject]) != nil) {
        // Place a single pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(cache.lat_float, cache.lon_float);
        [annotation setCoordinate:coord];

        [annotation setTitle:cache.name]; //You can set the subtitle too
        [mapView addAnnotation:annotation];
    }
}

#pragma mark - Local menu related functions

- (void)showCache
{
    CLLocationCoordinate2D t;
    t.latitude = currentCache.lat_float;
    t.longitude = currentCache.lon_float;
    [mapView setCenterCoordinate:t animated:YES];
}

- (void)showMe
{
    [mapView setCenterCoordinate:me.coordinate animated:YES];
}

- (void)showCacheAndMe
{

    NSMutableArray *coords = [NSMutableArray arrayWithCapacity:2];

    [coords addObject:me];

    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(currentCache.lat_float, currentCache.lon_float);
    [annotation setCoordinate:coord];
    [coords addObject:annotation];

    [mapView showAnnotations:coords animated:YES];
}

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

        case 3: { /* Show cache */
            [self showCache];
            return;
        }
        case 4: { /* Show me */
            [self showMe];
            return;
        }
        case 5: /* Show both */
            [self showCacheAndMe];
            return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
