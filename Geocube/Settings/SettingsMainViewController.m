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

@interface SettingsMainViewController ()

@property (nonatomic, retain) NSArray<NSString *> *compassTypes;
@property (nonatomic, retain) NSArray<NSString *> *externalMapTypes;
@property (nonatomic, retain) NSArray<NSString *> *mapBrandsCodes;
@property (nonatomic, retain) NSArray<NSString *> *mapBrandsNames;

@property (nonatomic, retain) NSArray<NSString *> *orientationStrings;
@property (nonatomic, retain) NSArray<NSNumber *> *orientationValues;

@property (nonatomic, retain) NSMutableArray<NSNumber *> *speedsWalkingMetric;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *speedsCyclingMetric;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *speedsDrivingMetric;
@property (nonatomic, retain) NSMutableArray<NSString *> *speedsWalking;
@property (nonatomic, retain) NSMutableArray<NSString *> *speedsCycling;
@property (nonatomic, retain) NSMutableArray<NSString *> *speedsDriving;

@property (nonatomic, retain) NSMutableArray<NSNumber *> *distancesWalkingMetric;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *distancesCyclingMetric;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *distancesDrivingMetric;
@property (nonatomic, retain) NSMutableArray<NSString *> *distancesWalking;
@property (nonatomic, retain) NSMutableArray<NSString *> *distancesCycling;
@property (nonatomic, retain) NSMutableArray<NSString *> *distancesDriving;

@property (nonatomic, retain) NSArray<NSString *> *accuracies;

@property (nonatomic        ) NSInteger mapcacheMaxAge;
@property (nonatomic        ) NSInteger mapcacheMaxSize;
@property (nonatomic, retain) NSArray<NSString *> *mapcacheMaxAgeValues;
@property (nonatomic, retain) NSArray<NSString *> *mapcacheMaxSizeValues;

@property (nonatomic, retain) NSMutableArray<NSString *> *downloadSimpleTimeouts;
@property (nonatomic, retain) NSMutableArray<NSString *> *downloadQueryTimeouts;

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
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLRIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSWITCH bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSWITCH];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuResetToDefault label:_(@"settingsmainviewcontroller-Reset to default")];

    self.compassTypes = @[
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
    self.mapBrandsCodes = codes;
    self.mapBrandsNames = names;

    self.orientationStrings = @[
        _(@"settingsmainviewcontroller-Portrait"),
        _(@"settingsmainviewcontroller-Portrait UpsideDown"),
        _(@"settingsmainviewcontroller-LandscapeLeft Portrait LandscapeRight"),
        _(@"settingsmainviewcontroller-LandscapeLeft Portrait UpsideDown LandscapeRight"),
        _(@"settingsmainviewcontroller-LandscapeRight"),
        _(@"settingsmainviewcontroller-LandscapeLeft"),
        _(@"settingsmainviewcontroller-LandscapeLeft LandscapeRight"),
        ];
    self.orientationValues = @[
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeRight],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeLeft],
        [NSNumber numberWithInteger:UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight],
        ];

    self.accuracies = @[
        _(@"settingsmainviewcontroller-Highest possible accuracy with additional sensor data"),
        _(@"settingsmainviewcontroller-Highest possible accuracy"),
        _(@"settingsmainviewcontroller-Accurate to ten meters"),
        _(@"settingsmainviewcontroller-Accurate to hundred meters"),
        _(@"settingsmainviewcontroller-Accurate to one kilometer"),
        _(@"settingsmainviewcontroller-Accurate to three kilometers"),
        ];

    self.downloadSimpleTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 30; i < 600; i += 30) {
        [self.downloadSimpleTimeouts addObject:[NSString stringWithFormat:@"%ld %@", (long)i, _(@"time-seconds")]];
    }
    self.downloadQueryTimeouts = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 60; i < 1200; i += 30) {
        [self.downloadQueryTimeouts addObject:[NSString stringWithFormat:@"%ld %@", (long)i, _(@"time-seconds")]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithCapacity:20];
    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull em, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:em.name];
    }];
    self.externalMapTypes = as;
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
    self.mapcacheMaxAgeValues = [NSArray arrayWithArray:as];

    as = [NSMutableArray arrayWithCapacity:20];
    for (NSInteger i = 0; i < 40; i++) {
        [as addObject:[NSString stringWithFormat:@"%ld Mb", (long)i * 25]];
    }
    self.mapcacheMaxSizeValues = [NSArray arrayWithArray:as];
}

