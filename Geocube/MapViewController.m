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

    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */

    CLLocationCoordinate2D meLocation;

    NSInteger waypointCount;
    NSArray *waypointsArray;
}

@end

@implementation MapViewController

@synthesize waypointsArray;

- (instancetype)init
{
    NSAssert(FALSE, @"Don't call this one");
    return nil;
}

- (instancetype)init:(NSInteger)maptype
{
    self = [super init];

    map = [[MapGoogle alloc] init:self];
//    map = [[MapApple alloc] init:self];
//    map = [[MapOSM alloc] init:self];

    menuItems = [NSMutableArray arrayWithArray:@[@"Google Maps", @"Apple Maps", @"OpenStreet\nMaps", @"Map", @"Satellite", @"Hybrid", @"Terrain", @"Show target", @"Follow me", @"Show both"]];

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
    [map initCamera];

    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    distanceLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:distanceLabel];

    [self recalculateRects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [map viewWillAppear];
    [map removeMarkers];
    [self refreshWaypointsData:nil];
    [map placeMarkers];
    [waypointManager startDelegation:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [map viewDidAppear];
    [LM startDelegation:self isNavigating:(showType == SHOW_ONECACHE)];
    if (meLocation.longitude == 0 && meLocation.latitude == 0)
        [self updateLocationManagerLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
    [map viewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [map removeMarkers];
    [waypointManager stopDelegation:self];
    [super viewDidDisappear:animated];
    [map viewDidDisappear];
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
    NSInteger height = applicationFrame.size.height - 50;

    distanceLabel.frame = CGRectMake(width - 250, height - 40, 250, 20);
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
        distanceLabel.text = @"";
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
    [map removeCamera];
    [map removeMap];

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

    [map initMap];
    [map initCamera];
    [map viewDidAppear];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case 0: /* Google maps */
            [self menuChangeMapbrand:MAPBRAND_GOOGLEMAPS];
            return;
        case 1: /* Apple maps */
            [self menuChangeMapbrand:MAPBRAND_APPLEMAPS];
            return;
        case 2: /* OpenStreet maps */
            [self menuChangeMapbrand:MAPBRAND_OPENSTREETMAPS];
            return;

        case 3: /* Map view */
            [self menuMapType:MAPTYPE_NORMAL];
            return;
        case 4: /* Satellite view */
            [self menuMapType:MAPTYPE_SATELLITE];
            return;
        case 5: /* Hybrid view */
            [self menuMapType:MAPTYPE_HYBRID];
            return;
        case 6: /* Terrain view */
            [self menuMapType:MAPTYPE_TERRAIN];
            return;

        case 7: /* Show cache */
            [self menuShowWhom:SHOW_CACHE];
            return;
        case 8: /* Show Me */
            [self menuShowWhom:SHOW_ME];
            return;
        case 9: /* Show Both */
            [self menuShowWhom:SHOW_BOTH];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}


@end
