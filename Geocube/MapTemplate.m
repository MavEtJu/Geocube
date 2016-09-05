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
    MapWaypointInfoView *wpInfoView;
    NSArray *wpInfoViewButtons;
}

@end

@implementation MapTemplate

@synthesize mapvc, circlesShown;

EMPTY_METHOD(mapViewDidDisappear)
EMPTY_METHOD(mapViewWillDisappear)
EMPTY_METHOD(mapViewDidAppear)
EMPTY_METHOD(mapViewWillAppear)
EMPTY_METHOD(mapViewDidLoad)

NEEDS_OVERLOADING(startActivityViewer:(NSString *)text)
NEEDS_OVERLOADING(stopActivityViewer)
NEEDS_OVERLOADING(initCamera:(CLLocationCoordinate2D)coords)
NEEDS_OVERLOADING(removeCamera)
NEEDS_OVERLOADING(initMap)
NEEDS_OVERLOADING(removeMap)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
NEEDS_OVERLOADING(updateMyBearing:(CLLocationDirection)bearing)
NEEDS_OVERLOADING(placeMarkers)
NEEDS_OVERLOADING(removeMarkers)
NEEDS_OVERLOADING(showBoundaries:(BOOL)yesno)
NEEDS_OVERLOADING(addLineMeToWaypoint)
NEEDS_OVERLOADING(removeLineMeToWaypoint)
NEEDS_OVERLOADING(setMapType:(NSInteger)mapType)
NEEDS_OVERLOADING(updateMyPosition:(CLLocationCoordinate2D)c)
NEEDS_OVERLOADING(removeHistory)
NEEDS_OVERLOADING(addHistory)
- (CLLocationCoordinate2D)currentCenter { NEEDS_OVERLOADING_ASSERT; return CLLocationCoordinate2DMake(0, 0); }
- (double)currentZoom { NEEDS_OVERLOADING_ASSERT; return 0; }
NEEDS_OVERLOADING_BOOL(mapHasViewMap)
NEEDS_OVERLOADING_BOOL(mapHasViewSatellite)
NEEDS_OVERLOADING_BOOL(mapHasViewHybrid)
NEEDS_OVERLOADING_BOOL(mapHasViewTerrain)
NEEDS_OVERLOADING(openWaypointInfo:(id)sender)
NEEDS_OVERLOADING(currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight)
NEEDS_OVERLOADING(addMarker:(dbWaypoint *)wp)
NEEDS_OVERLOADING(removeMarker:(dbWaypoint *)wp)
NEEDS_OVERLOADING(updateMarker:(dbWaypoint *)wp)

- (instancetype)init:(MapViewController *)mvc
{
    self = [super init];

    mapvc = mvc;
    circlesShown = NO;

    return self;
}

- (void)updateActivityViewer:(NSString *)s
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView currentActivityView].activityLabel.text = s;
    }];
}

- (UIImage *)waypointImage:(dbWaypoint *)wp
{
    return [imageLibrary getPin:wp];
}

- (NSInteger)calculateSpan
{
    if (myConfig.dynamicmapEnable == NO)
        return myConfig.dynamicmapWalkingDistance;

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

    float dmWS = myConfig.dynamicmapWalkingSpeed / 3.6;
    float dmCS = myConfig.dynamicmapCyclingSpeed / 3.6;
    float dmDS = myConfig.dynamicmapDrivingSpeed / 3.6;
    float dmWD = myConfig.dynamicmapWalkingDistance;
    float dmCD = myConfig.dynamicmapCyclingDistance;
    float dmDD = myConfig.dynamicmapDrivingDistance;

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
    dbWaypoint *wp = [waypointManager waypoint_byName:name];

    // Find the right tab and the right navigation view controller
    MHTabBarController *tb = nil;
    UINavigationController *nvc = nil;
    if (_AppDelegate.currentTabBar == RC_WAYPOINTS) {
        // Find the right tab and the right navigation view controller
        tb = [_AppDelegate.tabBars objectAtIndex:RC_WAYPOINTS];
        nvc = [tb.viewControllers objectAtIndex:VC_WAYPOINTS_LIST];

        // Pick the right view controller
        WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];

        // Make sure there is nothing extra on it
        while ([cvc.navigationController.viewControllers count] != 1)
            [cvc.navigationController popViewControllerAnimated:NO];

        // Bring the right tab to the front.
        [tb setSelectedIndex:VC_WAYPOINTS_LIST animated:YES];

        // And then push the CacheViewController on top of it
        WaypointViewController *newController = [[WaypointViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:YES];
        [newController showWaypoint:wp];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        newController.title = wp.wpt_name;
        [cvc.navigationController pushViewController:newController animated:YES];

        return;
    }
    if (_AppDelegate.currentTabBar == RC_NAVIGATE) {
        // Find the right tab and the right navigation view controller
        tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
        nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];

        // Pick the right view controller
        WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];

        // Make sure there is nothing extra on it
        [cvc showWaypoint:waypointManager.currentWaypoint];

        // Bring the right tab to the front.
        [tb setSelectedIndex:VC_NAVIGATE_TARGET animated:YES];

        return;
    }
}

