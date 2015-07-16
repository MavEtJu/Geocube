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

- (id)init:(NSInteger)_type
{
    self = [super init];
    [self whichCachesToSnow:_type whichCache:nil];

    menuItems = @[@"Map", @"Satellite", @"Hybrid", @"Terrain",
                  @"Show cache", @"Show me", @"Show both"
                  ];

    type = SHOW_ALLCACHES;
    thatCache = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[Coordinates myLocation_Lat]
                                                            longitude:[Coordinates myLocation_Lon]
                                                                 zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;

    self.view = mapView;
}

- (void)loadMarkers
{
    // Creates a marker in the center of the map.
    [self refreshCachesData:nil];
    NSEnumerator *e = [caches objectEnumerator];
    dbCache *cache;
    while ((cache = [e nextObject]) != nil) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(cache.lat_float, cache.lon_float);
        marker.icon = [imageLibrary get:cache.cache_type.icon];
        marker.title = cache.name;
        marker.snippet = cache.description;
        marker.map = mapView;
    }
}

#pragma mark - Local menu related functions

- (void)showCache
{
    CLLocationCoordinate2D t;
    t.latitude = currentCache.lat_float;
    t.longitude = currentCache.lon_float;
    NSLog(@"Move camera to %f %f", t.latitude, t.longitude);
    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:t];
    [mapView animateWithCameraUpdate:currentCam];
}

- (void)showMe
{
    CLLocationCoordinate2D t;
    t.latitude = [Coordinates myLocation_Lat];
    t.longitude = [Coordinates myLocation_Lon];
    NSLog(@"Move camera to %f %f", t.latitude, t.longitude);
    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:t];
    [mapView animateWithCameraUpdate:currentCam];
}

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

        case 4: /* Show cache */
            [self showCache];
            return;
        case 5: /* Show Me */
            [self showMe];
            return;
        case 6: /* Show Both */
            [self showCacheAndMe];
            break;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end