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

@interface SettingsMainViewController ()
{
    UISwitch *distanceMetric;
    UISwitch *themeGeosphere;
    UISwitch *soundDirection;
    UISwitch *soundDistance;
    UISwitch *mapClustersEnable;
    UISwitch *dynamicmapEnable;
    float mapClustersZoomlevel;

    NSArray *compassTypes;
    NSArray *externalMapTypes;

    NSMutableArray *speedsWalkingMetric;
    NSMutableArray *speedsCyclingMetric;
    NSMutableArray *speedsDrivingMetric;
    NSMutableArray *speedsWalking;
    NSMutableArray *speedsCycling;
    NSMutableArray *speedsDriving;

    NSMutableArray *distancesWalkingMetric;
    NSMutableArray *distancesCyclingMetric;
    NSMutableArray *distancesDrivingMetric;
    NSMutableArray *distancesWalking;
    NSMutableArray *distancesCycling;
    NSMutableArray *distancesDriving;
}

@end

#define THISCELL_SUBTITLE @"SettingsMainViewControllerCellSubtitle"
#define THISCELL_DEFAULT @"SettingsMainViewControllerCellDefault"

@implementation SettingsMainViewController

enum {
    menuResetToDefault,
    menuMax
};

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_DEFAULT];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL_SUBTITLE];

    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuResetToDefault label:@"Reset to default"];
    menuItems = [lmi makeMenu];

    compassTypes = @[@"Red arrow on blue", @"White arrow on black", @"Red arrow on black", @"Airplane"];
    externalMapTypes = @[@"Apple Maps", @"Google Maps"];

    [self calculateDynamicmapSpeedsDistances];
}

