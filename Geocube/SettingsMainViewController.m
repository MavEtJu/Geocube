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
    UISwitch *orientationPortrait, *orientationPortraitUpsideDown, *orientationLandscapeLeft, *orientationLandscapeRight;
    UISwitch *soundDirection;
    UISwitch *soundDistance;

    UISwitch *keeptrackAutoRotate;

    UISwitch *mapClustersEnable;
    UISwitch *dynamicmapEnable;
    float mapClustersZoomlevel;
    UISwitch *mapRotateToBearing;

    NSArray *compassTypes;
    NSArray *externalMapTypes;

    NSArray *orientationStrings;
    NSArray *orientationValues;

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

    UISwitch *mapcacheEnable;
    NSInteger mapcacheMaxAge;
    NSInteger mapcacheMaxSize;
    NSArray *mapcacheMaxAgeValues;
    NSArray *mapcacheMaxSizeValues;

    UISwitch *markasFoundDNFClearsTarget;

    UISwitch *downloadImagesWaypoints;
    UISwitch *downloadImagesLogs;
    UISwitch *downloadImagesMobile;
    UISwitch *downloadQueriesMobile;
    NSMutableArray *downloadSimpleTimeouts;
    NSMutableArray *downloadQueryTimeouts;
}

@end

#define THISCELL_SUBTITLE @"SettingsMainViewControllerCellSubtitle"
#define THISCELL_DEFAULT @"SettingsMainViewControllerCellDefault"
#define THISCELL_IMAGE @"SettingsMainViewControllerCellImage"

@implementation SettingsMainViewController

enum {
    menuResetToDefault,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_DEFAULT];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL_SUBTITLE];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_IMAGE];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuResetToDefault label:@"Reset to default"];

    compassTypes = @[@"Red arrow on blue", @"White arrow on black", @"Red arrow on black", @"Airplane"];

    [self calculateDynamicmapSpeedsDistances];
    [self calculateMapcache];

    orientationStrings = @[
                           @"Portrait",
                           @"Portrait UpsideDown",
                           @"LandscapeLeft Portrait LandscapeRight",
                           @"LandscapeLeft Portrait UpsideDown LandscapeRight",
                           @"LandscapeRight",
                           @"LandscapeLeft",
                           @"LandscapeLeft LandscapeRight",
                           ];
    orientationValues = @[
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeLeft],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        ];

    downloadSimpleTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 30; i < 600; i += 30) {
        [downloadSimpleTimeouts addObject:[NSString stringWithFormat:@"%ld seconds", (long)i]];
    }
    downloadQueryTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 60; i < 1200; i += 30) {
        [downloadQueryTimeouts addObject:[NSString stringWithFormat:@"%ld seconds", (long)i]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap *em, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:em.name];
    }];
    externalMapTypes = as;
    [self.tableView reloadData];
}

