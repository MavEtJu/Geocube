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

@interface MapTemplate ()
{
//    MapViewController *mapvc;

//    NSInteger waypointCount;

//    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
//    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */

//    CLLocationCoordinate2D meLocation;
}

@end

@implementation MapTemplate

@synthesize mapvc;

EMPTY_METHOD(viewDidDisappear)
EMPTY_METHOD(viewWillDisappear)
EMPTY_METHOD(viewDidAppear)
EMPTY_METHOD(viewWillAppear)

NEEDS_OVERLOADING(initCamera)
NEEDS_OVERLOADING(removeCamera)
NEEDS_OVERLOADING(initMap)
NEEDS_OVERLOADING(removeMap)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)coord)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
NEEDS_OVERLOADING(placeMarkers)
NEEDS_OVERLOADING(removeMarkers)
NEEDS_OVERLOADING(addLineMeToWaypoint)
NEEDS_OVERLOADING(removeLineMeToWaypoint)
NEEDS_OVERLOADING(setMapType:(NSInteger)mapType)
NEEDS_OVERLOADING(updateMyPosition:(CLLocationCoordinate2D)c);
NEEDS_OVERLOADING(removeHistory)
NEEDS_OVERLOADING(addHistory)

- (instancetype)init:(MapViewController *)mvc
{
    self = [super init];

    mapvc = mvc;

    return self;
}

- (UIImage *)waypointImage:(dbWaypoint *)wp
{
    return [imageLibrary getPin:wp];
}

- (NSInteger)calculateSpan
{

    if ([myConfig dynamicmapEnable] == NO)
        return [myConfig dynamicmapWalkingDistance];

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

    float dmWS = [myConfig dynamicmapWalkingSpeed] / 3.6;
    float dmCS = [myConfig dynamicmapCyclingSpeed] / 3.6;
    float dmDS = [myConfig dynamicmapDrivingSpeed] / 3.6;
    float dmWD = [myConfig dynamicmapWalkingDistance];
    float dmCD = [myConfig dynamicmapCyclingDistance];
    float dmDD = [myConfig dynamicmapDrivingDistance];

    NSInteger speed = LM.speed;

    NSInteger span = 0;
    if (speed < dmWS) {
        span = dmWD;
    } else if (speed < dmCS) {
        span = dmWD + (speed - dmWS) * (dmCD - dmWD) / (dmCS - dmWS);
    } else if (speed < dmDS) {
        span = dmCD + (speed - dmCS) * (dmDD - dmCD) / (dmDS - dmCS);
    } else {
        // Don't show silly things when moving too fast (most likely due to running other apps)
        span = dmDD;
    }
    return span;
}

#pragma mark -- User interaction

- (void)openWaypointView:(NSString *)name
{
    NSId _id = [dbWaypoint dbGetByName:name];
    dbWaypoint *wp = [dbWaypoint dbGet:_id];

    // Find the right tab and the right navigation view controller
    BHTabsViewController *tb = nil;
    UINavigationController *nvc = nil;
    if (_AppDelegate.currentTabBar == RC_WAYPOINTS) {
        // Find the right tab and the right navigation view controller
        tb = [_AppDelegate.tabBars objectAtIndex:RC_WAYPOINTS];
        nvc = [tb.viewControllers objectAtIndex:VC_WAYPOINTS_LIST];

        // Pick the right view controller
        CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];

        // Make sure there is nothing extra on it
        while ([cvc.navigationController.viewControllers count] != 1)
            [cvc.navigationController popViewControllerAnimated:NO];

        // Bring the right tab to the front.
        [tb makeTabViewCurrent:VC_WAYPOINTS_LIST];

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

- (void)openWaypointsPicker:(NSArray *)names origin:(UIView *)origin
{
    NSLog(@"amount: %lu", (unsigned long)[names count]);

    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:[names count]];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        NSId _id = [dbWaypoint dbGetByName:name];
        dbWaypoint *wp = [dbWaypoint dbGet:_id];

        [descs addObject:[NSString stringWithFormat:@"%@ - %@", name, wp.urlname]];
    }];

    [ActionSheetStringPicker
     showPickerWithTitle:@"Select a waypoint"
     rows:descs
     initialSelection:0
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
         [self openWaypointView:[names objectAtIndex:selectedIndex]];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
         NSLog(@"Block Picker Canceled");
     }
     origin:origin
     ];
}

@end