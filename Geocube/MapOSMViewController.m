//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapOSMViewController

- (id)init
{
    self = [super init];
    
    menuItems = @[@"Map"];
    
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
    
    [self.view addSubview:mapView];
    //self.view = mapView;
    
    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";         // (1)
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:template]; // (2)
    overlay.canReplaceMapContent = YES;                        // (3)
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];         // (4)
    mapView.delegate = self;
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

// From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    return nil;
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
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
