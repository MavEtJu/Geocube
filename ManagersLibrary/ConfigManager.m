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

@interface ConfigManager ()

@end

@implementation ConfigManager

- (instancetype)init
{
    self = [super init];

    [self checkDefaults];
    [self loadValues];

    NSLog(@"%@ initialized", [self class]);

    return self;
}

- (void)checkDefaults
{
    dbConfig *c;

#define CHECK(__key__, __default__) \
    c = [dbConfig dbGetByKey:__key__]; \
    if (c == nil) \
[dbConfig dbUpdateOrInsert:__key__ value:__default__];

    NSString *defaultUsesMetric = @"1";
    if ([[NSLocale currentLocale] usesMetricSystem] == NO)
        // This locale doesn't default to metric system.
        defaultUsesMetric = @"0";
    CHECK(@"distance_metric", defaultUsesMetric)
    CHECK(@"waypoint_current", @"")
    CHECK(@"page_current", @"0")
    CHECK(@"pagetab_current", @"0")
    CHECK(@"track_current", @"0")
    CHECK(@"lastimport_group", @"0")
    CHECK(@"lastadded_group", @"0")
    CHECK(@"lastimport_source", @"0")

    CHECK(@"map_external", @"1")
    CHECK(@"map_tilebackend", @"0")
    CHECK(@"map_branddefault", @"apple")
    CHECK(@"map_track_colour", @"00F0F0")
    CHECK(@"map_destination_colour", @"FF0000")
    CHECK(@"map_circle_ring_colour", @"0000FF")
    CHECK(@"map_circle_ring_size", @"1")
    CHECK(@"map_circle_fill_colour", @"000013")
    CHECK(@"map_kml_fill_colour", @"0000FF")
    CHECK(@"map_kml_border_colour", @"FF0000")
    CHECK(@"map_kml_border_size", @"2")

    CHECK(@"compass_type", @"0")
    NSString *s = [NSString stringWithFormat:@"%ld", (long)THEME_STYLE_IOS_NORMALSIZE];
    CHECK(@"theme_style_type", s)
    s = [NSString stringWithFormat:@"%ld", (long)THEME_IMAGE_GEOCUBE];
    CHECK(@"theme_image_type", s)
    s = [NSString stringWithFormat:@"%ld", (long)(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight)];
    CHECK(@"orientations_allowed", s)

    CHECK(@"sound_direction", @"0")
    CHECK(@"sound_distance", @"0")

    CHECK(@"keeptrack_enable", @"1")
    CHECK(@"keeptrack_memoryonly", @"0")
    CHECK(@"keeptrack_autorotate", @"1")
    CHECK(@"keeptrack_timedelta_min", @"5.0")
    CHECK(@"keeptrack_timedelta_max", @"10.0")
    CHECK(@"keeptrack_distancedelta_min", @"100")
    CHECK(@"keeptrack_distancedelta_max", @"200")
    CHECK(@"keeptrack_purgeage", @"30")
    CHECK(@"keeptrack_sync", @"120")
    CHECK(@"keeptrack_beeper_interval", @"10")

    CHECK(@"dynamicmap_enable", @"1")
    CHECK(@"dynamicmap_speed_walking", @"7")
    CHECK(@"dynamicmap_speed_cycling", @"40")
    CHECK(@"dynamicmap_speed_driving", @"120")
    CHECK(@"dynamicmap_distance_walking", @"100")
    CHECK(@"dynamicmap_distance_cycling", @"1000")
    CHECK(@"dynamicmap_distance_driving", @"5000")

    CHECK(@"mapcache_enable", @"1")
    CHECK(@"mapcache_maxsize", @"250")
    CHECK(@"mapcache_maxage", @"30")

    CHECK(@"download_images_logs", @"0")
    CHECK(@"download_images_waypoints", @"1")
    CHECK(@"download_images_mobile", @"0")
    CHECK(@"download_queries_mobile", @"0")
    CHECK(@"download_timeout_query", @"600")
    CHECK(@"download_timeout_simple", @"120")

    CHECK(@"markas_founddnf_clearstarget", @"1")
    CHECK(@"markas_foundmarksallwaypoints", @"1")
    CHECK(@"logging_removesmarkedasfounddnf", @"1")
    CHECK(@"logging_ggcwofferfavourites", @"0")

    CHECK(@"compass_alwaysinportraitmode", @"1")
    CHECK(@"showasabbrevation_country", @"1")
    CHECK(@"showasabbrevation_state", @"0")
    CHECK(@"showasabbrevation_statewithlocale", @"1")

    CHECK(@"waypointlist_sortby", @"0")

    CHECK(@"waypoint_refreshafterlog", @"1")

    CHECK(@"list_sortby", @"0")

    CHECK(@"accounts_save_authenticationname", @"1")
    CHECK(@"accounts_save_authenticationpassword", @"0")

    CHECK(@"intro_seen", @"0")

    CHECK(@"log_temporary_text", @"")

    CHECK(@"locationless_showfound", @"1")
    CHECK(@"locationless_sortby", @"0")

    CHECK(@"opencage_enable", @"0")
    CHECK(@"opencage_key", @"")
    CHECK(@"opencage_wifionly", @"1")
    CHECK(@"mapbox_key", @"")
    CHECK(@"thunderforest_key", @"")

    CHECK(@"configupdate_lastversion", @"1.3")
    s = [NSString stringWithFormat:@"%ld", time(NULL)];
    CHECK(@"configupdate_lasttime", s)

    CHECK(@"automaticdatabasebackup_enable", @"0")
    CHECK(@"automaticdatabasebackup_last", @"0")
    CHECK(@"automaticdatabasebackup_period", @"7")
    CHECK(@"automaticdatabasebackup_rotate", @"5")

    CHECK(@"accuracy_dynamic_enable", @"1")
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_BEST];
    CHECK(@"accuracy_dynamic_accuracy_near", s)
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_10M];
    CHECK(@"accuracy_dynamic_accuracy_midrange", s)
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_100M];
    CHECK(@"accuracy_dynamic_accuracy_far", s)
    CHECK(@"accuracy_dynamic_deltad_near", @"0")
    CHECK(@"accuracy_dynamic_deltad_midrange", @"5")
    CHECK(@"accuracy_dynamic_deltad_far", @"10")
    CHECK(@"accuracy_dynamic_distance_neartomidrange", @"50")
    CHECK(@"accuracy_dynamic_distance_midrangetofar", @"250")
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_BEST];
    CHECK(@"accuracy_static_accuracy_navigating", s)
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_100M];
    CHECK(@"accuracy_static_accuracy_nonnavigating", s)
    CHECK(@"accuracy_static_deltad_navigating", @"0")
    CHECK(@"accuracy_static_deltad_nonnavigating", @"10")

    CHECK(@"speed_enable", @"1")
    CHECK(@"speed_samples", @"10")
    CHECK(@"speed_minimum", @"3")

    CHECK(@"mapsearch_ggcw_maximumnumber", @"50")
    CHECK(@"mapsearch_ggcw_numberthreads", @"10")

    CHECK(@"font_smalltext_size", @"15")
    CHECK(@"font_normaltext_size", @"24")

    CHECK(@"coordinates_show", @"0")
    CHECK(@"coordinates_edit", @"0")
    CHECK(@"coordinates_decimals_seconds", @"2")
    CHECK(@"coordinates_decimals_minutes", @"3")
    CHECK(@"coordinates_decimals_degrees", @"7")

    CHECK(@"service_showlocationless", @"1")
    CHECK(@"service_showtrackables", @"1")
    CHECK(@"service_showmoveables", @"1")
    CHECK(@"service_showdeveloper", @"0")

    CHECK(@"moveables_showfound", @"1")
    CHECK(@"moveables_listsortby", @"0")

    CHECK(@"myaccount_lastnumber", @"0")

    CHECK(@"owntracks_enable", @"0")
    CHECK(@"owntracks_url", @"https://geocube.mavetju.org/keeptrack/")
    CHECK(@"owntracks_username", @"")
    CHECK(@"owntracks_secret", @"")
    CHECK(@"owntracks_password", @"")
    CHECK(@"owntracks_interval", @"10")
    CHECK(@"owntracks_interval_failure", @"10")
    CHECK(@"owntracks_interval_offline", @"30")
    CHECK(@"owntracks_failure", @"10")
}

