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

@interface SettingsMainViewController ()
{
    float mapClustersZoomlevel;

    NSArray<NSString *> *compassTypes;
    NSArray<NSString *> *externalMapTypes;
    NSArray<NSString *> *mapBrandsCodes;
    NSArray<NSString *> *mapBrandsNames;

    NSArray<NSString *> *orientationStrings;
    NSArray<NSNumber *> *orientationValues;

    NSMutableArray<NSNumber *> *speedsWalkingMetric;
    NSMutableArray<NSNumber *> *speedsCyclingMetric;
    NSMutableArray<NSNumber *> *speedsDrivingMetric;
    NSMutableArray<NSString *> *speedsWalking;
    NSMutableArray<NSString *> *speedsCycling;
    NSMutableArray<NSString *> *speedsDriving;

    NSMutableArray<NSNumber *> *distancesWalkingMetric;
    NSMutableArray<NSNumber *> *distancesCyclingMetric;
    NSMutableArray<NSNumber *> *distancesDrivingMetric;
    NSMutableArray<NSString *> *distancesWalking;
    NSMutableArray<NSString *> *distancesCycling;
    NSMutableArray<NSString *> *distancesDriving;

    NSArray<NSString *> *accuracies;

    NSInteger mapcacheMaxAge;
    NSInteger mapcacheMaxSize;
    NSArray<NSString *> *mapcacheMaxAgeValues;
    NSArray<NSString *> *mapcacheMaxSizeValues;

    NSMutableArray<NSString *> *downloadSimpleTimeouts;
    NSMutableArray<NSString *> *downloadQueryTimeouts;
}

@end

@implementation SettingsMainViewController

enum {
    menuResetToDefault,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLRIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSWITCH bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSWITCH];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuResetToDefault label:_(@"settingsmainviewcontroller-Reset to default")];

    compassTypes = @[
                     _(@"settingsmainviewcontroller-Red arrow on blue"),
                     _(@"settingsmainviewcontroller-White arrow on black"),
                     _(@"settingsmainviewcontroller-Red arrow on black"),
                     _(@"settingsmainviewcontroller-Airplane")
                     ];

    [self calculateDynamicmapSpeedsDistances];
    [self calculateMapcache];

    NSArray<MapBrand *> *mapBrands = [MapTemplateViewController initMapBrands];
    NSMutableArray<NSString *> *codes = [NSMutableArray arrayWithCapacity:[mapBrands count]];
    NSMutableArray<NSString *> *names = [NSMutableArray arrayWithCapacity:[mapBrands count]];
    [mapBrands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mp, NSUInteger idx, BOOL * _Nonnull stop) {
        [codes addObject:mp.defaultString];
        [names addObject:mp.key];
    }];
    mapBrandsCodes = codes;
    mapBrandsNames = names;

    orientationStrings = @[
                           _(@"settingsmainviewcontroller-Portrait"),
                           _(@"settingsmainviewcontroller-Portrait UpsideDown"),
                           _(@"settingsmainviewcontroller-LandscapeLeft Portrait LandscapeRight"),
                           _(@"settingsmainviewcontroller-LandscapeLeft Portrait UpsideDown LandscapeRight"),
                           _(@"settingsmainviewcontroller-LandscapeRight"),
                           _(@"settingsmainviewcontroller-LandscapeLeft"),
                           _(@"settingsmainviewcontroller-LandscapeLeft LandscapeRight"),
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

    accuracies = @[
        _(@"settingsmainviewcontroller-Highest possible accuracy with additional sensor data"),
        _(@"settingsmainviewcontroller-Highest possible accuracy"),
        _(@"settingsmainviewcontroller-Accurate to ten meters"),
        _(@"settingsmainviewcontroller-Accurate to hundred meters"),
        _(@"settingsmainviewcontroller-Accurate to one kilometer"),
        _(@"settingsmainviewcontroller-Accurate to three kilometers"),
        ];

    downloadSimpleTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 30; i < 600; i += 30) {
        [downloadSimpleTimeouts addObject:[NSString stringWithFormat:@"%ld %@", (long)i, _(@"time-seconds")]];
    }
    downloadQueryTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 60; i < 1200; i += 30) {
        [downloadQueryTimeouts addObject:[NSString stringWithFormat:@"%ld %@", (long)i, _(@"time-seconds")]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:20];
    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull em, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:em.name];
    }];
    externalMapTypes = as;
    [self.tableView reloadData];
}

