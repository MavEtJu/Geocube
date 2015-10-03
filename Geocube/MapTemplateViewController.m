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

@implementation MapTemplateViewController

NEEDS_OVERLOADING(initCamera)
NEEDS_OVERLOADING(initMenu)
NEEDS_OVERLOADING(initMap)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)coord)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
NEEDS_OVERLOADING(placeMarkers)
NEEDS_OVERLOADING(removeMarkers)
NEEDS_OVERLOADING(addLineMeToWaypoint)
NEEDS_OVERLOADING(removeLineMeToWaypoint)
NEEDS_OVERLOADING(setMapType:(NSInteger)mapType)
NEEDS_OVERLOADING(updateMyPosition:(CLLocationCoordinate2D)c);

- (instancetype)init:(NSInteger)_type
{
    self = [super init];
    waypointsArray = nil;
    waypointCount = 0;

    showType = _type; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    showWhom = (showType == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_ME;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self initMenu];
    [self initMap];
    [self initCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshWaypointsData:nil];
    [self placeMarkers];
    [waypointManager startDelegation:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [LM startDelegation:self isNavigating:(showType == SHOW_ONECACHE)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [self removeMarkers];
    [waypointManager stopDelegation:self];
    [super viewDidDisappear:animated];
}

/* Delegated from GCLocationManager */
- (void)updateData
{
    meLocation = [LM coords];
    if (showWhom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (showWhom == SHOW_BOTH)
        [self moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];

    [self removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [self addLineMeToWaypoint];
}

/* Delegated from CacheFilterManager */
- (void)refreshWaypoints
{
    [self refreshWaypointsData:nil];
    [self removeMarkers];
    [self placeMarkers];
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

- (UIImage *)waypointImage:(dbWaypoint *)wp
{
    return [imageLibrary getPin:wp];
}

- (NSInteger)calculateSpan
{
    /*
     * 5000 |                              .
     *      |                          ....
     *      |                     .....
     *      |                .....
     *      |           .....
     * 1000 |         ..
     *      |      ...
     *  100 |......
     *    0 +----------------------------------------
     *      0    2    10                 30
     *
     * Up to 2 m/s, walking speed, show 100 meters around.
     * Up to 2 - 10 m/s, cycling speed, show between 100 and 1000 meters around.
     * Up to 10 - 30 m/s, driving speed, show between 1000 and 5000 meters around
     */

    NSInteger span = 100;
    if (LM.speed < 2) {
        span = 100;
    } else if (LM.speed < 10) {
        span = 100 + (LM.speed - 2) * (1000 - 100) / (10 - 2);
    } else {
        span = 1000 + (LM.speed - 10) * (5000 - 1000) / (30 - 10);
    }
    // Don't show silly things when moving too fast (most likely due to running other apps
    if (span > 5000)
        span = 5000;
    return span;
}



#pragma mark -- Menu related functions

- (void)menuShowWhom:(NSInteger)whom
{
    showWhom = whom;
    if (whom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (whom == SHOW_CACHE && waypointManager.currentWaypoint != nil)
        [self moveCameraTo:waypointManager.currentWaypoint.coordinates];
    if (whom == SHOW_BOTH && waypointManager.currentWaypoint != nil)
        [self moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
}

- (void)menuMapType:(NSInteger)maptype
{
    [self setMapType:maptype];
}

#pragma mark -- User interaction

- (void)userInteraction
{
    showWhom = SHOW_NEITHER;
}

- (void)openWaypointView:(NSString *)name
{
    NSId _id = [dbWaypoint dbGetByName:name];
    dbWaypoint *wp = [dbWaypoint dbGet:_id];

    // Find the right tab and the right navigation view controller
    BHTabsViewController *tb = nil;
    UINavigationController *nvc = nil;
    if (_AppDelegate.currentTabBar == RC_CACHESOFFLINE) {
        // Find the right tab and the right navigation view controller
        tb = [_AppDelegate.tabBars objectAtIndex:RC_CACHESOFFLINE];
        nvc = [tb.viewControllers objectAtIndex:VC_CACHESOFFLINE_LIST];

        // Pick the right view controller
        CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];

        // Make sure there is nothing extra on it
        while ([cvc.navigationController.viewControllers count] != 1)
            [cvc.navigationController popViewControllerAnimated:NO];

        // Bring the right tab to the front.
        [tb makeTabViewCurrent:VC_CACHESOFFLINE_LIST];

        // And then push the CacheViewController on top of it
        CacheViewController *newController = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:YES];
        [newController showWaypoint:wp];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        newController.title = wp.name;
        [cvc.navigationController pushViewController:newController animated:YES];

        return;
    }
    if (_AppDelegate.currentTabBar == RC_NAVIGATE) {
        // Find the right tab and the right navigation view controller
        tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
        nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];

        // Pick the right view controller
        CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];

        // Make sure there is nothing extra on it
        [cvc showWaypoint:waypointManager.currentWaypoint];

        // Bring the right tab to the front.
        [tb makeTabViewCurrent:VC_NAVIGATE_TARGET];

        return;
    }

}

@end