- (void)loadValues
{
#define LOAD_VALUE(__field__, __key__) \
    self.__field__ = [dbConfig dbGetByKey:__key__].value;
#define LOAD_BOOL(__field__, __key__) \
    self.__field__ = [[dbConfig dbGetByKey:__key__].value boolValue];
#define LOAD_INTEGER(__field__, __key__) \
    self.__field__ = [[dbConfig dbGetByKey:__key__].value integerValue];
#define LOAD_FLOAT(__field__, __key__) \
    self.__field__ = [[dbConfig dbGetByKey:__key__].value floatValue];
#define LOAD_DOUBLE(__field__, __key__) \
    self.__field__ = [[dbConfig dbGetByKey:__key__].value doubleValue];

    LOAD_BOOL   (self.distanceMetric, @"distance_metric");
    LOAD_VALUE  (self.currentWaypoint, @"waypoint_current");
    LOAD_INTEGER(self.currentPage, @"page_current");
    LOAD_INTEGER(self.currentPageTab, @"pagetab_current");
    LOAD_INTEGER(self.lastImportSource, @"lastimport_source");
    LOAD_INTEGER(self.lastImportGroup, @"lastimport_group");
    LOAD_INTEGER(self.lastAddedGroup, @"lastadded_group");
    LOAD_INTEGER(self.mapExternal, @"map_external");
    LOAD_INTEGER(self.mapTileBackend, @"map_tilebackend");
    LOAD_VALUE  (self.mapBrandDefault, @"map_branddefault");
    LOAD_INTEGER(self.compassType, @"compass_type");
    LOAD_INTEGER(self.themeStyleType, @"theme_style_type");
    LOAD_INTEGER(self.themeImageType, @"theme_image_type");
    LOAD_INTEGER(self.orientationsAllowed, @"orientations_allowed");
    LOAD_BOOL   (self.soundDirection, @"sound_direction");
    LOAD_BOOL   (self.soundDistance, @"sound_distance");
    LOAD_BOOL   (self.keeptrackEnable, @"keeptrack_enable");
    LOAD_BOOL   (self.keeptrackMemoryOnly, @"keeptrack_memoryonly");
    LOAD_BOOL   (self.keeptrackAutoRotate, @"keeptrack_autorotate");
    LOAD_FLOAT  (self.keeptrackTimeDeltaMin, @"keeptrack_timedelta_min");
    LOAD_FLOAT  (self.keeptrackTimeDeltaMax, @"keeptrack_timedelta_max");
    LOAD_FLOAT  (self.keeptrackDistanceDeltaMin, @"keeptrack_distancedelta_min");
    LOAD_FLOAT  (self.keeptrackDistanceDeltaMax, @"keeptrack_distancedelta_max");
    LOAD_INTEGER(self.keeptrackPurgeAge, @"keeptrack_purgeage");
    LOAD_INTEGER(self.keeptrackSync, @"keeptrack_sync");
    LOAD_INTEGER(self.keeptrackBeeperInterval, @"keeptrack_beeper_interval");
    LOAD_BOOL   (self.dynamicmapEnable, @"dynamicmap_enable");
    LOAD_FLOAT  (self.dynamicmapWalkingDistance, @"dynamicmap_distance_walking");
    LOAD_FLOAT  (self.dynamicmapCyclingDistance, @"dynamicmap_distance_cycling");
    LOAD_FLOAT  (self.dynamicmapDrivingDistance, @"dynamicmap_distance_driving");
    LOAD_INTEGER(self.dynamicmapWalkingSpeed, @"dynamicmap_speed_walking");
    LOAD_INTEGER(self.dynamicmapCyclingSpeed, @"dynamicmap_speed_cycling");
    LOAD_INTEGER(self.dynamicmapDrivingSpeed, @"dynamicmap_speed_driving");
    LOAD_BOOL   (self.mapcacheEnable, @"mapcache_enable");
    LOAD_INTEGER(self.mapcacheMaxAge, @"mapcache_maxage");
    LOAD_INTEGER(self.mapcacheMaxSize, @"mapcache_maxsize");
    LOAD_BOOL   (self.downloadImagesLogs, @"download_images_logs");
    LOAD_BOOL   (self.downloadImagesWaypoints, @"download_images_waypoints");
    LOAD_BOOL   (self.downloadImagesMobile, @"download_images_mobile");
    LOAD_BOOL   (self.downloadQueriesMobile, @"download_queries_mobile");
    LOAD_INTEGER(self.downloadTimeoutSimple, @"download_timeout_simple");
    LOAD_INTEGER(self.downloadTimeoutQuery, @"download_timeout_query");
    LOAD_BOOL   (self.markasFoundDNFClearsTarget, @"markas_founddnf_clearstarget");
    LOAD_BOOL   (self.markasFoundMarksAllWaypoints, @"markas_foundmarksallwaypoints");
    LOAD_BOOL   (self.loggingRemovesMarkedAsFoundDNF, @"logging_removesmarkedasfounddnf");
    LOAD_BOOL   (self.loggingGGCWOfferFavourites, @"logging_ggcwofferfavourites");
    LOAD_BOOL   (self.compassAlwaysInPortraitMode, @"compass_alwaysinportraitmode");
    LOAD_BOOL   (self.showCountryAsAbbrevation, @"showasabbrevation_country");
    LOAD_BOOL   (self.showStateAsAbbrevation, @"showasabbrevation_state");
    LOAD_BOOL   (self.showStateAsAbbrevationIfLocalityExists, @"showasabbrevation_statewithlocale");
    LOAD_INTEGER(self.waypointListSortBy, @"waypointlist_sortby");
    LOAD_BOOL   (self.refreshWaypointAfterLog, @"waypoint_refreshafterlog");
    LOAD_INTEGER(self.listSortBy, @"list_sortby");
    LOAD_BOOL   (self.accountsSaveAuthenticationName, @"accounts_save_authenticationname");
    LOAD_BOOL   (self.accountsSaveAuthenticationPassword, @"accounts_save_authenticationpassword");
    LOAD_BOOL   (self.introSeen, @"intro_seen");
    LOAD_VALUE  (self.logTemporaryText, @"log_temporary_text");
    LOAD_BOOL   (self.locationlessShowFound, @"locationless_showfound");
    LOAD_INTEGER(self.locationlessListSortBy, @"locationless_sortby");
    LOAD_BOOL   (self.opencageEnable, @"opencage_enable");
    LOAD_VALUE  (self.opencageKey, @"opencage_key");
    LOAD_BOOL   (self.opencageWifiOnly, @"opencage_wifionly");
    LOAD_VALUE  (self.mapboxKey, @"mapbox_key");
    LOAD_VALUE  (self.thunderforestKey, @"thunderforest_key");
    LOAD_VALUE  (self.configUpdateLastVersion, @"configupdate_lastversion");
    LOAD_INTEGER(self.configUpdateLastTime, @"configupdate_lasttime");
    LOAD_BOOL   (self.automaticDatabaseBackup, @"automaticdatabasebackup_enable");
    LOAD_DOUBLE (self.automaticDatabaseBackupLast, @"automaticdatabasebackup_last");
    LOAD_INTEGER(self.automaticDatabaseBackupPeriod, @"automaticdatabasebackup_period");
    LOAD_INTEGER(self.automaticDatabaseBackupRotate, @"automaticdatabasebackup_rotate");
    LOAD_BOOL   (self.accuracyDynamicEnable, @"accuracy_dynamic_enable");
    LOAD_INTEGER(self.accuracyDynamicAccuracyNear, @"accuracy_dynamic_accuracy_near");
    LOAD_INTEGER(self.accuracyDynamicAccuracyMidrange, @"accuracy_dynamic_accuracy_midrange");
    LOAD_INTEGER(self.accuracyDynamicAccuracyFar, @"accuracy_dynamic_accuracy_far");
    LOAD_INTEGER(self.accuracyDynamicDeltaDNear, @"accuracy_dynamic_deltad_near");
    LOAD_INTEGER(self.accuracyDynamicDeltaDMidrange, @"accuracy_dynamic_deltad_midrange");
    LOAD_INTEGER(self.accuracyDynamicDeltaDFar, @"accuracy_dynamic_deltad_far");
    LOAD_INTEGER(self.accuracyDynamicDistanceNearToMidrange, @"accuracy_dynamic_distance_neartomidrange");
    LOAD_INTEGER(self.accuracyDynamicDistanceMidrangeToFar, @"accuracy_dynamic_distance_midrangetofar");
    LOAD_INTEGER(self.accuracyStaticAccuracyNavigating, @"accuracy_static_accuracy_navigating");
    LOAD_INTEGER(self.accuracyStaticAccuracyNonNavigating, @"accuracy_static_accuracy_nonnavigating");
    LOAD_INTEGER(self.accuracyStaticDeltaDNavigating, @"accuracy_static_deltad_navigating");
    LOAD_INTEGER(self.accuracyStaticDeltaDNonNavigating, @"accuracy_static_deltad_nonnavigating");
    LOAD_BOOL   (self.speedEnable, @"speed_enable");
    LOAD_INTEGER(self.speedMinimum, @"speed_minimum");
    LOAD_INTEGER(self.speedSamples, @"speed_samples");
    LOAD_INTEGER(self.mapsearchGGCWMaximumNumber, @"mapsearch_ggcw_maximumnumber");
    LOAD_INTEGER(self.mapsearchGGCWNumberThreads, @"mapsearch_ggcw_numberthreads");
    LOAD_INTEGER(self.fontSmallTextSize, @"font_smalltext_size");
    LOAD_INTEGER(self.fontNormalTextSize, @"font_normaltext_size");
    LOAD_INTEGER(self.coordinatesTypeShow, @"coordinates_show");
    LOAD_INTEGER(self.coordinatesTypeEdit, @"coordinates_edit");
    LOAD_INTEGER(self.coordinatesDecimalsSeconds, @"coordinates_decimals_seconds");
    LOAD_INTEGER(self.coordinatesDecimalsMinutes, @"coordinates_decimals_minutes");
    LOAD_INTEGER(self.coordinatesDecimalsDegrees, @"coordinates_decimals_degrees");
    LOAD_BOOL   (self.serviceShowMoveables, @"service_showmoveables");
    LOAD_BOOL   (self.serviceShowTrackables, @"service_showtrackables");
    LOAD_BOOL   (self.serviceShowLocationless, @"service_showlocationless");
    LOAD_BOOL   (self.serviceShowDeveloper, @"service_showdeveloper");
    LOAD_BOOL   (self.moveablesShowFound, @"moveables_showfound");
    LOAD_INTEGER(self.moveablesListSortBy, @"moveables_listsortby");
    LOAD_INTEGER(self.mapKMLBorderSize, @"map_kml_border_size");
    LOAD_INTEGER(self.mapCircleRingSize, @"map_circle_ring_size");
    LOAD_INTEGER(self.myAccountLastNumber, @"myaccount_lastnumber");
    LOAD_VALUE  (self.owntracksURL, @"owntracks_url");
    LOAD_VALUE  (self.owntracksUsername, @"owntracks_username");
    LOAD_VALUE  (self.owntracksSecret, @"owntracks_secret");
    LOAD_BOOL   (self.ownTracksEnable, @"owntracks_enable");
    LOAD_VALUE  (self.owntracksPassword, @"owntracks_password");
    LOAD_INTEGER(self.owntracksInterval, @"owntracks_interval");
    LOAD_INTEGER(self.owntracksIntervalFailure, @"owntracks_interval_failure");
    LOAD_INTEGER(self.owntracksIntervalOffline, @"owntracks_interval_offline");
    LOAD_INTEGER(self.owntracksFailure, @"owntracks_failure");

    /* Leftovers */
    self.currentTrack = [dbTrack dbGet:[[dbConfig dbGetByKey:@"track_current"].value integerValue]];
    self.mapTrackColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_track_colour"].value];
    self.mapDestinationColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_destination_colour"].value];
    self.mapCircleFillColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_circle_ring_colour"].value];
    self.mapCircleRingColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_circle_fill_colour"].value];
    self.mapKMLBorderColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_kml_border_colour"].value];
    self.mapKMLFillColour = [ImageManager RGBtoColor:[dbConfig dbGetByKey:@"map_kml_fill_colour"].value];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_resetpage"] == TRUE) {
        NSLog(@"Erasing page settings.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_resetpage"];

        [self currentPageUpdate:0];
        [self currentPageTabUpdate:0];
    }
}

