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

@interface WaypointWaypointsViewController ()
{
    NSArray *wps;
    dbWaypoint *waypoint;
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

    hasCloseButton = YES;

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    cell.imageView.image = [imageLibrary get:wp.wpt_type.icon];

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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Add a waypoint
    switch (index) {
        case menuAddWaypoint:
            [self newWaypoint];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)newWaypoint
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Add a related waypoint"
                               message:@"Enter the coordinates"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
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
                             wp.wpt_date_placed = [MyTools dateString:wp.wpt_date_placed_epoch];
                             wp.wpt_url = nil;
                             wp.wpt_urlname = wp.wpt_name;
                             wp.wpt_symbol_id = 1;
                             wp.wpt_type_id = [dbc Type_Unknown]._id;
                             [dbWaypoint dbCreate:wp];

                             [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
                             [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

                             [self.tableView reloadData];
                             [waypointManager needsRefresh];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Latitude (like S 12 34.567)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

@end
