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

@interface SettingsMainViewController ()
{
    GCSwitch *distanceMetric;
    GCSwitch *themeGeosphere;
    GCSwitch *orientationPortrait, *orientationPortraitUpsideDown, *orientationLandscapeLeft, *orientationLandscapeRight;
    GCSwitch *soundDirection;
    GCSwitch *soundDistance;

    GCSwitch *keeptrackAutoRotate;

    GCSwitch *mapClustersEnable;
    GCSwitch *dynamicmapEnable;
    float mapClustersZoomlevel;
    GCSwitch *mapRotateToBearing;

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

    GCSwitch *mapcacheEnable;
    NSInteger mapcacheMaxAge;
    NSInteger mapcacheMaxSize;
    NSArray *mapcacheMaxAgeValues;
    NSArray *mapcacheMaxSizeValues;

    GCSwitch *compassAlwaysInPortraitMode;
    GCSwitch *markasFoundDNFClearsTarget;
    GCSwitch *markasFoundMarksAllWaypoints;
    GCSwitch *loggingRemovesMarkedAsFoundDNF;
    GCSwitch *showCountryAsAbbrevation;
    GCSwitch *showStateAsAbbrevation;
    GCSwitch *showStateAsAbbrevationIfLocaleExists;
    GCSwitch *refreshWaypointAfterLog;

    GCSwitch *downloadImagesWaypoints;
    GCSwitch *downloadImagesLogs;
    GCSwitch *downloadImagesMobile;
    GCSwitch *downloadQueriesMobile;
    NSMutableArray *downloadSimpleTimeouts;
    NSMutableArray *downloadQueryTimeouts;

    GCSwitch *AccountKeepUsername;
    GCSwitch *AccountKeepPassword;
    GCSwitch *GPSAdjustmentEnable;
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
    SECTION_COMPASS,
    SECTION_MAPCOLOURS,
    SECTION_MAPSEARCHMAXIMUM,
    SECTION_MAPS,
    SECTION_MAPCACHE,
    SECTION_DYNAMICMAP,
    SECTION_KEEPTRACK,
    SECTION_MARKAS,
    SECTION_WAYPOINTS,
    SECTION_ACCOUNTS,
    SECTION_GPSADJUSTMENT,
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

    SECTION_COMPASS_ALWAYSPORTRAIT = 0,
    SECTION_COMPASS_MAX,

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
    SECTION_KEEPTRACK_PURGEAGE,
    SECTION_KEEPTRACK_SYNC,
    SECTION_KEEPTRACK_MAX,

    SECTION_IMPORTS_TIMEOUT_SIMPLE = 0,
    SECTION_IMPORTS_TIMEOUT_QUERY,
    SECTION_IMPORTS_IMAGES_WAYPOINT,
    SECTION_IMPORTS_IMAGES_LOGS,
    SECTION_IMPORTS_LOG_IMAGES_MOBILE,
    SECTION_IMPORTS_QUERIES_MOBILE,
    SECTION_IMPORTS_MAX,

    SECTION_MARKAS_FOUNDDNFCLEARSTARGET = 0,
    SECTION_MARKAS_FOUNDMARKSALLWAYPOINTS,
    SECTION_LOG_REMOVEMARKASFOUNDDNF,
    SECTION_MARKAS_MAX,

    SECTION_WAYPOINTS_SORTBY = 0,
    SECTION_WAYPOINTS_SHOWCOUNTRYASABBREVATION,
    SECTION_WAYPOINTS_SHOWSTATEASABBREVATION,
    SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALE,
    SECTION_WAYPOINTS_REFRESHAFTERLOG,
    SECTION_WAYPOINTS_MAX,

    SECTION_ACCOUNTS_AUTHENTICATEKEEPUSERNAME = 0,
    SECTION_ACCOUNTS_AUTHENTICATEKEEPPASSWORD,
    SECTION_ACCOUNTS_MAX,

