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

@interface WaypointWaypointsViewController ()

@property (nonatomic, retain) NSArray<dbWaypoint *> *wps;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) UITextField *tfLatitude, *tfLongitude;
@property (nonatomic, retain) UIAlertAction *okButton;

@end

@implementation WaypointWaypointsViewController

enum {
    menuAddWaypoint,
    menuCleanup,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super init];

    self.waypoint = wp;
    self.wps = [self.waypoint hasWaypoints];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuAddWaypoint label:_(@"waypointwaypointsviewcontroller-Add waypoint")];
    [self.lmi addItem:menuCleanup label:_(@"waypointwaypointsviewcontroller-Remove dupes")];

    self.delegateWaypoint = nil;

    [self.tableView registerClass:[WaypointWaypointsTableViewCell class] forCellReuseIdentifier:XIB_WAYPOINTSWAYPOINTSTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_WAYPOINTSWAYPOINTSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_WAYPOINTSWAYPOINTSTABLEVIEWCELL];

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = YES;
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.wps count] == 1)
        [self newWaypoint];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.wps count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointWaypointsTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTSWAYPOINTSTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [self.wps objectAtIndex:indexPath.row];

    cell.iconImage.image = [imageManager getType:wp];
    cell.nameLabel.text = wp.wpt_urlname;
    cell.codeLabel.text = wp.wpt_name;
    cell.coordinatesLabel.text = [Coordinates niceCoordinates:wp.wpt_latitude longitude:wp.wpt_longitude];
    [cell viewWillTransitionToSize];

    if (wp._id == self.waypoint._id) {
        cell.userInteractionEnabled = NO;
        cell.nameLabel.textColor = [UIColor lightGrayColor];
        cell.codeLabel.textColor = [UIColor lightGrayColor];
        cell.coordinatesLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.userInteractionEnabled = YES;
        cell.nameLabel.textColor = [UIColor darkGrayColor];
        cell.codeLabel.textColor = [UIColor darkGrayColor];
        cell.coordinatesLabel.textColor = [UIColor darkGrayColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.wps objectAtIndex:indexPath.row];

    [self.navigationController popViewControllerAnimated:YES];
    WaypointViewController *cvc = (WaypointViewController *)self.navigationController.topViewController;
    [cvc showWaypoint:wp];
    return;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.wps objectAtIndex:indexPath.row];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [waypointManager needsRefreshRemove:wp];
        [wp dbDelete];
        self.wps = [self.waypoint hasWaypoints];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointWaypoints_refreshTable];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.wps objectAtIndex:indexPath.row];
    if (wp._id == self.waypoint._id)
        return NO;
    return YES;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Add a waypoint
    switch (index) {
        case menuAddWaypoint:
            [self newWaypoint];
            return;
        case menuCleanup:
            [self cleanup];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)cleanup
{
    // Find which waypoints are duplicates
    NSMutableArray<dbWaypoint *> *nwps = [NSMutableArray arrayWithCapacity:[self.wps count]];
    [self.wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp1, NSUInteger idx1, BOOL * _Nonnull stop1) {
        __block BOOL found = NO;
        [nwps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp2, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if (wp1.wpt_latitude == wp2.wpt_latitude &&
                wp1.wpt_longitude == wp2.wpt_longitude) {
                found = YES;
                *stop2 = YES;
            }
        }];
        if (found == NO)
            [nwps addObject:wp1];
    }];

    // Find which waypoints are unique and don't delete them
    [self.wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL found = NO;
        [nwps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull nwp, NSUInteger idx2, BOOL * _Nonnull stop2) {
            if (nwp._id == wp._id) {
                found = YES;
                *stop2 = YES;
            }
        }];
        if (found == NO) {
            [wp dbDelete];
            [waypointManager needsRefreshRemove:wp];
        }
    }];

    self.wps = nwps;
    [self.tableView reloadData];

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointWaypoints_refreshTable];
}

- (void)newWaypoint
{
    NSString *s = [NSString stringWithFormat:_(@"waypointwaypointsviewcontroller-Waypoint coordinates:\n%@\nCurrent coordinates:\n%@"), [Coordinates niceCoordinates:self.waypoint.wpt_latitude longitude:self.waypoint.wpt_longitude], [Coordinates niceCoordinates:LM.coords]];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointwaypointsviewcontroller-Add a related waypoint")
                                message:s
                                preferredStyle:UIAlertControllerStyleAlert];

    self.okButton = [UIAlertAction
                actionWithTitle:_(@"OK")
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                    //Do Some action
                    UITextField *tf = [alert.textFields objectAtIndex:0];
                    NSString *lat = tf.text;
                    NSLog(@"Latitude '%@'", lat);

                    tf = [alert.textFields objectAtIndex:1];
                    NSString *lon = tf.text;
                    NSLog(@"Longitude '%@'", lon);

                    Coordinates *c;
                    c = [[Coordinates alloc] initString:lat longitude:lon];

                    dbWaypoint *wp = [[dbWaypoint alloc] init];
                    wp.wpt_latitude = [c latitude];
                    wp.wpt_longitude = [c longitude];
                    wp.wpt_name = [dbWaypoint makeName:[self.waypoint.wpt_name substringFromIndex:2]];
                    wp.wpt_description = wp.wpt_name;
                    wp.wpt_date_placed_epoch = time(NULL);
                    wp.wpt_url = nil;
                    wp.wpt_urlname = wp.wpt_name;
                    wp.wpt_symbol = dbc.symbolVirtualStage;
                    wp.wpt_type = dbc.typeManuallyEntered;
                    wp.account = self.waypoint.account;
                    [wp finish];
                    [wp dbCreate];

                    [opencageManager addForProcessing:wp];

                    [dbc.groupAllWaypointsManuallyAdded addWaypointToGroup:wp];
                    [dbc.groupAllWaypoints addWaypointToGroup:wp];
                    [dbc.groupManualWaypoints addWaypointToGroup:wp];

                    self.wps = [self.waypoint hasWaypoints];
                    [self.tableView reloadData];
                    [waypointManager needsRefreshAdd:wp];
                    if (self.delegateWaypoint != nil)
                        [self.delegateWaypoint WaypointWaypoints_refreshTable];
                }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:self.okButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointwaypointsviewcontroller-Latitude (like S 12 34.567)");
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
        textField.text = [NSString stringWithString:[Coordinates niceLatitudeForEditing:self.waypoint.wpt_latitude]];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.tfLatitude = textField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointwaypointsviewcontroller-Longitude (like E 23 45.678)");
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
        textField.text = [NSString stringWithString:[Coordinates niceLongitudeForEditing:self.waypoint.wpt_longitude]];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.tfLongitude = textField;
    }];

    if ([Coordinates checkCoordinate:self.tfLatitude.text] == YES &&
        [Coordinates checkCoordinate:self.tfLongitude.text] == YES)
        self.okButton.enabled = YES;
    else
        self.okButton.enabled = NO;

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    if ([Coordinates checkCoordinate:self.tfLatitude.text] == YES &&
        [Coordinates checkCoordinate:self.tfLongitude.text] == YES)
        self.okButton.enabled = YES;
    else
        self.okButton.enabled = NO;
}

@end
