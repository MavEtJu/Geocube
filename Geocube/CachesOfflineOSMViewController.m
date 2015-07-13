//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation CachesOfflineOSMViewController

- (id)init
{
    self = [super init];
    
    menuItems = @[@"Map", @"Satellite"];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    
    MKMapView *mv = [[MKMapView alloc] initWithFrame:self.view.frame];
    mv.mapType = MKMapTypeStandard; // MKMapTypeHybrid;
    [self.view addSubview:mv];
    
    // Place this into your -viewDidLoad method
    NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";         // (1)
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:template]; // (2)
    overlay.canReplaceMapContent = YES;                        // (3)
    [mv addOverlay:overlay level:MKOverlayLevelAboveLabels];         // (4)
    mv.delegate = self;
    
    // Creates a marker in the center of the map.
    [self refreshWaypointsData:nil];
    NSEnumerator *e = [wps objectEnumerator];
    dbWaypoint *wp;
    while ((wp = [e nextObject]) != nil) {
        // Place a single pin
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(wp.lat_float, wp.lon_float);
        [annotation setCoordinate:coord];
        
        [annotation setTitle:wp.name]; //You can set the subtitle too
        [mv addAnnotation:annotation];
    }

    self.view = mv;
}

// And this somewhere in your class that’s mapView’s delegate (most likely a view controller).
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    return nil;
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
