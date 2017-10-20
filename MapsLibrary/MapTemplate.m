/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface MapTemplate ()

@end

@implementation MapTemplate

EMPTY_METHOD(mapViewDidDisappear)
EMPTY_METHOD(mapViewWillDisappear)
EMPTY_METHOD(mapViewDidAppear)
EMPTY_METHOD(mapViewWillAppear)
EMPTY_METHOD(mapViewDidLoad)

- NEEDS_OVERLOADING_VOID(initCamera:(CLLocationCoordinate2D)coords)
- NEEDS_OVERLOADING_VOID(removeCamera)
- NEEDS_OVERLOADING_VOID(initMap)
- NEEDS_OVERLOADING_VOID(removeMap)
- NEEDS_OVERLOADING_VOID(moveCameraTo:(CLLocationCoordinate2D)coord zoom:(BOOL)zoom)
- NEEDS_OVERLOADING_VOID(moveCameraTo:(CLLocationCoordinate2D)coord zoomLevel:(double)zoomLevel)
- NEEDS_OVERLOADING_VOID(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
- NEEDS_OVERLOADING_VOID(placeMarkers)
- NEEDS_OVERLOADING_VOID(removeMarkers)
- NEEDS_OVERLOADING_VOID(showBoundaries:(BOOL)yesno)
- NEEDS_OVERLOADING_VOID(addLineMeToWaypoint)
- NEEDS_OVERLOADING_VOID(removeLineMeToWaypoint)
- NEEDS_OVERLOADING_VOID(addLineTapToMe:(CLLocationCoordinate2D)c)
- NEEDS_OVERLOADING_VOID(removeLineTapToMe)
- NEEDS_OVERLOADING_VOID(setMapType:(GCMapType)mapType)
- NEEDS_OVERLOADING_VOID(removeHistory)
- NEEDS_OVERLOADING_VOID(showHistory)
- NEEDS_OVERLOADING_VOID(addHistory:(GCCoordsHistorical *)ch)
- NEEDS_OVERLOADING_VOID(showTrack:(dbTrack *)track)
- NEEDS_OVERLOADING_VOID(showTrack)
- NEEDS_OVERLOADING_CLLOCATIONCOORDINATE2D(currentCenter)
- NEEDS_OVERLOADING_DOUBLE(currentZoom)
- NEEDS_OVERLOADING_BOOL(mapHasViewMap)
- NEEDS_OVERLOADING_BOOL(mapHasViewAerial)
- NEEDS_OVERLOADING_BOOL(mapHasViewHybridMapAerial)
- NEEDS_OVERLOADING_BOOL(mapHasViewTerrain)
- NEEDS_OVERLOADING_VOID(currentRectangle:(CLLocationCoordinate2D *)bottomLeft topRight:(CLLocationCoordinate2D *)topRight)
- NEEDS_OVERLOADING_VOID(placeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(removeMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(updateMarker:(dbWaypoint *)wp)
- NEEDS_OVERLOADING_VOID(loadKML:(NSString *)file)
- NEEDS_OVERLOADING_VOID(removeKMLs)

- (instancetype)initMapObject:(MapTemplateViewController *)mvc
{
    self = [super init];

    self.mapvc = mvc;
    self.circlesShown = NO;

    [waypointManager startDelegationKML:self];
    return self;
}

- (UIImage *)waypointImage:(dbWaypoint *)wp
{
    return [imageManager getPin:wp];
}

- (NSInteger)calculateSpan
{
    if (configManager.dynamicmapEnable == NO)
        return configManager.dynamicmapWalkingDistance;

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

    float dmWS = configManager.dynamicmapWalkingSpeed / 3.6;
    float dmCS = configManager.dynamicmapCyclingSpeed / 3.6;
    float dmDS = configManager.dynamicmapDrivingSpeed / 3.6;
    float dmWD = configManager.dynamicmapWalkingDistance;
    float dmCD = configManager.dynamicmapCyclingDistance;
    float dmDD = configManager.dynamicmapDrivingDistance;

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

- (double)altitudeForSpan:(double)span
{
    double adjacent = span / 2;
    double height = adjacent / tan([Coordinates degrees2rad:15]);
    return height;
}

- (double)determineAltitudeForRectangle:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 viewPort:(CGRect)viewPort
{
    // Determine the borders
    CLLocationCoordinate2D UL = CLLocationCoordinate2DMake(c1.latitude > c2.latitude ? c1.latitude : c2.latitude, c1.longitude < c2.longitude ?  c1.longitude : c2.longitude);
    CLLocationCoordinate2D UR = CLLocationCoordinate2DMake(c1.latitude > c2.latitude ? c1.latitude : c2.latitude, c1.longitude > c2.longitude ? c1.longitude : c2.longitude);
    CLLocationCoordinate2D LL = CLLocationCoordinate2DMake(c1.latitude < c2.latitude ? c1.latitude : c2.latitude, c1.longitude < c2.longitude ? c1.longitude : c2.longitude);

    CLLocationDistance dLon = MKMetersBetweenMapPoints(MKMapPointForCoordinate(UL), MKMapPointForCoordinate(UR));
    CLLocationDistance dLat = MKMetersBetweenMapPoints(MKMapPointForCoordinate(UL), MKMapPointForCoordinate(LL));

    float ratio = viewPort.size.height / viewPort.size.width;

    if (dLat > dLon) // More above each other than besides each other
        return [self altitudeForSpan:dLat];
    // More besides each other than above each other
    return [self altitudeForSpan:dLon * ratio];
}

#pragma mark -- User interaction

- (void)openWaypointView:(dbWaypoint *)wp
{
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
        WaypointViewController *newController = [[WaypointViewController alloc] init];
        newController.hasCloseButton = YES;
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

- (void)openWaypointsPicker:(NSArray<NSString *> *)names origin:(UIView *)origin
{
    NSAssert(NO, @"XXX");
    NSLog(@"amount: %lu", (unsigned long)[names count]);

    NSMutableArray<NSString *> *descs = [NSMutableArray arrayWithCapacity:[names count]];
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        dbWaypoint *wp = [waypointManager waypoint_byName:name];

        [descs addObject:[NSString stringWithFormat:@"%@ - %@", name, wp.wpt_urlname]];
    }];

    [ActionSheetStringPicker
     showPickerWithTitle:_(@"maptemplate-Select a waypoint")
     rows:descs
     initialSelection:0
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, NSString *selectedValue) {
         dbWaypoint *wp = [waypointManager waypoint_byName:[names objectAtIndex:selectedIndex]];
         [self openWaypointView:wp];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
         NSLog(@"Block Picker Canceled");
     }
     origin:origin
     ];
}

- (void)recalculateRects
{
}

- (void)updateMapScaleView
{
    [mapScaleView update];
}

- (void)moveCameraToAll
{
    __block CLLocationDegrees left, right, top, bottom;
    left = 180;
    right = -180;
    top = -180;
    bottom = 180;

    [self.mapvc.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp.wpt_latitude != 0) {
            bottom = MIN(bottom, wp.wpt_latitude);
            top = MAX(top, wp.wpt_latitude);
        }
        if (wp.wpt_longitude != 0) {
            right = MAX(right, wp.wpt_longitude);
            left = MIN(left, wp.wpt_longitude);
        }
    }];

    [self moveCameraTo:CLLocationCoordinate2DMake(bottom, left) c2:CLLocationCoordinate2DMake(top, right)];
}

- (void)loadKMLs
{
    [[dbKMLFile dbAll] enumerateObjectsUsingBlock:^(dbKMLFile * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
        if (f.enabled == NO)
            return;
        NSString *path = [NSString stringWithFormat:@"%@/%@", [MyTools KMLDir], f.filename];
        [self loadKML:path];
    }];
}

- (void)reloadKMLFiles
{
    [self removeKMLs];
    [self loadKMLs];
}

@end
