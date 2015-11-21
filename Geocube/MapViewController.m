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
    UIButton *labelMap1;
    UIButton *labelMap2;

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
    menuMap,
    menuSatellite,
    menuHybrid,
    menuTerrain,
    menuShowTarget,
    menuFollowMe,
    menuShowBoth,
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

    map = [[MapGoogle alloc] init:self];
    showBrand = MAPBRAND_GOOGLEMAPS;

    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
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
    [lmi addItem:menuShowTarget label:@"Show target"];
    [lmi addItem:menuFollowMe label:@"Follow me"];
    [lmi addItem:menuShowBoth label:@"Show both"];
    menuItems = [lmi makeMenu];

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

    labelMap1.frame = CGRectMake(width - 150 - 3, 3, 75 , 20);
    labelMap2.frame = CGRectMake(width - 75 - 3, 3, 75 , 20);
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
    labelMap1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMap1.layer.borderWidth = 1;
    labelMap1.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMap1 addTarget:self action:@selector(choseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMap1.userInteractionEnabled = YES;
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            [labelMap1 setTitle:@"Apple" forState:UIControlStateNormal];;
            break;
        case MAPBRAND_APPLEMAPS:
        case MAPBRAND_OPENSTREETMAPS:
            [labelMap1 setTitle:@"Google" forState:UIControlStateNormal];;
            break;
    }
    [labelMap1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMap1];

    labelMap2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMap2.layer.borderWidth = 1;
    labelMap2.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMap2 addTarget:self action:@selector(choseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMap2.userInteractionEnabled = YES;
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
        case MAPBRAND_APPLEMAPS:
            [labelMap2 setTitle:@"OSM" forState:UIControlStateNormal];;
            break;
        case MAPBRAND_OPENSTREETMAPS:
            [labelMap2 setTitle:@"Apple" forState:UIControlStateNormal];;
            break;
    }
    [labelMap2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMap2];
}

- (void)removeDistanceLabel
{
    distanceLabel = nil;
    labelMap1 = nil;
    labelMap2 = nil;
}

- (void)choseMapBrand:(UIButton *)button
{
    if (button == labelMap1) {
        switch (showBrand) {
            case MAPBRAND_GOOGLEMAPS:
                [self menuChangeMapbrand:MAPBRAND_APPLEMAPS];
                return;
            case MAPBRAND_APPLEMAPS:
            case MAPBRAND_OPENSTREETMAPS:
                [self menuChangeMapbrand:MAPBRAND_GOOGLEMAPS];
                return;
        }
    }
    if (button == labelMap2) {
        switch (showBrand) {
            case MAPBRAND_GOOGLEMAPS:
            case MAPBRAND_APPLEMAPS:
                [self menuChangeMapbrand:MAPBRAND_OPENSTREETMAPS];
                return;
            case MAPBRAND_OPENSTREETMAPS:
                [self menuChangeMapbrand:MAPBRAND_APPLEMAPS];
                return;
        }
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
            break;;
        case MAPBRAND_APPLEMAPS:
            NSLog(@"Switching to Apple Maps");
            map = [[MapApple alloc] init:self];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            NSLog(@"Switching to OpenStreet Maps");
            map = [[MapOSM alloc] init:self];
            break;
    }
    showBrand = brand;

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
    }

    [super didSelectedMenu:menu atIndex:index];
}


@end
