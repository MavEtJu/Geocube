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

@interface WaypointAddViewController ()

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) dbAccount *account;
@property (nonatomic        ) CLLocationCoordinate2D coords;
@property (nonatomic, retain) UIAlertAction *coordsOkButton;
@property (nonatomic, retain) UITextField *coordsField1;
@property (nonatomic, retain) UITextField *coordsField2;
@property (nonatomic        ) CoordinatesType coordType;

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

    self.lmi = nil;

    self.code = [MyTools makeNewWaypoint:@"MY"];
    self.name = @"A new name";
    self.coords = [LM coords];
    self.coordType = configManager.coordinatesTypeEdit;

    self.hasCloseButton = YES;

    return self;
}

- (void)setCoordinates:(CLLocationCoordinate2D)coords
{
    self.coords = coords;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.account = dbc.accountPrivate;
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
            cell.detailTextLabel.text = self.code;
            break;
        case cellName:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Short Name");
            cell.detailTextLabel.text = self.name;
            break;
        case cellCoords:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Coords");
            cell.detailTextLabel.text = [Coordinates niceCoordinates:self.coords];
            break;
        case cellAccount:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Account");
            if (self.account == nil)
                cell.detailTextLabel.text = _(@"waypointaddviewcontroller-None chosen yet");
            else
                cell.detailTextLabel.text = self.account.site;
            break;
        case cellSubmit:
            cell.textLabel.text = _(@"waypointaddviewcontroller-Create this waypoint");
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (self.account == nil) {
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
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
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
         self.account = [accounts objectAtIndex:selectedIndex];
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
                             self.code = tf.text;

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
        textField.text = self.code;
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
                             self.name = tf.text;

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
        textField.text = self.name;
        textField.placeholder = _(@"waypointaddviewcontroller-Waypoint name");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateCoords
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointaddviewcontroller-Update waypoint")
                                message:[NSString stringWithFormat:_(@"waypointaddviewcontroller-Please enter the coordinates.__Expected format: %@"), [Coordinates coordinateExample:self.coordType]]
                                preferredStyle:UIAlertControllerStyleAlert];

    self.coordsOkButton = [UIAlertAction
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
                          self.coords = CLLocationCoordinate2DMake(c.latitude, c.longitude);

                          [self.tableView reloadData];
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
                                       [self updateCoords];
                                   }];

    [alert addAction:self.coordsOkButton];
    [alert addAction:changeFormat];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [Coordinates niceLatitudeForEditing:self.coords.latitude coordType:self.coordType];
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
            textField.text = [Coordinates niceLongitudeForEditing:self.coords.longitude coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", (@"Longitude"), _(@"waypointaddviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
            KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
            [kb.firstView showsLatitude:NO];
            textField.inputView = kb;
            [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            self.coordsField2 = textField;
        }];
    }

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)alertControllerTextFieldDidChange:(UITextField *)tf
{
    NSString *s;
    if (self.coordsField2 == nil)
        s = self.coordsField1.text;
    else
        s = [NSString stringWithFormat:@"%@ %@", self.coordsField1.text, self.coordsField2.text];
    if ([Coordinates checkCoordinate:s coordType:self.coordType] == YES)
        self.coordsOkButton.enabled = YES;
    else
        self.coordsOkButton.enabled = NO;
}

- (void)updateSubmit
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    Coordinates *c = [[Coordinates alloc] initWithCoordinates:self.coords];

    wp.wpt_latitude = [c latitude];
    wp.wpt_longitude = [c longitude];
    wp.wpt_name = self.code;
    wp.wpt_description = self.name;
    wp.wpt_date_placed_epoch = time(NULL);
    wp.wpt_url = nil;
    wp.wpt_urlname = [NSString stringWithFormat:@"%@ - %@", self.code, self.name];
    wp.wpt_symbol = dbc.symbolVirtualStage;
    wp.wpt_type = dbc.typeManuallyEntered;
    wp.account = self.account;
    [wp finish];
    [wp dbCreate];

    [dbc.groupAllWaypointsManuallyAdded addWaypointToGroup:wp];
    [dbc.groupAllWaypoints addWaypointToGroup:wp];
    [dbc.groupManualWaypoints addWaypointToGroup:wp];

    [waypointManager needsRefreshAdd:wp];
    [opencageManager addForProcessing:wp];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
