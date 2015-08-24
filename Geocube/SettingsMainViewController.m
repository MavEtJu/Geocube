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

#define THISCELL_SUBTITLE @"SettingsMainViewControllerCellSubtitle"
#define THISCELL_DEFAULT @"SettingsMainViewControllerCellDefault"

@implementation SettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_DEFAULT];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL_SUBTITLE];
    menuItems = [NSMutableArray arrayWithArray:@[@"Reset to default"]];

    compassTypes = @[@"Default", @"White arrow on black"];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 3;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: // Distance section
            return 1;
        case 1: // Theme section
            return 2;
        case 2: // Groudspeak API
            return 3;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Metric section */
    switch (section) {
        case 0:
            return @"Distances";
        case 1:
            return @"Theme";
        case 2:
            return @"Groundspeak GeocachingLive";
    }

    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.section) {
        case 0: {   // Distance
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
            if (cell == nil)
                cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];
            switch (indexPath.row) {
                case 0: {   // Metric
                    cell.textLabel.text = @"Metric";

                    distanceMetric = [[UISwitch alloc] initWithFrame:CGRectZero];
                    distanceMetric.on = myConfig.distanceMetric;
                    [distanceMetric addTarget:self action:@selector(updateDistanceMetric:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = distanceMetric;

                    return cell;
                }
            }
            break;
        }
        case 1: {   // Theme
            switch (indexPath.row) {
                case 0: {   // Geosphere theme
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];
                    cell.textLabel.text = @"Geosphere";

                    themeGeosphere = [[UISwitch alloc] initWithFrame:CGRectZero];
                    themeGeosphere.on = myConfig.themeGeosphere;
                    [themeGeosphere addTarget:self action:@selector(updateThemeGeosphere:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = themeGeosphere;

                    return cell;
                }
                case 1: {   // Compass type
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];
                    cell.textLabel.text = @"Compass type";
                    cell.detailTextLabel.text = [compassTypes objectAtIndex:[myConfig compassType]];
                    return cell;
                }

            }
            break;
        }
        case 2: {   // Groundspeak API
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
            if (cell == nil)
                cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_SUBTITLE];
            switch (indexPath.row) {
                case 0: {   // API key 1
                    cell.textLabel.text = @"API key 1";
                    cell.detailTextLabel.text = myConfig.GeocachingLive_API1;
                    return cell;
                }
                case 1: {   // API key 1
                    cell.textLabel.text = @"API key 2";
                    cell.detailTextLabel.text = myConfig.GeocachingLive_API2;
                    return cell;
                }
                case 2: {   // Staging
                    cell.textLabel.text = @"Use staging server";
                    
                    geocachingLiveStaging = [[UISwitch alloc] initWithFrame:CGRectZero];
                    geocachingLiveStaging.on = myConfig.GeocachingLive_staging;
                    [geocachingLiveStaging addTarget:self action:@selector(updateGeocachingLiveStaging:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = geocachingLiveStaging;
                    return cell;
                }
            }
            break;
        }
    }

    return nil;
}

- (void)updateDistanceMetric:(UISwitch *)s
{
    [myConfig distanceMetricUpdate:s.on];
}

- (void)updateThemeGeosphere:(UISwitch *)s
{
    [myConfig themeGeosphereUpdate:s.on];
    if (s.on == YES) {
        currentTheme = [[ThemeGeosphere alloc] init];
    } else {
        currentTheme = [[ThemeNormal alloc] init];
    }
    [self.tableView setNeedsDisplay];

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Theme changed"
                               message:@"Please restart the app"
                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateGeocachingLiveStaging:(UISwitch *)s
{
    [myConfig geocachingLive_staging:s.on];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {   // Groundspeak geocaching.com
        if (indexPath.row == 0 || indexPath.row == 1)
            [self updateGeocachingLiveKey:indexPath.row];
        return;
    }

    if (indexPath.section == 1) {   // Theme
        if (indexPath.row == 1)
            [self updateThemeCompass];
        return;
    }
}

- (void)updateThemeCompass
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select Compass"
                                            rows:compassTypes
                                initialSelection:myConfig.compassType
                                          target:self
                                   successAction:@selector(updateThemeCompassSuccess:element:)
                                    cancelAction:@selector(updateThemeCompassCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateThemeCompassSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig compassTypeUpdate:i];
    [self.tableView reloadData];
}

- (void)updateThemeCompassCancel:(id)sender
{
    // nothing
}


- (void)updateGeocachingLiveKey:(NSInteger)row
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Groundspeak Geocaching Live key"
                               message:@"API key"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *key = tf.text;

                             if (row == 0)
                                 [myConfig geocachingLive_API1Update:key];
                             else
                                 [myConfig geocachingLive_API2Update:key];

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
        if (row == 0)
            textField.text = myConfig.GeocachingLive_API1;
        else
            textField.text = myConfig.GeocachingLive_API2;
        textField.placeholder = @"API Key";
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (index == 0) {
        [self resetValues];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)resetValues
{
}

@end
