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

@interface KeepTrackCar ()
{
    CLLocationCoordinate2D coordsRecordedLocation;

    CGRect rectRecordedLocation;
    CGRect rectRecordedLocationCoordinates;
    CGRect rectCurrentLocation;
    CGRect rectCurrentLocationCoordinates;
    CGRect rectDistance;
    CGRect rectDirection;
    CGRect rectButtonRemember;
    CGRect rectButtonSetAsTarget;

    GCLabel *labelRecordedLocation;
    GCLabel *labelRecordedLocationCoordinates;
    GCLabel *labelCurrentLocation;
    GCLabel *labelCurrentLocationCoordinates;
    GCLabel *labelDistance;
    GCLabel *labelDirection;
    UIButton *buttonSetAsTarget;
}

@end

@implementation KeepTrackCar

enum {
    menuRememberLocation,
    menuClearCoordinates,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuRememberLocation label:_(@"keeptrackcar-Remember location")];
    [lmi addItem:menuClearCoordinates label:_(@"keeptrackcar-Clear coordinates")];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    self.view = contentView;
    [self.view sizeToFit];

    [self calculateRects];

    labelRecordedLocation = [[GCLabel alloc] initWithFrame:rectRecordedLocation];
    labelRecordedLocation.textAlignment = NSTextAlignmentCenter;
    labelRecordedLocation.text = @"Remembered Coordinates:";
    [self.view addSubview:labelRecordedLocation];

    labelRecordedLocationCoordinates = [[GCLabel alloc] initWithFrame:rectRecordedLocationCoordinates];
    labelRecordedLocationCoordinates.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelRecordedLocationCoordinates];

    labelCurrentLocation = [[GCLabel alloc] initWithFrame:rectCurrentLocation];
    labelCurrentLocation.textAlignment = NSTextAlignmentCenter;
    labelCurrentLocation.text = @"Current Coordinates:";
    [self.view addSubview:labelCurrentLocation];

    labelCurrentLocationCoordinates = [[GCLabel alloc] initWithFrame:rectCurrentLocationCoordinates];
    labelCurrentLocationCoordinates.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCurrentLocationCoordinates];

    labelDistance = [[GCLabel alloc] initWithFrame:rectDistance];
    labelDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelDistance];

    labelDirection = [[GCLabel alloc] initWithFrame:rectDirection];
    labelDirection.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelDirection];

    buttonSetAsTarget = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSetAsTarget.frame = rectButtonSetAsTarget;
    [buttonSetAsTarget setTitle:@"Set remembered location as target" forState:UIControlStateNormal];
    [buttonSetAsTarget addTarget:self action:@selector(setastarget:) forControlEvents:UIControlEventTouchDown];
    buttonSetAsTarget.userInteractionEnabled = NO;
    [self.view addSubview:buttonSetAsTarget];

    dbWaypoint *waypoint = [dbWaypoint dbGetByName:@"MYCAR"];
    if (waypoint == nil)
        coordsRecordedLocation = CLLocationCoordinate2DZero;
    else {
        coordsRecordedLocation = CLLocationCoordinate2DMake(waypoint.wpt_latitude, waypoint.wpt_longitude);
        buttonSetAsTarget.userInteractionEnabled = YES;
    }

    [self updateLocationManagerLocation];

    [self changeTheme];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger height = bounds.size.height;
    NSInteger height18 = bounds.size.height / 18;

    /*
     * +---------------------------------+
     * |       Current Coordinates       |
     * |           Curr Coords           |
     * |     Remembered Coordinates      |
     * |         Car coordinates         |
     * |                                 |
     * |         Distance: xxxx          |
     * |         Direction: xxx          |
     * |                                 |
     * |          Set as Target          |
     * |    Remember Current Location    |
     * |                                 |
     * +---------------------------------+
     */

    rectCurrentLocation = CGRectMake(0, 1 * height18, width, height18);
    rectCurrentLocationCoordinates = CGRectMake(0, 2 * height18, width, height18);

    rectRecordedLocation = CGRectMake(0, 4 * height18, width, height18);
    rectRecordedLocationCoordinates = CGRectMake(0, 5 * height18, width, height18);

    rectDistance = CGRectMake(0, 7 * height18, width, height18);
    rectDirection = CGRectMake(0, 8 * height18, width, height18);

    rectButtonRemember = CGRectMake(0, height - 7 * height18, width, height18);
    rectButtonSetAsTarget = CGRectMake(0, height - 5 * height18, width, height18);
}

