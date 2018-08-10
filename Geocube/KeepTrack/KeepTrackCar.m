/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic        ) CLLocationCoordinate2D coordsRecordedLocation;

@property (nonatomic        ) CGRect rectRecordedLocation;
@property (nonatomic        ) CGRect rectRecordedLocationCoordinates;
@property (nonatomic        ) CGRect rectCurrentLocation;
@property (nonatomic        ) CGRect rectCurrentLocationCoordinates;
@property (nonatomic        ) CGRect rectDistance;
@property (nonatomic        ) CGRect rectDirection;
@property (nonatomic        ) CGRect rectButtonRemember;
@property (nonatomic        ) CGRect rectButtonSetAsTarget;

@property (nonatomic, retain) GCLabelNormalText *labelRecordedLocation;
@property (nonatomic, retain) GCLabelNormalText *labelRecordedLocationCoordinates;
@property (nonatomic, retain) GCLabelNormalText *labelCurrentLocation;
@property (nonatomic, retain) GCLabelNormalText *labelCurrentLocationCoordinates;
@property (nonatomic, retain) GCLabelNormalText *labelDistance;
@property (nonatomic, retain) GCLabelNormalText *labelDirection;
@property (nonatomic, retain) GCButton *buttonSetAsTarget;

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

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuRememberLocation label:_(@"keeptrackcar-Remember location")];
    [self.lmi addItem:menuClearCoordinates label:_(@"keeptrackcar-Clear coordinates")];

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

    self.labelRecordedLocation = [[GCLabelNormalText alloc] initWithFrame:self.rectRecordedLocation];
    self.labelRecordedLocation.textAlignment = NSTextAlignmentCenter;
    self.labelRecordedLocation.text = [NSString stringWithFormat:@"%@:", _(@"keeptrackcar-Remembered coordinates")];
    [self.view addSubview:self.labelRecordedLocation];

    self.labelRecordedLocationCoordinates = [[GCLabelNormalText alloc] initWithFrame:self.rectRecordedLocationCoordinates];
    self.labelRecordedLocationCoordinates.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelRecordedLocationCoordinates];

    self.labelCurrentLocation = [[GCLabelNormalText alloc] initWithFrame:self.rectCurrentLocation];
    self.labelCurrentLocation.textAlignment = NSTextAlignmentCenter;
    self.labelCurrentLocation.text = [NSString stringWithFormat:@"%@:", _(@"keeptrackcar-Current coordinates")];
    [self.view addSubview:self.labelCurrentLocation];

    self.labelCurrentLocationCoordinates = [[GCLabelNormalText alloc] initWithFrame:self.rectCurrentLocationCoordinates];
    self.labelCurrentLocationCoordinates.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelCurrentLocationCoordinates];

    self.labelDistance = [[GCLabelNormalText alloc] initWithFrame:self.rectDistance];
    self.labelDistance.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelDistance];

    self.labelDirection = [[GCLabelNormalText alloc] initWithFrame:self.rectDirection];
    self.labelDirection.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.labelDirection];

    self.buttonSetAsTarget = [GCButton buttonWithType:UIButtonTypeSystem];
    self.buttonSetAsTarget.frame = self.rectButtonSetAsTarget;
    [self.buttonSetAsTarget setTitle:_(@"keeptrackcar-Set remembered coordinates as target") forState:UIControlStateNormal];
    [self.buttonSetAsTarget addTarget:self action:@selector(setastarget:) forControlEvents:UIControlEventTouchDown];
    self.buttonSetAsTarget.userInteractionEnabled = NO;
    [self.view addSubview:self.buttonSetAsTarget];

    dbWaypoint *waypoint = [dbWaypoint dbGetByName:@"MYCAR"];
    if (waypoint == nil)
        self.coordsRecordedLocation = CLLocationCoordinate2DZero;
    else {
        self.coordsRecordedLocation = CLLocationCoordinate2DMake(waypoint.wpt_latitude, waypoint.wpt_longitude);
        self.buttonSetAsTarget.userInteractionEnabled = YES;
    }

    [self locationManagerUpdateLocation];

    [self changeThemeStyle];
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

    self.rectCurrentLocation = CGRectMake(0, 1 * height18, width, height18);
    self.rectCurrentLocationCoordinates = CGRectMake(0, 2 * height18, width, height18);

    self.rectRecordedLocation = CGRectMake(0, 4 * height18, width, height18);
    self.rectRecordedLocationCoordinates = CGRectMake(0, 5 * height18, width, height18);

    self.rectDistance = CGRectMake(0, 7 * height18, width, height18);
    self.rectDirection = CGRectMake(0, 8 * height18, width, height18);

    self.rectButtonRemember = CGRectMake(0, height - 7 * height18, width, height18);
    self.rectButtonSetAsTarget = CGRectMake(0, height - 5 * height18, width, height18);
}

