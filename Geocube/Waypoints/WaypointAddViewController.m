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

@interface WaypointAddViewController ()
{
    NSString *code;
    NSString *name;
    dbAccount *account;
    CLLocationCoordinate2D coords;
    UIAlertAction *coordsOkButton;
    UITextField *coordsLatitude;
    UITextField *coordsLongitude;
}

@end

@implementation WaypointAddViewController

enum {
    cellCode = 0,
    cellName,
    cellCoords,
    cellAccount,
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

    self.hasCloseButton = YES;

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

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (account == nil) {
        // The user hasn't set an account. If there is only one account with a name, then
        // choose that.
        [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
            if (IS_EMPTY(a.accountname.name) == YES)
                return;
            if (account == nil) {
                account = a;
            } else {
                // There was another account, so reset account to nil and stop.
                account = nil;
                *stop = YES;
            }
        }];
    }
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
    return _(@"waypointaddviewcontroller-New waypoint data");
}

// Return a cell for the index path
- (GCTableViewCellWithSubtitle *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = YES;
    cell.textLabel.textColor = currentTheme.labelTextColor;
    switch (indexPath.row) {
        case cellCode:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Waypoint code");
            cell.detailTextLabel.text = code;
            break;
        case cellName:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Short Name");
            cell.detailTextLabel.text = name;
            break;
        case cellCoords:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Coords");
            cell.detailTextLabel.text = [Coordinates niceCoordinates:coords];
            break;
        case cellAccount:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Account");
            if (account == nil)
                cell.detailTextLabel.text = _(@"waypointaddviewcontroller-None chosen yet");
            else
                cell.detailTextLabel.text = account.site;
            break;
        case cellSubmit:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Create this waypoint");
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (account == nil) {
                cell.textLabel.textColor = currentTheme.labelTextColorDisabled;
                cell.userInteractionEnabled = NO;
            }
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
        case cellAccount:
            [self updateAccount:[aTableView cellForRowAtIndexPath:indexPath]];
            break;
        case cellSubmit:
            [self updateSubmit];
            break;
    }
}

- (void)updateAccount:(UITableViewCell *)tablecell
{
    NSMutableArray<dbAccount *> *accounts = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray<NSString *> *accountNames = [NSMutableArray arrayWithCapacity:10];
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        if (IS_EMPTY(a.accountname.name) == YES)
            return;
        [accountNames addObject:a.site];
        [accounts addObject:a];
    }];

    [ActionSheetStringPicker
     showPickerWithTitle:_(@"waypointaddviewcontroller-Select the account")
     rows:accountNames
     initialSelection:configManager.lastImportSource
     doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
         account = [accounts objectAtIndex:selectedIndex];
         [self.tableView reloadData];
     }
     cancelBlock:^(ActionSheetStringPicker *picker) {
         NSLog(@"Block Picker Canceled");
     }
     origin:tablecell
    ];
}

- (void)updateCode
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointaddviewcontroller-Update waypoint")
                                message:_(@"waypointaddviewcontroller-Update waypoint code")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             code = tf.text;

                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = code;
        textField.placeholder = _(@"waypointaddviewcontroller-Waypoint code");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateName
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointaddviewcontroller-Update waypoint")
                                message:_(@"waypointaddviewcontroller-Update waypoint name")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             name = tf.text;

                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = name;
        textField.placeholder = _(@"waypointaddviewcontroller-Waypoint name");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateCoords
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointaddviewcontroller-Update waypoint")
                                message:_(@"waypointaddviewcontroller-Please enter the coordinates")
                                preferredStyle:UIAlertControllerStyleAlert];

    coordsOkButton = [UIAlertAction
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
                          coords.latitude = c.latitude;
                          coords.longitude = c.longitude;

                          [self.tableView reloadData];
                      }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:coordsOkButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates niceLatitudeForEditing:coords.latitude];
        textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@ 12 34.567)", _(@"Latitude"), _(@"waypointaddviewcontroller-like"), (@"compass-S")];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:YES];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        coordsLatitude = textField;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates niceLongitudeForEditing:coords.longitude];
        textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@ 23 45.678)", _(@"Longitude"), _(@"waypointaddviewcontroller-like"), _(@"compass-E")];
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.inputView = [[KeyboardCoordinateView alloc] initWithIsLatitude:NO];
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        coordsLongitude = textField;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)tf
{
    if ([Coordinates checkCoordinate:coordsLatitude.text] == YES &&
        [Coordinates checkCoordinate:coordsLongitude.text] == YES)
        coordsOkButton.enabled = YES;
    else
        coordsOkButton.enabled = NO;
}

- (void)updateSubmit
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    Coordinates *c = [[Coordinates alloc] init:coords];

    wp.wpt_latitude = [c latitude];
    wp.wpt_longitude = [c longitude];
    wp.wpt_name = code;
    wp.wpt_description = name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_url = nil;
    wp.wpt_urlname = [NSString stringWithFormat:@"%@ - %@", code, name];
    wp.wpt_symbol = [dbc Symbol_VirtualStage];
    wp.wpt_type = [dbc Type_ManuallyEntered];
    wp.account = account;
    [wp finish];
    [wp dbCreate];

    [dbc.Group_AllWaypoints_ManuallyAdded addWaypointToGroup:wp];
    [dbc.Group_AllWaypoints addWaypointToGroup:wp];
    [dbc.Group_ManualWaypoints addWaypointToGroup:wp];

    [waypointManager needsRefreshAdd:wp];
    [opencageManager addForProcessing:wp];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
