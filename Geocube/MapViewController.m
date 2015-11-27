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

@interface MapViewController ()
{
    MapTemplate *map;

    UILabel *distanceLabel;
    UIButton *labelMapGoogle;
    UIButton *labelMapApple;
    UIButton *labelMapOSM;

    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */
    NSInteger showBrand; /* MAPBRAND_GOOGLEMAPS | MAPBRAND_APPLEMAPS | MAPBRAND_OPENSTREETMAPS */

    CLLocationCoordinate2D meLocation;

    NSInteger waypointCount;
    NSArray *waypointsArray;
}

@end

@implementation MapViewController

@synthesize waypointsArray;

enum {
    menuFollowMe,
    menuShowBoth,
    menuShowTarget,
    menuMap,
    menuSatellite,
    menuHybrid,
    menuTerrain,
    menuDirections,
    menuMax
};

- (instancetype)init
{
    NSAssert(FALSE, @"Don't call this one");
    return nil;
}

- (instancetype)init:(NSInteger)maptype
{
    self = [super init];

    showBrand = myConfig.mapBrand;
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            map = [[MapGoogle alloc] init:self];
            break;
        case MAPBRAND_APPLEMAPS:
            map = [[MapApple alloc] init:self];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            map = [[MapOSM alloc] init:self];
            break;
    }

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuShowTarget label:@"Show target"];
    [lmi addItem:menuFollowMe label:@"Follow me"];
    [lmi addItem:menuShowBoth label:@"Show both"];
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"Satellite"];
            [lmi addItem:menuHybrid label:@"Hybrid"];
            [lmi addItem:menuTerrain label:@"Terrain"];
            break;
        case MAPBRAND_APPLEMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"Satellite"];
            [lmi addItem:menuHybrid label:@"Hybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"XSatellite"];
            [lmi addItem:menuHybrid label:@"XHybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];
            break;
    }
    [lmi addItem:menuDirections label:@"Directions"];

    showType = maptype; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    showWhom = (showType == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_ME;

    waypointsArray = nil;
    waypointCount = 0;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera];
    [map mapViewDidLoad];

    [self initDistanceLabel];
    [self initMapBrandsPicker];
    [self recalculateRects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [map mapViewWillAppear];
    [map removeMarkers];
    [self refreshWaypointsData:nil];
    [map placeMarkers];
    [waypointManager startDelegation:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [map mapViewDidAppear];
    [LM startDelegation:self isNavigating:(showType == SHOW_ONECACHE)];
    if (meLocation.longitude == 0 && meLocation.latitude == 0)
        [self updateLocationManagerLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
    [map mapViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [map removeMarkers];
    [waypointManager stopDelegation:self];
    [super viewDidDisappear:animated];
    [map mapViewDidDisappear];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self recalculateRects];
                                 }
     ];
}

- (void)recalculateRects
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
//    NSInteger height = applicationFrame.size.height - 50;

    distanceLabel.frame = CGRectMake(3, 3, 250, 20);

    labelMapGoogle.frame = CGRectMake(width - 189 - 3, 3, 63 , 20);
    labelMapApple.frame = CGRectMake(width - 126 - 3, 3, 63 , 20);
    labelMapOSM.frame = CGRectMake(width - 63 - 3, 3, 63 , 20);
}

- (void)initDistanceLabel
{
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    //distanceLabel.textAlignment = NSTextAlignmentRight;
    distanceLabel.text = @"Nothing yet";
    [self.view addSubview:distanceLabel];
}

- (void)initMapBrandsPicker
{
    labelMapGoogle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapGoogle.layer.borderWidth = 1;
    labelMapGoogle.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapGoogle addTarget:self action:@selector(choseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapGoogle.userInteractionEnabled = YES;
    [labelMapGoogle setTitle:@"Google" forState:UIControlStateNormal];;
    [labelMapGoogle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapGoogle];

    labelMapApple = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapApple.layer.borderWidth = 1;
    labelMapApple.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapApple addTarget:self action:@selector(choseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapApple.userInteractionEnabled = YES;
    [labelMapApple setTitle:@"Apple" forState:UIControlStateNormal];;
    [labelMapApple setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapApple];

    labelMapOSM = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapOSM.layer.borderWidth = 1;
    labelMapOSM.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapOSM addTarget:self action:@selector(choseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapOSM.userInteractionEnabled = YES;
    [labelMapOSM setTitle:@"OSM" forState:UIControlStateNormal];;
    [labelMapOSM setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapOSM];

    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            [labelMapGoogle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapApple setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapOSM setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapGoogle setBackgroundColor:[UIColor grayColor]];
            [labelMapApple setBackgroundColor:[UIColor clearColor]];
            [labelMapOSM setBackgroundColor:[UIColor clearColor]];
            break;
        case MAPBRAND_APPLEMAPS:
            [labelMapGoogle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapApple setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapOSM setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapGoogle setBackgroundColor:[UIColor clearColor]];
            [labelMapApple setBackgroundColor:[UIColor grayColor]];
            [labelMapOSM setBackgroundColor:[UIColor clearColor]];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            [labelMapGoogle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapApple setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapOSM setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [labelMapGoogle setBackgroundColor:[UIColor clearColor]];
            [labelMapApple setBackgroundColor:[UIColor clearColor]];
            [labelMapOSM setBackgroundColor:[UIColor grayColor]];
            break;
    }
}

- (void)removeDistanceLabel
{
    distanceLabel = nil;
    labelMapGoogle = nil;
    labelMapApple = nil;
    labelMapOSM = nil;
}

- (void)choseMapBrand:(UIButton *)button
{
    if (button == labelMapGoogle) {
        [self menuChangeMapbrand:MAPBRAND_GOOGLEMAPS];
        return;
    }
    if (button == labelMapApple) {
        [self menuChangeMapbrand:MAPBRAND_APPLEMAPS];
        return;
    }
    if (button == labelMapOSM) {
        [self menuChangeMapbrand:MAPBRAND_OPENSTREETMAPS];
        return;
    }
}


/* Delegated from GCLocationManager */
- (void)updateLocationManagerLocation
{
    meLocation = [LM coords];

    // Move the map around to match current location
    if (showWhom == SHOW_ME)
        [map moveCameraTo:meLocation];
    if (showWhom == SHOW_BOTH)
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];

    [map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools NiceDistance:[Coordinates coordinates2distance:meLocation to:waypointManager.currentWaypoint.coordinates]];
        distanceLabel.text = distance;
    } else {
        distanceLabel.text = @"-";
    }
}

- (void)updateLocationManagerHistory
{
    [map removeHistory];
    [map addHistory];
}

- (void)refreshWaypoints
{
    [self refreshWaypointsData:nil];
    [map removeMarkers];
    [map placeMarkers];
}

- (void)refreshWaypointsData:(NSString *)searchString
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    [waypointManager applyFilters:LM.coords];

    if (showType == SHOW_ONECACHE) {
        if (waypointManager.currentWaypoint != nil) {
            waypointManager.currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:waypointManager.currentWaypoint.coordinates to:LM.coords];
            waypointsArray = @[waypointManager.currentWaypoint];
            waypointCount = [waypointsArray count];
        } else {
            waypointsArray = nil;
            waypointCount = 0;
        }
        return;
    }

    if (showType == SHOW_ALLCACHES) {
        [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                return;
            [wps addObject:wp];
        }];
        waypointsArray = [wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) {

            if (obj1.calculatedDistance > obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            if (obj1.calculatedDistance < obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];

        waypointCount = [waypointsArray count];
        return;
    }
}

