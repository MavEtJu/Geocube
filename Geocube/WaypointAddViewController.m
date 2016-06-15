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

@interface WaypointAddViewController ()
{
    NSString *code;
    NSString *name;
    CLLocationCoordinate2D coords;
}

@end

@implementation WaypointAddViewController

#define THISCELL @"WaypointAddTableViewCell"

enum {
    cellCode = 0,
    cellName,
    cellCoords,
    cellSubmit,
    cellMax
};

- (instancetype)init
{
    self = [super init];

    lmi = nil;

    code = [MyTools makeNewWaypoint:@"MY"];
    name = @"A new name";
    coords = [LM coords];

    hasCloseButton = YES;

    return self;
}

- (void)setCoordinates:(CLLocationCoordinate2D)_coords
{
    coords = _coords;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return cellMax;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"New waypoint data";
}

// Return a cell for the index path
- (GCTableViewCellWithSubtitle *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];

    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.row) {
        case cellCode:
            cell.textLabel.text = @"Waypoint code";
            cell.detailTextLabel.text = code;
            break;
        case cellName:
            cell.textLabel.text = @"Short Name";
            cell.detailTextLabel.text = name;
            break;
        case cellCoords:
            cell.textLabel.text = @"Coords";
            cell.detailTextLabel.text = [Coordinates NiceCoordinates:coords];
            break;
        case cellSubmit:
            cell.textLabel.text = @"Create this waypoint";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case cellCode:
            [self updateCode];
            break;
        case cellName:
            [self updateName];
            break;
        case cellCoords:
            [self updateCoords];
            break;
        case cellSubmit:
            [self updateSubmit];
            break;
    }
}

- (void)updateCode
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update waypoint"
                               message:@"Update waypoint code"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             code = tf.text;

                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = code;
        textField.placeholder = @"Waypoint code";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateName
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update waypoint"
                               message:@"Update waypoint name"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             name = tf.text;

                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = name;
        textField.placeholder = @"Waypoint name";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateCoords
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update waypoint"
                               message:@"Please enter the coordinates"
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
                             coords.latitude = c.lat;
                             coords.longitude = c.lon;

                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates NiceLatitudeForEditing:coords.latitude];
        textField.placeholder = @"Latitude (like S 12 34.567)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates NiceLongitudeForEditing:coords.longitude];
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)editingChanged:(UITextField *)tf
{
}

- (void)updateSubmit
{
    dbWaypoint *wp = [[dbWaypoint alloc] init:0];
    Coordinates *c = [[Coordinates alloc] init:coords];

    wp.wpt_lat = [c lat_decimalDegreesSigned];
    wp.wpt_lon = [c lon_decimalDegreesSigned];
    wp.wpt_lat_int = [c lat] * 1000000;
    wp.wpt_lon_int = [c lon] * 1000000;
    wp.wpt_name = code;
    wp.wpt_description = name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_date_placed = [MyTools dateTimeString:wp.wpt_date_placed_epoch];
    wp.wpt_url = nil;
    wp.wpt_urlname = wp.wpt_name;
    wp.wpt_symbol_id = 1;
    wp.wpt_type_id = [dbc Type_Unknown]._id;
    [dbWaypoint dbCreate:wp];

    [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
    [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];
    [dbc.Group_ManualWaypoints dbAddWaypoint:wp._id];

    [waypointManager needsRefresh];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