- (void)calculateDynamicmapSpeedsDistances
{
    speedsWalking = [NSMutableArray arrayWithCapacity:20];
    speedsCycling = [NSMutableArray arrayWithCapacity:20];
    speedsDriving = [NSMutableArray arrayWithCapacity:20];
    speedsWalkingMetric = [NSMutableArray arrayWithCapacity:20];
    speedsCyclingMetric = [NSMutableArray arrayWithCapacity:20];
    speedsDrivingMetric = [NSMutableArray arrayWithCapacity:20];

    distancesWalking = [NSMutableArray arrayWithCapacity:20];
    distancesCycling = [NSMutableArray arrayWithCapacity:20];
    distancesDriving = [NSMutableArray arrayWithCapacity:20];
    distancesWalkingMetric = [NSMutableArray arrayWithCapacity:20];
    distancesCyclingMetric = [NSMutableArray arrayWithCapacity:20];
    distancesDrivingMetric = [NSMutableArray arrayWithCapacity:20];

#define SPEED_WALKING_MIN   1
#define SPEED_WALKING_MAX   10
#define SPEED_WALKING_INC   1

#define SPEED_CYCLING_MIN   10
#define SPEED_CYCLING_MAX   50
#define SPEED_CYCLING_INC   5

#define SPEED_DRIVING_MIN   20
#define SPEED_DRIVING_MAX   180
#define SPEED_DRIVING_INC   10

#define DISTANCE_WALKING_MIN    50
#define DISTANCE_WALKING_MAX    500
#define DISTANCE_WALKING_INC    50

#define DISTANCE_CYCLING_MIN    100
#define DISTANCE_CYCLING_MAX    2000
#define DISTANCE_CYCLING_INC    100

#define DISTANCE_DRIVING_MIN    250
#define DISTANCE_DRIVING_MAX    5000
#define DISTANCE_DRIVING_INC    250

    for (NSInteger i = SPEED_WALKING_MIN; i <= SPEED_WALKING_MAX; i += SPEED_WALKING_INC) {
        [speedsWalking addObject:[MyTools NiceSpeed:i]];
        [speedsWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_CYCLING_MIN; i <= SPEED_CYCLING_MAX; i += SPEED_CYCLING_INC) {
        [speedsCycling addObject:[MyTools NiceSpeed:i]];
        [speedsCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_DRIVING_MIN; i <= SPEED_DRIVING_MAX; i += SPEED_DRIVING_INC) {
        [speedsDriving addObject:[MyTools NiceSpeed:i]];
        [speedsDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }

    for (NSInteger i = DISTANCE_WALKING_MIN; i <= DISTANCE_WALKING_MAX; i += DISTANCE_WALKING_INC) {
        [distancesWalking addObject:[MyTools NiceDistance:i]];
        [distancesWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_CYCLING_MIN; i <= DISTANCE_CYCLING_MAX; i += DISTANCE_CYCLING_INC) {
        [distancesCycling addObject:[MyTools NiceDistance:i]];
        [distancesCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_DRIVING_MIN; i <= DISTANCE_DRIVING_MAX; i += DISTANCE_DRIVING_INC) {
        [distancesDriving addObject:[MyTools NiceDistance:i]];
        [distancesDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }

}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 5;
}

enum sections {
    SECTION_DISTANCE = 0,
    SECTION_APPS,
    SECTION_THEME,
    SECTION_SOUNDS,
    SECTION_MAPS,
    SECTION_DYNAMICMAP,
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

    SECTION_APPS_EXTERNALMAP = 0,
    SECTION_APPS_MAX,

    SECTION_DYNAMICMAP_ENABLED = 0,
    SECTION_DYNAMICMAP_SPEED_WALKING,
    SECTION_DYNAMICMAP_SPEED_CYCLING,
    SECTION_DYNAMICMAP_SPEED_DRIVING,
    SECTION_DYNAMICMAP_DISTANCE_WALKING,
    SECTION_DYNAMICMAP_DISTANCE_CYCLING,
    SECTION_DYNAMICMAP_DISTANCE_DRIVING,
    SECTION_DYNAMICMAP_MAX,
};

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_DISTANCE: // Distance section
            return SECTION_DISTANCE_MAX;
        case SECTION_APPS:
            return SECTION_APPS_MAX;
        case SECTION_THEME: // Theme section
            return SECTION_THEME_MAX;
        case SECTION_SOUNDS: // Sounds section
            return SECTION_SOUNDS_MAX;
        case SECTION_MAPS: // Maps section
            return SECTION_MAPS_MAX;
        case SECTION_DYNAMICMAP: // Maps section
            return SECTION_DYNAMICMAP_MAX;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Metric section */
    switch (section) {
        case SECTION_DISTANCE:
            return @"Distances";
        case SECTION_APPS:
            return @"External apps";
        case SECTION_THEME:
            return @"Theme";
        case SECTION_SOUNDS:
            return @"Sounds";
        case SECTION_MAPS:
            return @"Maps";
        case SECTION_DYNAMICMAP:
            return @"Dynamic Maps";
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
        case SECTION_APPS: {
            switch (indexPath.row) {
                case SECTION_APPS_EXTERNALMAP: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];
                    cell.textLabel.text = @"External Maps";
                    cell.detailTextLabel.text = [externalMapTypes objectAtIndex:myConfig.mapExternal - 40];
                    return cell;
                }
            }
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

                    cell.textLabel.text = @"Maximum zoom level for clustering";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f", myConfig.mapClustersZoomLevel];

                    return cell;
                }
            }
            break;
        }

        case SECTION_DYNAMICMAP: {
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_ENABLED: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DEFAULT];

                    cell.textLabel.text = @"Enable dynamic maps";

                    dynamicmapEnable = [[UISwitch alloc] initWithFrame:CGRectZero];
                    dynamicmapEnable.on = myConfig.dynamicmapEnable;
                    [dynamicmapEnable addTarget:self action:@selector(updateDynamicmapEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = dynamicmapEnable;

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Maximum walking speed";
                    cell.detailTextLabel.text = [MyTools NiceSpeed:myConfig.dynamicmapWalkingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Maximum cycling speed";
                    cell.detailTextLabel.text = [MyTools NiceSpeed:myConfig.dynamicmapCyclingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Maximum driving speed";
                    cell.detailTextLabel.text = [MyTools NiceSpeed:myConfig.dynamicmapDrivingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Walking zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Always %@", [MyTools NiceDistance:myConfig.dynamicmapWalkingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Cycling zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools NiceDistance:myConfig.dynamicmapWalkingDistance], [MyTools NiceDistance:myConfig.dynamicmapCyclingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];
                    if (cell == nil)
                        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL_SUBTITLE];

                    cell.textLabel.text = @"Driving zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools NiceDistance:myConfig.dynamicmapCyclingDistance], [MyTools NiceDistance:myConfig.dynamicmapDrivingDistance]];

                    return cell;
                }
            }
            break;
        }

    }

    return nil;
}

- (void)updateDynamicmapEnable:(UISwitch *)s
{
    [myConfig dynamicmapEnableUpdate:s.on];
}

- (void)updateDistanceMetric:(UISwitch *)s
{
    [myConfig distanceMetricUpdate:s.on];
    [self calculateDynamicmapSpeedsDistances];
    [self.tableView reloadData];
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
    switch (indexPath.section) {
        case SECTION_THEME:
            switch (indexPath.row) {
                case SECTION_THEME_THEME:
                    [self updateThemeTheme];
                    break;
                case SECTION_THEME_COMPASS:
                    [self updateThemeCompass];
                    break;
            }
            return;
        case SECTION_APPS:
            switch (indexPath.row) {
                case SECTION_APPS_EXTERNALMAP:
                    [self updateAppsExternalMap];
                    break;
            }
            return;
        case SECTION_MAPS:
            switch (indexPath.row) {
                case SECTION_MAPS_ZOOMLEVEL:
                    [self updateMapZoomLevel];
                    break;
            }
            return;
        case SECTION_DYNAMICMAP:
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_SPEED_WALKING:
                case SECTION_DYNAMICMAP_SPEED_CYCLING:
                case SECTION_DYNAMICMAP_SPEED_DRIVING:
                    [self updateDynamicmapSpeed:indexPath.row];
                    break;
                case SECTION_DYNAMICMAP_DISTANCE_WALKING:
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
                    [self updateDynamicmapDistance:indexPath.row];
                    break;
            }
            return;
    }
}