- (void)viewWilltransitionToSize
{
    labelCurrentLocation.frame = rectCurrentLocation;
    labelCurrentLocationCoordinates.frame = rectCurrentLocationCoordinates;
    labelRecordedLocation.frame = rectRecordedLocation;
    labelRecordedLocationCoordinates.frame = rectRecordedLocationCoordinates;
    labelDirection.frame = rectDirection;
    labelDistance.frame = rectDistance;
    buttonSetAsTarget.frame = rectButtonSetAsTarget;
}

- (void)updateLocationManagerLocation
{
    labelCurrentLocationCoordinates.text = [Coordinates niceCoordinates:[LM coords]];
    if (coordsRecordedLocation.latitude != 0 && coordsRecordedLocation.longitude != 0) {
        labelRecordedLocationCoordinates.text = [Coordinates niceCoordinates:coordsRecordedLocation];
        labelDistance.text = [NSString stringWithFormat:@"Distance: %@", [MyTools niceDistance:[Coordinates coordinates2distance:[LM coords] to:coordsRecordedLocation]]];
        labelDirection.text = [NSString stringWithFormat:@"Direction: %@", [Coordinates bearing2compass:[Coordinates coordinates2bearing:[LM coords] to:coordsRecordedLocation]]];
    } else {
        labelRecordedLocationCoordinates.text = @"-";
        labelDistance.text = @"Distance: -";
        labelDirection.text = @"Direction: -";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LM startDelegation:self isNavigating:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [LM stopDelegation:self];
}

- (void)remember
{
    coordsRecordedLocation = [LM coords];
    [self updateLocationManagerLocation];

    // Update waypoint
    dbWaypoint *waypoint = [dbWaypoint dbGetByName:@"MYCAR"];
    if (waypoint == nil) {
        waypoint = [[dbWaypoint alloc] init];

        waypoint.wpt_name = @"MYCAR";
        waypoint.wpt_description = @"Remembered location";
        waypoint.wpt_urlname = @"Remembered location";
        waypoint.wpt_type = [dbc Type_get_byname:@"Waypoint" minor:@"Final Location"];
        waypoint.wpt_symbol = [dbc Symbol_get_bysymbol:@"Final Location"];
        [waypoint dbCreate];
        [waypointManager needsRefreshAdd:waypoint];
    }

    waypoint.wpt_longitude = coordsRecordedLocation.longitude;
    waypoint.wpt_latitude = coordsRecordedLocation.latitude;

    waypoint.wpt_date_placed_epoch = time(NULL);
    [waypointManager needsRefreshUpdate:waypoint];

    [waypoint finish];
    [waypoint dbUpdate];

    // Enable "set as target"
    buttonSetAsTarget.userInteractionEnabled = YES;
}

- (void)setastarget:(UIButton *)b
{
    dbWaypoint *waypoint = [dbWaypoint dbGetByName:@"MYCAR"];
    [waypointManager setTheCurrentWaypoint:waypoint];

    MHTabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapTemplateViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb setSelectedIndex:VC_NAVIGATE_COMPASS animated:YES];

    return;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuRememberLocation:
            [self remember];
            return;
        case menuClearCoordinates:
            coordsRecordedLocation = CLLocationCoordinate2DZero;
            [self updateLocationManagerLocation];
            dbWaypoint *wp = [dbWaypoint dbGetByName:@"MYCAR"];
            [wp dbDelete];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