- (void)calculateMapcache
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 7; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld %@", (long)i, i == 1 ? _(@"time-day") : _(@"time-days")]];
    }
    for (NSInteger i = 7; i < 9 * 7; i += 7) {
        [as addObject:[NSString stringWithFormat:@"%ld %@ (%ld %@)", (long)i, _(@"time-days"), (long)i / 7, (i / 7) == 1 ? _(@"time-week") : _(@"time-weeks")]];
    }
    for (NSInteger i = 30; i < 13 * 30; i += 30) {
        [as addObject:[NSString stringWithFormat:@"%ld %@ (%ld %@)", (long)i, _(@"time-days"), (long)i / 30, (i / 30) == 1 ? _(@"time-month") : _(@"time-months")]];
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
    SECTION_ACCURACY,
    SECTION_MAPCACHE,
    SECTION_DYNAMICMAP,
    SECTION_KEEPTRACK,
    SECTION_MARKAS,
    SECTION_WAYPOINTS,
    SECTION_LISTS,
    SECTION_ACCOUNTS,
    SECTION_LOCATIONLESS,
    SECTION_BACKUPS,
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

    SECTION_MAPS_DEFAULTBRAND = 0,
    SECTION_MAPS_ROTATE_TO_BEARING,
    SECTION_MAPS_MAX,

    SECTION_MAPCOLOURS_TRACK = 0,
    SECTION_MAPCOLOURS_DESTINATION,
    SECTION_MAPCOLOURS_MAX,

    SECTION_APPS_EXTERNALMAP = 0,
    SECTION_APPS_TWITTER,
    SECTION_APPS_OPENCAGEOVERWIFIONLY,
    SECTION_APPS_OPENCAGEKEY,
    SECTION_APPS_MAX,

    SECTION_MAPCACHE_ENABLED = 0,
    SECTION_MAPCACHE_MAXAGE,
    SECTION_MAPCACHE_MAXSIZE,
    SECTION_MAPCACHE_MAX,

    SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS = 0,
    SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA,
    SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI,
    SECTION_MAPSEARCHMAXIMUM_DISTANCE_GCA,
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
    SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALITY,
    SECTION_WAYPOINTS_REFRESHAFTERLOG,
    SECTION_WAYPOINTS_MAX,

    SECTION_LISTS_SORTBY = 0,
    SECTION_LISTS_MAX,

    SECTION_ACCOUNTS_AUTHENTICATEKEEPUSERNAME = 0,
    SECTION_ACCOUNTS_AUTHENTICATEKEEPPASSWORD,
    SECTION_ACCOUNTS_MAX,

    SECTION_LOCATIONLESS_SORTBY = 0,
    SECTION_LOCATIONLESS_SHOWFOUND,
    SECTION_LOCATIONLESS_MAX,

    SECTION_BACKUPS_ENABLED = 0,
    SECTION_BACKUPS_INTERVAL,
    SECTION_BACKUPS_ROTATION,
    SECTION_BACKUPS_MAX,

    SECTION_ACCURACY_DYNAMIC_ENABLE = 0,
    SECTION_ACCURACY_DYNAMIC_NEAR,
    SECTION_ACCURACY_DYNAMIC_MIDRANGE,
    SECTION_ACCURACY_DYNAMIC_FAR,
    SECTION_ACCURACY_DYNAMIC_NEARTOMIDRANGE,
    SECTION_ACCURACY_DYNAMIC_MIDRANGETOFAR,
    SECTION_ACCURACY_STATIC_NAVIGATING,
    SECTION_ACCURACY_STATIC_NONNAVIGATING,
    SECTION_ACCURACY_MAX,
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
        SECTION_MAX(LISTS);
        SECTION_MAX(ACCOUNTS);
        SECTION_MAX(LOCATIONLESS);
        SECTION_MAX(BACKUPS);
        SECTION_MAX(ACCURACY);
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
            return _(@"settingsmainviewcontroller-Distances");
        case SECTION_APPS:
            return _(@"settingsmainviewcontroller-External apps");
        case SECTION_THEME:
            return _(@"settingsmainviewcontroller-Theme");
        case SECTION_SOUNDS:
            return _(@"settingsmainviewcontroller-Sounds");
        case SECTION_COMPASS:
            return _(@"settingsmainviewcontroller-Compass");
        case SECTION_MAPCOLOURS:
            return _(@"settingsmainviewcontroller-Map colours");
        case SECTION_MAPS:
            return _(@"settingsmainviewcontroller-Maps");
        case SECTION_DYNAMICMAP:
            return _(@"settingsmainviewcontroller-Dynamic Maps");
        case SECTION_KEEPTRACK:
            return _(@"settingsmainviewcontroller-Keep track");
        case SECTION_MAPCACHE:
            return _(@"settingsmainviewcontroller-Map cache");
        case SECTION_IMPORTS:
            return _(@"settingsmainviewcontroller-Import options");
        case SECTION_MAPSEARCHMAXIMUM:
            return _(@"settingsmainviewcontroller-Map search maximums");
        case SECTION_MARKAS:
            return _(@"settingsmainviewcontroller-Mark as...");
        case SECTION_WAYPOINTS:
            return _(@"settingsmainviewcontroller-Waypoints");
        case SECTION_LISTS:
            return _(@"settingsmainviewcontroller-Lists");
        case SECTION_ACCOUNTS:
            return _(@"settingsmainviewcontroller-Accounts");
        case SECTION_LOCATIONLESS:
            return _(@"settingsmainviewcontroller-Locationless");
        case SECTION_BACKUPS:
            return _(@"settingsmainviewcontroller-Backups");
        case SECTION_ACCURACY:
            return _(@"settingsmainviewcontroller-Accuracy");
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
            switch (indexPath.row) {
                case SECTION_DISTANCE_METRIC: {   // Metric
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Use metric units");
                    cell.optionSwitch.on = configManager.distanceMetric;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDistanceMetric:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_APPS: {
            switch (indexPath.row) {
                case SECTION_APPS_EXTERNALMAP: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-External Maps");
                    __block NSString *name = nil;
                    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull em, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (em.geocube_id == configManager.mapExternal) {
                            name = em.name;
                            *stop = YES;
                        }
                    }];
                    cell.detailTextLabel.text = name;
                    return cell;
                }
                case SECTION_APPS_OPENCAGEKEY: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-OpenCage key");
                    cell.detailTextLabel.text = configManager.opencageKey;
                    return cell;
                }
                case SECTION_APPS_OPENCAGEOVERWIFIONLY: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-OpenCage only over Wifi");
                    cell.optionSwitch.on = configManager.opencageWifiOnly;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateOpenCageWifiOnly:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_APPS_TWITTER: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Offer to send tweets");
                    cell.optionSwitch.on = configManager.sendTweets;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateSendTweets:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_THEME: {   // Theme
            switch (indexPath.row) {
                case SECTION_THEME_THEME: {   // Theme
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Theme");
                    cell.detailTextLabel.text = [[themeManager themeNames] objectAtIndex:configManager.themeType];
                    return cell;
                }
                case SECTION_THEME_COMPASS: {   // Compass type
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Compass type");
                    cell.detailTextLabel.text = [compassTypes objectAtIndex:configManager.compassType];
                    return cell;
                }
                case SECTION_THEME_ORIENTATIONS: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    NSMutableString *s = [NSMutableString stringWithString:@""];
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskPortrait) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:_(@"settingsmainviewcontroller-Portrait")];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskPortraitUpsideDown) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:_(@"settingsmainviewcontroller-Upside Down")];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskLandscapeLeft) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:_(@"settingsmainviewcontroller-Landscape Left")];
                    }
                    if ((configManager.orientationsAllowed & UIInterfaceOrientationMaskLandscapeRight) != 0) {
                        if ([s isEqualToString:@""] == NO)
                            [s appendString:@", "];
                        [s appendString:_(@"settingsmainviewcontroller-Landscape Right")];
                    }
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Orientations allowed");
                    cell.detailTextLabel.text = s;
                    return cell;
                }
            }
            break;
        }

        case SECTION_SOUNDS: {   // Sounds
            switch (indexPath.row) {
                case SECTION_SOUNDS_DIRECTION: {   // soundDirection
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable sounds for direction");
                    cell.optionSwitch.on = configManager.soundDirection;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateSoundDirection:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_SOUNDS_DISTANCE: {   // soundDistance
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable sounds for distance");
                    cell.optionSwitch.on = configManager.soundDistance;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateSoundDistance:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPCOLOURS: {
            switch (indexPath.row) {
                case SECTION_MAPCOLOURS_DESTINATION: {
                    GCTableViewCellRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Destination line");
                    cell.imageView.image = [ImageLibrary circleWithColour:configManager.mapDestinationColour];
                    return cell;
                }
                case SECTION_MAPCOLOURS_TRACK: {
                    GCTableViewCellRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Track line");
                    cell.imageView.image = [ImageLibrary circleWithColour:configManager.mapTrackColour];
                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPS: {   // Maps
            switch (indexPath.row) {
                case SECTION_MAPS_DEFAULTBRAND: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Default map");
                    __block NSString *value = nil;
                    [mapBrandsCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull k, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([k isEqualToString:configManager.mapBrandDefault] == YES) {
                            value = [mapBrandsNames objectAtIndex:idx];
                            *stop = YES;
                            return;
                        }
                    }];
                    cell.detailTextLabel.text = value;
                    return cell;
                }
                case SECTION_MAPS_ROTATE_TO_BEARING: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Rotate to bearing");
                    cell.optionSwitch.on = configManager.mapRotateToBearing;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateMapRotateToBearing:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPSEARCHMAXIMUM: {
            switch (indexPath.row) {
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance in GroundSpeak geocaching.com search radius");
                    cell.detailTextLabel.text = [MyTools niceDistance:configManager.mapSearchMaximumDistanceGS];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance in OKAPI search radius");
                    cell.detailTextLabel.text = [MyTools niceDistance:configManager.mapSearchMaximumDistanceOKAPI];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GCA: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance in GCA search radius");
                    cell.detailTextLabel.text = [MyTools niceDistance:configManager.mapSearchMaximumDistanceGCA];
                    return cell;
                }
                case SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Number of waypoints in Geocaching Australia search");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.mapSearchMaximumNumberGCA, _(@"waypoints")];
                    return cell;
                }
            }
            break;
        }

        case SECTION_DYNAMICMAP: {
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_ENABLED: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable dynamic maps");
                    cell.optionSwitch.on = configManager.dynamicmapEnable;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDynamicmapEnable:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_WALKING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Maximum walking speed");
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed];
                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_CYCLING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Maximum cycling speed");
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed];
                    return cell;
                }
                case SECTION_DYNAMICMAP_SPEED_DRIVING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Maximum driving speed");
                    cell.detailTextLabel.text = [MyTools niceSpeed:configManager.dynamicmapDrivingSpeed];
                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_WALKING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Walking zoom-out distance");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", _(@"settingsmainviewcontroller-Always"), [MyTools niceDistance:configManager.dynamicmapWalkingDistance]];
                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Cycling zoom-out distance");
                    cell.detailTextLabel.text = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Between %@ and %@"), [MyTools niceDistance:configManager.dynamicmapWalkingDistance], [MyTools niceDistance:configManager.dynamicmapCyclingDistance]];
                    return cell;
                }
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Driving zoom-out distance");
                    cell.detailTextLabel.text = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Between %@ and %@"), [MyTools niceDistance:configManager.dynamicmapCyclingDistance], [MyTools niceDistance:configManager.dynamicmapDrivingDistance]];
                    return cell;
                }
            }
            break;
        }

        case SECTION_KEEPTRACK: {
            switch (indexPath.row) {
                case SECTION_KEEPTRACK_AUTOROTATE: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Autorotate every day");
                    cell.optionSwitch.on = configManager.keeptrackAutoRotate;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateKeeptrackAutoRotate:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Time difference for a new track point");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f %@", configManager.keeptrackTimeDeltaMin, _(@"time-seconds")];
                    return cell;
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Time difference for a new track");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.1f %@", configManager.keeptrackTimeDeltaMax, _(@"time-seconds")];
                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance difference for a new track point");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:configManager.keeptrackDistanceDeltaMin]];
                    return cell;
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance difference for a new track");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceDistance:configManager.keeptrackDistanceDeltaMax]];
                    return cell;
                }
                case SECTION_KEEPTRACK_PURGEAGE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Autopurge age for old tracks");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.keeptrackPurgeAge, _(@"time-days")];
                    return cell;
                }
                case SECTION_KEEPTRACK_SYNC: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Sync track data");
                    cell.detailTextLabel.text = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Every %ld seconds"), (long)configManager.keeptrackSync];
                    return cell;
                }
            }
            break;
        }

        case SECTION_MAPCACHE: {
            switch (indexPath.row) {
                case SECTION_MAPCACHE_ENABLED: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable map cache");
                    cell.optionSwitch.on = configManager.mapcacheEnable;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateMapcacheEnable:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_MAPCACHE_MAXAGE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Maximum age for objects in cache");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.mapcacheMaxAge, _(@"time-days")];
                    return cell;
                }
                case SECTION_MAPCACHE_MAXSIZE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Maximum size for the cache");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld Mb", (long)configManager.mapcacheMaxSize];
                    return cell;
                }
            }
            break;
        }

        case SECTION_IMPORTS: {
            switch (indexPath.row) {
                case SECTION_IMPORTS_TIMEOUT_SIMPLE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Timeout for simple HTTP requests");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.downloadTimeoutSimple, _(@"time-seconds")];
                    return cell;
                }
                case SECTION_IMPORTS_TIMEOUT_QUERY: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Timeout for big HTTP requests");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.downloadTimeoutQuery, _(@"time-seconds")];
                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_WAYPOINT: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Download waypoint images");
                    cell.optionSwitch.on = configManager.downloadImagesWaypoints;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDownloadImagesWaypoints:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_IMPORTS_IMAGES_LOGS: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Download log images");
                    cell.optionSwitch.on = configManager.downloadImagesLogs;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDownloadImagesLogs:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_IMPORTS_LOG_IMAGES_MOBILE: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Download logged images over mobile data");
                    cell.optionSwitch.on = configManager.downloadImagesMobile;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDownloadImagesMobile:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_IMPORTS_QUERIES_MOBILE: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Download batch queries over mobile data");
                    cell.optionSwitch.on = configManager.downloadQueriesMobile;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDownloadQueriesMobile:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_MARKAS: {
            switch (indexPath.row) {
                case SECTION_MARKAS_FOUNDDNFCLEARSTARGET: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Remove target when marking as found/DNF");
                    cell.optionSwitch.on = configManager.markasFoundDNFClearsTarget;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateMarkasFoundDNFClearsTarget:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_MARKAS_FOUNDMARKSALLWAYPOINTS: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Mark all related waypoints when marked as found");
                    cell.optionSwitch.on = configManager.markasFoundMarksAllWaypoints;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateMarkasFoundMarksAllWaypoints:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_LOG_REMOVEMARKASFOUNDDNF: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Remove Marked as Found/DNF when logging");
                    cell.optionSwitch.on = configManager.loggingRemovesMarkedAsFoundDNF;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateLoggingRemovesMarkedAsFoundDNF:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_COMPASS: {
            switch (indexPath.row) {
                case SECTION_COMPASS_ALWAYSPORTRAIT: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Compass is always in portrait mode");
                    cell.optionSwitch.on = configManager.compassAlwaysInPortraitMode;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateCompassAlwaysInPortraitMode:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_WAYPOINTS: {
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Sort waypoints default by...");
                    NSArray<NSString *> *order = [WaypointSorter waypointsSortOrders];
                    cell.detailTextLabel.text = [order objectAtIndex:configManager.waypointListSortBy];
                    return cell;
                }
                case SECTION_WAYPOINTS_REFRESHAFTERLOG: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Refresh after log");
                    cell.optionSwitch.on = configManager.refreshWaypointAfterLog;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateRefreshWaypointAfterLog:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_WAYPOINTS_SHOWCOUNTRYASABBREVATION: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Show country as abbrevation");
                    cell.optionSwitch.on = configManager.showCountryAsAbbrevation;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateShowCountryAsAbbrevation:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATION: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Show state as abbrevation");
                    cell.optionSwitch.on = configManager.showStateAsAbbrevation;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateShowStateAsAbbrevation:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALITY: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Show state as abbrevation if locality exist");
                    cell.optionSwitch.on = configManager.showStateAsAbbrevationIfLocalityExists;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateShowStateAsAbbrevationWithLocality:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
            break;
        }

        case SECTION_LISTS: {
            switch (indexPath.row) {
                case SECTION_LISTS_SORTBY: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Sort lists default by...");
                    NSArray<NSString *> *order = [WaypointSorter listSortOrders];
                    cell.detailTextLabel.text = [order objectAtIndex:configManager.listSortBy];
                    return cell;
                }
            }
            break;
        }

        case SECTION_ACCOUNTS: {
            switch (indexPath.row) {
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPUSERNAME: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Save authentication username");
                    cell.optionSwitch.on = configManager.accountsSaveAuthenticationName;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateAccountKeepUsername:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPPASSWORD: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Save authentication password");
                    cell.optionSwitch.on = configManager.accountsSaveAuthenticationPassword;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateAccountKeepPassword:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
            }
        }

        case SECTION_LOCATIONLESS: {
            switch (indexPath.row) {
                case SECTION_LOCATIONLESS_SHOWFOUND: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Show found in list");
                    cell.optionSwitch.on = configManager.locationlessShowFound;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateLocationlessShowFound:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_LOCATIONLESS_SORTBY: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Sort by");
                    NSArray<NSString *> *order = [WaypointSorter locationlessSortOrders];
                    cell.detailTextLabel.text = [order objectAtIndex:configManager.locationlessListSortBy];
                    return cell;
                }
            }
        }

        case SECTION_BACKUPS: {
            switch (indexPath.row) {
                case SECTION_BACKUPS_ENABLED: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable backups");
                    cell.optionSwitch.on = configManager.automaticDatabaseBackup;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateBackupsEnable:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_BACKUPS_INTERVAL: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Make a new backup every");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.automaticDatabaseBackupPeriod, _(@"time-days")];
                    return cell;
                }
                case SECTION_BACKUPS_ROTATION: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Number of backups to be kept");
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %@", (long)configManager.automaticDatabaseBackupRotate, _(@"settingsmainviewcontroller-backups")];
                    return cell;
                }
            }
        }

        case SECTION_ACCURACY: {
            switch (indexPath.row) {
                case SECTION_ACCURACY_DYNAMIC_ENABLE: {
                    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Enable dynamic accuracy");
                    cell.optionSwitch.on = configManager.accuracyDynamicEnable;
                    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                    [cell.optionSwitch addTarget:self action:@selector(updateDynamicAccuracyEnable:) forControlEvents:UIControlEventTouchUpInside];
                    return cell;
                }
                case SECTION_ACCURACY_DYNAMIC_NEAR: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Accuracy for 'near' accuracy");
                    cell.detailTextLabel.text = [accuracies objectAtIndex:configManager.accuracyDynamicAccuracyNear];
                    return cell;
                }
                case SECTION_ACCURACY_DYNAMIC_MIDRANGE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Accuracy for 'midrange' accuracy");
                    cell.detailTextLabel.text = [accuracies objectAtIndex:configManager.accuracyDynamicAccuracyMidrange];
                    return cell;
                }
                case SECTION_ACCURACY_DYNAMIC_FAR: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Accuracy for 'far' accuracy");
                    cell.detailTextLabel.text = [accuracies objectAtIndex:configManager.accuracyDynamicAccuracyFar];
                    return cell;
                }
                case SECTION_ACCURACY_DYNAMIC_NEARTOMIDRANGE: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance for 'near' accuracy");
                    cell.detailTextLabel.text = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Up to %@"), [MyTools niceDistance:configManager.accuracyDynamicDistanceNearToMidrange]];
                    return cell;
                }
                case SECTION_ACCURACY_DYNAMIC_MIDRANGETOFAR: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Distance for 'midrange' accuracy");
                    cell.detailTextLabel.text = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Up to %@"), [MyTools niceDistance:configManager.accuracyDynamicDistanceNearToMidrange]];
                    return cell;
                }
                case SECTION_ACCURACY_STATIC_NAVIGATING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Accuracy for static 'navigating' accuracy");
                    cell.detailTextLabel.text = [accuracies objectAtIndex:configManager.accuracyStaticAccuracyNavigating];
                    return cell;
                }
                case SECTION_ACCURACY_STATIC_NONNAVIGATING: {
                    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];
                    cell.textLabel.text = _(@"settingsmainviewcontroller-Accuracy for static 'non-navigating' accuracy");
                    cell.detailTextLabel.text = [accuracies objectAtIndex:configManager.accuracyStaticAccuracyNonNavigating];
                    return cell;
                }
            }
        }

    }

    // Not reached
    abort();
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

