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
@property (nonatomic, retain) UIAlertAction *okButton;
@property (nonatomic, retain) UITextField *coordsField1;
@property (nonatomic, retain) UITextField *coordsField2;
@property (nonatomic        ) CoordinatesType coordType;


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
    self.coordType = configManager.coordinatesTypeEdit;
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
    NSString *s = [NSString stringWithFormat:_(@"waypointwaypointsviewcontroller-Waypoint coordinates:__%@__Current coordinates:__%@"), [Coordinates niceCoordinates:self.waypoint.wpt_latitude longitude:self.waypoint.wpt_longitude coordType:self.coordType], [Coordinates niceCoordinates:LM.coords coordType:self.coordType]];
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
                    NSString *field1 = tf.text;
                    NSLog(@"Field 1: '%@'", field1);

                    NSString *field2 = nil;
                    if (self.coordsField2 != nil) {
                        tf = [alert.textFields objectAtIndex:1];
                        field2 = tf.text;
                        NSLog(@"Field 2: '%@'", field2);
                    }

                    Coordinates *c;
                    if (self.coordsField2 == nil)
                        c = [Coordinates parseCoordinatesWithString:field1 coordType:self.coordType];
                    else
                        c = [Coordinates parseCoordinatesWithString:[NSString stringWithFormat:@"%@ %@", field1, field2] coordType:self.coordType];

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
    UIAlertAction *changeFormat = [UIAlertAction
                                   actionWithTitle:_(@"coordinates-Change Format") style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       self.coordType = (self.coordType + 1) % COORDINATES_MAX;
                                       [self newWaypoint];
                                   }];

    [alert addAction:self.okButton];
    [alert addAction:changeFormat];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates niceLatitudeForEditing:self.waypoint.wpt_latitude coordType:self.coordType];
        textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", _(@"Latitude"), _(@"waypointaddviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
        KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
        [kb.firstView showsLatitude:YES];
        textField.inputView = kb;
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.coordsField1 = textField;
    }];

    self.coordsField2 = nil;
    if (self.coordType != COORDINATES_UTM &&
        self.coordType != COORDINATES_MGRS &&
        self.coordType != COORDINATES_OPENLOCATIONCODE) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = [Coordinates niceLongitudeForEditing:self.waypoint.wpt_longitude coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", _(@"Longitude"), _(@"waypointaddviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
            KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
            [kb.firstView showsLatitude:NO];
            textField.inputView = kb;
            [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.coordsField2 = textField;
        }];
    }

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)sender
{
    NSString *s;
    if (self.coordsField2 == nil)
        s = self.coordsField1.text;
    else
        s = [NSString stringWithFormat:@"%@ %@", self.coordsField1.text, self.coordsField2.text];
    if ([Coordinates checkCoordinate:s coordType:self.coordType] == YES)
        self.okButton.enabled = YES;
    else
        self.okButton.enabled = NO;
}

@end