- (void)calculateDynamicmapSpeedsDistances
{
    self.speedsWalking = [NSMutableArray arrayWithCapacity:20];
    self.speedsCycling = [NSMutableArray arrayWithCapacity:20];
    self.speedsDriving = [NSMutableArray arrayWithCapacity:20];
    self.speedsWalkingMetric = [NSMutableArray arrayWithCapacity:20];
    self.speedsCyclingMetric = [NSMutableArray arrayWithCapacity:20];
    self.speedsDrivingMetric = [NSMutableArray arrayWithCapacity:20];

    self.distancesWalking = [NSMutableArray arrayWithCapacity:20];
    self.distancesCycling = [NSMutableArray arrayWithCapacity:20];
    self.distancesDriving = [NSMutableArray arrayWithCapacity:20];
    self.distancesWalkingMetric = [NSMutableArray arrayWithCapacity:20];
    self.distancesCyclingMetric = [NSMutableArray arrayWithCapacity:20];
    self.distancesDrivingMetric = [NSMutableArray arrayWithCapacity:20];

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
        [self.speedsWalking addObject:[MyTools niceSpeed:i]];
        [self.speedsWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_CYCLING_MIN; i <= SPEED_CYCLING_MAX; i += SPEED_CYCLING_INC) {
        [self.speedsCycling addObject:[MyTools niceSpeed:i]];
        [self.speedsCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = SPEED_DRIVING_MIN; i <= SPEED_DRIVING_MAX; i += SPEED_DRIVING_INC) {
        [self.speedsDriving addObject:[MyTools niceSpeed:i]];
        [self.speedsDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }

    for (NSInteger i = DISTANCE_WALKING_MIN; i <= DISTANCE_WALKING_MAX; i += DISTANCE_WALKING_INC) {
        [self.distancesWalking addObject:[MyTools niceDistance:i]];
        [self.distancesWalkingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_CYCLING_MIN; i <= DISTANCE_CYCLING_MAX; i += DISTANCE_CYCLING_INC) {
        [self.distancesCycling addObject:[MyTools niceDistance:i]];
        [self.distancesCyclingMetric addObject:[NSNumber numberWithInteger:i]];
    }
    for (NSInteger i = DISTANCE_DRIVING_MIN; i <= DISTANCE_DRIVING_MAX; i += DISTANCE_DRIVING_INC) {
        [self.distancesDriving addObject:[MyTools niceDistance:i]];
        [self.distancesDrivingMetric addObject:[NSNumber numberWithInteger:i]];
    }
}

- (void)reloadMessage
{
    [MyTools messageBox:self header:_(@"settingsmainviewcontroller-Restart required") text:_(@"settingsmainviewcontroller-When you are finished with these settings, please leave Geocube, swipe it up and restart it.")];
}

#pragma mark - TableViewController related functions

enum sections {
    SECTION_DISTANCE = 0,
    SECTION_IMPORTS,
    SECTION_THEME,
    SECTION_SOUNDS,
    SECTION_COMPASS,
    SECTION_COORDINATES,
    SECTION_MAPCOLOURS,
    SECTION_MAPS,
    SECTION_MAPSEARCH,
    SECTION_ACCURACY,
    SECTION_MAPCACHE,
    SECTION_DYNAMICMAP,
    SECTION_KEEPTRACK,
    SECTION_MARKAS,
    SECTION_WAYPOINTS,
    SECTION_LISTS,
    SECTION_ACCOUNTS,
    SECTION_LOCATIONLESS,
    SECTION_SPEED,
    SECTION_BACKUPS,
    SECTION_MAX,

    SECTION_DISTANCE_METRIC = 0,
    SECTION_DISTANCE_MAX,

    SECTION_THEME_THEME = 0,
    SECTION_THEME_COMPASS,
    SECTION_THEME_ORIENTATIONS,
    SECTION_THEME_FONTS_SIZE_SMALLTEXT,
    SECTION_THEME_FONTS_SIZE_NORMALTEXT,
    SECTION_THEME_MAX,

    SECTION_SOUNDS_DIRECTION = 0,
    SECTION_SOUNDS_DISTANCE,
    SECTION_SOUNDS_MAX,

    SECTION_COMPASS_ALWAYSPORTRAIT = 0,
    SECTION_COMPASS_MAX,

    SECTION_COORDINATES_TYPE_SHOW = 0,
    SECTION_COORDINATES_TYPE_EDIT,
    SECTION_COORDINATES_DECIMALS_DEGREESMINUTESDECIMALSECONDS,
    SECTION_COORDINATES_DECIMALS_DEGREESDECIMALMINUTES,
    SECTION_COORDINATES_DECIMALS_DECIMALDEGREES,
    SECTION_COORDINATES_MAX,

    SECTION_MAPS_DEFAULTBRAND = 0,
    SECTION_MAPS_MAPBOXKEY,
    SECTION_MAPS_EXTERNALMAP,
    SECTION_MAPS_MAX,

    SECTION_MAPCOLOURS_TRACK = 0,
    SECTION_MAPCOLOURS_DESTINATION,
    SECTION_MAPCOLOURS_CIRCLERING,
    SECTION_MAPCOLOURS_CIRCLEFILL,
    SECTION_MAPCOLOURS_MAX,

    SECTION_MAPCACHE_ENABLED = 0,
    SECTION_MAPCACHE_MAXAGE,
    SECTION_MAPCACHE_MAXSIZE,
    SECTION_MAPCACHE_MAX,

    SECTION_DYNAMICMAP_ENABLED = 0,
    SECTION_DYNAMICMAP_SPEED_WALKING,
    SECTION_DYNAMICMAP_SPEED_CYCLING,
    SECTION_DYNAMICMAP_SPEED_DRIVING,
    SECTION_DYNAMICMAP_DISTANCE_WALKING,
    SECTION_DYNAMICMAP_DISTANCE_CYCLING,
    SECTION_DYNAMICMAP_DISTANCE_DRIVING,
    SECTION_DYNAMICMAP_MAX,

    SECTION_KEEPTRACK_ENABLE = 0,
    SECTION_KEEPTRACK_MEMORYONLY,
    SECTION_KEEPTRACK_AUTOROTATE,
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
    SECTION_LOG_GGCWOFFERFAVOURITE,
    SECTION_MARKAS_MAX,

    SECTION_WAYPOINTS_SORTBY = 0,
    SECTION_WAYPOINTS_SHOWCOUNTRYASABBREVATION,
    SECTION_WAYPOINTS_SHOWSTATEASABBREVATION,
    SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALITY,
    SECTION_WAYPOINTS_REFRESHAFTERLOG,
    SECTION_WAYPOINTS_OPENCAGEENABLE,
    SECTION_WAYPOINTS_OPENCAGEOVERWIFIONLY,
    SECTION_WAYPOINTS_OPENCAGEKEY,
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
    SECTION_ACCURACY_DYNAMIC_ACCURACY_NEAR,
    SECTION_ACCURACY_DYNAMIC_ACCURACY_MIDRANGE,
    SECTION_ACCURACY_DYNAMIC_ACCURACY_FAR,
    SECTION_ACCURACY_DYNAMIC_DELTAD_NEAR,
    SECTION_ACCURACY_DYNAMIC_DELTAD_MIDRANGE,
    SECTION_ACCURACY_DYNAMIC_DELTAD_FAR,
    SECTION_ACCURACY_DYNAMIC_DISTANCE_NEARTOMIDRANGE,
    SECTION_ACCURACY_DYNAMIC_DISTANCE_MIDRANGETOFAR,
    SECTION_ACCURACY_STATIC_ACCURACY_NAVIGATING,
    SECTION_ACCURACY_STATIC_ACCURACY_NONNAVIGATING,
    SECTION_ACCURACY_STATIC_DELTAD_NAVIGATING,
    SECTION_ACCURACY_STATIC_DELTAD_NONNAVIGATING,
    SECTION_ACCURACY_MAX,

    SECTION_SPEED_ENABLE = 0,
    SECTION_SPEED_SAMPLES,
    SECTION_SPEED_MINIMUM,
    SECTION_SPEED_MAX,

    SECTION_MAPSEARCH_GGCW_MAXIMUMLOADED = 0,
    SECTION_MAPSEARCH_GGCW_NUMBERTHREADS,
    SECTION_MAPSEARCH_MAX,
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
        SECTION_MAX(THEME);
        SECTION_MAX(SOUNDS);
        SECTION_MAX(COMPASS);
        SECTION_MAX(COORDINATES);
        SECTION_MAX(MAPS);
        SECTION_MAX(DYNAMICMAP);
        SECTION_MAX(SPEED);
        SECTION_MAX(MAPCOLOURS);
        SECTION_MAX(KEEPTRACK);
        SECTION_MAX(MAPCACHE);
        SECTION_MAX(IMPORTS);
        SECTION_MAX(MARKAS);
        SECTION_MAX(WAYPOINTS);
        SECTION_MAX(LISTS);
        SECTION_MAX(ACCOUNTS);
        SECTION_MAX(LOCATIONLESS);
        SECTION_MAX(BACKUPS);
        SECTION_MAX(ACCURACY);
        SECTION_MAX(MAPSEARCH);
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
        case SECTION_THEME:
            return _(@"settingsmainviewcontroller-Theme");
        case SECTION_SOUNDS:
            return _(@"settingsmainviewcontroller-Sounds");
        case SECTION_COMPASS:
            return _(@"settingsmainviewcontroller-Compass");
        case SECTION_COORDINATES:
            return _(@"settingsmainviewcontroller-Coordinates");
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
        case SECTION_SPEED:
            return _(@"settingsmainviewcontroller-Speed");
        case SECTION_MAPSEARCH:
            return _(@"settingsmainviewcontroller-Map search");
        default:
            NSAssert1(0, @"Unknown section %ld", (long)section);
    }

    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define CELL_SWITCH(__text__, __configfield__, __selector__) { \
    GCTableViewCellSwitch *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSWITCH forIndexPath:indexPath]; \
    cell.textLabel.text = __text__; \
    cell.optionSwitch.on = configManager.__configfield__; \
    [cell.optionSwitch removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside]; \
    [cell.optionSwitch addTarget:self action:@selector(__selector__:) forControlEvents:UIControlEventTouchUpInside]; \
    return cell; \
}

#define CELL_SUBTITLE(__text__, __detail__) { \
    GCTableViewCellWithSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath]; \
    cell.textLabel.text = __text__; \
    cell.detailTextLabel.text = __detail__; \
    return cell; \
    }