/*
 * Updates-related meta functions
 */
- (void)BOOLUpdate:(NSString *)key value:(BOOL)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%ld", (long)value];
    [c dbUpdate];
}

- (void)NSIntegerUpdate:(NSString *)key value:(NSInteger)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%ld", (long)value];
    [c dbUpdate];
}

- (void)NSIdUpdate:(NSString *)key value:(NSId)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%ld", (long)value];
    [c dbUpdate];
}

- (void)CoordinatesTypeUpdate:(NSString *)key value:(CoordinatesType)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%ld", (long)value];
    [c dbUpdate];
}

- (void)floatUpdate:(NSString *)key value:(float)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%f", value];
    [c dbUpdate];
}

- (void)doubleUpdate:(NSString *)key value:(double)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = [NSString stringWithFormat:@"%f", value];
    [c dbUpdate];
}

- (void)NSStringUpdate:(NSString *)key value:(NSString *)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = value;
    [c dbUpdate];
}

/*
 * Updates-related functions
 */

#define UPDATE3(__type__, __field__, __key__) \
    - (void)__field__ ## Update:(__type__)value \
    { \
        self.__field__ = value; \
        [self __type__ ## Update:__key__ value:value]; \
    }
#define UPDATE4(__type__, __func__, __field__, __key__) \
    - (void)__field__ ## Update:(__type__)value \
    { \
        self.__field__ = value; \
        [self __func__ ## Update:__key__ value:value]; \
    }
#define UPDATE5(__type__, __func__, __field__, __key__, __field2__) \
    - (void)__field__ ## Update:(__type__)value \
    { \
        self.__field__ = value; \
        [self __func__ ## Update:__key__ value:value.__field2__]; \
    }
#define UPDATECOLOUR(__field__, __key__) \
    - (void)__field__ ## Update:(NSString *)value \
    { \
        self.__field__ = [ImageManager RGBtoColor:value]; \
        [self NSStringUpdate:__key__ value:value]; \
    }

UPDATE3(BOOL, distanceMetric, @"distance_metric")
UPDATE3(BOOL, soundDirection, @"sound_direction")
UPDATE3(BOOL, soundDistance, @"sound_distance")
UPDATE3(BOOL, keeptrackEnable, @"keeptrack_enable")
UPDATE3(BOOL, keeptrackMemoryOnly, @"keeptrack_memoryonly")
UPDATE3(BOOL, keeptrackAutoRotate, @"keeptrack_autorotate")
UPDATE3(BOOL, dynamicmapEnable, @"dynamicmap_enable")
UPDATE3(BOOL, mapcacheEnable, @"mapcache_enable")
UPDATE3(BOOL, downloadImagesLogs, @"download_images_logs")
UPDATE3(BOOL, downloadImagesWaypoints, @"download_images_waypoints")
UPDATE3(BOOL, downloadImagesMobile, @"download_images_mobile")
UPDATE3(BOOL, downloadQueriesMobile, @"download_queries_mobile")
UPDATE3(BOOL, markasFoundDNFClearsTarget, @"markas_founddnf_clearstarget")
UPDATE3(BOOL, markasFoundMarksAllWaypoints, @"markas_foundmarksallwaypoints")
UPDATE3(BOOL, loggingRemovesMarkedAsFoundDNF, @"logging_removesmarkedasfounddnf")
UPDATE3(BOOL, loggingGGCWOfferFavourites, @"logging_ggcwofferfavourites")
UPDATE3(BOOL, compassAlwaysInPortraitMode, @"compass_alwaysinportraitmode")
UPDATE3(BOOL, showStateAsAbbrevation, @"showasabbrevation_state")
UPDATE3(BOOL, showStateAsAbbrevationIfLocalityExists, @"showasabbrevation_statewithlocale")
UPDATE3(BOOL, showCountryAsAbbrevation, @"showasabbrevation_country")
UPDATE3(BOOL, refreshWaypointAfterLog, @"waypoint_refreshafterlog")
UPDATE3(BOOL, accountsSaveAuthenticationName, @"accounts_save_authenticationname")
UPDATE3(BOOL, accountsSaveAuthenticationPassword, @"accounts_save_authenticationpassword")
UPDATE3(BOOL, introSeen, @"intro_seen")
UPDATE3(BOOL, locationlessShowFound, @"locationless_showfound")
UPDATE3(BOOL, opencageEnable, @"opencage_enable")
UPDATE3(BOOL, opencageWifiOnly, @"opencage_wifionly")
UPDATE3(BOOL, automaticDatabaseBackup, @"automaticdatabasebackup_enable")
UPDATE3(BOOL, accuracyDynamicEnable, @"accuracy_dynamic_enable")
UPDATE3(BOOL, speedEnable, @"speed_enable")
UPDATE3(BOOL, serviceShowMoveables, @"service_showmoveables")
UPDATE3(BOOL, serviceShowLocationless, @"service_showlocationless")
UPDATE3(BOOL, serviceShowTrackables, @"service_showtrackables")
UPDATE3(BOOL, serviceShowDeveloper, @"service_showdeveloper")
UPDATE3(BOOL, moveablesShowFound, @"moveables_showfound")
UPDATE3(BOOL, ownTracksEnable, @"owntracks_enable")

UPDATE4(MapTileBackend, NSInteger, mapTileBackend, @"map_tilebackend")
UPDATE4(LM_ACCURACY, NSInteger, accuracyDynamicAccuracyNear, @"accuracy_dynamic_accuracy_near")
UPDATE4(LM_ACCURACY, NSInteger, accuracyDynamicAccuracyMidrange, @"accuracy_dynamic_accuracy_midrange")
UPDATE4(LM_ACCURACY, NSInteger, accuracyDynamicAccuracyFar, @"accuracy_dynamic_accuracy_far")
UPDATE3(NSInteger, accuracyDynamicDeltaDNear, @"accuracy_dynamic_deltad_near")
UPDATE3(NSInteger, accuracyDynamicDeltaDMidrange, @"accuracy_dynamic_deltad_midrange")
UPDATE3(NSInteger, accuracyDynamicDeltaDFar, @"accuracy_dynamic_deltad_far")
UPDATE3(NSInteger, accuracyDynamicDistanceNearToMidrange, @"accuracy_dynamic_distance_neartomidrange")
UPDATE3(NSInteger, accuracyDynamicDistanceMidrangeToFar, @"accuracy_dynamic_distance_midrangetofar")
UPDATE4(LM_ACCURACY, NSInteger, accuracyStaticAccuracyNavigating, @"accuracy_static_accuracy_navigating")
UPDATE4(LM_ACCURACY, NSInteger, accuracyStaticAccuracyNonNavigating, @"accuracy_static_accuracy_nonnavigating")
UPDATE3(NSInteger, accuracyStaticDeltaDNavigating, @"accuracy_static_deltad_navigating")
UPDATE3(NSInteger, accuracyStaticDeltaDNonNavigating, @"accuracy_static_deltad_nonnavigating")
UPDATE3(NSInteger, currentPage, @"page_current")
UPDATE3(NSInteger, currentPageTab, @"pagetab_current")
UPDATE3(NSInteger, lastImportGroup, @"lastimport_group")
UPDATE3(NSInteger, lastAddedGroup, @"lastadded_group")
UPDATE3(NSInteger, lastImportSource, @"lastimport_source")
UPDATE3(NSInteger, mapExternal, @"map_external")
UPDATE3(NSInteger, compassType, @"compass_type")
UPDATE3(NSInteger, themeStyleType, @"theme_style_type")
UPDATE3(NSInteger, themeImageType, @"theme_image_type")
UPDATE3(NSInteger, orientationsAllowed, @"orientations_allowed")
UPDATE3(NSInteger, keeptrackDistanceDeltaMin, @"keeptrack_distancedelta_min")
UPDATE3(NSInteger, keeptrackDistanceDeltaMax, @"keeptrack_distancedelta_max")
UPDATE3(NSInteger, keeptrackPurgeAge, @"keeptrack_purgeage")
UPDATE3(NSInteger, keeptrackSync, @"keeptrack_sync")
UPDATE3(NSInteger, keeptrackBeeperInterval, @"keeptrack_beeper_interval")
UPDATE3(NSInteger, dynamicmapWalkingSpeed, @"dynamicmap_speed_walking")
UPDATE3(NSInteger, dynamicmapWalkingDistance, @"dynamicmap_distance_walking")
UPDATE3(NSInteger, dynamicmapCyclingSpeed, @"dynamicmap_speed_cycling")
UPDATE3(NSInteger, dynamicmapCyclingDistance, @"dynamicmap_distance_cycling")
UPDATE3(NSInteger, dynamicmapDrivingSpeed, @"dynamicmap_speed_driving")
UPDATE3(NSInteger, dynamicmapDrivingDistance, @"dynamicmap_distance_driving")
UPDATE3(NSInteger, mapcacheMaxSize, @"mapcache_maxsize")
UPDATE3(NSInteger, mapcacheMaxAge, @"mapcache_maxage")
UPDATE3(NSInteger, downloadTimeoutSimple, @"download_timeout_simple")
UPDATE3(NSInteger, downloadTimeoutQuery, @"download_timeout_query")
UPDATE3(NSInteger, waypointListSortBy, @"waypointlist_sortby")
UPDATE3(NSInteger, listSortBy, @"list_sortby")
UPDATE3(NSInteger, locationlessListSortBy, @"locationless_sortby")
UPDATE3(NSInteger, configUpdateLastTime, @"configupdate_lasttime")
UPDATE3(NSInteger, automaticDatabaseBackupPeriod, @"automaticdatabasebackup_period")
UPDATE3(NSInteger, automaticDatabaseBackupRotate, @"automaticdatabasebackup_rotate")
UPDATE3(NSInteger, speedSamples, @"speed_samples")
UPDATE3(NSInteger, speedMinimum, @"speed_minimum")
UPDATE3(NSInteger, mapsearchGGCWMaximumNumber, @"mapsearch_ggcw_maximumnumber")
UPDATE3(NSInteger, mapsearchGGCWNumberThreads, @"mapsearch_ggcw_numberthreads")
UPDATE3(NSInteger, fontSmallTextSize, @"font_smalltext_size")
UPDATE3(NSInteger, fontNormalTextSize, @"font_normaltext_size")
UPDATE3(CoordinatesType, coordinatesTypeShow, @"coordinates_show")
UPDATE3(CoordinatesType, coordinatesTypeEdit, @"coordinates_edit")
UPDATE3(NSInteger, coordinatesDecimalsDegrees, @"coordinates_decimals_degrees")
UPDATE3(NSInteger, coordinatesDecimalsMinutes, @"coordinates_decimals_minutes")
UPDATE3(NSInteger, coordinatesDecimalsSeconds, @"coordinates_decimals_seconds")
UPDATE3(NSInteger, moveablesListSortBy, @"moveables_listsortby")
UPDATE3(NSInteger, mapKMLBorderSize, @"map_kml_border_size")
UPDATE3(NSInteger, mapCircleRingSize, @"map_circle_ring_size")
UPDATE3(NSInteger, myAccountLastNumber, @"myaccount_lastnumber")
UPDATE3(NSInteger, owntracksInterval, @"owntracks_interval")
UPDATE3(NSInteger, owntracksIntervalFailure, @"owntracks_interval_failure")
UPDATE3(NSInteger, owntracksIntervalOffline, @"owntracks_interval_offline")
UPDATE3(NSInteger, owntracksFailure, @"owntracks_failure")

UPDATE3(float, keeptrackTimeDeltaMin, @"keeptrack_timedelta_min")
UPDATE3(float, keeptrackTimeDeltaMax, @"keeptrack_timedelta_max")

UPDATE4(NSString *, NSString, currentWaypoint, @"waypoint_current")
UPDATE4(NSString *, NSString, mapBrandDefault, @"map_branddefault")
UPDATE4(NSString *, NSString, logTemporaryText, @"log_temporary_text")
UPDATE4(NSString *, NSString, opencageKey, @"opencage_key")
UPDATE4(NSString *, NSString, mapboxKey, @"mapbox_key")
UPDATE4(NSString *, NSString, thunderforestKey, @"thunderforest_key")
UPDATE4(NSString *, NSString, configUpdateLastVersion, @"configupdate_lastversion")
UPDATE4(NSString *, NSString, owntracksURL, @"owntracks_url")
UPDATE4(NSString *, NSString, owntracksUsername, @"owntracks_username")
UPDATE4(NSString *, NSString, owntracksSecret, @"owntracks_secret")
UPDATE4(NSString *, NSString, owntracksPassword, @"owntracks_password")

UPDATE4(NSTimeInterval, double, automaticDatabaseBackupLast, @"automaticdatabasebackup_last")

UPDATE5(dbTrack *, NSId, currentTrack, @"track_current", _id)

UPDATECOLOUR(mapTrackColour, @"map_track_colour")
UPDATECOLOUR(mapDestinationColour, @"map_destination_colour")
UPDATECOLOUR(mapCircleRingColour, @"map_circle_ring_colour")
UPDATECOLOUR(mapCircleFillColour, @"map_circle_fill_colour")
UPDATECOLOUR(mapKMLFillColour, @"map_kml_fill_colour")
UPDATECOLOUR(mapKMLBorderColour, @"map_kml_border_colour")

@end
