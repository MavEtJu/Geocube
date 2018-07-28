/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@interface WaypointEditViewController ()

@property (nonatomic, retain) dbWaypoint *waypoint;

@property (nonatomic, retain) UIAlertAction *coordsOkButton;
@property (nonatomic, retain) UITextField *coordsField1;
@property (nonatomic, retain) UITextField *coordsField2;
@property (nonatomic        ) CoordinatesType coordType;

@end

@implementation WaypointEditViewController

enum {
    CELL_NAME,
    CELL_DIFFICULTY,
    CELL_TERRAIN,
    CELL_ISPHYSICAL,
    CELL_COORDINATES,

    CELL_MAX
};

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super init];

    self.waypoint = wp;

    return self;
}
- (void)viewDidLoad
{
    self.hasCloseButton = YES;
    [super viewDidLoad];

    self.coordType = configManager.coordinatesTypeEdit;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSWITCH bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSWITCH];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CELL_MAX;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case CELL_NAME: {
            GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

            cell.textLabel.text = _(@"waypointeditviewcontroller-Waypoint name");
            cell.detailTextLabel.text = self.waypoint.wpt_urlname;

            return cell;
        }

        case CELL_DIFFICULTY: {
            GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

            cell.textLabel.text = _(@"waypointeditviewcontroller-Difficulty rating");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f", self.waypoint.gs_rating_difficulty];

            return cell;
        }

        case CELL_TERRAIN: {
            GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

            cell.textLabel.text = _(@"waypointeditviewcontroller-Terrain rating");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f", self.waypoint.gs_rating_terrain];

            return cell;
        }

        case CELL_COORDINATES: {
            GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

            cell.textLabel.text = _(@"waypointeditviewcontroller-Coordinates");
            cell.detailTextLabel.text = [Coordinates niceCoordinates:self.waypoint.wpt_latitude longitude:self.waypoint.wpt_longitude];

            return cell;
        }

        case CELL_ISPHYSICAL: {
            GCTableViewCellSwitch *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH];

            cell.textLabel.text = _(@"waypointlogviewcontroller-Is a physical waypoint");
            cell.optionSwitch.on = self.waypoint.isPhysical;

            [cell.optionSwitch addTarget:self action:@selector(updateIsPhysicalSwitch:) forControlEvents:UIControlEventTouchUpInside];

            return cell;
        }
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {

        case CELL_NAME: {
            [self updateName];
            break;
        }

        case CELL_DIFFICULTY: {
            [self updateDifficulty];
            break;
        }

        case CELL_TERRAIN: {
            [self updateTerrain];
            break;
        }

        case CELL_COORDINATES: {
            [self updateCoordinates];
            break;
        }

    }
}

- (void)updateName
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointeditviewcontroller-Update name")
                                message:_(@"waypointeditviewcontroller-Please enter the name")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *OkButton = [UIAlertAction
                               actionWithTitle:_(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   //Do Some action
                                   UITextField *tf = [alert.textFields objectAtIndex:0];
                                   NSString *field1 = tf.text;
                                   NSLog(@"Field 1: '%@'", field1);

                                   self.waypoint.wpt_urlname = field1;
                                   [self.waypoint dbUpdate];
                                   [self.tableView reloadData];
                                   [waypointManager needsRefreshUpdate:self.waypoint];
                                   [self.delegateWaypoint waypointEditRefreshTable];
                               }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:OkButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = self.waypoint.wpt_urlname;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateDifficulty
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointeditviewcontroller-Update difficulty rating")
                                message:_(@"waypointeditviewcontroller-Please enter the difficulty rating")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *OkButton = [UIAlertAction
                               actionWithTitle:_(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   //Do Some action
                                   UITextField *tf = [alert.textFields objectAtIndex:0];
                                   NSString *field1 = tf.text;
                                   NSLog(@"Field 1: '%@'", field1);

                                   self.waypoint.gs_rating_difficulty = [field1 floatValue];
                                   [self.waypoint dbUpdate];
                                   [self.tableView reloadData];
                                   [waypointManager needsRefreshUpdate:self.waypoint];
                                   [self.delegateWaypoint waypointEditRefreshTable];
                               }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:OkButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%0.1f", self.waypoint.gs_rating_difficulty];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateTerrain
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointeditviewcontroller-Update terrain rating")
                                message:_(@"waypointeditviewcontroller-Please enter the terrain rating")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *OkButton = [UIAlertAction
                               actionWithTitle:_(@"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   //Do Some action
                                   UITextField *tf = [alert.textFields objectAtIndex:0];
                                   NSString *field1 = tf.text;
                                   NSLog(@"Field 1: '%@'", field1);

                                   self.waypoint.gs_rating_terrain = [field1 floatValue];
                                   [self.waypoint dbUpdate];
                                   [self.tableView reloadData];
                                   [waypointManager needsRefreshUpdate:self.waypoint];
                                   [self.delegateWaypoint waypointEditRefreshTable];
                               }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:OkButton];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%0.1f", self.waypoint.gs_rating_terrain];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)updateCoordinates
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointeditviewcontroller-Update coordinates")
                                message:[NSString stringWithFormat:_(@"waypointeditviewcontroller-Please enter the coordinates.__Expected format: %@"), [Coordinates coordinateExample:self.coordType]]
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
                               self.waypoint.wpt_latitude = c.latitude;
                               self.waypoint.wpt_longitude = c.longitude;

                               [self.waypoint dbUpdate];
                               [self.tableView reloadData];
                               [waypointManager needsRefreshUpdate:self.waypoint];
                               [self.delegateWaypoint waypointEditRefreshTable];
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
                                       [self updateCoordinates];
                                   }];

    [alert addAction:self.coordsOkButton];
    [alert addAction:changeFormat];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        if ([Coordinates numberOfFields:self.coordType] == 2) {
            textField.text = [Coordinates niceLatitudeForEditing:self.waypoint.wpt_latitude coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", _(@"Latitude"), _(@"waypointeditviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
        } else {
            textField.text = [Coordinates niceCoordinatesForEditing:CLLocationCoordinate2DMake(self.waypoint.wpt_latitude, self.waypoint.wpt_longitude) coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"(%@ %@)", _(@"waypointeditviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
        }
        KeyboardCoordinateView *kb = [KeyboardCoordinateView pickKeyboard:self.coordType];
        [kb.firstView showsLatitude:YES];
        textField.inputView = kb;
        [textField addTarget:self action:@selector(alertControllerTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        self.coordsField1 = textField;
    }];

    self.coordsField2 = nil;
    if ([Coordinates numberOfFields:self.coordType] == 2) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = [Coordinates niceLongitudeForEditing:self.waypoint.wpt_longitude coordType:self.coordType];
            textField.placeholder = [NSString stringWithFormat:@"%@ (%@ %@)", (@"Longitude"), _(@"waypointeditviewcontroller-like"), [Coordinates coordinateExample:self.coordType]];
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

- (void)updateIsPhysicalSwitch:(UISwitch *)s
{
    self.waypoint.isPhysical = s.on;
    [self.waypoint dbUpdate];
    [waypointManager needsRefreshUpdate:self.waypoint];
    [self.delegateWaypoint waypointEditRefreshTable];
}

@end