- (void)openWaypointsPicker:(NSArray *)names origin:(UIView *)origin
{
    NSLog(@"amount: %lu", (unsigned long)[names count]);

    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:[names count]];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL * _Nonnull stop) {
        dbWaypoint *wp = [waypointManager waypoint_byName:name];

        [descs addObject:[NSString stringWithFormat:@"%@ - %@", name, wp.wpt_urlname]];
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

- (void)recalculateRects
{
    CGRect frame = mapvc.view.frame;
    wpInfoView.frame = CGRectMake(0, frame.size.height - [wpInfoView cellHeight], frame.size.width, [wpInfoView cellHeight]);

    UIButton *b = [wpInfoViewButtons objectAtIndex:0];
    b.frame = wpInfoView.frame;
    b.frame = CGRectMake(30, wpInfoView.frame.origin.y, b.frame.size.width - 30, b.frame.size.height);

    b = [wpInfoViewButtons objectAtIndex:1];
    b.frame = CGRectMake(0, wpInfoView.frame.origin.y, 30, 30);

    [wpInfoView calculateRects];
    [wpInfoView viewWillTransitionToSize];
}

- (void)updateMapScaleView
{
    [mapScaleView update];
}

/*
 * WaypointInfo related stuff
 */

- (void)hideWaypointInfo
{
    [mapvc.view sendSubviewToBack:wpInfoView];
    [wpInfoViewButtons enumerateObjectsUsingBlock:^(UIButton *wpInfoViewButton, NSUInteger idx, BOOL * _Nonnull stop) {
        [mapvc.view sendSubviewToBack:wpInfoViewButton];
        [wpInfoViewButton removeTarget:self action:@selector(openWaypointInfo:) forControlEvents:UIControlEventTouchDown];
    }];
}

- (void)showWaypointInfo
{
    [mapvc.view bringSubviewToFront:wpInfoView];
    [wpInfoViewButtons enumerateObjectsUsingBlock:^(UIButton *wpInfoViewButton, NSUInteger idx, BOOL * _Nonnull stop) {
        [mapvc.view bringSubviewToFront:wpInfoViewButton];
        [wpInfoViewButton addTarget:self action:@selector(openWaypointInfo:) forControlEvents:UIControlEventTouchDown];
    }];
}

- (void)updateWaypointInfo:(dbWaypoint *)wp
{
    [wpInfoView waypointData:wp];
    [self recalculateRects];
}


- (void)initWaypointInfo
{
    /* Add the info window */
    wpInfoView = [[MapWaypointInfoView alloc] initWithFrame:CGRectZero];
    [mapvc.view addSubview:wpInfoView];

    NSMutableArray *as = [NSMutableArray arrayWithCapacity:2];

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.backgroundColor = [UIColor clearColor];
    b.frame = wpInfoView.frame;
    b.frame = CGRectMake(30, wpInfoView.frame.origin.y, b.frame.size.width - 30, b.frame.size.height);
    [mapvc.view addSubview:b];
    [as addObject:b];

    b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.backgroundColor = [UIColor clearColor];
    b.frame = CGRectMake(0, wpInfoView.frame.origin.y, 30, 30);
    [mapvc.view addSubview:b];
    [as addObject:b];

    wpInfoViewButtons = as;

    [self hideWaypointInfo];
}

@end