- (void)calculateMapcache
{
    NSMutableArray *as = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 7; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld day%@", (long)i, i == 1 ? @"" : @"s"]];
    }
    for (NSInteger i = 7; i < 9 * 7; i += 7) {
        [as addObject:[NSString stringWithFormat:@"%ld days (%ld week%@)", (long)i, (long)i / 7, (i / 7) == 1 ? @"" : @"s"]];
    }
    for (NSInteger i = 30; i < 13 * 30; i += 30) {
        [as addObject:[NSString stringWithFormat:@"%ld days (%ld month%@)", (long)i, (long)i / 30, (i / 30) == 1 ? @"" : @"s"]];
    }
    mapcacheMaxAgeValues = [NSArray arrayWithArray:as];

    as = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 40; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld Mb", (long)i * 25]];
    }
    mapcacheMaxSizeValues = [NSArray arrayWithArray:as];
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
        [speedsWalking addObject:[MyTools niceSpeed:i]];
        [speedsWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_CYCLING_MIN; i <= SPEED_CYCLING_MAX; i += SPEED_CYCLING_INC) {
        [speedsCycling addObject:[MyTools niceSpeed:i]];
        [speedsCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_DRIVING_MIN; i <= SPEED_DRIVING_MAX; i += SPEED_DRIVING_INC) {
        [speedsDriving addObject:[MyTools niceSpeed:i]];
        [speedsDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }

    for (NSInteger i = DISTANCE_WALKING_MIN; i <= DISTANCE_WALKING_MAX; i += DISTANCE_WALKING_INC) {
        [distancesWalking addObject:[MyTools niceDistance:i]];
        [distancesWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_CYCLING_MIN; i <= DISTANCE_CYCLING_MAX; i += DISTANCE_CYCLING_INC) {
        [distancesCycling addObject:[MyTools niceDistance:i]];
        [distancesCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_DRIVING_MIN; i <= DISTANCE_DRIVING_MAX; i += DISTANCE_DRIVING_INC) {
        [distancesDriving addObject:[MyTools niceDistance:i]];
        [distancesDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }

}

#pragma mark - TableViewController related functions

enum sections {
    SECTION_DISTANCE = 0,
    SECTION_APPS,
    SECTION_IMPORTS,
    SECTION_THEME,
    SECTION_SOUNDS,
    SECTION_MAPCOLOURS,
    SECTION_MAPSEARCHMAXIMUM,
    SECTION_MAPS,
    SECTION_MAPCACHE,
    SECTION_DYNAMICMAP,
    SECTION_KEEPTRACK,
    SECTION_MARKAS,
    SECTION_WAYPOINTS,
    SECTION_MAX,

    SECTION_DISTANCE_METRIC = 0,
    SECTION_DISTANCE_MAX,

    SECTION_THEME_THEME = 0,
    SECTION_THEME_COMPASS,
    SECTION_THEME_ORIENTATIONS,
    SECTION_THEME_MAX,

    SECTION_SOUNDS_DIRECTION = 0,
    SECTION_SOUNDS_DISTANCE,
    SECTION_SOUNDS_MAX,

    SECTION_MAPS_ROTATE_TO_BEARING = 0,
    SECTION_MAPS_MAX,

    SECTION_MAPCOLOURS_TRACK = 0,
    SECTION_MAPCOLOURS_DESTINATION,
    SECTION_MAPCOLOURS_MAX,

    SECTION_APPS_EXTERNALMAP = 0,
    SECTION_APPS_MAX,

    SECTION_MAPCACHE_ENABLED = 0,
    SECTION_MAPCACHE_MAXAGE,
    SECTION_MAPCACHE_MAXSIZE,
    SECTION_MAPCACHE_MAX,

    SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS = 0,
    SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA,
    SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI,
    SECTION_MAPSEARCHMAXIMUM_MAX,

    SECTION_DYNAMICMAP_ENABLED = 0,
    SECTION_DYNAMICMAP_SPEED_WALKING,
    SECTION_DYNAMICMAP_SPEED_CYCLING,
    SECTION_DYNAMICMAP_SPEED_DRIVING,
    SECTION_DYNAMICMAP_DISTANCE_WALKING,
    SECTION_DYNAMICMAP_DISTANCE_CYCLING,
    SECTION_DYNAMICMAP_DISTANCE_DRIVING,
    SECTION_DYNAMICMAP_MAX,

    SECTION_KEEPTRACK_AUTOROTATE = 0,
    SECTION_KEEPTRACK_TIMEDELTA_MIN,
    SECTION_KEEPTRACK_TIMEDELTA_MAX,
    SECTION_KEEPTRACK_DISTANCEDELTA_MIN,
    SECTION_KEEPTRACK_DISTANCEDELTA_MAX,
    SECTION_KEEPTRACK_MAX,

    SECTION_IMPORTS_TIMEOUT_SIMPLE = 0,
    SECTION_IMPORTS_TIMEOUT_QUERY,
    SECTION_IMPORTS_IMAGES_WAYPOINT,
    SECTION_IMPORTS_IMAGES_LOGS,
    SECTION_IMPORTS_LOG_IMAGES_MOBILE,
    SECTION_IMPORTS_QUERIES_MOBILE,
    SECTION_IMPORTS_MAX,

    SECTION_MARKAS_FOUNDDNFCLEARSTARGET = 0,
    SECTION_MARKAS_MAX,

    SECTION_WAYPOINTS_SORTBY = 0,
    SECTION_WAYPOINTS_MAX,
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return SECTION_MAX;
}

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
        case SECTION_MAPCOLOURS:
            return SECTION_MAPCOLOURS_MAX;
        case SECTION_KEEPTRACK:
            return SECTION_KEEPTRACK_MAX;
        case SECTION_MAPCACHE:
            return SECTION_MAPCACHE_MAX;
        case SECTION_IMPORTS:
            return SECTION_IMPORTS_MAX;
        case SECTION_MAPSEARCHMAXIMUM:
            return SECTION_MAPSEARCHMAXIMUM_MAX;
        case SECTION_MARKAS:
            return SECTION_MARKAS_MAX;
        case SECTION_WAYPOINTS:
            return SECTION_WAYPOINTS_MAX;
        default:
            NSAssert1(0, @"Unknown section %ld", (long)section);
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
        case SECTION_MAPCOLOURS:
            return @"Map colours";
        case SECTION_MAPS:
            return @"Maps";
        case SECTION_DYNAMICMAP:
            return @"Dynamic Maps";
        case SECTION_KEEPTRACK:
            return @"Keep track";
        case SECTION_MAPCACHE:
            return @"Map cache";
        case SECTION_IMPORTS:
            return @"Import options";
        case SECTION_MAPSEARCHMAXIMUM:
            return @"Map search maximums";
        case SECTION_MARKAS:
            return @"Mark as...";
        case SECTION_WAYPOINTS:
            return @"Waypoints";
    }

    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_DISTANCE: {   // Distance
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

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

                    cell.textLabel.text = @"External Maps";

                    __block NSString *name = nil;
                    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap *em, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (em.geocube_id == myConfig.mapExternal) {
                            name = em.name;
                            *stop = YES;
                        }
                    }];
                    cell.detailTextLabel.text = name;
                    return cell;
                }
            }
        }

        case SECTION_THEME: {   // Theme
            switch (indexPath.row) {
                case SECTION_THEME_THEME: {   // Theme
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Theme";
                    cell.detailTextLabel.text = [[themeManager themeNames] objectAtIndex:myConfig.themeType];
                    return cell;
                }
                case SECTION_THEME_COMPASS: {   // Compass type
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Compass type";
                    cell.detailTextLabel.text = [compassTypes objectAtIndex:myConfig.compassType];
                    return cell;
                }
                case SECTION_THEME_ORIENTATIONS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    NSMutableString *s = [NSMutableString stringWithString:@""];
                    if ((myConfig.orientationsAllowed & UIInterfaceOrientationMaskPortrait) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Portrait"];
                    }
                    if ((myConfig.orientationsAllowed & UIInterfaceOrientationMaskPortraitUpsideDown) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Upside Down"];
                    }
                    if ((myConfig.orientationsAllowed & UIInterfaceOrientationMaskLandscapeLeft) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Landscape Left"];
                    }
                    if ((myConfig.orientationsAllowed & UIInterfaceOrientationMaskLandscapeRight) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Landscape Right"];
                    }

                    cell.textLabel.text = @"Orientations allowed";
                    cell.detailTextLabel.text = s;
                    return cell;
                }

            }
            break;
        }

        case SECTION_SOUNDS: {   // Sounds
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

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

        case SECTION_MAPCOLOURS: {
            switch (indexPath.row) {
                case SECTION_MAPCOLOURS_DESTINATION: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_IMAGE forIndexPath:indexPath];

                    cell.textLabel.text = @"Destination line";
                    cell.imageView.image = [ImageLibrary circleWithColour:myConfig.mapDestinationColour];

                    return cell;
                }
                case SECTION_MAPCOLOURS_TRACK: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_IMAGE forIndexPath:indexPath];

                    cell.textLabel.text = @"Track line";
                    cell.imageView.image = [ImageLibrary circleWithColour:myConfig.mapTrackColour];

                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPS: {   // Maps
            switch (indexPath.row) {
                case SECTION_MAPS_ROTATE_TO_BEARING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

                    cell.textLabel.text = @"Rotate to bearing";

                    mapRotateToBearing = [[UISwitch alloc] initWithFrame:CGRectZero];
                    mapRotateToBearing.on = myConfig.mapClustersEnable;
                    [mapRotateToBearing addTarget:self action:@selector(updateMapRotateToBearing:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = mapRotateToBearing;

                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPSEARCHMAXIMUM: {
            switch (indexPath.row) {
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance in GroundSpeak geocaching.com search radius";
                    cell.detailTextLabel.text = [MyTools niceDistance:myConfig.mapSearchMaximumDistanceGS];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance in OKAPI search radius";
                    cell.detailTextLabel.text = [MyTools niceDistance:myConfig.mapSearchMaximumDistanceOKAPI];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Number of waypoints in Geocaching Australia search";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld waypoints", (long)myConfig.mapSearchMaximumNumberGCA];
                    return cell;
                }
            }
            break;
        }

        case SECTION_DYNAMICMAP: {
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_ENABLED: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

                    cell.textLabel.text = @"Enable dynamic maps";

                    dynamicmapEnable = [[UISwitch alloc] initWithFrame:CGRectZero];
                    dynamicmapEnable.on = myConfig.dynamicmapEnable;
                    [dynamicmapEnable addTarget:self action:@selector(updateDynamicmapEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = dynamicmapEnable;

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum walking speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:myConfig.dynamicmapWalkingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum cycling speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:myConfig.dynamicmapCyclingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum driving speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:myConfig.dynamicmapDrivingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Walking zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Always %@", [MyTools niceDistance:myConfig.dynamicmapWalkingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Cycling zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools niceDistance:myConfig.dynamicmapWalkingDistance], [MyTools niceDistance:myConfig.dynamicmapCyclingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Driving zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools niceDistance:myConfig.dynamicmapCyclingDistance], [MyTools niceDistance:myConfig.dynamicmapDrivingDistance]];

                    return cell;
                }
            }
            break;
        }

        case SECTION_KEEPTRACK: {

            switch (indexPath.row) {
                case SECTION_KEEPTRACK_AUTOROTATE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

                    cell.textLabel.text = @"Autorotate every day";

                    keeptrackAutoRotate = [[UISwitch alloc] initWithFrame:CGRectZero];
                    keeptrackAutoRotate.on = myConfig.keeptrackAutoRotate;
                    [keeptrackAutoRotate addTarget:self action:@selector(updateKeeptrackAutoRotate:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = keeptrackAutoRotate;

                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Time difference for a new track point";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f seconds", myConfig.keeptrackTimeDeltaMin];

                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Time difference for a new track";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f seconds", myConfig.keeptrackTimeDeltaMax];

                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance difference for a new track point";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:myConfig.keeptrackDistanceDeltaMin]];

                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance difference for a new track";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:myConfig.keeptrackDistanceDeltaMax]];

                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPCACHE: {
            switch (indexPath.row) {
                case SECTION_MAPCACHE_ENABLED: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];

                    cell.textLabel.text = @"Enable map cache";

                    mapcacheEnable = [[UISwitch alloc] initWithFrame:CGRectZero];
                    mapcacheEnable.on = myConfig.mapcacheEnable;
                    [mapcacheEnable addTarget:self action:@selector(updateMapcacheEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = mapcacheEnable;

                    return cell;
                }
                case SECTION_MAPCACHE_MAXAGE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum age for objects in cache";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days", (long)myConfig.mapcacheMaxAge];

                    return cell;
                }
                case SECTION_MAPCACHE_MAXSIZE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum size for the cache";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Mb", (long)myConfig.mapcacheMaxSize];

                    return cell;
                }
            }
            break;
        }

        case SECTION_IMPORTS: {
            switch (indexPath.row) {
                case SECTION_IMPORTS_TIMEOUT_SIMPLE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Timeout for simple HTTP requests";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld seconds", (long)myConfig.downloadTimeoutSimple];

                    return cell;
                }
                case SECTION_IMPORTS_TIMEOUT_QUERY: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Timeout for big HTTP requests";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld seconds", (long)myConfig.downloadTimeoutQuery];

                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_WAYPOINT: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download waypoint images";

                    downloadImagesWaypoints = [[UISwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesWaypoints.on = myConfig.downloadImagesWaypoints;
                    [downloadImagesWaypoints addTarget:self action:@selector(updateDownloadImagesWaypoints:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesWaypoints;

                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_LOGS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download log images";

                    downloadImagesLogs = [[UISwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesLogs.on = myConfig.downloadImagesLogs;
                    [downloadImagesLogs addTarget:self action:@selector(updateDownloadImagesLogs:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesLogs;

                    return cell;
                }
                case SECTION_IMPORTS_LOG_IMAGES_MOBILE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download logged images over mobile data";

                    downloadImagesMobile = [[UISwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesMobile.on = myConfig.downloadImagesMobile;
                    [downloadImagesMobile addTarget:self action:@selector(updateDownloadImagesMobile:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesMobile;

                    return cell;
                }
                case SECTION_IMPORTS_QUERIES_MOBILE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download batch queries over mobile data";

                    downloadQueriesMobile = [[UISwitch alloc] initWithFrame:CGRectZero];
                    downloadQueriesMobile.on = myConfig.downloadQueriesMobile;
                    [downloadQueriesMobile addTarget:self action:@selector(updateDownloadQueriesMobile:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadQueriesMobile;

                    return cell;
                }
            }
            break;
        }

        case SECTION_MARKAS: {
            switch (indexPath.row) {
                case SECTION_MARKAS_FOUNDDNFCLEARSTARGET: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Remove target when marking as found/DNF";

                    markasFoundDNFClearsTarget = [[UISwitch alloc] initWithFrame:CGRectZero];
                    markasFoundDNFClearsTarget.on = myConfig.markasFoundDNFClearsTarget;
                    [markasFoundDNFClearsTarget addTarget:self action:@selector(updatemarkasFoundDNFClearsTarget:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = markasFoundDNFClearsTarget;

                    return cell;
                }
            }
        }

        case SECTION_WAYPOINTS: {
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Sort waypoints default by...";
                    NSArray *order = [WaypointsOfflineListViewController sortByOrder];
                    cell.detailTextLabel.text = [order objectAtIndex:myConfig.waypointListSortBy];

                    return cell;
                }
            }
        }

    }

    return nil;
}

- (void)updatemarkasFoundDNFClearsTarget:(UISwitch *)s
{
    [myConfig markasFoundDNFClearsTargetUpdate:s.on];
}

- (void)updateDownloadImagesLogs:(UISwitch *)s
{
    [myConfig downloadImagesLogsUpdate:s.on];
}

- (void)updateDownloadImagesWaypoints:(UISwitch *)s
{
    [myConfig downloadImagesWaypointsUpdate:s.on];
}

- (void)updateDownloadImagesMobile:(UISwitch *)s
{
    [myConfig downloadImagesMobileUpdate:s.on];
}

- (void)updateDownloadQueriesMobile:(UISwitch *)s
{
    [myConfig downloadQueriesMobileUpdate:s.on];
}

- (void)updateMapcacheEnable:(UISwitch *)s
{
    [myConfig mapcacheEnableUpdate:s.on];
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
- (void)updateMapRotateToBearing:(UISwitch *)s
{
    [myConfig mapRotateToBearingUpdate:s.on];
}

- (void)updateKeeptrackAutoRotate:(UISwitch *)s
{
    [myConfig keeptrackAutoRotateUpdate:s.on];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SECTION_THEME:
            switch (indexPath.row) {
                case SECTION_THEME_THEME:
                    [self changeThemeTheme];
                    break;
                case SECTION_THEME_COMPASS:
                    [self changeThemeCompass];
                    break;
                case SECTION_THEME_ORIENTATIONS:
                    [self changeThemeOrientations];
                    break;
            }
            return;
        case SECTION_APPS:
            switch (indexPath.row) {
                case SECTION_APPS_EXTERNALMAP:
                    [self changeAppsExternalMap];
                    break;
            }
            return;
        case SECTION_MAPSEARCHMAXIMUM:
            switch (indexPath.row) {
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS:
                    [self changeMapSearchMaximumDistanceGS];
                    break;
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI:
                    [self changeMapSearchMaximumDistanceOKAPI];
                    break;
                case SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA:
                    [self changeMapSearchMaximumNumberGCA];
                    break;
            }
            return;
        case SECTION_MAPS:
            switch (indexPath.row) {
            }
            return;
        case SECTION_DYNAMICMAP:
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_SPEED_WALKING:
                case SECTION_DYNAMICMAP_SPEED_CYCLING:
                case SECTION_DYNAMICMAP_SPEED_DRIVING:
                    [self changeDynamicmapSpeed:indexPath.row];
                    break;
                case SECTION_DYNAMICMAP_DISTANCE_WALKING:
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
                    [self changeDynamicmapDistance:indexPath.row];
                    break;
            }
            return;
        case SECTION_MAPCOLOURS:
            switch (indexPath.row) {
                case SECTION_MAPCOLOURS_TRACK: {
                    UIViewController *newController = [[SettingsMainColorPickerViewController alloc] init:SettingsMainColorPickerTrack];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    break;
                }
                case SECTION_MAPCOLOURS_DESTINATION: {
                    UIViewController *newController = [[SettingsMainColorPickerViewController alloc] init:SettingsMainColorPickerDestination];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    break;
                }
            }
            return;

        case SECTION_MAPCACHE:
            switch (indexPath.row) {
                case SECTION_MAPCACHE_MAXAGE:
                    [self changeMapCacheMaxAge];
                    break;
                case SECTION_MAPCACHE_MAXSIZE:
                    [self changeMapCacheMaxSize];
                    break;
            }
            return;

        case SECTION_IMPORTS:
            switch (indexPath.row) {
                case SECTION_IMPORTS_TIMEOUT_SIMPLE:
                    [self changeImportsSimpleTimeout];
                    break;
                case SECTION_IMPORTS_TIMEOUT_QUERY:
                    [self changeImportsQueryTimeout];
                    break;
            }
            return;

        case SECTION_KEEPTRACK:
            switch (indexPath.row) {
                case SECTION_KEEPTRACK_TIMEDELTA_MIN:
                case SECTION_KEEPTRACK_TIMEDELTA_MAX:
                case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
                case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
                    [self keeptrackChange:indexPath.row];
                    break;
            }
            return;

        case SECTION_WAYPOINTS:
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY:
                    [self changeWaypointSortBy];
                    break;
            }
            return;
    }
}

/* ********************************************************************************* */

- (void)keeptrackChange:(NSInteger)type
{
    NSString *message;
    switch (type) {
        case SECTION_KEEPTRACK_TIMEDELTA_MIN:
            message = @"Change the time difference for a new track point.";
            break;
        case SECTION_KEEPTRACK_TIMEDELTA_MAX:
            message = @"Change the time difference for a new track.";
            break;
        case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
            message = @"Change the distance difference for a new track point.";
            break;
        case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
            message = @"Change the distance difference for a new track.";
            break;
    }
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update value"
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             switch (type) {
                                 case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                                     float f = [value floatValue];
                                     if (f > myConfig.keeptrackTimeDeltaMax) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be less than %0.1f.", myConfig.keeptrackTimeDeltaMax]];
                                         break;
                                     }
                                     [myConfig keeptrackTimeDeltaMinUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                                     float f = [value floatValue];
                                     if (f < myConfig.keeptrackTimeDeltaMin) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be more than %0.1f.", myConfig.keeptrackTimeDeltaMin]];
                                         break;
                                     }
                                     [myConfig keeptrackTimeDeltaMaxUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                                     NSInteger i = [value integerValue];
                                     if (i > myConfig.keeptrackDistanceDeltaMax) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be less than %ld.", (long)myConfig.keeptrackDistanceDeltaMin]];
                                         break;
                                     }
                                     [myConfig keeptrackDistanceDeltaMinUpdate:i];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                                     NSInteger i = [value integerValue];
                                     if (i < myConfig.keeptrackDistanceDeltaMin) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be more than %ld.", (long)myConfig.keeptrackDistanceDeltaMin]];
                                         break;
                                     }
                                     [myConfig keeptrackDistanceDeltaMaxUpdate:i];
                                     break;
                                 }
                            }

                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        switch (type) {
            case SECTION_KEEPTRACK_TIMEDELTA_MIN:
                textField.text = [NSString stringWithFormat:@"%0.1f", myConfig.keeptrackTimeDeltaMin];
                break;
            case SECTION_KEEPTRACK_TIMEDELTA_MAX:
                textField.text = [NSString stringWithFormat:@"%0.1f", myConfig.keeptrackTimeDeltaMax];
                break;
            case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
                textField.text = [NSString stringWithFormat:@"%ld", (long)myConfig.keeptrackDistanceDeltaMin];
                break;
            case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
                textField.text = [NSString stringWithFormat:@"%ld", (long)myConfig.keeptrackDistanceDeltaMax];
                break;
        }
        textField.placeholder = @"Enter value...";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeDynamicmapSpeed:(NSInteger)row
{
    NSArray *speeds = nil;
    NSString *title = nil;
    NSString *currentSpeed = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_SPEED_WALKING:
            speeds = speedsWalking;
            currentSpeed = [MyTools niceSpeed:myConfig.dynamicmapWalkingSpeed];
            title = @"Maximum walking speed";
            successAction = @selector(updateDynamicmapSpeedWalking:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_CYCLING:
            speeds = speedsCycling;
            currentSpeed = [MyTools niceSpeed:myConfig.dynamicmapCyclingSpeed];
            title = @"Maximum cycling speed";
            successAction = @selector(updateDynamicmapSpeedCycling:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_DRIVING:
            speeds = speedsDriving;
            currentSpeed = [MyTools niceSpeed:myConfig.dynamicmapDrivingSpeed];
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

- (void)changeDynamicmapDistance:(NSInteger)row
{
    NSArray *distances = nil;
    NSString *title = nil;
    NSString *currentDistance = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_DISTANCE_WALKING:
            distances = distancesWalking;
            currentDistance = [MyTools niceDistance:myConfig.dynamicmapWalkingDistance];
            title = @"Maximum walking distance";
            successAction = @selector(updateDynamicmapDistanceWalking:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
            distances = distancesCycling;
            currentDistance = [MyTools niceDistance:myConfig.dynamicmapCyclingDistance];
            title = @"Maximum cycling distance";
            successAction = @selector(updateDynamicmapDistanceCycling:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
            distances = distancesDriving;
            currentDistance = [MyTools niceDistance:myConfig.dynamicmapDrivingDistance];
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

/* ********************************************************************************* */

- (void)changeImportsQueryTimeout
{
    __block NSInteger currentChoice = 10;   // 600 seconds
    [downloadQueryTimeouts enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == myConfig.downloadTimeoutQuery) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Timeout value for big HTTP requests"
                                            rows:downloadQueryTimeouts
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateDownloadQueryTimeout:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateDownloadQueryTimeout:(NSNumber *)selectedIndex element:(NSString *)element
{
    [myConfig downloadTimeoutQueryUpdate:[[downloadQueryTimeouts objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeImportsSimpleTimeout
{
    __block NSInteger currentChoice = 4;   // 120 seconds
    [downloadSimpleTimeouts enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == myConfig.downloadTimeoutSimple) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Timeout value for simple HTTP requests"
                                            rows:downloadSimpleTimeouts
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateDownloadSimpleTimeout:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateDownloadSimpleTimeout:(NSNumber *)selectedIndex element:(NSString *)element
{
    [myConfig downloadTimeoutSimpleUpdate:[[downloadSimpleTimeouts objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)updateMapcacheMaxAge:(NSNumber *)selectedIndex element:(NSString *)element
{
    [myConfig mapcacheMaxAgeUpdate:[[mapcacheMaxAgeValues objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeMapCacheMaxAge
{
    __block NSInteger currentChoice = 14;   // 30 days
    [mapcacheMaxAgeValues enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == myConfig.mapcacheMaxAge) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Maximum age for objects in the map cache"
                                            rows:mapcacheMaxAgeValues
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateMapcacheMaxAge:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapcacheMaxSize:(NSNumber *)selectedIndex element:(NSString *)element
{
    [myConfig mapcacheMaxSizeUpdate:[[mapcacheMaxSizeValues objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeMapCacheMaxSize
{    __block NSInteger currentChoice = 10;   // 250 Mb
    [mapcacheMaxSizeValues enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == myConfig.mapcacheMaxSize) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Maximum size for the map cache"
                                            rows:mapcacheMaxSizeValues
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateMapcacheMaxSize:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

/* ********************************************************************************* */

- (void)changeThemeTheme
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

- (void)updateThemeThemeSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig themeTypeUpdate:i];
    [self.tableView reloadData];

    [themeManager setTheme:i];
    [self.tableView reloadData];
}

- (void)changeThemeCompass
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

- (void)updateThemeCompassSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [myConfig compassTypeUpdate:i];
    [self.tableView reloadData];
}

- (void)changeThemeOrientations
{
    __block NSInteger orientationIndex = 0;
    [orientationValues enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([n integerValue] == myConfig.orientationsAllowed) {
            orientationIndex = idx;
            *stop = YES;
        }
    }];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Orientations"
                                            rows:orientationStrings
                                initialSelection:orientationIndex
                                          target:self
                                   successAction:@selector(updateThemeOrientations:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateThemeOrientations:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = [[orientationValues objectAtIndex:[selectedIndex integerValue]] integerValue];
    [myConfig orientationsAllowedUpdate:d];
    [self.tableView reloadData];
}


/* ********************************************************************************* */

- (void)changeMapSearchMaximumDistanceGS
{
    NSMutableArray *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 250; d < 10000; d += 250) {
        [distances addObject:[MyTools niceDistance:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Maximum Distance"
                                            rows:distances
                                initialSelection:(myConfig.mapSearchMaximumDistanceGS / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceGS:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumDistanceGS:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [myConfig mapSearchMaximumDistanceGSUpdate:d];
    [self.tableView reloadData];
}

- (void)changeMapSearchMaximumDistanceOKAPI
{
    NSMutableArray *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 250; d < 10000; d += 250) {
        [distances addObject:[MyTools niceDistance:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Maximum Distance"
                                            rows:distances
                                initialSelection:(myConfig.mapSearchMaximumDistanceOKAPI / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceOKAPI:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumDistanceOKAPI:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [myConfig mapSearchMaximumDistanceOKAPIUpdate:d];
    [self.tableView reloadData];
}

- (void)changeMapSearchMaximumNumberGCA
{
    NSMutableArray *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 10; d < 200; d += 10) {
        [distances addObject:[NSNumber numberWithInteger:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:@"Select Maximum Waypoints"
                                            rows:distances
                                initialSelection:(myConfig.mapSearchMaximumNumberGCA / 10) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumNumberGCA:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumNumberGCA:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 10;
    [myConfig mapSearchMaximumNumberGCAUpdate:d];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeWaypointSortBy
{
    [ActionSheetStringPicker showPickerWithTitle:@"Sort waypoints by"
                                            rows:[WaypointsOfflineListViewController sortByOrder]
                                initialSelection:myConfig.waypointListSortBy
                                          target:self
                                   successAction:@selector(updateWaypointSortBy:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateWaypointSortBy:(NSNumber *)selectedIndex element:(id)element
{
    [myConfig waypointListSortByUpdate:selectedIndex.integerValue];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeAppsExternalMap
{
    NSArray *maps = [dbExternalMap dbAll];
    __block NSInteger initial = 0;
    [maps enumerateObjectsUsingBlock:^(dbExternalMap *map, NSUInteger idx, BOOL * _Nonnull stop) {
        if (map.geocube_id == myConfig.mapExternal) {
            initial = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Select External Maps"
                                            rows:externalMapTypes
                                initialSelection:initial
                                          target:self
                                   successAction:@selector(updateAppsExternalMap:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateAppsExternalMap:(NSNumber *)selectedIndex element:(id)element
{
    NSArray *maps = [dbExternalMap dbAll];
    dbExternalMap *map = [maps objectAtIndex:[selectedIndex integerValue]];
    [myConfig mapExternalUpdate:map.geocube_id];
    [self.tableView reloadData];
}

- (void)updateCancel:(id)sender
{
    // nothing
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuResetToDefault:
            [self resetValues];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)resetValues
{
}

@end
