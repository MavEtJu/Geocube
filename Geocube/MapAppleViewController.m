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
    [self showWhom:(_type == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_CACHE];

    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"Satellite", @"Hybrid", @"XTerrain",
                  @"Show target", @"Show me", @"Show both"]];

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

    /* Me */
    me = nil;
    me = [[MKPointAnnotation alloc] init];
    [me setCoordinate:LM.coords];
    [me setTitle:@"*"]; //You can set the subtitle too
    // [mapView addAnnotation:me];

    [self showMe];

    /* Zoom in */
    CLLocationCoordinate2D noLocation;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1500, 1500);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    mapView.showsUserLocation = YES;

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
        CLLocationCoordinate2D coord = cache.coordinates;
        [annotation setCoordinate:coord];

        [annotation setTitle:cache.name]; //You can set the subtitle too
        [mapView addAnnotation:annotation];
    }
}

- (void)updateMe
{
    if (showWhom != SHOW_ME && showWhom != SHOW_BOTH)
        return;

    me = nil;
    me = [[MKPointAnnotation alloc] init];
    [me setCoordinate:LM.coords];
    
    if (showWhom == SHOW_ME)
        [self showMe];
    if (showWhom == SHOW_BOTH)
        [self showCacheAndMe];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                         reuseIdentifier:AnnotationIdentifier];
        annotationView.canShowCallout = YES;
        annotationView.image = [imageLibrary getFound:ImageMap_dnfBrown];
//        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        [rightButton addTarget:self action:@selector(writeSomething:) forControlEvents:UIControlEventTouchUpInside];
//        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
//        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        return annotationView;
    }
    return nil;
}

#pragma mark - Local menu related functions

- (void)showCache
{
    if (currentCache == nil)
        return;

    [super showCache];
    CLLocationCoordinate2D t = currentCache.coordinates;
    [mapView setCenterCoordinate:t animated:YES];
}

- (void)showMe
{
    [super showMe];
    [mapView setCenterCoordinate:me.coordinate animated:YES];
}

- (void)showCacheAndMe
{
    if (currentCache == nil)
        return;

    [super showCacheAndMe];
    NSMutableArray *coords = [NSMutableArray arrayWithCapacity:2];

    [coords addObject:me];

    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = currentCache.coordinates;
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

        case 4: { /* Show cache */
            [self showCache];
            return;
        }
        case 5: { /* Show me */
            [self showMe];
            return;
        }
        case 6: /* Show both */
            [self showCacheAndMe];
            return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