    SECTION_GPSADJUSTMENT_ENABLE = 0,
    SECTION_GPSADJUSTMENT_LATITUDE,
    SECTION_GPSADJUSTMENT_LONGITUDE,
    SECTION_GPSADJUSTMENT_MAX,
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return SECTION_MAX;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
#define SECTION_MAX(__d__) \
    case SECTION_##__d__: \
        return SECTION_##__d__##_MAX;
        SECTION_MAX(DISTANCE);
        SECTION_MAX(APPS);
        SECTION_MAX(THEME);
        SECTION_MAX(SOUNDS);
        SECTION_MAX(COMPASS);
        SECTION_MAX(MAPS);
        SECTION_MAX(DYNAMICMAP);
        SECTION_MAX(MAPCOLOURS);
        SECTION_MAX(KEEPTRACK);
        SECTION_MAX(MAPCACHE);
        SECTION_MAX(IMPORTS);
        SECTION_MAX(MAPSEARCHMAXIMUM);
        SECTION_MAX(MARKAS);
        SECTION_MAX(WAYPOINTS);
        SECTION_MAX(ACCOUNTS);
        SECTION_MAX(GPSADJUSTMENT);
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
        case SECTION_COMPASS:
            return @"Compass";
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
        case SECTION_ACCOUNTS:
            return @"Accounts";
        case SECTION_GPSADJUSTMENT:
            return @"GPS Adjustments";
        default:
            NSAssert1(0, @"Unknown section %ld", (long)section);
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

