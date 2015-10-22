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

    compassTypes = @[@"Red arrow on blue", @"White arrow on black", @"Red arrow on black", @"Airplane"];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 4;
}

enum sections {
    SECTION_DISTANCE = 0,
    SECTION_THEME,
    SECTION_SOUNDS,
    SECTION_MAPS,
    SECTION_MAX,

    SECTION_DISTANCE_METRIC = 0,
    SECTION_DISTANCE_MAX,

    SECTION_THEME_THEME = 0,
    SECTION_THEME_COMPASS,
    SECTION_THEME_MAX,

    SECTION_SOUNDS_DIRECTION = 0,
    SECTION_SOUNDS_DISTANCE,
    SECTION_SOUNDS_MAX,

    SECTION_MAPS_CLUSTERS = 0,
    SECTION_MAPS_ZOOMLEVEL,
    SECTION_MAPS_MAX,

};

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_DISTANCE: // Distance section
            return SECTION_DISTANCE_MAX;
        case SECTION_THEME: // Theme section
            return SECTION_THEME_MAX;
        case SECTION_SOUNDS: // Sounds section
            return SECTION_SOUNDS_MAX;
        case SECTION_MAPS: // Maps section
            return SECTION_MAPS_MAX;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Metric section */
    switch (section) {
        case SECTION_DISTANCE:
            return @"Distances";
        case SECTION_THEME:
            return @"Theme";
        case SECTION_SOUNDS:
            return @"Sounds";
        case SECTION_MAPS:
            return @"Maps";
    }

    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    switch (indexPath.section) {
        case SECTION_DISTANCE: {   // Distance
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
            if (cell == nil)
                cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];
            switch (indexPath.row) {
                case SECTION_DISTANCE_METRIC: {   // Metric
                    cell.textLabel.text = @"Use metric units";

                    distanceMetric = [[UISwitch alloc] initWithFrame:CGRectZero];
                    distanceMetric.on = myConfig.distanceMetric;
                    [distanceMetric addTarget:self action:@selector(updateDistanceMetric:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = distanceMetric;

                    return cell;
                }
            }
            break;
        }
        case SECTION_THEME: {   // Theme
            switch (indexPath.row) {
                case SECTION_THEME_THEME: {   // Theme
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];
                    cell.textLabel.text = @"Theme";
                    cell.detailTextLabel.text = [[themeManager themeNames] objectAtIndex:[myConfig themeType]];
                    return cell;
                }
                case SECTION_THEME_COMPASS: {   // Compass type
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
        case SECTION_SOUNDS: {   // Sounds
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
            if (cell == nil)
                cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];
            switch (indexPath.row) {
                case SECTION_SOUNDS_DIRECTION: {   // soundDirection
                    cell.textLabel.text = @"Enable sounds for direction";

                    soundDirection = [[UISwitch alloc] initWithFrame:CGRectZero];
                    soundDirection.on = myConfig.soundDirection;
                    [soundDirection addTarget:self action:@selector(updateSoundDirection:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = soundDirection;

                    return cell;
                }
                case SECTION_SOUNDS_DISTANCE: {   // soundDistance
                    cell.textLabel.text = @"Enable sounds for distance";

                    soundDistance = [[UISwitch alloc] initWithFrame:CGRectZero];
                    soundDistance.on = myConfig.soundDistance;
                    [soundDistance addTarget:self action:@selector(updateSoundDistance:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = soundDistance;

                    return cell;
                }
            }
            break;
        }
        case SECTION_MAPS: {   // Maps
            switch (indexPath.row) {
                case SECTION_MAPS_CLUSTERS: {   // Enable
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];

                    cell.textLabel.text = @"Enable clusters";

                    mapClustersEnable = [[UISwitch alloc] initWithFrame:CGRectZero];
                    mapClustersEnable.on = myConfig.mapClustersEnable;
                    [mapClustersEnable addTarget:self action:@selector(updateMapClustersEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = mapClustersEnable;

                    return cell;
                }
                case SECTION_MAPS_ZOOMLEVEL: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];
                    cell.textLabel.text = @"Maxmimum zoom level for clustering";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f", myConfig.mapClustersZoomLevel];

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

- (void)updateSoundDistance:(UISwitch *)s
{
    [myConfig soundDistanceUpdate:s.on];
}

- (void)updateSoundDirection:(UISwitch *)s
{
    [audioFeedback togglePlay:s.on];
    [myConfig soundDirectionUpdate:s.on];
}

- (void)updateMapClustersEnable:(UISwitch *)s
{
    [myConfig mapClustersUpdateEnable:s.on];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SECTION_THEME) {   // Theme
        if (indexPath.row == SECTION_THEME_THEME)
            [self updateThemeTheme];
        if (indexPath.row == SECTION_THEME_COMPASS)
            [self updateThemeCompass];
        return;
    }
    if (indexPath.section == SECTION_MAPS) {
        if (indexPath.row == SECTION_MAPS_ZOOMLEVEL)
            [self updateMapZoomLevel];
        return;
    }
}

- (void)updateThemeTheme
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select theme"
                                            rows:[themeManager themeNames]
                                initialSelection:myConfig.themeType
                                          target:self
                                   successAction:@selector(updateThemeThemeSuccess:element:)
                                    cancelAction:@selector(updateThemeThemeCancel:)
                                          origin:self.tableView
     ];
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

- (void)updateMapZoomLevel
{
    NSMutableArray *zoomLevels = [NSMutableArray arrayWithCapacity:2 * 19];
    for (float f = 0; f < 19.2; f += 0.5) {
        [zoomLevels addObject:[NSString stringWithFormat:@"%0.1f", f]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Zoom Level"
                                            rows:zoomLevels
                                initialSelection:[myConfig mapClustersZoomLevel] * 2
                                          target:self
                                   successAction:@selector(updateMapZoomLevelSuccess:element:)
                                    cancelAction:@selector(updateMapZoomLevelCancel:)
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

- (void)updateMapZoomLevelSuccess:(NSNumber *)selectedIndex element:(id)element
{
    float f = [selectedIndex floatValue] / 2.0;
    [myConfig mapClustersUpdateZoomLevel:f];
    [self.tableView reloadData];
}

- (void)updateMapZoomLevelCancel:(id)sender
{
    // nothing
}

- (void)updateThemeThemeSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig themeTypeUpdate:i];
    [self.tableView reloadData];

    [themeManager setTheme:i];
    [self.tableView reloadData];
}

- (void)updateThemeThemeCancel:(id)sender
{
    // nothing
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (index == 0) {
        [self resetValues];
        return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)resetValues
{
}

@end