- (void)updateDynamicmapSpeed:(NSInteger)row
{
    NSArray *speeds = nil;
    NSString *title = nil;
    NSString *currentSpeed = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_SPEED_WALKING:
            speeds = speedsWalking;
            currentSpeed = [MyTools NiceSpeed:myConfig.dynamicmapWalkingSpeed];
            title = @"Maximum walking speed";
            successAction = @selector(updateDynamicmapSpeedWalking:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_CYCLING:
            speeds = speedsCycling;
            currentSpeed = [MyTools NiceSpeed:myConfig.dynamicmapCyclingSpeed];
            title = @"Maximum cycling speed";
            successAction = @selector(updateDynamicmapSpeedCycling:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_DRIVING:
            speeds = speedsDriving;
            currentSpeed = [MyTools NiceSpeed:myConfig.dynamicmapDrivingSpeed];
            title = @"Maximum driving speed";
            successAction = @selector(updateDynamicmapSpeedDriving:element:);
            break;
    }

    __block NSInteger selectedSpeed = 0;
    [speeds enumerateObjectsUsingBlock:^(NSString *speed, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([currentSpeed isEqualToString:speed] == YES) {
            selectedSpeed = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:title
                                            rows:speeds
                                initialSelection:selectedSpeed
                                          target:self
                                   successAction:successAction
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateDynamicmapSpeedWalking:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapWalkingSpeedUpdate:[[speedsWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedCycling:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapCyclingSpeedUpdate:[[speedsCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedDriving:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapDrivingSpeedUpdate:[[speedsDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistance:(NSInteger)row
{
    NSArray *distances = nil;
    NSString *title = nil;
    NSString *currentDistance = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_DISTANCE_WALKING:
            distances = distancesWalking;
            currentDistance = [MyTools NiceDistance:myConfig.dynamicmapWalkingDistance];
            title = @"Maximum walking distance";
            successAction = @selector(updateDynamicmapDistanceWalking:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
            distances = distancesCycling;
            currentDistance = [MyTools NiceDistance:myConfig.dynamicmapCyclingDistance];
            title = @"Maximum cycling distance";
            successAction = @selector(updateDynamicmapDistanceCycling:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
            distances = distancesDriving;
            currentDistance = [MyTools NiceDistance:myConfig.dynamicmapDrivingDistance];
            title = @"Maximum driving distance";
            successAction = @selector(updateDynamicmapDistanceDriving:element:);
            break;
    }

    __block NSInteger selectedDistance = 0;
    [distances enumerateObjectsUsingBlock:^(NSString *distance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([currentDistance isEqualToString:distance] == YES) {
            selectedDistance = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:title
                                            rows:distances
                                initialSelection:selectedDistance
                                          target:self
                                   successAction:successAction
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateDynamicmapDistanceWalking:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapWalkingDistanceUpdate:[[distancesWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceCycling:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapCyclingDistanceUpdate:[[distancesCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceDriving:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig dynamicmapDrivingDistanceUpdate:[[distancesDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}


- (void)updateThemeTheme
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select theme"
                                            rows:[themeManager themeNames]
                                initialSelection:myConfig.themeType
                                          target:self
                                   successAction:@selector(updateThemeThemeSuccess:element:)
                                    cancelAction:@selector(updateCancel:)
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
                                    cancelAction:@selector(updateCancel:)
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
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateThemeCompassSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig compassTypeUpdate:i];
    [self.tableView reloadData];
}

- (void)updateMapZoomLevelSuccess:(NSNumber *)selectedIndex element:(id)element
{
    float f = [selectedIndex floatValue] / 2.0;
    [myConfig mapClustersUpdateZoomLevel:f];
    [self.tableView reloadData];
}

- (void)updateThemeThemeSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig themeTypeUpdate:i];
    [self.tableView reloadData];

    [themeManager setTheme:i];
    [self.tableView reloadData];
}

- (void)updateAppsExternalMap
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select External Maps"
                                            rows:externalMapTypes
                                initialSelection:myConfig.mapExternal - 40
                                          target:self
                                   successAction:@selector(updateAppsExternalMap:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateAppsExternalMap:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig mapExternalUpdate:i + 40];
    [self.tableView reloadData];
}

- (void)updateCancel:(id)sender
{
    // nothing
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case menuResetToDefault:
            [self resetValues];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)resetValues
{
}

@end
