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

@interface WaypointWaypointsViewController ()
{
    NSArray *wps;
    dbWaypoint *waypoint;
    UITextField *tfLatitude, *tfLongitude;
    UIAlertAction *okButton;
}

@end

#define THISCELL @"WaypointWaypointsViewController"

@implementation WaypointWaypointsViewController

enum {
    menuAddWaypoint,
    menuMax
};

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    wps = [waypoint hasWaypoints];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddWaypoint label:@"Add waypoint"];

    self.delegateWaypoint = nil;

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = YES;
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
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    cell.textLabel.text = wp.wpt_urlname;
    cell.detailTextLabel.text = wp.wpt_name;
    cell.imageView.image = [imageLibrary getType:wp];

    if (wp._id == waypoint._id) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.userInteractionEnabled = YES;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
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
        [wp dbDelete];
        wps = [waypoint hasWaypoints];
        [self.tableView reloadData];
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
    }

    [super performLocalMenuAction:index];
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
                    [dbWaypoint dbCreate:wp];

                    [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
                    [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

                    wps = [waypoint hasWaypoints];
                    [self.tableView reloadData];
                    [waypointManager needsRefreshAdd:wp];
                    if (self.delegateWaypoint != nil)
                        [self.delegateWaypoint WaypointWaypoints_refreshTable];
                }];
    [okButton setEnabled:NO];
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
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tfLatitude = textField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tfLongitude = textField;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    if ([MyTools checkCoordinate:tfLatitude.text] == YES &&
        [MyTools checkCoordinate:tfLongitude.text] == YES)
        okButton.enabled = YES;
    else
        okButton.enabled = NO;
}

@end
