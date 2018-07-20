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

@end

@implementation WaypointEditViewController

enum {
    CELL_NAME,
    CELL_DIFFICULTY,
    CELL_TERRAIN,
    CELL_ISPHYSICAL,

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

- (void)updateIsPhysicalSwitch:(UISwitch *)s
{
    self.waypoint.isPhysical = s.on;
    [self.waypoint dbUpdate];
    [waypointManager needsRefreshUpdate:self.waypoint];
    [self.delegateWaypoint waypointEditRefreshTable];
}

@end
