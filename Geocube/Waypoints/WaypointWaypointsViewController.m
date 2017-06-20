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

@interface WaypointWaypointsViewController ()
{
    NSArray<dbWaypoint *> *wps;
    dbWaypoint *waypoint;
    UITextField *tfLatitude, *tfLongitude;
    UIAlertAction *okButton;
}

@end

@implementation WaypointWaypointsViewController

enum {
    menuAddWaypoint,
    menuCleanup,
    menuMax
};

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    wps = [waypoint hasWaypoints];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddWaypoint label:@"Add waypoint"];
    [lmi addItem:menuCleanup label:@"Remove dupes"];

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
    if ([wps count] == 1)
        [self newWaypoint];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [wps count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointWaypointsTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTSWAYPOINTSTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    cell.iconImage.image = [imageLibrary getType:wp];
    cell.nameLabel.text = wp.wpt_urlname;
    cell.codeLabel.text = wp.wpt_name;
    cell.coordinatesLabel.text = [Coordinates NiceCoordinates:wp.coordinates];
    [cell viewWillTransitionToSize];

    if (wp._id == waypoint._id) {
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
    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    [self.navigationController popViewControllerAnimated:YES];
    WaypointViewController *cvc = (WaypointViewController *)self.navigationController.topViewController;
    [cvc showWaypoint:wp];
    return;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [waypointManager needsRefreshRemove:wp];
        [wp dbDelete];
        wps = [waypoint hasWaypoints];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (self.delegateWaypoint != nil)
            [self.delegateWaypoint WaypointWaypoints_refreshTable];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];
    if (wp._id == waypoint._id)
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
    NSMutableArray<dbWaypoint *> *nwps = [NSMutableArray arrayWithCapacity:[wps count]];
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp1, NSUInteger idx1, BOOL *stop1) {
        __block BOOL found = NO;
        [nwps enumerateObjectsUsingBlock:^(dbWaypoint *wp2, NSUInteger idx2, BOOL *stop2) {
            if (wp1.wpt_lat_int == wp2.wpt_lat_int &&
                wp1.wpt_lon_int == wp2.wpt_lon_int) {
                found = YES;
                *stop2 = YES;
            }
        }];
        if (found == NO)
            [nwps addObject:wp1];
    }];

    // Find which waypoints are unique and don't delete them
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        __block BOOL found = NO;
        [nwps enumerateObjectsUsingBlock:^(dbWaypoint *nwp, NSUInteger idx2, BOOL *stop2) {
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

    wps = nwps;
    [self.tableView reloadData];

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointWaypoints_refreshTable];

}

- (void)newWaypoint
{
    NSString *s = [NSString stringWithFormat:@"Waypoint coordinates:\n%@\nCurrent coordinates:\n%@", [Coordinates NiceCoordinates:waypoint.coordinates], [Coordinates NiceCoordinates:LM.coords]];
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Add a related waypoint"
                                message:s
                                preferredStyle:UIAlertControllerStyleAlert];

    okButton = [UIAlertAction
                actionWithTitle:@"OK"
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
                    c = [[Coordinates alloc] initString:lat lon:lon];

                    dbWaypoint *wp = [[dbWaypoint alloc] init:0];
                    wp.wpt_lat = [c lat_decimalDegreesSigned];
                    wp.wpt_lon = [c lon_decimalDegreesSigned];
                    wp.wpt_lat_int = [c lat] * 1000000;
                    wp.wpt_lon_int = [c lon] * 1000000;
                    wp.wpt_name = [dbWaypoint makeName:[waypoint.wpt_name substringFromIndex:2]];
                    wp.wpt_description = wp.wpt_name;
                    wp.wpt_date_placed_epoch = time(NULL);
                    wp.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:wp.wpt_date_placed_epoch];
                    wp.wpt_url = nil;
                    wp.wpt_urlname = wp.wpt_name;
                    wp.wpt_symbol_id = 1;
                    wp.wpt_type_id = [dbc Type_ManuallyEntered]._id;
                    wp.related_id = waypoint._id;
                    wp.account_id = waypoint.account_id;
                    [wp finish];
                    [dbWaypoint dbCreate:wp];

                    [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
                    [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

                    wps = [waypoint hasWaypoints];
                    [self.tableView reloadData];
                    [waypointManager needsRefreshAdd:wp];
                    if (self.delegateWaypoint != nil)
                        [self.delegateWaypoint WaypointWaypoints_refreshTable];
                }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:okButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Latitude (like S 12 34.567)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
        textField.text = [NSString stringWithString:[Coordinates NiceLatitude:waypoint.coordinates.latitude]];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tfLatitude = textField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
        textField.text = [NSString stringWithString:[Coordinates NiceLongitude:waypoint.coordinates.longitude]];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tfLongitude = textField;
    }];

    if ([Coordinates checkCoordinate:tfLatitude.text] == YES &&
        [Coordinates checkCoordinate:tfLongitude.text] == YES)
        okButton.enabled = YES;
    else
        okButton.enabled = NO;

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    if ([Coordinates checkCoordinate:tfLatitude.text] == YES &&
        [Coordinates checkCoordinate:tfLongitude.text] == YES)
        okButton.enabled = YES;
    else
        okButton.enabled = NO;
}

@end