#define CELL_RIGHTIMAGE(__text__, __image__) { \
    GCTableViewCellRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGE forIndexPath:indexPath]; \
    cell.textLabel.text = __text__; \
    cell.imageView.image = __image__; \
    return cell; \
    }

    switch (indexPath.section) {
        case SECTION_DISTANCE: {   // Distance
            switch (indexPath.row) {
                case SECTION_DISTANCE_METRIC:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Use metric units"), distanceMetric, updateDistanceMetric)
            }
            abort();
        }

        case SECTION_THEME: {   // Theme
            switch (indexPath.row) {
                case SECTION_THEME_THEME:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Theme"), [[themeManager themeNames] objectAtIndex:configManager.themeType]);
                case SECTION_THEME_COMPASS:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Compass type"), [self.compassTypes objectAtIndex:configManager.compassType]);
                case SECTION_THEME_ORIENTATIONS: {
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
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Orientations allowed"), s);
                }
                case SECTION_THEME_FONTS_SIZE_SMALLTEXT: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.fontSmallTextSize, _(@"pixels")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Small text font size"), s)
                }
                case SECTION_THEME_FONTS_SIZE_NORMALTEXT: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.fontNormalTextSize, _(@"pixels")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Normal text font size"), s)
                }
            }
            abort();
        }

        case SECTION_SOUNDS: {   // Sounds
            switch (indexPath.row) {
                case SECTION_SOUNDS_DIRECTION:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable sounds for direction"), soundDirection, updateSoundDirection)
                case SECTION_SOUNDS_DISTANCE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable sounds for distance"), soundDistance, updateSoundDistance)
            }
            abort();
        }

        case SECTION_MAPCOLOURS: {
            switch (indexPath.row) {
                case SECTION_MAPCOLOURS_DESTINATION:
                    CELL_RIGHTIMAGE(_(@"settingsmainviewcontroller-Destination line"), [ImageManager circleWithColour:configManager.mapDestinationColour])
                case SECTION_MAPCOLOURS_TRACK:
                    CELL_RIGHTIMAGE(_(@"settingsmainviewcontroller-Track line"), [ImageManager circleWithColour:configManager.mapTrackColour])
                case SECTION_MAPCOLOURS_CIRCLERING:
                    CELL_RIGHTIMAGE(_(@"settingsmainviewcontroller-Boundary circle ring"), [ImageManager circleWithColour:configManager.mapCircleRingColour])
                case SECTION_MAPCOLOURS_CIRCLEFILL:
                    CELL_RIGHTIMAGE(_(@"settingsmainviewcontroller-Boundary circle fill"), [ImageManager circleWithColour:configManager.mapCircleFillColour])
            }
            abort();
        }

        case SECTION_MAPS: {   // Maps
            switch (indexPath.row) {
                case SECTION_MAPS_DEFAULTBRAND: {
                    __block NSString *value = nil;
                    [self.mapBrandsCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull k, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([k isEqualToString:configManager.mapBrandDefault] == YES) {
                            value = [self.mapBrandsNames objectAtIndex:idx];
                            *stop = YES;
                            return;
                        }
                    }];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Default map"), value);
                }
                case SECTION_MAPS_MAPBOXKEY:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Mapbox key"), configManager.mapboxKey);

                case SECTION_MAPS_EXTERNALMAP: {
                    __block NSString *name = nil;
                    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull em, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (em.geocube_id == configManager.mapExternal) {
                            name = em.name;
                            *stop = YES;
                        }
                    }];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-External Maps"), name);
                }
            }
            abort();
        }

        case SECTION_MAPSEARCH: {
            switch (indexPath.row) {
                case SECTION_MAPSEARCH_GGCW_MAXIMUMLOADED: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-%ld waypoints"), (long)configManager.mapsearchGGCWMaximumNumber];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Geocaching.com website: Maximum number of waypoints returned by 'load waypoints'"), s);
                }
                case SECTION_MAPSEARCH_GGCW_NUMBERTHREADS: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-%ld threads"), (long)configManager.mapsearchGGCWNumberThreads];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Geocaching.com website: Maximum number of simultanuous downloads"), s)
                }
            }
            abort();
        }

        case SECTION_DYNAMICMAP: {
            switch (indexPath.row) {
                case SECTION_DYNAMICMAP_ENABLED:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable dynamic maps"), dynamicmapEnable, updateDynamicmapEnable)
                case SECTION_DYNAMICMAP_SPEED_WALKING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Maximum walking speed"), [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed])
                case SECTION_DYNAMICMAP_SPEED_CYCLING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Maximum cycling speed"), [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed])
                case SECTION_DYNAMICMAP_SPEED_DRIVING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Maximum driving speed"), [MyTools niceSpeed:configManager.dynamicmapDrivingSpeed])
                case SECTION_DYNAMICMAP_DISTANCE_WALKING: {
                    NSString *s = [NSString stringWithFormat:@"%@ %@", _(@"settingsmainviewcontroller-Always"), [MyTools niceDistance:configManager.dynamicmapWalkingDistance]];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Walking zoom-out distance"), s);
                }
                case SECTION_DYNAMICMAP_DISTANCE_CYCLING: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Between %@ and %@"), [MyTools niceDistance:configManager.dynamicmapWalkingDistance], [MyTools niceDistance:configManager.dynamicmapCyclingDistance]];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Cycling zoom-out distance"), s)
                }
                case SECTION_DYNAMICMAP_DISTANCE_DRIVING: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Between %@ and %@"), [MyTools niceDistance:configManager.dynamicmapCyclingDistance], [MyTools niceDistance:configManager.dynamicmapDrivingDistance]];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Driving zoom-out distance"), s)
                }
            }
            abort();
        }

        case SECTION_KEEPTRACK: {
            switch (indexPath.row) {
                case SECTION_KEEPTRACK_ENABLE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable keeping track"), keeptrackEnable, updateKeeptrackEnable)
                case SECTION_KEEPTRACK_MEMORYONLY:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Keep tracks in memory only"), keeptrackMemoryOnly, updateKeeptrackMemoryOnly)
                case SECTION_KEEPTRACK_AUTOROTATE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Autorotate every day"), keeptrackAutoRotate, updateKeeptrackAutoRotate)
                case SECTION_KEEPTRACK_TIMEDELTA_MIN: {
                    NSString *s = [NSString stringWithFormat:@"%0.1f %@", configManager.keeptrackTimeDeltaMin, _(@"time-seconds")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Time difference for a new track point"), s)
                }
                case SECTION_KEEPTRACK_TIMEDELTA_MAX: {
                    NSString *s = [NSString stringWithFormat:@"%0.1f %@", configManager.keeptrackTimeDeltaMax, _(@"time-seconds")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Time difference for a new track"), s)
                }
                case SECTION_KEEPTRACK_DISTANCEDELTA_MIN:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Distance difference for a new track point"), [MyTools niceDistance:configManager.keeptrackDistanceDeltaMin]);
                case SECTION_KEEPTRACK_DISTANCEDELTA_MAX:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Distance difference for a new track"), [MyTools niceDistance:configManager.keeptrackDistanceDeltaMax])
                case SECTION_KEEPTRACK_PURGEAGE: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.keeptrackPurgeAge, _(@"time-days")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Autopurge age for old tracks"), s)
                }
                case SECTION_KEEPTRACK_SYNC: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Every %ld seconds"), (long)configManager.keeptrackSync];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Sync track data"), s)
                }
            }
            abort();
        }

        case SECTION_MAPCACHE: {
            switch (indexPath.row) {
                case SECTION_MAPCACHE_ENABLED:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable map cache"), mapcacheEnable, updateMapcacheEnable)
                case SECTION_MAPCACHE_MAXAGE: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.mapcacheMaxAge, _(@"time-days")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Maximum age for objects in cache"), s)
                }
                case SECTION_MAPCACHE_MAXSIZE: {
                    NSString *s = [NSString stringWithFormat:@"%ld Mb", (long)configManager.mapcacheMaxSize];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Maximum size for the cache"), s)
                }
            }
            abort();
        }

        case SECTION_IMPORTS: {
            switch (indexPath.row) {
                case SECTION_IMPORTS_TIMEOUT_SIMPLE: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.downloadTimeoutSimple, _(@"time-seconds")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Timeout for simple HTTP requests"), s);
                }
                case SECTION_IMPORTS_TIMEOUT_QUERY: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.downloadTimeoutQuery, _(@"time-seconds")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Timeout for big HTTP requests"), s);
                }
                case SECTION_IMPORTS_IMAGES_WAYPOINT:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Download waypoint images"), downloadImagesWaypoints, updateDownloadImagesWaypoints)
                case SECTION_IMPORTS_IMAGES_LOGS:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Download log images"), downloadImagesLogs, updateDownloadImagesLogs)
                case SECTION_IMPORTS_LOG_IMAGES_MOBILE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Download logged images over mobile data"), downloadImagesMobile, updateDownloadImagesMobile)
                case SECTION_IMPORTS_QUERIES_MOBILE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Download batch queries over mobile data"), downloadQueriesMobile, updateDownloadQueriesMobile)
            }
            abort();
        }

        case SECTION_MARKAS: {
            switch (indexPath.row) {
                case SECTION_MARKAS_FOUNDDNFCLEARSTARGET:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Remove target when marking as found/DNF"), markasFoundDNFClearsTarget, updateMarkasFoundDNFClearsTarget)
                case SECTION_MARKAS_FOUNDMARKSALLWAYPOINTS:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Mark all related waypoints when marked as found"), markasFoundMarksAllWaypoints, updateMarkasFoundMarksAllWaypoints)
                case SECTION_LOG_REMOVEMARKASFOUNDDNF:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Remove Marked as Found/DNF when logging"), loggingRemovesMarkedAsFoundDNF, updateLoggingRemovesMarkedAsFoundDNF)
                case SECTION_LOG_GGCWOFFERFAVOURITE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Offer favourites for LiveAPI / GGCW logging"), loggingGGCWOfferFavourites, updateLoggingGGCWOfferFavourites)
            }
            abort();
        }

        case SECTION_COMPASS: {
            switch (indexPath.row) {
                case SECTION_COMPASS_ALWAYSPORTRAIT:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Compass is always in portrait mode"), compassAlwaysInPortraitMode, updateCompassAlwaysInPortraitMode)
            }
            abort();
        }

        case SECTION_COORDINATES: {
            switch (indexPath.row) {
                case SECTION_COORDINATES_TYPE_SHOW:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Coordinate type for showing"), [[Coordinates coordinateTypes] objectAtIndex:configManager.coordinatesTypeShow])
                case SECTION_COORDINATES_TYPE_EDIT:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Coordinate type for editing"), [[Coordinates coordinateTypes] objectAtIndex:configManager.coordinatesTypeEdit])
                case SECTION_COORDINATES_DECIMALS_DECIMALDEGREES: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.coordinatesDecimalsDegrees, _(@"misc-decimals")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Number of decimals in decimal degrees"), s);
                }
                case SECTION_COORDINATES_DECIMALS_DEGREESDECIMALMINUTES: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.coordinatesDecimalsMinutes, _(@"misc-decimals")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Number of decimals in decimal minutes"), s);
                }
                case SECTION_COORDINATES_DECIMALS_DEGREESMINUTESDECIMALSECONDS: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.coordinatesDecimalsSeconds, _(@"misc-decimals")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Number of decimals in decimal seconds"), s);
                }
            }
            abort();
        }

        case SECTION_WAYPOINTS: {
            switch (indexPath.row) {
                case SECTION_WAYPOINTS_SORTBY: {
                    NSArray<NSString *> *order = [WaypointSorter waypointsSortOrders];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Sort waypoints default by..."), [order objectAtIndex:configManager.waypointListSortBy])
                }
                case SECTION_WAYPOINTS_REFRESHAFTERLOG:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Refresh after log"), refreshWaypointAfterLog, updateRefreshWaypointAfterLog)
                case SECTION_WAYPOINTS_SHOWCOUNTRYASABBREVATION:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Show country as abbrevation"), showCountryAsAbbrevation, updateShowCountryAsAbbrevation)
                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATION:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Show state as abbrevation"), showStateAsAbbrevation, updateShowStateAsAbbrevation)
                case SECTION_WAYPOINTS_SHOWSTATEASABBREVATIONWITHLOCALITY:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Show state as abbrevation if locality exist"), showStateAsAbbrevationIfLocalityExists, updateShowStateAsAbbrevationWithLocality)
                case SECTION_WAYPOINTS_OPENCAGEENABLE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable OpenCage"), opencageEnable, updateOpenCageEnable);
                case SECTION_WAYPOINTS_OPENCAGEKEY:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-OpenCage key"), configManager.opencageKey);
                case SECTION_WAYPOINTS_OPENCAGEOVERWIFIONLY:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-OpenCage only over Wifi"), opencageWifiOnly, updateOpenCageWifiOnly)
            }
            abort();
        }

        case SECTION_LISTS: {
            switch (indexPath.row) {
                case SECTION_LISTS_SORTBY: {
                    NSArray<NSString *> *order = [WaypointSorter listSortOrders];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Sort lists default by..."), [order objectAtIndex:configManager.listSortBy])
                }
            }
            abort();
        }

        case SECTION_ACCOUNTS: {
            switch (indexPath.row) {
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPUSERNAME:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Save authentication username"), accountsSaveAuthenticationName, updateAccountKeepUsername)
                case SECTION_ACCOUNTS_AUTHENTICATEKEEPPASSWORD:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Save authentication password"), accountsSaveAuthenticationPassword, updateAccountKeepPassword)
            }
            abort();
        }

        case SECTION_LOCATIONLESS: {
            switch (indexPath.row) {
                case SECTION_LOCATIONLESS_SHOWFOUND:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Show found in list"), locationlessShowFound, updateLocationlessShowFound)
                case SECTION_LOCATIONLESS_SORTBY: {
                    NSArray<NSString *> *order = [WaypointSorter locationlessSortOrders];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Sort by"), [order objectAtIndex:configManager.locationlessListSortBy])
                }
            }
            abort();
        }

        case SECTION_BACKUPS: {
            switch (indexPath.row) {
                case SECTION_BACKUPS_ENABLED:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable backups"), automaticDatabaseBackup, updateBackupsEnable)
                case SECTION_BACKUPS_INTERVAL: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.automaticDatabaseBackupPeriod, _(@"time-days")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Make a new backup every"), s)
                }
                case SECTION_BACKUPS_ROTATION: {
                    NSString *s = [NSString stringWithFormat:@"%ld %@", (long)configManager.automaticDatabaseBackupRotate, _(@"settingsmainviewcontroller-backups")];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Number of backups to be kept"), s)
                }
            }
            abort();
        }

        case SECTION_ACCURACY: {
            switch (indexPath.row) {
                case SECTION_ACCURACY_DYNAMIC_ENABLE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable dynamic accuracy"), accuracyDynamicEnable, updateDynamicAccuracyEnable)
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_NEAR:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Accuracy for 'near' accuracy"), [self.accuracies objectAtIndex:configManager.accuracyDynamicAccuracyNear])
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_MIDRANGE:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Accuracy for 'midrange' accuracy"), [self.accuracies objectAtIndex:configManager.accuracyDynamicAccuracyMidrange])
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_FAR:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Accuracy for 'far' accuracy"), [self.accuracies objectAtIndex:configManager.accuracyDynamicAccuracyFar])
                case SECTION_ACCURACY_DYNAMIC_DISTANCE_NEARTOMIDRANGE: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Up to %@"), [MyTools niceDistance:configManager.accuracyDynamicDistanceNearToMidrange]];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Distance for 'near' accuracy"), s)
                }
                case SECTION_ACCURACY_DYNAMIC_DISTANCE_MIDRANGETOFAR: {
                    NSString *s = [NSString stringWithFormat:_(@"settingsmainviewcontroller-Up to %@"), [MyTools niceDistance:configManager.accuracyDynamicDistanceMidrangeToFar]];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Distance for 'midrange' accuracy"), s)
                }
                case SECTION_ACCURACY_STATIC_ACCURACY_NAVIGATING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Accuracy for static 'navigating' accuracy"), [self.accuracies objectAtIndex:configManager.accuracyStaticAccuracyNavigating])
                case SECTION_ACCURACY_STATIC_ACCURACY_NONNAVIGATING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Accuracy for static 'non-navigating' accuracy"), [self.accuracies objectAtIndex:configManager.accuracyStaticAccuracyNonNavigating])
                case SECTION_ACCURACY_STATIC_DELTAD_NONNAVIGATING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Update distance for static 'non-navigating' pages"), [MyTools niceDistance:configManager.accuracyStaticDeltaDNonNavigating])
                case SECTION_ACCURACY_STATIC_DELTAD_NAVIGATING:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Update distance for static 'navigating' pages"), [MyTools niceDistance:configManager.accuracyStaticDeltaDNavigating])
                case SECTION_ACCURACY_DYNAMIC_DELTAD_NEAR:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Update distance for 'near' accuracy"), [MyTools niceDistance:configManager.accuracyDynamicDeltaDNear])
                case SECTION_ACCURACY_DYNAMIC_DELTAD_MIDRANGE:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Update distance for 'midrange' accuracy"), [MyTools niceDistance:configManager.accuracyDynamicDeltaDMidrange])
                case SECTION_ACCURACY_DYNAMIC_DELTAD_FAR:
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Update distance for 'far' accuracy"), [MyTools niceDistance:configManager.accuracyDynamicDeltaDFar])
            }
            abort();
        }

        case SECTION_SPEED: {
            switch (indexPath.row) {
                case SECTION_SPEED_ENABLE:
                    CELL_SWITCH(_(@"settingsmainviewcontroller-Enable speed calculation"), speedEnable, updateSpeedEnable)
                case SECTION_SPEED_MINIMUM: {
                    NSString *t = [MyTools niceSpeed:configManager.speedMinimum isMetric:YES];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Minimum speed to show"), t);
                }
                case SECTION_SPEED_SAMPLES: {
                    NSString *t = [NSString stringWithFormat:_(@"settingsmainviewcontroller-%ld seconds"), configManager.speedSamples];
                    CELL_SUBTITLE(_(@"settingsmainviewcontroller-Speed sample time"), t);
                }
            }
            abort();
        }

    }

    // Not reached
    abort();
}