- (void)viewWilltransitionToSize
{
    self.labelCurrentLocation.frame = self.rectCurrentLocation;
    self.labelCurrentLocationCoordinates.frame = self.rectCurrentLocationCoordinates;
    self.labelRecordedLocation.frame = self.rectRecordedLocation;
    self.labelRecordedLocationCoordinates.frame = self.rectRecordedLocationCoordinates;
    self.labelDirection.frame = self.rectDirection;
    self.labelDistance.frame = self.rectDistance;
    self.buttonSetAsTarget.frame = self.rectButtonSetAsTarget;
}

- (void)locationManagerUpdateLocation
{
    self.labelCurrentLocationCoordinates.text = [Coordinates niceCoordinates:[LM coords]];
    if (self.coordsRecordedLocation.latitude != 0 && self.coordsRecordedLocation.longitude != 0) {
        self.labelRecordedLocationCoordinates.text = [Coordinates niceCoordinates:self.coordsRecordedLocation];
        self.labelDistance.text = [NSString stringWithFormat:@"%@: %@", _(@"keeptrackcar-Distance"), [MyTools niceDistance:[Coordinates coordinates2distance:[LM coords] to:self.coordsRecordedLocation]]];
        self.labelDirection.text = [NSString stringWithFormat:@"%@: %@", _(@"keeptrackcar-Distance"), [Coordinates bearing2compass:[Coordinates coordinates2bearing:[LM coords] to:self.coordsRecordedLocation]]];
    } else {
        self.labelRecordedLocationCoordinates.text = @"-";
        self.labelDistance.text = [NSString stringWithFormat:@"%@: - ", _(@"keeptrackcar-Distance")];
        self.labelDirection.text = [NSString stringWithFormat:@"%@: - ", _(@"keeptrackcar-Direction")];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LM startDelegationLocation:self isNavigating:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [LM stopDelegationLocation:self];
}

- (void)remember
{
    self.coordsRecordedLocation = [LM coords];
    [self locationManagerUpdateLocation];

    // Update waypoint
    dbWaypoint *waypoint = [dbWaypoint dbGetByName:@"MYCAR"];
    if (waypoint == nil) {
        waypoint = [[dbWaypoint alloc] init];

        waypoint.wpt_name = @"MYCAR";
        waypoint.wpt_description = _(@"keeptrackcar-Remembered location");
        waypoint.wpt_urlname = _(@"keeptrackcar-Remembered location");
        waypoint.wpt_type = [dbc typeGetByName:@"Waypoint" minor:@"Final Location"];
        waypoint.wpt_symbol = [dbc symbolGetBySymbol:@"Final Location"];
        waypoint.account = dbc.accountPrivate;
        [waypoint finish];
        [waypoint dbCreate];
        [waypointManager needsRefreshAdd:waypoint];
    }

    waypoint.wpt_longitude = self.coordsRecordedLocation.longitude;
    waypoint.wpt_latitude = self.coordsRecordedLocation.latitude;

    waypoint.wpt_date_placed_epoch = time(NULL);
    [waypointManager needsRefreshUpdate:waypoint];

    [waypoint finish];
    [waypoint dbUpdate];

    [owntracksManager alertCarParked];

    // Enable "set as target"
    self.buttonSetAsTarget.userInteractionEnabled = YES;
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
            self.coordsRecordedLocation = CLLocationCoordinate2DZero;
            [self locationManagerUpdateLocation];
            dbWaypoint *wp = [dbWaypoint dbGetByName:@"MYCAR"];
            [wp dbDelete];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
