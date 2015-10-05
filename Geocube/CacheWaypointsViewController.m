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

#define THISCELL @"CacheWaypointsViewController"

@implementation CacheWaypointsViewController

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    wps = [waypoint hasWaypoints];

    menuItems = [NSMutableArray arrayWithArray:@[@"Add waypoint"]];
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
    if (cell == nil) {
        cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    cell.textLabel.text = wp.urlname;
    cell.detailTextLabel.text = wp.name;
    cell.imageView.image = [imageLibrary get:wp.type.icon];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    [self.navigationController popViewControllerAnimated:YES];
    CacheViewController *cvc = (CacheViewController *)self.navigationController.topViewController;
    [cvc showWaypoint:wp];
    return;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Add a waypoint
    switch (index) {
        case 0:
            [self newWaypoint];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)newWaypoint
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Add a related waypoint"
                               message:@"Lattitude is north and south\nLongitude is east and west\nUse 3679 for the directional"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *lat = tf.text;
                             NSLog(@"Lattitude '%@'", lat);

                             tf = [alert.textFields objectAtIndex:1];
                             NSString *lon = tf.text;
                             NSLog(@"Longitude '%@'", lon);

                             Coordinates *c;
                             c = [[Coordinates alloc] initString:lat lon:lon];

                             dbWaypoint *wp = [[dbWaypoint alloc] init:0];
                             wp.lat = [c lat_decimalDegreesSigned];
                             wp.lon = [c lon_decimalDegreesSigned];
                             wp.lat_int = [c lat] * 1000000;
                             wp.lon_int = [c lon] * 1000000;
                             wp.name = [dbWaypoint makeName:[waypoint.name substringFromIndex:2]];
                             wp.description = wp.name;
                             wp.date_placed_epoch = time(NULL);
                             wp.date_placed = [MyTools dateString:wp.date_placed_epoch];
                             wp.url = nil;
                             wp.urlname = wp.name;
                             wp.symbol_id = 1;
                             wp.type_id = [dbc Type_Unknown]._id;
                             [dbWaypoint dbCreate:wp];

                             [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
                             [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

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
        textField.placeholder = @"Lattitude (like S 12 34.567)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        [textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude (like E 23 45.678)";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        [textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editingChanged:(UITextField *)tf
{
    tf.text = [MyTools checkCoordinate:tf.text];
}

@end