#define SWITCH_UPDATE(__func__, __field__) \
    - (void)__func__:(GCSwitch *)s \
    { \
        [configManager __field__ ## Update:s.on]; \
    }

SWITCH_UPDATE(updateAccountKeepUsername, accountsSaveAuthenticationName)
SWITCH_UPDATE(updateAccountKeepPassword, accountsSaveAuthenticationPassword)
SWITCH_UPDATE(updateMarkasFoundDNFClearsTarget, markasFoundDNFClearsTarget)
SWITCH_UPDATE(updateMarkasFoundMarksAllWaypoints, markasFoundMarksAllWaypoints)
SWITCH_UPDATE(updateLoggingRemovesMarkedAsFoundDNF, loggingRemovesMarkedAsFoundDNF)
SWITCH_UPDATE(updateCompassAlwaysInPortraitMode, compassAlwaysInPortraitMode)
SWITCH_UPDATE(updateDownloadImagesLogs, downloadImagesLogs)
SWITCH_UPDATE(updateDownloadImagesWaypoints, downloadImagesWaypoints)
SWITCH_UPDATE(updateDownloadImagesMobile, downloadImagesMobile)
SWITCH_UPDATE(updateDownloadQueriesMobile, downloadQueriesMobile)
SWITCH_UPDATE(updateMapcacheEnable, mapcacheEnable)
SWITCH_UPDATE(updateDynamicmapEnable, dynamicmapEnable)
SWITCH_UPDATE(updateOpenCageEnable, opencageEnable)
SWITCH_UPDATE(updateOpenCageWifiOnly, opencageWifiOnly)
SWITCH_UPDATE(updateSoundDistance, soundDistance)
SWITCH_UPDATE(updateKeeptrackAutoRotate, keeptrackAutoRotate)
SWITCH_UPDATE(updateKeeptrackEnable, keeptrackEnable)
SWITCH_UPDATE(updateKeeptrackMemoryOnly, keeptrackMemoryOnly)
SWITCH_UPDATE(updateBackupsEnable, automaticDatabaseBackup)
SWITCH_UPDATE(updateDynamicAccuracyEnable, accuracyDynamicEnable)
SWITCH_UPDATE(updateRefreshWaypointAfterLog, refreshWaypointAfterLog)
SWITCH_UPDATE(updateShowCountryAsAbbrevation, showCountryAsAbbrevation)
SWITCH_UPDATE(updateShowStateAsAbbrevation, showStateAsAbbrevation)
SWITCH_UPDATE(updateShowStateAsAbbrevationWithLocality, showStateAsAbbrevationIfLocalityExists)
SWITCH_UPDATE(updateLocationlessShowFound, locationlessShowFound)
SWITCH_UPDATE(updateSpeedEnable, speedEnable)
SWITCH_UPDATE(updateLoggingGGCWOfferFavourites, loggingGGCWOfferFavourites)

- (void)updateDistanceMetric:(GCSwitch *)s
{
    [configManager distanceMetricUpdate:s.on];
    [self calculateDynamicmapSpeedsDistances];
    [self.tableView reloadData];
}

- (void)updateSoundDirection:(GCSwitch *)s
{
    [audioFeedback togglePlay:s.on];
    [configManager soundDirectionUpdate:s.on];
}

/*************************************/

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
                case SECTION_THEME_FONTS_SIZE_SMALLTEXT:
                    [self changeSmallTextFontSize];
                    break;
                case SECTION_THEME_FONTS_SIZE_NORMALTEXT:
                    [self changeNormalTextFontSize];
                    break;
            }
            break;
        case SECTION_MAPS:
            switch (indexPath.row) {
                case SECTION_MAPS_DEFAULTBRAND:
                    [self changeMapsDefaultBrand];
                    break;
                case SECTION_MAPS_MAPBOXKEY:
                    [self changeMapboxKey];
                    break;
                case SECTION_MAPS_EXTERNALMAP:
                    [self changeAppsExternalMap];
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
        case SECTION_MAPSEARCH:
            switch (indexPath.row) {
                case SECTION_MAPSEARCH_GGCW_MAXIMUMLOADED:
                    [self changeMapSearchGGCWMaximumLoaded];
                    break;
                case SECTION_MAPSEARCH_GGCW_NUMBERTHREADS:
                    [self changeMapSearchGGCWNumberThreads];
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
                case SECTION_MAPCOLOURS_CIRCLERING: {
                    UIViewController *newController = [[SettingsMainColorPickerViewController alloc] init:SettingsMainColorPickerCircleRing];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    break;
                }
                case SECTION_MAPCOLOURS_CIRCLEFILL: {
                    UIViewController *newController = [[SettingsMainColorPickerViewController alloc] init:SettingsMainColorPickerCircleFill];
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
                case SECTION_WAYPOINTS_OPENCAGEKEY:
                    [self changeOpenCageKey];
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
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_NEAR:
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_MIDRANGE:
                case SECTION_ACCURACY_DYNAMIC_ACCURACY_FAR:
                case SECTION_ACCURACY_STATIC_ACCURACY_NAVIGATING:
                case SECTION_ACCURACY_STATIC_ACCURACY_NONNAVIGATING:
                    [self changeAccuracyAccuracy:indexPath.row];
                    break;
                case SECTION_ACCURACY_DYNAMIC_DELTAD_NEAR:
                case SECTION_ACCURACY_DYNAMIC_DELTAD_MIDRANGE:
                case SECTION_ACCURACY_DYNAMIC_DELTAD_FAR:
                case SECTION_ACCURACY_STATIC_DELTAD_NAVIGATING:
                case SECTION_ACCURACY_STATIC_DELTAD_NONNAVIGATING:
                    [self changeAccuracyDeltaD:indexPath.row];
                    break;
                case SECTION_ACCURACY_DYNAMIC_DISTANCE_NEARTOMIDRANGE:
                case SECTION_ACCURACY_DYNAMIC_DISTANCE_MIDRANGETOFAR:
                    [self changeAccuracyDistance:indexPath.row];
                    break;
            }
            break;

        case SECTION_SPEED:
            switch (indexPath.row) {
                case SECTION_SPEED_MINIMUM:
                    [self changeSpeedMinimum];
                    break;
                case SECTION_SPEED_SAMPLES:
                    [self changeSpeedSamples];
                    break;
            }
            break;

        case SECTION_COORDINATES:
            switch (indexPath.row) {
                case SECTION_COORDINATES_TYPE_SHOW:
                    [self changeCoordinatesTypeShow];
                    break;
                case SECTION_COORDINATES_TYPE_EDIT:
                    [self changeCoordinatesTypeEdit];
                    break;
                case SECTION_COORDINATES_DECIMALS_DECIMALDEGREES:
                    [self changeCoordinatesDecimalsDegrees];
                    break;
                case SECTION_COORDINATES_DECIMALS_DEGREESDECIMALMINUTES:
                    [self changeCoordinatesDecimalsinutes];
                    break;
                case SECTION_COORDINATES_DECIMALS_DEGREESMINUTESDECIMALSECONDS:
                    [self changeCoordinatesDecimalsSeconds];
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
            speeds = self.speedsWalking;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapWalkingSpeed];
            title = _(@"settingsmainviewcontroller-Maximum walking speed");
            successAction = @selector(updateDynamicmapSpeedWalking:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_CYCLING:
            speeds = self.speedsCycling;
            currentSpeed = [MyTools niceSpeed:configManager.dynamicmapCyclingSpeed];
            title = _(@"settingsmainviewcontroller-Maximum cycling speed");
            successAction = @selector(updateDynamicmapSpeedCycling:element:);
            break;
        case SECTION_DYNAMICMAP_SPEED_DRIVING:
            speeds = self.speedsDriving;
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
    [configManager dynamicmapWalkingSpeedUpdate:[[self.speedsWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedCycling:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapCyclingSpeedUpdate:[[self.speedsCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapSpeedDriving:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapDrivingSpeedUpdate:[[self.speedsDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
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
            distances = self.distancesWalking;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapWalkingDistance];
            title = _(@"settingsmainviewcontroller-Maximum walking distance");
            successAction = @selector(updateDynamicmapDistanceWalking:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_CYCLING:
            distances = self.distancesCycling;
            currentDistance = [MyTools niceDistance:configManager.dynamicmapCyclingDistance];
            title = _(@"settingsmainviewcontroller-Maximum cycling distance");
            successAction = @selector(updateDynamicmapDistanceCycling:element:);
            break;
        case SECTION_DYNAMICMAP_DISTANCE_DRIVING:
            distances = self.distancesDriving;
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
    [configManager dynamicmapWalkingDistanceUpdate:[[self.distancesWalkingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceCycling:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapCyclingDistanceUpdate:[[self.distancesCyclingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

- (void)updateDynamicmapDistanceDriving:(NSNumber *)selectedIndex element:(id)element
{
    [configManager dynamicmapDrivingDistanceUpdate:[[self.distancesDrivingMetric objectAtIndex:[selectedIndex integerValue]] integerValue]];
    [self.tableView reloadData];
}

/* ********************************************************************************* */

- (void)changeImportsQueryTimeout
{
    __block NSInteger currentChoice = 10;   // 600 seconds
    [self.downloadQueryTimeouts enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutQuery) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_IMPORTS_TIMEOUT_QUERY inSection:SECTION_IMPORTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Timeout value for big HTTP requests")
                                            rows:self.downloadQueryTimeouts
                                initialSelection:currentChoice
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager downloadTimeoutQueryUpdate:[[self.downloadQueryTimeouts objectAtIndex:selectedIndex] integerValue]];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeImportsSimpleTimeout
{
    __block NSInteger currentChoice = 4;   // 120 seconds
    [self.downloadSimpleTimeouts enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.downloadTimeoutSimple) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_IMPORTS_TIMEOUT_SIMPLE inSection:SECTION_IMPORTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Timeout value for simple HTTP requests")
                                            rows:self.downloadSimpleTimeouts
                                initialSelection:currentChoice
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager downloadTimeoutSimpleUpdate:[[self.downloadSimpleTimeouts objectAtIndex:selectedIndex] integerValue]];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

/* ********************************************************************************* */

- (void)changeMapCacheMaxAge
{
    __block NSInteger currentChoice = 14;   // 30 days
    [self.mapcacheMaxAgeValues enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxAge) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPCACHE_MAXAGE inSection:SECTION_MAPCACHE]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Maximum age for objects in the map cache")
                                            rows:self.mapcacheMaxAgeValues
                                initialSelection:currentChoice
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager mapcacheMaxAgeUpdate:[[self.mapcacheMaxAgeValues objectAtIndex:selectedIndex] integerValue]];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeMapCacheMaxSize
{    __block NSInteger currentChoice = 10;   // 250 Mb
    [self.mapcacheMaxSizeValues enumerateObjectsUsingBlock:^(NSString * _Nonnull s, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([s integerValue] == configManager.mapcacheMaxSize) {
            currentChoice = idx;
            *stop = YES;
        }
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPCACHE_MAXSIZE inSection:SECTION_MAPCACHE]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Maximum size for the map cache")
                                            rows:self.mapcacheMaxSizeValues
                                initialSelection:currentChoice
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager mapcacheMaxSizeUpdate:[[self.mapcacheMaxSizeValues objectAtIndex:selectedIndex] integerValue]];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
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
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager themeTypeUpdate:selectedIndex];
                                           [themeManager setTheme:selectedIndex];
                                           [self.tableView reloadData];
                                           [self reloadMessage];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeThemeCompass
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_THEME_COMPASS inSection:SECTION_THEME]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Compass")
                                            rows:self.compassTypes
                                initialSelection:configManager.compassType
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager compassTypeUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeThemeOrientations
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_THEME_ORIENTATIONS inSection:SECTION_THEME]];

    __block NSInteger orientationIndex = 0;
    [self.orientationValues enumerateObjectsUsingBlock:^(NSNumber * _Nonnull n, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([n integerValue] == configManager.orientationsAllowed) {
            orientationIndex = idx;
            *stop = YES;
        }
    }];
    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Orientations")
                                            rows:self.orientationStrings
                                initialSelection:orientationIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSInteger d = [[self.orientationValues objectAtIndex:selectedIndex] integerValue];
                                           [configManager orientationsAllowedUpdate:d];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

/* ********************************************************************************* */

- (void)changeWaypointSortBy
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_WAYPOINTS_SORTBY inSection:SECTION_WAYPOINTS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Sort waypoints by")
                                            rows:[WaypointSorter waypointsSortOrders]
                                initialSelection:configManager.waypointListSortBy
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager waypointListSortByUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
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

- (void)changeMapSearchGGCWMaximumLoaded
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Maximum waypoints")
                                message:_(@"settingsmainviewcontroller-Maximum number of waypoints to download, maximum of 50, for the Geocaching.com Website with 'Load Waypoints'.")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             if (i >=0 && i <= 50)
                                 [configManager mapsearchGGCWMaximumNumberUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.mapsearchGGCWMaximumNumber];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeMapSearchGGCWNumberThreads
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Maximum threads")
                                message:_(@"settingsmainviewcontroller-Maximum number of concurrent downloads for the Geocaching.com Website with 'Load Waypoints'.")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             if (i >=0)
                                 [configManager mapsearchGGCWNumberThreadsUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.mapsearchGGCWNumberThreads];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeSmallTextFontSize
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Small Text Font Size")
                                message:_(@"settingsmainviewcontroller-Size of font in pixels__Small: 10 pixels__Normal: 15 pixels")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             [configManager fontSmallTextSizeUpdate:i];
                             [self.tableView reloadData];
                             [self reloadMessage];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.fontSmallTextSize];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeNormalTextFontSize
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Normal Text Font Size")
                                message:_(@"settingsmainviewcontroller-Size of font in pixels__Small: 17 pixels__Normal: 24 pixels")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             [configManager fontNormalTextSizeUpdate:i];
                             [self.tableView reloadData];
                             [self reloadMessage];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.fontNormalTextSize];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeSpeedMinimum
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Speed")
                                message:_(@"settingsmainviewcontroller-Minimum speed to be displayed (in km/h)")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             [configManager speedMinimumUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.speedMinimum];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeSpeedSamples
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Speed")
                                message:_(@"settingsmainviewcontroller-Averaged over X seconds")
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
                                 [configManager speedSamplesUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.speedSamples];
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
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager listSortByUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

/* ********************************************************************************* */

- (void)changeCoordinatesTypeShow
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_COORDINATES_TYPE_SHOW inSection:SECTION_COORDINATES]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Coordinate type for showing")
                                            rows:[Coordinates coordinateTypes]
                                initialSelection:configManager.coordinatesTypeShow
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager coordinatesTypeShowUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeCoordinatesTypeEdit
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_COORDINATES_TYPE_EDIT inSection:SECTION_COORDINATES]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Coordinate type for editing")
                                            rows:[Coordinates coordinateTypes]
                                initialSelection:configManager.coordinatesTypeEdit
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager coordinatesTypeEditUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeCoordinatesDecimalsDegrees
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Decimals in coordinates")
                                message:_(@"settingsmainviewcontroller-Number of decimals in decimal degrees")
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
                                 [configManager coordinatesDecimalsDegreesUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.coordinatesDecimalsDegrees];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeCoordinatesDecimalsinutes
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Decimals in coordinates")
                                message:_(@"settingsmainviewcontroller-Number of decimals in decimal minutes")
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
                                 [configManager coordinatesDecimalsMinutesUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.coordinatesDecimalsMinutes];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeCoordinatesDecimalsSeconds
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Decimals in coordinates")
                                message:_(@"settingsmainviewcontroller-Number of decimals in decimal seconds")
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
                                 [configManager coordinatesDecimalsSecondsUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)configManager.coordinatesDecimalsSeconds];
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeLocationlessSortOrder
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_LOCATIONLESS_SORTBY inSection:SECTION_LOCATIONLESS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Sort locationless by")
                                            rows:[WaypointSorter locationlessSortOrders]
                                initialSelection:configManager.locationlessListSortBy
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [configManager locationlessListSortByUpdate:selectedIndex];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

/* ********************************************************************************* */

- (void)changeMapsDefaultBrand
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPS_DEFAULTBRAND inSection:SECTION_MAPS]];

    __block NSInteger initial = 0;
    [self.mapBrandsCodes enumerateObjectsUsingBlock:^(NSString * _Nonnull k, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([k isEqualToString:configManager.mapBrandDefault] == YES) {
            initial = idx;
            *stop = YES;
        }
    }];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select Default Map")
                                            rows:self.mapBrandsNames
                                initialSelection:initial
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           NSString *code = [self.mapBrandsCodes objectAtIndex:selectedIndex];
                                           [configManager mapBrandDefaultUpdate:code];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
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

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SECTION_MAPS_EXTERNALMAP inSection:SECTION_MAPS]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select External Maps")
                                            rows:self.externalMapTypes
                                initialSelection:initial
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           dbExternalMap *map = [maps objectAtIndex:selectedIndex];
                                           [configManager mapExternalUpdate:map.geocube_id];
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeMapboxKey
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Mapbox key")
                                message:_(@"settingsmainviewcontroller-Enter your Mapbox key")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             [configManager mapboxKeyUpdate:value];
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
        textField.text = configManager.mapboxKey;
        textField.placeholder = _(@"settingsmainviewcontroller-Mapbox key");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

/* ********************************************************************************* */

- (void)changeAccuracyAccuracy:(NSInteger)field
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:field inSection:SECTION_ACCURACY]];

    NSInteger initial = LMACCURACY_1000M;
    switch (field) {
        case SECTION_ACCURACY_STATIC_ACCURACY_NONNAVIGATING:
            initial = configManager.accuracyStaticAccuracyNonNavigating;
            break;
        case SECTION_ACCURACY_STATIC_ACCURACY_NAVIGATING:
            initial = configManager.accuracyStaticAccuracyNavigating;
            break;
        case SECTION_ACCURACY_DYNAMIC_ACCURACY_NEAR:
            initial = configManager.accuracyDynamicAccuracyNear;
            break;
        case SECTION_ACCURACY_DYNAMIC_ACCURACY_MIDRANGE:
            initial = configManager.accuracyDynamicAccuracyMidrange;
            break;
        case SECTION_ACCURACY_DYNAMIC_ACCURACY_FAR:
            initial = configManager.accuracyDynamicAccuracyFar;
            break;
        default:
            abort();
    }

    [ActionSheetStringPicker showPickerWithTitle:_(@"settingsmainviewcontroller-Select accuracy")
                                            rows:self.accuracies
                                initialSelection:initial
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           switch (field) {
                                               case SECTION_ACCURACY_STATIC_ACCURACY_NONNAVIGATING:
                                                   [configManager accuracyStaticAccuracyNonNavigatingUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_STATIC_ACCURACY_NAVIGATING:
                                                    [configManager accuracyStaticAccuracyNavigatingUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_ACCURACY_NEAR:
                                                    [configManager accuracyDynamicAccuracyNearUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_ACCURACY_MIDRANGE:
                                                    [configManager accuracyDynamicAccuracyMidrangeUpdate:selectedIndex];
                                                   break;
                                               case SECTION_ACCURACY_DYNAMIC_ACCURACY_FAR:
                                                    [configManager accuracyDynamicAccuracyFarUpdate:selectedIndex];
                                                   break;
                                           }
                                           [self.tableView reloadData];
                                       }
                                     cancelBlock:nil
                                          origin:cell.contentView
     ];
}

- (void)changeAccuracyDistance:(NSInteger)field
{
    NSInteger value = 0;
    switch (field) {
        case SECTION_ACCURACY_DYNAMIC_DISTANCE_NEARTOMIDRANGE:
            value = configManager.accuracyDynamicDistanceNearToMidrange;
            break;
        case SECTION_ACCURACY_DYNAMIC_DISTANCE_MIDRANGETOFAR:
            value = configManager.accuracyDynamicDistanceMidrangeToFar;
            break;
        default:
            abort();
    }

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Select Distance")
                                message:_(@"settingsmainviewcontroller-Radius around the destination waypoint")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             if (i > 0) {
                                 switch (field) {
                                     case SECTION_ACCURACY_DYNAMIC_DISTANCE_NEARTOMIDRANGE:
                                         [configManager accuracyDynamicDistanceNearToMidrangeUpdate:i];
                                         break;
                                     case SECTION_ACCURACY_DYNAMIC_DISTANCE_MIDRANGETOFAR:
                                         [configManager accuracyDynamicDistanceMidrangeToFarUpdate:i];
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)value];
        textField.placeholder = _(@"settingsmainviewcontroller-Distance in meters");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)changeAccuracyDeltaD:(NSInteger)field
{
    NSInteger value = 0;
    switch (field) {
        case SECTION_ACCURACY_DYNAMIC_DELTAD_FAR:
            value = configManager.accuracyDynamicDeltaDFar;
            break;
        case SECTION_ACCURACY_DYNAMIC_DELTAD_NEAR:
            value = configManager.accuracyDynamicDeltaDNear;
            break;
        case SECTION_ACCURACY_DYNAMIC_DELTAD_MIDRANGE:
            value = configManager.accuracyDynamicDeltaDMidrange;
            break;
        case SECTION_ACCURACY_STATIC_DELTAD_NAVIGATING:
            value = configManager.accuracyStaticDeltaDNavigating;
            break;
        case SECTION_ACCURACY_STATIC_DELTAD_NONNAVIGATING:
            value = configManager.accuracyStaticDeltaDNonNavigating;
            break;
        default:
            abort();
    }

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsmainviewcontroller-Select Distance")
                                message:_(@"settingsmainviewcontroller-Distance update interval")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             NSInteger i = [value integerValue];
                             switch (field) {
                                 case SECTION_ACCURACY_DYNAMIC_DELTAD_NEAR:
                                     [configManager accuracyDynamicDeltaDNearUpdate:i];
                                     break;
                                 case SECTION_ACCURACY_DYNAMIC_DELTAD_MIDRANGE:
                                     [configManager accuracyDynamicDeltaDMidrangeUpdate:i];
                                     break;
                                 case SECTION_ACCURACY_DYNAMIC_DELTAD_FAR:
                                     [configManager accuracyDynamicDeltaDFarUpdate:i];
                                     break;
                                 case SECTION_ACCURACY_STATIC_DELTAD_NONNAVIGATING:
                                     [configManager accuracyStaticDeltaDNonNavigatingUpdate:i];
                                     break;
                                 case SECTION_ACCURACY_STATIC_DELTAD_NAVIGATING:
                                     [configManager accuracyStaticDeltaDNavigatingUpdate:i];
                                     break;
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
        textField.text = [NSString stringWithFormat:@"%ld", (long)value];
        textField.placeholder = _(@"settingsmainviewcontroller-Distance in meters");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
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