- (void)updateOpenCageWifiOnly:(GCSwitch *)s
{
    [configManager opencageWifiOnlyUpdate:s.on];
}

- (void)updateSendTweets:(GCSwitch *)s
{
    [configManager sendTweetsUpdate:s.on];
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
    [configManager mapClustersEnableUpdate:s.on];
}
- (void)updateMapRotateToBearing:(GCSwitch *)s
{
    [configManager mapRotateToBearingUpdate:s.on];
}

- (void)updateKeeptrackAutoRotate:(GCSwitch *)s
{
    [configManager keeptrackAutoRotateUpdate:s.on];
}

- (void)updateBackupsEnable:(GCSwitch *)s
{
    [configManager automaticDatabaseBackupUpdate:s.on];
}

- (void)updateDynamicAccuracyEnable:(GCSwitch *)s
{
    [configManager accuracyDynamicEnableUpdate:s.on];
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
            break;
        case SECTION_APPS:
            switch (indexPath.row) {
                case SECTION_APPS_EXTERNALMAP:
                    [self changeAppsExternalMap];
                    break;
                case SECTION_APPS_OPENCAGEKEY:
                    [self changeOpenCageKey];
                    break;
            }
            break;
        case SECTION_MAPSEARCHMAXIMUM:
            switch (indexPath.row) {
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS:
                    [self changeMapSearchMaximumDistanceGS];
                    break;
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI:
                    [self changeMapSearchMaximumDistanceOKAPI];
                    break;
                case SECTION_MAPSEARCHMAXIMUM_DISTANCE_GCA:
                    [self changeMapSearchMaximumDistanceGCA];
                    break;
                case SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA:
                    [self changeMapSearchMaximumNumberGCA];
                    break;
            }
            break;
        case SECTION_MAPS:
            switch (indexPath.row) {
                case SECTION_MAPS_DEFAULTBRAND:
                    [self changeMapsDefaultBrand];
                    break;
            }
            break;
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
            break;
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
            break;

        case SECTION_MAPCACHE:
            switch (indexPath.row) {
                case SECTION_MAPCACHE_MAXAGE:
                    [self changeMapCacheMaxAge];
                    break;
                case SECTION_MAPCACHE_MAXSIZE:
                    [self changeMapCacheMaxSize];
                    break;
            }
            break;

        case SECTION_IMPORTS:
            switch (indexPath.row) {
                case SECTION_IMPORTS_TIMEOUT_SIMPLE:
                    [self changeImportsSimpleTimeout];
                    break;
                case SECTION_IMPORTS_TIMEOUT_QUERY:
                    [self changeImportsQueryTimeout];
                    break;
            }
            break;

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
            break;

        case SECTION_WAYPOINTS:
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY:
                    [self changeWaypointSortBy];
                    break;
            }
            break;

        case SECTION_LISTS:
            switch (indexPath.row) {
                case SECTION_LISTS_SORTBY:
                    [self changeListSortBy];
                    break;
            }
            break;

        case SECTION_LOCATIONLESS:
            switch (indexPath.row) {
                case SECTION_LOCATIONLESS_SORTBY:
                    [self changeLocationlessSortOrder];
                    break;
            }
            break;

        case SECTION_BACKUPS:
            switch (indexPath.row) {
                case SECTION_BACKUPS_ROTATION:
                    [self changeBackupsRotation];
                    break;
                case SECTION_BACKUPS_INTERVAL:
                    [self changeBackupsInterval];
                    break;
            }
            break;
        case SECTION_ACCURACY:
            switch (indexPath.row) {
                case SECTION_ACCURACY_DYNAMIC_NEAR:
                case SECTION_ACCURACY_DYNAMIC_MIDRANGE:
                case SECTION_ACCURACY_DYNAMIC_FAR:
                case SECTION_ACCURACY_DYNAMIC_NEARTOMIDRANGE:
                case SECTION_ACCURACY_DYNAMIC_MIDRANGETOFAR:
                case SECTION_ACCURACY_STATIC_NAVIGATING:
                case SECTION_ACCURACY_STATIC_NONNAVIGATING:
                    [self changeAccuracy:indexPath.row];
                    break;
            }
            break;
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* ********************************************************************************* */

