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
    UIButton *buttonRemember;
    UIButton *buttonSetAsTarget;
}

@end

@implementation KeepTrackCar

- (instancetype)init
{
    self = [super init];

    menuItems = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
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

    buttonRemember = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonRemember.frame = rectButtonRemember;
    [buttonRemember setTitle:@"Remember current location" forState:UIControlStateNormal];
    [buttonRemember addTarget:self action:@selector(remember:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:buttonRemember];

    buttonSetAsTarget = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonSetAsTarget.frame = rectButtonSetAsTarget;
    [buttonSetAsTarget setTitle:@"Set remembered location as target" forState:UIControlStateNormal];
    [buttonSetAsTarget addTarget:self action:@selector(setastarget:) forControlEvents:UIControlEventTouchDown];
    buttonSetAsTarget.userInteractionEnabled = NO;
    [self.view addSubview:buttonSetAsTarget];

    NSId wpid = [dbWaypoint dbGetByName:@"MYCAR"];
    if (wpid == 0)
        coordsRecordedLocation = CLLocationCoordinate2DMake(0, 0);
    else {
        dbWaypoint *waypoint = [dbWaypoint dbGet:wpid];
        coordsRecordedLocation = waypoint.coordinates;
        buttonSetAsTarget.userInteractionEnabled = YES;
    }

    [self updateLocationManagerLocation];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self calculateRects];
                                     [self viewWilltransitionToSize];
                                 }
     ];
}

- (void)viewWilltransitionToSize
{
    labelCurrentLocation.frame = rectCurrentLocation;
    labelCurrentLocationCoordinates.frame = rectCurrentLocationCoordinates;
    labelRecordedLocation.frame = rectRecordedLocation;
    labelRecordedLocationCoordinates.frame = rectRecordedLocationCoordinates;
    labelDirection.frame = rectDirection;
    labelDistance.frame = rectDistance;
    buttonRemember.frame = rectButtonRemember;
    buttonSetAsTarget.frame = rectButtonSetAsTarget;
}

- (void)updateLocationManagerLocation
{
    labelCurrentLocationCoordinates.text = [Coordinates NiceCoordinates:[LM coords]];
    labelRecordedLocationCoordinates.text = [Coordinates NiceCoordinates:coordsRecordedLocation];
    labelDistance.text = [NSString stringWithFormat:@"Distance: %@", [MyTools NiceDistance:[Coordinates coordinates2distance:[LM coords] to:coordsRecordedLocation]]];
    labelDirection.text = [NSString stringWithFormat:@"Direction: %@", [Coordinates bearing2compass:[Coordinates coordinates2bearing:[LM coords] to:coordsRecordedLocation]]];
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

- (void)remember:(UIButton *)b
{
    coordsRecordedLocation = [LM coords];
    [self updateLocationManagerLocation];

    // Update waypoint
    dbWaypoint *waypoint;

    NSId wpid = [dbWaypoint dbGetByName:@"MYCAR"];
    if (wpid == 0) {
        waypoint = [[dbWaypoint alloc] init];

        waypoint.name = @"MYCAR";
        waypoint.description = @"Remembered location";
        waypoint.urlname = @"Remembered location";
        waypoint.type = [dbc Type_get_byname:@"Waypoint" minor:@"Final Location"];
        waypoint.type_id = waypoint.type._id;
        waypoint.symbol = [dbc Symbol_get_bysymbol:@"Final Location"];
        waypoint.symbol_id = waypoint.symbol._id;
        [dbWaypoint dbCreate:waypoint];
    } else {
        waypoint = [dbWaypoint dbGet:wpid];
    }

    waypoint.coordinates = coordsRecordedLocation;
    waypoint.lon = [NSString stringWithFormat:@"%f", coordsRecordedLocation.longitude];
    waypoint.lat = [NSString stringWithFormat:@"%f", coordsRecordedLocation.latitude];

    waypoint.date_placed = [MyTools dateString:time(NULL)];

    [waypoint finish];
    [waypoint dbUpdate];

    // Enable "set as target"
    buttonSetAsTarget.userInteractionEnabled = YES;
}

- (void)setastarget:(UIButton *)b
{
    dbWaypoint *waypoint;
    NSId wpid = [dbWaypoint dbGetByName:@"MYCAR"];
    waypoint = [dbWaypoint dbGet:wpid];

    [waypointManager setCurrentWaypoint:waypoint];

    BHTabsViewController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb makeTabViewCurrent:VC_NAVIGATE_COMPASS];

    return;
}

@end