                    distanceMetric = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    distanceMetric.on = configManager.distanceMetric;
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
                        if (em.geocube_id == configManager.mapExternal) {
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
                    cell.detailTextLabel.text = [[themeManager themeNames] objectAtIndex:configManager.themeType];
                    return cell;
                }
                case SECTION_THEME_COMPASS: {   // Compass type
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Compass type";
                    cell.detailTextLabel.text = [compassTypes objectAtIndex:configManager.compassType];
                    return cell;
                }
                case SECTION_THEME_ORIENTATIONS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    NSMutableString *s = [NSMutableString stringWithString:@""];
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskPortrait) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Portrait"];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskPortraitUpsideDown) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Upside Down"];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskLandscapeLeft) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:@"Landscape Left"];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskLandscapeRight) != 0) {
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

                    soundDirection = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    soundDirection.on = configManager.soundDirection;
                    [soundDirection addTarget:self action:@selector(updateSoundDirection:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = soundDirection;

                    return cell;
                }
                case SECTION_SOUNDS_DISTANCE: {   // soundDistance
                    cell.textLabel.text = @"Enable sounds for distance";

                    soundDistance = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    soundDistance.on = configManager.soundDistance;
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
                    cell.imageView.image = [ImageLibrary circleWithColour:configManager.mapDestinationColour];

                    return cell;
                }
                case SECTION_MAPCOLOURS_TRACK: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_IMAGE forIndexPath:indexPath];

                    cell.textLabel.text = @"Track line";
                    cell.imageView.image = [ImageLibrary circleWithColour:configManager.mapTrackColour];

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

                    mapRotateToBearing = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    mapRotateToBearing.on = configManager.mapRotateToBearing;
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
                    cell.detailTextLabel.text = [MyTools niceDistance:configManager.mapSearchMaximumDistanceGS];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance in OKAPI search radius";
                    cell.detailTextLabel.text = [MyTools niceDistance:configManager.mapSearchMaximumDistanceOKAPI];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Number of waypoints in Geocaching Australia search";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld waypoints", (long)configManager.mapSearchMaximumNumberGCA];
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

                    dynamicmapEnable = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    dynamicmapEnable.on = configManager.dynamicmapEnable;
                    [dynamicmapEnable addTarget:self action:@selector(updateDynamicmapEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = dynamicmapEnable;

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum walking speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum cycling speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum driving speed";
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapDrivingSpeed];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_WALKING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Walking zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Always %@", [MyTools niceDistance:configManager.dynamicmapWalkingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Cycling zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools niceDistance:configManager.dynamicmapWalkingDistance], [MyTools niceDistance:configManager.dynamicmapCyclingDistance]];

                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Driving zoom-out distance";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Between %@ and %@", [MyTools niceDistance:configManager.dynamicmapCyclingDistance], [MyTools niceDistance:configManager.dynamicmapDrivingDistance]];

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

                    keeptrackAutoRotate = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    keeptrackAutoRotate.on = configManager.keeptrackAutoRotate;
                    [keeptrackAutoRotate addTarget:self action:@selector(updateKeeptrackAutoRotate:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = keeptrackAutoRotate;

                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Time difference for a new track point";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f seconds", configManager.keeptrackTimeDeltaMin];

                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Time difference for a new track";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f seconds", configManager.keeptrackTimeDeltaMax];

                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance difference for a new track point";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:configManager.keeptrackDistanceDeltaMin]];

                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Distance difference for a new track";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:configManager.keeptrackDistanceDeltaMax]];

                    return cell;
                }
                case SECTION_KEEPTRACK_PURGEAGE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Autopurge age for old tracks";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days", (long)configManager.keeptrackPurgeAge];

                    return cell;
                }
                case SECTION_KEEPTRACK_SYNC: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Sync track data";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Every %ld seconds", (long)configManager.keeptrackSync];

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

                    mapcacheEnable = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    mapcacheEnable.on = configManager.mapcacheEnable;
                    [mapcacheEnable addTarget:self action:@selector(updateMapcacheEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = mapcacheEnable;

                    return cell;
                }
                case SECTION_MAPCACHE_MAXAGE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum age for objects in cache";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld days", (long)configManager.mapcacheMaxAge];

                    return cell;
                }
                case SECTION_MAPCACHE_MAXSIZE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Maximum size for the cache";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Mb", (long)configManager.mapcacheMaxSize];

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
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld seconds", (long)configManager.downloadTimeoutSimple];

                    return cell;
                }
                case SECTION_IMPORTS_TIMEOUT_QUERY: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Timeout for big HTTP requests";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld seconds", (long)configManager.downloadTimeoutQuery];

                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_WAYPOINT: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download waypoint images";

                    downloadImagesWaypoints = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesWaypoints.on = configManager.downloadImagesWaypoints;
                    [downloadImagesWaypoints addTarget:self action:@selector(updateDownloadImagesWaypoints:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesWaypoints;

                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_LOGS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download log images";

                    downloadImagesLogs = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesLogs.on = configManager.downloadImagesLogs;
                    [downloadImagesLogs addTarget:self action:@selector(updateDownloadImagesLogs:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesLogs;

                    return cell;
                }
                case SECTION_IMPORTS_LOG_IMAGES_MOBILE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download logged images over mobile data";

                    downloadImagesMobile = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    downloadImagesMobile.on = configManager.downloadImagesMobile;
                    [downloadImagesMobile addTarget:self action:@selector(updateDownloadImagesMobile:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = downloadImagesMobile;

                    return cell;
                }
                case SECTION_IMPORTS_QUERIES_MOBILE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Download batch queries over mobile data";

                    downloadQueriesMobile = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    downloadQueriesMobile.on = configManager.downloadQueriesMobile;
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

                    markasFoundDNFClearsTarget = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    markasFoundDNFClearsTarget.on = configManager.markasFoundDNFClearsTarget;
                    [markasFoundDNFClearsTarget addTarget:self action:@selector(updateMarkasFoundDNFClearsTarget:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = markasFoundDNFClearsTarget;

                    return cell;
                }
                case SECTION_MARKAS_FOUNDMARKSALLWAYPOINTS: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Mark all related waypoints when marked as found";

                    markasFoundMarksAllWaypoints = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    markasFoundMarksAllWaypoints.on = configManager.markasFoundMarksAllWaypoints;
                    [markasFoundMarksAllWaypoints addTarget:self action:@selector(updateMarkasFoundMarksAllWaypoints:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = markasFoundMarksAllWaypoints;

                    return cell;
                }
                case SECTION_LOG_REMOVEMARKASFOUNDDNF: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Remove Marked as Found/DNF when logging";

                    loggingRemovesMarkedAsFoundDNF = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    loggingRemovesMarkedAsFoundDNF.on = configManager.loggingRemovesMarkedAsFoundDNF;
                    [loggingRemovesMarkedAsFoundDNF addTarget:self action:@selector(updateLoggingRemovesMarkedAsFoundDNF:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = loggingRemovesMarkedAsFoundDNF;

                    return cell;
                }
            }
            break;
        }

        case SECTION_COMPASS: {
            switch (indexPath.row) {
                case SECTION_COMPASS_ALWAYSPORTRAIT: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Compass is always in portrait mode";

                    compassAlwaysInPortraitMode = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    compassAlwaysInPortraitMode.on = configManager.compassAlwaysInPortraitMode;
                    [compassAlwaysInPortraitMode addTarget:self action:@selector(updateCompassAlwaysInPortraitMode:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = compassAlwaysInPortraitMode;

                    return cell;
                }
            }
            break;
        }

        case SECTION_WAYPOINTS: {
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"Sort waypoints default by...";
                    NSArray *order = [WaypointsOfflineListViewController sortByOrder];
                    cell.detailTextLabel.text = [order objectAtIndex:configManager.waypointListSortBy];

                    return cell;
                }

                case SECTION_WAYPOINTS_REFRESHAFTERLOG: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Refresh after log";

                    refreshWaypointAfterLog = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    refreshWaypointAfterLog.on = configManager.refreshWaypointAfterLog;
                    [refreshWaypointAfterLog addTarget:self action:@selector(updateRefreshWaypointAfterLog:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = refreshWaypointAfterLog;

                    return cell;
                }

                case SECTION_WAYPOINTS_SHOWCOUNTRYASABBREVATION: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Show country as abbrevation";

                    showCountryAsAbbrevation = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    showCountryAsAbbrevation.on = configManager.showCountryAsAbbrevation;
                    [showCountryAsAbbrevation addTarget:self action:@selector(updateShowCountryAsAbbrevation:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = showCountryAsAbbrevation;

                    return cell;
                }

                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATION: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Show state as abbrevation";

                    showStateAsAbbrevation = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    showStateAsAbbrevation.on = configManager.showStateAsAbbrevation;
                    [showStateAsAbbrevation addTarget:self action:@selector(updateShowStateAsAbbrevation:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = showStateAsAbbrevation;

                    return cell;
                }

                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Show state as abbrevation if locale exist";

                    showStateAsAbbrevationIfLocaleExists = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    showStateAsAbbrevationIfLocaleExists.on = configManager.showStateAsAbbrevationIfLocaleExists;
                    [showStateAsAbbrevationIfLocaleExists addTarget:self action:@selector(updateShowStateAsAbbrevationWithLocale:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = showStateAsAbbrevationIfLocaleExists;

                    return cell;
                }
            }
            break;
        }

        case SECTION_ACCOUNTS: {
            switch (indexPath.row) {
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPUSERNAME: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Save authenticate username";

                    AccountKeepUsername = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    AccountKeepUsername.on = configManager.accountsSaveAuthenticationPassword;
                    [AccountKeepUsername addTarget:self action:@selector(updateAccountKeepUsername:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = AccountKeepUsername;

                    return cell;
                }
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPPASSWORD: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"Save authenticate password";

                    AccountKeepPassword = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    AccountKeepPassword.on = configManager.accountsSaveAuthenticationPassword;
                    [AccountKeepPassword addTarget:self action:@selector(updateAccountKeepPassword:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = AccountKeepPassword;

                    return cell;
                }
            }
        }

        case SECTION_GPSADJUSTMENT: {
            switch (indexPath.row) {
                case SECTION_GPSADJUSTMENT_ENABLE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_DEFAULT forIndexPath:indexPath];
                    cell.textLabel.text = @"GPS Adjustment enable";

                    GPSAdjustmentEnable = [[GCSwitch alloc] initWithFrame:CGRectZero];
                    GPSAdjustmentEnable.on = configManager.gpsAdjustmentEnable;
                    [GPSAdjustmentEnable addTarget:self action:@selector(updateGPSAdjustmentEnable:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = GPSAdjustmentEnable;

                    return cell;
                }
                case SECTION_GPSADJUSTMENT_LATITUDE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"GPS Adjustment for latitude";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld mm", (long)configManager.gpsAdjustmentLatitude];

                    return cell;
                }
                case SECTION_GPSADJUSTMENT_LONGITUDE: {
                    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL_SUBTITLE forIndexPath:indexPath];

                    cell.textLabel.text = @"GPS Adjustment for longitude";
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld mm", (long)configManager.gpsAdjustmentLongitude];

                    return cell;
                }
            }
            break;
        }

    }

    return nil;
}

- (void)updateGPSAdjustmentEnable:(GCSwitch *)s
{
    [configManager gpsAdjustmentEnableUpdate:s.on];
}

- (void)updateAccountKeepUsername:(GCSwitch *)s
{
    [configManager accountsSaveAuthenticationNameUpdate:s.on];
}
- (void)updateAccountKeepPassword:(GCSwitch *)s
{
    [configManager accountsSaveAuthenticationPasswordUpdate:s.on];
}

- (void)updateMarkasFoundDNFClearsTarget:(GCSwitch *)s
{
    [configManager markasFoundDNFClearsTargetUpdate:s.on];
}

- (void)updateMarkasFoundMarksAllWaypoints:(GCSwitch *)s
{
    [configManager markasFoundMarksAllWaypointsUpdate:s.on];
}

- (void)updateLoggingRemovesMarkedAsFoundDNF:(GCSwitch *)s
{
    [configManager loggingRemovesMarkedAsFoundDNFUpdate:s.on];
}

- (void)updateCompassAlwaysInPortraitMode:(GCSwitch *)s
{
    [configManager compassAlwaysInPortraitModeUpdate:s.on];
}

- (void)updateDownloadImagesLogs:(GCSwitch *)s
{
    [configManager downloadImagesLogsUpdate:s.on];
}

- (void)updateDownloadImagesWaypoints:(GCSwitch *)s
{
    [configManager downloadImagesWaypointsUpdate:s.on];
}

- (void)updateDownloadImagesMobile:(GCSwitch *)s
{
    [configManager downloadImagesMobileUpdate:s.on];
}

- (void)updateDownloadQueriesMobile:(GCSwitch *)s
{
    [configManager downloadQueriesMobileUpdate:s.on];
}

- (void)updateMapcacheEnable:(GCSwitch *)s
{
    [configManager mapcacheEnableUpdate:s.on];
}

- (void)updateDynamicmapEnable:(GCSwitch *)s
{
    [configManager dynamicmapEnableUpdate:s.on];
}

- (void)updateDistanceMetric:(GCSwitch *)s
{
    [configManager distanceMetricUpdate:s.on];
    [self calculateDynamicmapSpeedsDistances];
    [self.tableView reloadData];
}

- (void)updateSoundDistance:(GCSwitch *)s
{
    [configManager soundDistanceUpdate:s.on];
}

- (void)updateSoundDirection:(GCSwitch *)s
{
    [audioFeedback togglePlay:s.on];
    [configManager soundDirectionUpdate:s.on];
}

- (void)updateMapClustersEnable:(GCSwitch *)s
{
    [configManager mapClustersUpdateEnable:s.on];
}
- (void)updateMapRotateToBearing:(GCSwitch *)s
{
    [configManager mapRotateToBearingUpdate:s.on];
}

- (void)updateKeeptrackAutoRotate:(GCSwitch *)s
{
    [configManager keeptrackAutoRotateUpdate:s.on];
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
                case SECTION_KEEPTRACK_PURGEAGE:
                case SECTION_KEEPTRACK_SYNC:
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

        case SECTION_GPSADJUSTMENT:
            switch (indexPath.row) {
                case SECTION_GPSADJUSTMENT_LATITUDE:
                    [self changeGPSAdjustmentLatLon:YES];
                    break;

                case SECTION_GPSADJUSTMENT_LONGITUDE:
                    [self changeGPSAdjustmentLatLon:NO];
                    break;
            }
            return;
    }
}

/* ********************************************************************************* */

- (void)changeGPSAdjustmentLatLon:(BOOL)isLatitude
{
    NSString *message;

    if (isLatitude == YES)
        message = @"Adjust latitude by";
    else
        message = @"Adjust longitude by";
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:message
                               message:@"Please enter the adjustment in millimeters"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             if (isLatitude == YES)
                                 [configManager gpsAdjustmentLatitudeUpdate:[value integerValue]];
                             else
                                 [configManager gpsAdjustmentLongitudeUpdate:[value integerValue]];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)(isLatitude == YES ? configManager.gpsAdjustmentLatitude : configManager.gpsAdjustmentLongitude)];
        textField.placeholder = @"Distance in mm";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
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
        case SECTION_KEEPTRACK_PURGEAGE:
            message = @"Change the maximum age of old tracks before they get purged.";
            break;
        case SECTION_KEEPTRACK_SYNC:
            message = @"Change the time interval to sync the track data";
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
                                     if (f > configManager.keeptrackTimeDeltaMax) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be less than %0.1f.", configManager.keeptrackTimeDeltaMax]];
                                         break;
                                     }
                                     [configManager keeptrackTimeDeltaMinUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                                     float f = [value floatValue];
                                     if (f < configManager.keeptrackTimeDeltaMin) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be more than %0.1f.", configManager.keeptrackTimeDeltaMin]];
                                         break;
                                     }
                                     [configManager keeptrackTimeDeltaMaxUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                                     NSInteger i = [value integerValue];
                                     if (i > configManager.keeptrackDistanceDeltaMax) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be less than %ld.", (long)configManager.keeptrackDistanceDeltaMin]];
                                         break;
                                     }
                                     [configManager keeptrackDistanceDeltaMinUpdate:i];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                                     NSInteger i = [value integerValue];
                                     if (i < configManager.keeptrackDistanceDeltaMin) {
                                         [MyTools messageBox:self header:@"Invalid value" text:[NSString stringWithFormat:@"This value should be more than %ld.", (long)configManager.keeptrackDistanceDeltaMin]];
                                         break;
                                     }
                                     [configManager keeptrackDistanceDeltaMaxUpdate:i];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_PURGEAGE: {
                                     NSInteger i = [value integerValue];
                                     [configManager keeptrackPurgeAgeUpdate:i];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_SYNC: {
                                     NSInteger i = [value integerValue];
                                     [configManager keeptrackSync:i];
                                     break;
                                 }
                             }
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
        switch (type) {
            case SECTION_KEEPTRACK_TIMEDELTA_MIN:
                textField.text = [NSString stringWithFormat:@"%0.1f", configManager.keeptrackTimeDeltaMin];
                break;
            case SECTION_KEEPTRACK_TIMEDELTA_MAX:
                textField.text = [NSString stringWithFormat:@"%0.1f", configManager.keeptrackTimeDeltaMax];
                break;
            case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
                textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.keeptrackDistanceDeltaMin];
                break;
            case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
                textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.keeptrackDistanceDeltaMax];
                break;
            case SECTION_KEEPTRACK_PURGEAGE:
                textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.keeptrackPurgeAge];
                break;
            case SECTION_KEEPTRACK_SYNC:
                textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.keeptrackSync];
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
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed];
            title = @"Maximum walking speed";
            successAction = @selector(updateDynamicmapSpeedWalking:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_CYCLING:
            speeds = speedsCycling;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed];
            title = @"Maximum cycling speed";
            successAction = @selector(updateDynamicmapSpeedCycling:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_DRIVING:
            speeds = speedsDriving;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapDrivingSpeed];
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
    [configManager dynamicmapWalkingSpeedUpdate:[[speedsWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedCycling:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapCyclingSpeedUpdate:[[speedsCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedDriving:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapDrivingSpeedUpdate:[[speedsDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
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
            currentDistance = [MyTools niceDistance:configManager.dynamicmapWalkingDistance];
            title = @"Maximum walking distance";
            successAction = @selector(updateDynamicmapDistanceWalking:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
            distances = distancesCycling;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapCyclingDistance];
            title = @"Maximum cycling distance";
            successAction = @selector(updateDynamicmapDistanceCycling:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
            distances = distancesDriving;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapDrivingDistance];
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
    [configManager dynamicmapWalkingDistanceUpdate:[[distancesWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceCycling:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapCyclingDistanceUpdate:[[distancesCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceDriving:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapDrivingDistanceUpdate:[[distancesDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeImportsQueryTimeout
{
    __block NSInteger currentChoice = 10;   // 600 seconds
    [downloadQueryTimeouts enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutQuery) {
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
    [configManager downloadTimeoutQueryUpdate:[[downloadQueryTimeouts objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeImportsSimpleTimeout
{
    __block NSInteger currentChoice = 4;   // 120 seconds
    [downloadSimpleTimeouts enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutSimple) {
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
    [configManager downloadTimeoutSimpleUpdate:[[downloadSimpleTimeouts objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)updateMapcacheMaxAge:(NSNumber *)selectedIndex element:(NSString *)element
{
    [configManager mapcacheMaxAgeUpdate:[[mapcacheMaxAgeValues objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeMapCacheMaxAge
{
    __block NSInteger currentChoice = 14;   // 30 days
    [mapcacheMaxAgeValues enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxAge) {
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
    [configManager mapcacheMaxSizeUpdate:[[mapcacheMaxSizeValues objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeMapCacheMaxSize
{    __block NSInteger currentChoice = 10;   // 250 Mb
    [mapcacheMaxSizeValues enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxSize) {
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
                                initialSelection:configManager.themeType
                                          target:self
                                   successAction:@selector(updateThemeThemeSuccess:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateThemeThemeSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [configManager themeTypeUpdate:i];
    [self.tableView reloadData];

    [themeManager setTheme:i];
    [self.tableView reloadData];
}

- (void)changeThemeCompass
{
    [ActionSheetStringPicker showPickerWithTitle:@"Select Compass"
                                            rows:compassTypes
                                initialSelection:configManager.compassType
                                          target:self
                                   successAction:@selector(updateThemeCompassSuccess:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateThemeCompassSuccess:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger i = [selectedIndex intValue];
    [configManager compassTypeUpdate:i];
    [self.tableView reloadData];
}

- (void)changeThemeOrientations
{
    __block NSInteger orientationIndex = 0;
    [orientationValues enumerateObjectsUsingBlock:^(NSNumber *n, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([n integerValue] == configManager.orientationsAllowed) {
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
    [configManager orientationsAllowedUpdate:d];
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
                                initialSelection:(configManager.mapSearchMaximumDistanceGS / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceGS:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumDistanceGS:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [configManager mapSearchMaximumDistanceGSUpdate:d];
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
                                initialSelection:(configManager.mapSearchMaximumDistanceOKAPI / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceOKAPI:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumDistanceOKAPI:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [configManager mapSearchMaximumDistanceOKAPIUpdate:d];
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
                                initialSelection:(configManager.mapSearchMaximumNumberGCA / 10) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumNumberGCA:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateMapSearchMaximumNumberGCA:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 10;
    [configManager mapSearchMaximumNumberGCAUpdate:d];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeWaypointSortBy
{
    [ActionSheetStringPicker showPickerWithTitle:@"Sort waypoints by"
                                            rows:[WaypointsOfflineListViewController sortByOrder]
                                initialSelection:configManager.waypointListSortBy
                                          target:self
                                   successAction:@selector(updateWaypointSortBy:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:self.tableView
     ];
}

- (void)updateWaypointSortBy:(NSNumber *)selectedIndex element:(id)element
{
    [configManager waypointListSortByUpdate:selectedIndex.integerValue];
    [self.tableView reloadData];
}

- (void)updateRefreshWaypointAfterLog:(GCSwitch *)b
{
    [configManager refreshWaypointAfterLogUpdate:b.on];
    [self.tableView reloadData];
}

- (void)updateShowCountryAsAbbrevation:(GCSwitch *)b
{
    [configManager showCountryAsAbbrevationUpdate:b.on];
    [self.tableView reloadData];
}

- (void)updateShowStateAsAbbrevation:(GCSwitch *)b
{
    [configManager showStateAsAbbrevationUpdate:b.on];
    [self.tableView reloadData];
}

- (void)updateShowStateAsAbbrevationWithLocale:(GCSwitch *)b
{
    [configManager showStateAsAbbrevationIfLocaleExistsUpdate:b.on];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeAppsExternalMap
{
    NSArray *maps = [dbExternalMap dbAll];
    __block NSInteger initial = 0;
    [maps enumerateObjectsUsingBlock:^(dbExternalMap *map, NSUInteger idx, BOOL * _Nonnull stop) {
        if (map.geocube_id == configManager.mapExternal) {
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
    [configManager mapExternalUpdate:map.geocube_id];
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