- (void)changeOpenCageKey
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-OpenCage key")
                                message:_(@"settingsmainviewcontroller-Enter your OpenCage key")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             [configManager opencageKeyUpdate:value];
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
        textField.text = configManager.opencageKey;
        textField.placeholder = _(@"settingsmainviewcontroller-OpenCage key");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)keeptrackChange:(NSInteger)type
{
    NSString *message;
    switch (type) {
        case SECTION_KEEPTRACK_TIMEDELTA_MIN:
            message = _(@"settingsmainviewcontroller-Change the time difference for a new track point.");
            break;
        case SECTION_KEEPTRACK_TIMEDELTA_MAX:
            message = _(@"settingsmainviewcontroller-Change the time difference for a new track.");
            break;
        case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
            message = _(@"settingsmainviewcontroller-Change in distance difference for a new track point.");
            break;
        case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
            message = _(@"settingsmainviewcontroller-Change in distance difference for a new track.");
            break;
        case SECTION_KEEPTRACK_PURGEAGE:
            message = _(@"settingsmainviewcontroller-Change the maximum age of old tracks before they get purged.");
            break;
        case SECTION_KEEPTRACK_SYNC:
            message = _(@"settingsmainviewcontroller-Change the time interval to sync the track data");
            break;
    }
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Update value")
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             switch (type) {
                                 case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                                     float f = [value floatValue];
                                     if (f > configManager.keeptrackTimeDeltaMax) {
                                         [MyTools messageBox:self header:_(@"settingsmainviewcontroller-Invalid value") text:[NSString stringWithFormat:_(@"settingsmainviewcontroller-This value should be less than %0.1f."), configManager.keeptrackTimeDeltaMax]];
                                         break;
                                     }
                                     [configManager keeptrackTimeDeltaMinUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                                     float f = [value floatValue];
                                     if (f < configManager.keeptrackTimeDeltaMin) {
                                         [MyTools messageBox:self header:_(@"settingsmainviewcontroller-Invalid value") text:[NSString stringWithFormat:_(@"settingsmainviewcontroller-This value should be more than %0.1f."), configManager.keeptrackTimeDeltaMin]];
                                         break;
                                     }
                                     [configManager keeptrackTimeDeltaMaxUpdate:f];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MIN: {
                                     NSInteger i = [value integerValue];
                                     if (i > configManager.keeptrackDistanceDeltaMax) {
                                         [MyTools messageBox:self header:_(@"settingsmainviewcontroller-Invalid value") text:[NSString stringWithFormat:_(@"settingsmainviewcontroller-This value should be less than %ld."), (long)configManager.keeptrackDistanceDeltaMin]];
                                         break;
                                     }
                                     [configManager keeptrackDistanceDeltaMinUpdate:i];
                                     break;
                                 }
                                 case SECTION_KEEPTRACK_DISTANCEDELTA_MAX: {
                                     NSInteger i = [value integerValue];
                                     if (i < configManager.keeptrackDistanceDeltaMin) {
                                         [MyTools messageBox:self header:_(@"settingsmainviewcontroller-Invalid value") text:[NSString stringWithFormat:_(@"settingsmainviewcontroller-This value should be more than %ld."), (long)configManager.keeptrackDistanceDeltaMin]];
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
                                     [configManager keeptrackSyncUpdate:i];
                                     break;
                                 }
                             }
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
        textField.placeholder = _(@"settingsmainviewcontroller-Enter value...");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeDynamicmapSpeed:(NSInteger)row
{
    NSArray<NSString *> *speeds = nil;
    NSString *title = nil;
    NSString *currentSpeed = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_SPEED_WALKING:
            speeds = speedsWalking;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed];
            title = _(@"settingsmainviewcontroller-Maximum walking speed");
            successAction = @selector(updateDynamicmapSpeedWalking:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_CYCLING:
            speeds = speedsCycling;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed];
            title = _(@"settingsmainviewcontroller-Maximum cycling speed");
            successAction = @selector(updateDynamicmapSpeedCycling:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_DRIVING:
            speeds = speedsDriving;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapDrivingSpeed];
            title = _(@"settingsmainviewcontroller-Maximum driving speed");
            successAction = @selector(updateDynamicmapSpeedDriving:element:);
            break;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:SECTION_DYNAMICMAP]];

    __block NSInteger selectedSpeed = 0;
    [speeds enumerateObjectsUsingBlock:^(NSString * _Nonnull speed, NSUInteger idx, BOOL * _Nonnull stop) {
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
                                          origin:cell.contentView
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
    NSArray<NSString *> *distances = nil;
    NSString *title = nil;
    NSString *currentDistance = nil;
    SEL successAction = nil;
    switch (row) {
        case SECTION_DYNAMICMAP_DISTANCE_WALKING:
            distances = distancesWalking;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapWalkingDistance];
            title = _(@"settingsmainviewcontroller-Maximum walking distance");
            successAction = @selector(updateDynamicmapDistanceWalking:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
            distances = distancesCycling;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapCyclingDistance];
            title = _(@"settingsmainviewcontroller-Maximum cycling distance");
            successAction = @selector(updateDynamicmapDistanceCycling:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
            distances = distancesDriving;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapDrivingDistance];
            title = _(@"settingsmainviewcontroller-Maximum driving distance");
            successAction = @selector(updateDynamicmapDistanceDriving:element:);
            break;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:SECTION_DYNAMICMAP]];

    __block NSInteger selectedDistance = 0;
    [distances enumerateObjectsUsingBlock:^(NSString * _Nonnull distance, NSUInteger idx, BOOL * _Nonnull stop) {
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
                                          origin:cell.contentView
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
    [downloadQueryTimeouts enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutQuery) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_IMPORTS_TIMEOUT_QUERY inSection:SECTION_IMPORTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Timeout value for big HTTP requests")
                                            rows:downloadQueryTimeouts
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateDownloadQueryTimeout:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    [downloadSimpleTimeouts enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutSimple) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_IMPORTS_TIMEOUT_SIMPLE inSection:SECTION_IMPORTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Timeout value for simple HTTP requests")
                                            rows:downloadSimpleTimeouts
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateDownloadSimpleTimeout:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    [mapcacheMaxAgeValues enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxAge) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPCACHE_MAXAGE inSection:SECTION_MAPCACHE]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Maximum age for objects in the map cache")
                                            rows:mapcacheMaxAgeValues
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateMapcacheMaxAge:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateMapcacheMaxSize:(NSNumber *)selectedIndex element:(NSString *)element
{
    [configManager mapcacheMaxSizeUpdate:[[mapcacheMaxSizeValues objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)changeMapCacheMaxSize
{    __block NSInteger currentChoice = 10;   // 250 Mb
    [mapcacheMaxSizeValues enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxSize) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPCACHE_MAXSIZE inSection:SECTION_MAPCACHE]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Maximum size for the map cache")
                                            rows:mapcacheMaxSizeValues
                                initialSelection:currentChoice
                                          target:self
                                   successAction:@selector(updateMapcacheMaxSize:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

/* ********************************************************************************* */

- (void)changeThemeTheme
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_THEME_THEME inSection:SECTION_THEME]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select theme")
                                            rows:[themeManager themeNames]
                                initialSelection:configManager.themeType
                                          target:self
                                   successAction:@selector(updateThemeThemeSuccess:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_THEME_COMPASS inSection:SECTION_THEME]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Compass")
                                            rows:compassTypes
                                initialSelection:configManager.compassType
                                          target:self
                                   successAction:@selector(updateThemeCompassSuccess:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_THEME_ORIENTATIONS inSection:SECTION_THEME]];

    __block NSInteger orientationIndex = 0;
    [orientationValues enumerateObjectsUsingBlock:^(NSNumber * _Nonnull n, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([n integerValue] == configManager.orientationsAllowed) {
            orientationIndex = idx;
            *stop = YES;
        }
    }];
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Orientations")
                                            rows:orientationStrings
                                initialSelection:orientationIndex
                                          target:self
                                   successAction:@selector(updateThemeOrientations:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPSEARCHMAXIMUM_DISTANCE_GS inSection:SECTION_MAPSEARCHMAXIMUM]];

    NSMutableArray<NSString *> *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 250; d < 10000; d += 250) {
        [distances addObject:[MyTools niceDistance:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Maximum Distance")
                                            rows:distances
                                initialSelection:(configManager.mapSearchMaximumDistanceGS / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceGS:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateMapSearchMaximumDistanceGS:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [configManager mapSearchMaximumDistanceGSUpdate:d];
    [self.tableView reloadData];
}

- (void)changeMapSearchMaximumDistanceGCA
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPSEARCHMAXIMUM_DISTANCE_GCA inSection:SECTION_MAPSEARCHMAXIMUM]];

    NSMutableArray<NSString *> *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 250; d < 10000; d += 250) {
        [distances addObject:[MyTools niceDistance:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Maximum Distance")
                                            rows:distances
                                initialSelection:(configManager.mapSearchMaximumDistanceGCA / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceGCA:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateMapSearchMaximumDistanceGCA:(NSNumber *)selectedIndex element:(id)element
{
    NSInteger d = (1 + [selectedIndex integerValue]) * 250;
    [configManager mapSearchMaximumDistanceGCAUpdate:d];
    [self.tableView reloadData];
}

- (void)changeMapSearchMaximumDistanceOKAPI
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPSEARCHMAXIMUM_DISTANCE_OKAPI inSection:SECTION_MAPSEARCHMAXIMUM]];

    NSMutableArray<NSString *> *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 250; d < 10000; d += 250) {
        [distances addObject:[MyTools niceDistance:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Maximum Distance")
                                            rows:distances
                                initialSelection:(configManager.mapSearchMaximumDistanceOKAPI / 250) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumDistanceOKAPI:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPSEARCHMAXIMUM_NUMBER_GCA inSection:SECTION_MAPSEARCHMAXIMUM]];

    NSMutableArray<NSNumber *> *distances = [NSMutableArray arrayWithCapacity:10000 / 250];
    for (NSInteger d = 10; d < 200; d += 10) {
        [distances addObject:[NSNumber numberWithInteger:d]];
    }
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Maximum Waypoints")
                                            rows:distances
                                initialSelection:(configManager.mapSearchMaximumNumberGCA / 10) - 1
                                          target:self
                                   successAction:@selector(updateMapSearchMaximumNumberGCA:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_WAYPOINTS_SORTBY inSection:SECTION_WAYPOINTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Sort waypoints by")
                                            rows:[WaypointSorter waypointsSortOrders]
                                initialSelection:configManager.waypointListSortBy
                                          target:self
                                   successAction:@selector(updateWaypointSortBy:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
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

- (void)updateShowStateAsAbbrevationWithLocality:(GCSwitch *)b
{
    [configManager showStateAsAbbrevationIfLocalityExistsUpdate:b.on];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeBackupsRotation
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Backup rotation")
                                message:_(@"settingsmainviewcontroller-Specify how many backups need to be saved")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             if (i > 0 || i < 10)
                                 [configManager automaticDatabaseBackupRotateUpdate:i];
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
        textField.text = configManager.opencageKey;
        textField.placeholder = _(@"settingsmainviewcontroller-Number of backups (between 1 and 10)");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeBackupsInterval
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Backup rotation")
                                message:_(@"settingsmainviewcontroller-Specify the number of days between backups")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             if (i > 0)
                                 [configManager automaticDatabaseBackupPeriodUpdate:i];
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
        textField.text = configManager.opencageKey;
        textField.placeholder = _(@"settingsmainviewcontroller-Number of days between backups");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeListSortBy
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LISTS_SORTBY inSection:SECTION_LISTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Sort lists by")
                                            rows:[WaypointSorter listSortOrders]
                                initialSelection:configManager.listSortBy
                                          target:self
                                   successAction:@selector(updateListSortBy:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateListSortBy:(NSNumber *)selectedIndex element:(id)element
{
    [configManager listSortByUpdate:selectedIndex.integerValue];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeLocationlessSortOrder
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LOCATIONLESS_SORTBY inSection:SECTION_LOCATIONLESS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Sort locationless by")
                                            rows:[WaypointSorter locationlessSortOrders]
                                initialSelection:configManager.locationlessListSortBy
                                          target:self
                                   successAction:@selector(updateLocationlessSortBy:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateLocationlessSortBy:(NSNumber *)selectedIndex element:(id)element
{
    [configManager locationlessListSortByUpdate:selectedIndex.integerValue];
    [self.tableView reloadData];
}

- (void)updateLocationlessShowFound:(GCSwitch *)b
{
    [configManager locationlessShowFoundUpdate:b.on];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeMapsDefaultBrand
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPS_DEFAULTBRAND inSection:SECTION_MAPS]];

    __block NSInteger initial = 0;
    [mapBrandsCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull k, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([k isEqualToString:configManager.mapBrandDefault] == YES) {
            initial = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Default Map")
                                            rows:mapBrandsNames
                                initialSelection:initial
                                          target:self
                                   successAction:@selector(updateMapsDefaultBrand:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateMapsDefaultBrand:(NSNumber *)selectedIndex element:(id)element
{
    NSString *code = [mapBrandsCodes objectAtIndex:[selectedIndex integerValue]];
    [configManager mapBrandDefaultUpdate:code];
    [self.tableView reloadData];
}

- (void)changeAppsExternalMap
{
    NSArray<dbExternalMap *> *maps = [dbExternalMap dbAll];
    __block NSInteger initial = 0;
    [maps enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull map, NSUInteger idx, BOOL * _Nonnull stop) {
        if (map.geocube_id == configManager.mapExternal) {
            initial = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_APPS_EXTERNALMAP inSection:SECTION_APPS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select External Maps")
                                            rows:externalMapTypes
                                initialSelection:initial
                                          target:self
                                   successAction:@selector(updateAppsExternalMap:element:)
                                    cancelAction:@selector(updateCancel:)
                                          origin:cell.contentView
     ];
}

- (void)updateAppsExternalMap:(NSNumber *)selectedIndex element:(id)element
{
    NSArray<dbExternalMap *> *maps = [dbExternalMap dbAll];
    dbExternalMap *map = [maps objectAtIndex:[selectedIndex integerValue]];
    [configManager mapExternalUpdate:map.geocube_id];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeAccuracy:(NSInteger)field
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:field inSection:SECTION_ACCURACY]];

    NSInteger initial = LMACCURACY_1000M;
    switch (field) {
        case SECTION_ACCURACY_STATIC_NONNAVIGATING:
            initial = configManager.accuracyStaticAccuracyNonNavigating;
            break;
        case SECTION_ACCURACY_STATIC_NAVIGATING:
            initial = configManager.accuracyStaticAccuracyNavigating;
            break;
        case SECTION_ACCURACY_DYNAMIC_NEAR:
            initial = configManager.accuracyDynamicAccuracyNear;
            break;
        case SECTION_ACCURACY_DYNAMIC_MIDRANGE:
            initial = configManager.accuracyDynamicAccuracyMidrange;
            break;
        case SECTION_ACCURACY_DYNAMIC_FAR:
            initial = configManager.accuracyDynamicAccuracyFar;
            break;
        default:
            abort();
    }

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select accuracy")
                                            rows:accuracies
                                initialSelection:initial
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           switch (field) {
                                               case SECTION_ACCURACY_STATIC_NONNAVIGATING:
                                                   [configManager accuracyStaticAccuracyNonNavigatingUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_STATIC_NAVIGATING:
                                                    [configManager accuracyStaticAccuracyNavigatingUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_NEAR:
                                                    [configManager accuracyDynamicAccuracyNearUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_MIDRANGE:
                                                    [configManager accuracyDynamicAccuracyMidrangeUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_FAR:
                                                    [configManager accuracyDynamicAccuracyFarUpdate:selectedIndex];
                                                   break;
                                           }
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

/*******************************************************************/

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