- (void)refreshWaypointsData
{
    [self refreshWaypointsData:nil];
}

#pragma mark -- Menu related functions

- (void)userInteraction
{
    showWhom = SHOW_NEITHER;
}

- (void)menuShowWhom:(NSInteger)whom
{
    showWhom = whom;
    meLocation = [LM coords];
    if (whom == SHOW_ME)
        [map moveCameraTo:meLocation];
    if (whom == SHOW_CACHE && waypointManager.currentWaypoint != nil)
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates];
    if (whom == SHOW_BOTH && waypointManager.currentWaypoint != nil)
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
}

- (void)menuMapType:(NSInteger)maptype
{
    [map setMapType:maptype];
}

- (void)menuChangeMapbrand:(NSInteger)brand
{
    [self removeDistanceLabel];
    [map removeMarkers];
    [map removeCamera];
    [map removeMap];

    for (UIView* b in self.view.subviews) {
        [b removeFromSuperview];
    }

    switch (brand) {
        case MAPBRAND_GOOGLEMAPS:
            NSLog(@"Switching to Google Maps");
            map = [[MapGoogle alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi enableItem:menuSatellite];
            [lmi enableItem:menuHybrid];
            [lmi enableItem:menuTerrain];
            break;;
        case MAPBRAND_APPLEMAPS:
            NSLog(@"Switching to Apple Maps");
            map = [[MapApple alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi enableItem:menuSatellite];
            [lmi enableItem:menuHybrid];
            [lmi disableItem:menuTerrain];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            NSLog(@"Switching to OpenStreet Maps");
            map = [[MapOSM alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi disableItem:menuSatellite];
            [lmi disableItem:menuHybrid];
            [lmi disableItem:menuTerrain];
            break;
    }
    showBrand = brand;
    [myConfig mapBrandUpdate:brand];

    [self refreshMenu];

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera];

    [self initDistanceLabel];
    [self initMapBrandsPicker];
    [self recalculateRects];

    [self refreshWaypointsData:nil];
    [map placeMarkers];

    [map mapViewDidAppear];
    [self menuShowWhom:showWhom];

    [self updateLocationManagerLocation];
}

- (void)menuDirections
{
    if (myConfig.mapExternal == MAPEXTERNAL_APPLEMAPS) {
        if (waypointManager.currentWaypoint == nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(LM.coords.latitude, LM.coords.longitude);

            //create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                [destination openInMapsWithLaunchOptions:nil];
            return;
        }

        if (waypointManager.currentWaypoint != nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypointManager.currentWaypoint.lat_float, waypointManager.currentWaypoint.lon_float);

            //create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        }
        return;
    }

    if (myConfig.mapExternal == MAPBRAND_GOOGLEMAPS) {
        if (waypointManager.currentWaypoint == nil) {
            NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", waypointManager.currentWaypoint.lat_float, waypointManager.currentWaypoint.lon_float];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuMap: /* Map view */
            [self menuMapType:MAPTYPE_NORMAL];
            return;
        case menuSatellite: /* Satellite view */
            [self menuMapType:MAPTYPE_SATELLITE];
            return;
        case menuHybrid: /* Hybrid view */
            [self menuMapType:MAPTYPE_HYBRID];
            return;
        case menuTerrain: /* Terrain view */
            [self menuMapType:MAPTYPE_TERRAIN];
            return;

        case menuShowTarget: /* Show cache */
            [self menuShowWhom:SHOW_CACHE];
            return;
        case menuFollowMe: /* Show Me */
            [self menuShowWhom:SHOW_ME];
            return;
        case menuShowBoth: /* Show Both */
            [self menuShowWhom:SHOW_BOTH];
            return;
        case menuDirections:
            [self menuDirections];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end