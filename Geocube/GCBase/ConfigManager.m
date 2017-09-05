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

@interface ConfigManager ()

@end

@implementation ConfigManager

- (instancetype)init
{
    self = [super init];

    [self checkDefaults];
    [self loadValues];

    UITableViewCell *tvc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    self.GCLabelFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    self.GCTextblockFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    self.GCSmallFont = [UIFont systemFontOfSize:11];

    NSLog(@"%@ initialized", [self class]);

    return self;
}

- (void)checkDefaults
{
    dbConfig *c;

#define CHECK(__key__, __default__) \
    c = [dbConfig dbGetByKey:__key__]; \
    if (c == nil) \
        [dbConfig dbUpdateOrInsert:__key__ value:__default__]

    NSString *defaultUsesMetric = @"1";
    if ([MyTools iOSVersionAtLeast_10_0_0] == YES && [[NSLocale currentLocale] usesMetricSystem] == NO)
        // This locale doesn't default to metric system.
        defaultUsesMetric = @"0";
    CHECK(@"distance_metric", defaultUsesMetric);
    CHECK(@"send_tweets", @"1");
    CHECK(@"waypoint_current", @"");
    CHECK(@"page_current", @"0");
    CHECK(@"pagetab_current", @"0");
    CHECK(@"track_current", @"0");
    CHECK(@"lastimport_group", @"0");
    CHECK(@"lastadded_group", @"0");
    CHECK(@"lastimport_source", @"0");

    CHECK(@"map_external", @"1");
    CHECK(@"map_branddefault", @"apple");
    CHECK(@"map_track_colour", @"00F0F0");
    CHECK(@"map_destination_colour", @"FF0000");

    CHECK(@"compass_type", @"0");
    CHECK(@"theme_type", @"0");
    NSString *s = [NSString stringWithFormat:@"%ld", (long)(UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight)];
    CHECK(@"orientations_allowed", s);

    CHECK(@"sound_direction", @"0");
    CHECK(@"sound_distance", @"0");

    CHECK(@"keeptrack_autorotate", @"1");
    CHECK(@"keeptrack_timedelta_min", @"5.0");
    CHECK(@"keeptrack_timedelta_max", @"10.0");
    CHECK(@"keeptrack_distancedelta_min", @"100");
    CHECK(@"keeptrack_distancedelta_max", @"200");
    CHECK(@"keeptrack_purgeage", @"30");
    CHECK(@"keeptrack_sync", @"120");
    CHECK(@"keeptrack_beeper_interval", @"10");

    CHECK(@"map_clusters_enable", @"0");
    CHECK(@"map_clusters_zoomlevel", @"11.0");
    CHECK(@"map_rotate_to_bearing", @"0");

    CHECK(@"dynamicmap_enable", @"1");
    CHECK(@"dynamicmap_speed_walking", @"7");
    CHECK(@"dynamicmap_speed_cycling", @"40");
    CHECK(@"dynamicmap_speed_driving", @"120");
    CHECK(@"dynamicmap_distance_walking", @"100");
    CHECK(@"dynamicmap_distance_cycling", @"1000");
    CHECK(@"dynamicmap_distance_driving", @"5000");

    CHECK(@"mapcache_enable", @"1");
    CHECK(@"mapcache_maxsize", @"250");
    CHECK(@"mapcache_maxage", @"30");

    CHECK(@"download_images_logs", @"0");
    CHECK(@"download_images_waypoints", @"1");
    CHECK(@"download_images_mobile", @"0");
    CHECK(@"download_queries_mobile", @"0");
    CHECK(@"download_timeout_query", @"600");
    CHECK(@"download_timeout_simple", @"120");

    CHECK(@"mapsearchmaximum_distancegs", @"5000");
    CHECK(@"mapsearchmaximum_distanceokapi", @"5000");
    CHECK(@"mapsearchmaximum_distancegca", @"5000");
    CHECK(@"mapsearchmaximum_numbergca", @"50");

    CHECK(@"markas_founddnf_clearstarget", @"1");
    CHECK(@"markas_foundmarksallwaypoints", @"1");
    CHECK(@"logging_removesmarkedasfounddnf", @"1");

    CHECK(@"compass_alwaysinportraitmode", @"1");
    CHECK(@"showasabbrevation_country", @"1");
    CHECK(@"showasabbrevation_state", @"0");
    CHECK(@"showasabbrevation_statewithlocale", @"1");

    CHECK(@"waypointlist_sortby", @"0");

    CHECK(@"waypoint_refreshafterlog", @"1");

    CHECK(@"list_sortby", @"0");

    CHECK(@"accounts_save_authenticationname", @"1");
    CHECK(@"accounts_save_authenticationpassword", @"0");

    CHECK(@"intro_seen", @"0");

    CHECK(@"log_temporary_text", @"");

    CHECK(@"locationless_showfound", @"1");
    CHECK(@"locationless_sortby", @"0");

    CHECK(@"opencage_key", @"");
    CHECK(@"opencage_wifionly", @"1");

    CHECK(@"configupdate_lastversion", @"1.3");
    s = [NSString stringWithFormat:@"%ld", time(NULL)];
    CHECK(@"configupdate_lasttime", s);

    CHECK(@"automaticdatabasebackup_enable", @"0");
    CHECK(@"automaticdatabasebackup_last", @"0");
    CHECK(@"automaticdatabasebackup_period", @"7");
    CHECK(@"automaticdatabasebackup_rotate", @"5");

    CHECK(@"accuracy_dynamic_enable", @"1");
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_BEST];
    CHECK(@"accuracy_dynamic_accuracy_near", s);
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_10M];
    CHECK(@"accuracy_dynamic_accuracy_midrange", s);
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_100M];
    CHECK(@"accuracy_dynamic_accuracy_far", s);
    CHECK(@"accuracy_dynamic_deltad_near", @"0");
    CHECK(@"accuracy_dynamic_deltad_midrange", @"5");
    CHECK(@"accuracy_dynamic_deltad_far", @"10");
    CHECK(@"accuracy_dynamic_distance_neartomidrange", @"50");
    CHECK(@"accuracy_dynamic_distance_midrangetofar", @"250");
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_BEST];
    CHECK(@"accuracy_static_accuracy_navigating", s);
    s = [NSString stringWithFormat:@"%ld", (long)LMACCURACY_100M];
    CHECK(@"accuracy_static_accuracy_nonnavigating", s);
    CHECK(@"accuracy_static_deltad_navigating", @"0");
    CHECK(@"accuracy_static_deltad_nonnavigating", @"10");
}

- (void)loadValues
{
    self.distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    self.sendTweets = [[dbConfig dbGetByKey:@"send_tweets"].value boolValue];
    self.currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    self.currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    self.currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
    self.currentTrack = [dbTrack dbGet:[[dbConfig dbGetByKey:@"track_current"].value integerValue]];
    self.lastImportSource = [[dbConfig dbGetByKey:@"lastimport_source"].value integerValue];
    self.lastImportGroup = [[dbConfig dbGetByKey:@"lastimport_group"].value integerValue];
    self.lastAddedGroup = [[dbConfig dbGetByKey:@"lastadded_group"].value integerValue];
    self.mapExternal = [[dbConfig dbGetByKey:@"map_external"].value integerValue];
    self.mapBrandDefault = [dbConfig dbGetByKey:@"map_branddefault"].value;
    self.mapTrackColour = [ImageLibrary RGBtoColor:[dbConfig dbGetByKey:@"map_track_colour"].value];
    self.mapDestinationColour = [ImageLibrary RGBtoColor:[dbConfig dbGetByKey:@"map_destination_colour"].value];
    self.compassType = [[dbConfig dbGetByKey:@"compass_type"].value integerValue];
    self.themeType = [[dbConfig dbGetByKey:@"theme_type"].value integerValue];
    self.orientationsAllowed = [[dbConfig dbGetByKey:@"orientations_allowed"].value integerValue];
    self.soundDirection = [[dbConfig dbGetByKey:@"sound_direction"].value boolValue];
    self.soundDistance = [[dbConfig dbGetByKey:@"sound_distance"].value boolValue];
    self.keeptrackAutoRotate = [[dbConfig dbGetByKey:@"keeptrack_autorotate"].value boolValue];
    self.keeptrackTimeDeltaMin = [[dbConfig dbGetByKey:@"keeptrack_timedelta_min"].value floatValue];
    self.keeptrackTimeDeltaMax = [[dbConfig dbGetByKey:@"keeptrack_timedelta_max"].value floatValue];
    self.keeptrackDistanceDeltaMin = [[dbConfig dbGetByKey:@"keeptrack_distancedelta_min"].value floatValue];
    self.keeptrackDistanceDeltaMax = [[dbConfig dbGetByKey:@"keeptrack_distancedelta_max"].value floatValue];
    self.keeptrackPurgeAge = [[dbConfig dbGetByKey:@"keeptrack_purgeage"].value integerValue];
    self.keeptrackSync = [[dbConfig dbGetByKey:@"keeptrack_sync"].value integerValue];
    self.keeptrackBeeperInterval = [[dbConfig dbGetByKey:@"keeptrack_beeper_interval"].value integerValue];
    self.mapClustersEnable = [[dbConfig dbGetByKey:@"map_clusters_enable"].value boolValue];
    self.mapClustersZoomLevel = [[dbConfig dbGetByKey:@"map_clusters_zoomlevel"].value floatValue];
    self.mapRotateToBearing = [[dbConfig dbGetByKey:@"map_rotate_to_bearing"].value boolValue];
    self.dynamicmapEnable = [[dbConfig dbGetByKey:@"dynamicmap_enable"].value boolValue];
    self.dynamicmapWalkingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_walking"].value floatValue];
    self.dynamicmapCyclingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_cycling"].value floatValue];
    self.dynamicmapDrivingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_driving"].value floatValue];
    self.dynamicmapWalkingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_walking"].value integerValue];
    self.dynamicmapCyclingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_cycling"].value integerValue];
    self.dynamicmapDrivingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_driving"].value integerValue];
    self.mapcacheEnable = [[dbConfig dbGetByKey:@"mapcache_enable"].value boolValue];
    self.mapcacheMaxAge = [[dbConfig dbGetByKey:@"mapcache_maxage"].value integerValue];
    self.mapcacheMaxSize = [[dbConfig dbGetByKey:@"mapcache_maxsize"].value integerValue];
    self.downloadImagesLogs = [[dbConfig dbGetByKey:@"download_images_logs"].value boolValue];
    self.downloadImagesWaypoints = [[dbConfig dbGetByKey:@"download_images_waypoints"].value boolValue];
    self.downloadImagesMobile = [[dbConfig dbGetByKey:@"download_images_mobile"].value boolValue];
    self.downloadQueriesMobile = [[dbConfig dbGetByKey:@"download_queries_mobile"].value boolValue];
    self.downloadTimeoutSimple = [[dbConfig dbGetByKey:@"download_timeout_simple"].value integerValue];
    self.downloadTimeoutQuery = [[dbConfig dbGetByKey:@"download_timeout_query"].value integerValue];
    self.mapSearchMaximumNumberGCA = [[dbConfig dbGetByKey:@"mapsearchmaximum_numbergca"].value integerValue];
    self.mapSearchMaximumDistanceGS = [[dbConfig dbGetByKey:@"mapsearchmaximum_distancegs"].value integerValue];
    self.mapSearchMaximumDistanceOKAPI = [[dbConfig dbGetByKey:@"mapsearchmaximum_distanceokapi"].value integerValue];
    self.mapSearchMaximumDistanceGCA = [[dbConfig dbGetByKey:@"mapsearchmaximum_distancegca"].value integerValue];
    self.markasFoundDNFClearsTarget = [[dbConfig dbGetByKey:@"markas_founddnf_clearstarget"].value boolValue];
    self.markasFoundMarksAllWaypoints = [[dbConfig dbGetByKey:@"markas_foundmarksallwaypoints"].value boolValue];
    self.loggingRemovesMarkedAsFoundDNF = [[dbConfig dbGetByKey:@"logging_removesmarkedasfounddnf"].value boolValue];
    self.compassAlwaysInPortraitMode = [[dbConfig dbGetByKey:@"compass_alwaysinportraitmode"].value boolValue];
    self.showCountryAsAbbrevation = [[dbConfig dbGetByKey:@"showasabbrevation_country"].value boolValue];
    self.showStateAsAbbrevation = [[dbConfig dbGetByKey:@"showasabbrevation_state"].value boolValue];
    self.showStateAsAbbrevationIfLocalityExists = [[dbConfig dbGetByKey:@"showasabbrevation_statewithlocale"].value boolValue];
    self.waypointListSortBy = [[dbConfig dbGetByKey:@"waypointlist_sortby"].value integerValue];
    self.refreshWaypointAfterLog = [[dbConfig dbGetByKey:@"waypoint_refreshafterlog"].value boolValue];
    self.listSortBy = [[dbConfig dbGetByKey:@"list_sortby"].value integerValue];
    self.accountsSaveAuthenticationName = [[dbConfig dbGetByKey:@"accounts_save_authenticationname"].value boolValue];
    self.accountsSaveAuthenticationPassword = [[dbConfig dbGetByKey:@"accounts_save_authenticationpassword"].value boolValue];
    self.introSeen = [[dbConfig dbGetByKey:@"intro_seen"].value boolValue];
    self.logTemporaryText = [dbConfig dbGetByKey:@"log_temporary_text"].value;
    self.locationlessShowFound = [[dbConfig dbGetByKey:@"locationless_showfound"].value boolValue];
    self.locationlessListSortBy = [[dbConfig dbGetByKey:@"locationless_sortby"].value integerValue];
    self.opencageKey = [dbConfig dbGetByKey:@"opencage_key"].value;
    self.opencageWifiOnly = [[dbConfig dbGetByKey:@"opencage_wifionly"].value boolValue];
    self.configUpdateLastVersion = [dbConfig dbGetByKey:@"configupdate_lastversion"].value;
    self.configUpdateLastTime = [[dbConfig dbGetByKey:@"configupdate_lasttime"].value integerValue];
    self.automaticDatabaseBackup = [[dbConfig dbGetByKey:@"automaticdatabasebackup_enable"].value boolValue];
    self.automaticDatabaseBackupLast = [[dbConfig dbGetByKey:@"automaticdatabasebackup_last"].value doubleValue];
    self.automaticDatabaseBackupPeriod = [[dbConfig dbGetByKey:@"automaticdatabasebackup_period"].value integerValue];
    self.automaticDatabaseBackupRotate = [[dbConfig dbGetByKey:@"automaticdatabasebackup_rotate"].value integerValue];
    self.accuracyDynamicEnable = [[dbConfig dbGetByKey:@"accuracy_dynamic_enable"].value boolValue];
    self.accuracyDynamicAccuracyNear = [[dbConfig dbGetByKey:@"accuracy_dynamic_accuracy_near"].value integerValue];
    self.accuracyDynamicAccuracyMidrange = [[dbConfig dbGetByKey:@"accuracy_dynamic_accuracy_midrange"].value integerValue];
    self.accuracyDynamicAccuracyFar = [[dbConfig dbGetByKey:@"accuracy_dynamic_accuracy_far"].value integerValue];
    self.accuracyDynamicDeltaDNear = [[dbConfig dbGetByKey:@"accuracy_dynamic_deltad_near"].value integerValue];
    self.accuracyDynamicDeltaDMidrange = [[dbConfig dbGetByKey:@"accuracy_dynamic_deltad_midrange"].value integerValue];
    self.accuracyDynamicDeltaDFar = [[dbConfig dbGetByKey:@"accuracy_dynamic_deltad_far"].value integerValue];
    self.accuracyDynamicDistanceNearToMidrange = [[dbConfig dbGetByKey:@"accuracy_dynamic_distance_neartomidrange"].value integerValue];
    self.accuracyDynamicDistanceMidrangeToFar = [[dbConfig dbGetByKey:@"accuracy_dynamic_distance_midrangetofar"].value integerValue];
    self.accuracyStaticAccuracyNavigating = [[dbConfig dbGetByKey:@"accuracy_static_accuracy_navigating"].value integerValue];
    self.accuracyStaticAccuracyNonNavigating = [[dbConfig dbGetByKey:@"accuracy_static_accuracy_nonnavigating"].value integerValue];
    self.accuracyStaticDeltaDNavigating = [[dbConfig dbGetByKey:@"accuracy_static_deltad_navigating"].value integerValue];
    self.accuracyStaticDeltaDNonNavigating = [[dbConfig dbGetByKey:@"accuracy_static_deltad_nonnavigating"].value integerValue];

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

UPDATE3(BOOL, distanceMetric, @"distance_metric")
UPDATE3(BOOL, sendTweets, @"send_tweets")
UPDATE3(BOOL, soundDirection, @"sound_direction")
UPDATE3(BOOL, soundDistance, @"sound_distance")
UPDATE3(BOOL, keeptrackAutoRotate, @"keeptrack_autorotate")
UPDATE3(BOOL, mapClustersEnable, @"map_clusters_enable")
UPDATE3(BOOL, mapRotateToBearing, @"map_rotate_to_bearing")
UPDATE3(BOOL, dynamicmapEnable, @"dynamicmap_enable")
UPDATE3(BOOL, mapcacheEnable, @"mapcache_enable")
UPDATE3(BOOL, downloadImagesLogs, @"download_images_logs")
UPDATE3(BOOL, downloadImagesWaypoints, @"download_images_waypoints")
UPDATE3(BOOL, downloadImagesMobile, @"download_images_mobile")
UPDATE3(BOOL, downloadQueriesMobile, @"download_queries_mobile")
UPDATE3(BOOL, markasFoundDNFClearsTarget, @"markas_founddnf_clearstarget")
UPDATE3(BOOL, markasFoundMarksAllWaypoints, @"markas_foundmarksallwaypoints")
UPDATE3(BOOL, loggingRemovesMarkedAsFoundDNF, @"logging_removesmarkedasfounddnf")
UPDATE3(BOOL, compassAlwaysInPortraitMode, @"compass_alwaysinportraitmode")
UPDATE3(BOOL, showStateAsAbbrevation, @"showasabbrevation_state")
UPDATE3(BOOL, showStateAsAbbrevationIfLocalityExists, @"showasabbrevation_statewithlocale")
UPDATE3(BOOL, showCountryAsAbbrevation, @"showasabbrevation_country")
UPDATE3(BOOL, refreshWaypointAfterLog, @"waypoint_refreshafterlog")
UPDATE3(BOOL, accountsSaveAuthenticationName, @"accounts_save_authenticationname")
UPDATE3(BOOL, accountsSaveAuthenticationPassword, @"accounts_save_authenticationpassword")
UPDATE3(BOOL, introSeen, @"intro_seen")
UPDATE3(BOOL, locationlessShowFound, @"locationless_showfound")
UPDATE3(BOOL, opencageWifiOnly, @"opencage_wifionly")
UPDATE3(BOOL, automaticDatabaseBackup, @"automaticdatabasebackup_enable")
UPDATE3(BOOL, accuracyDynamicEnable, @"accuracy_dynamic_enable")

UPDATE3(NSInteger, accuracyDynamicAccuracyNear, @"accuracy_dynamic_accuracy_near")
UPDATE3(NSInteger, accuracyDynamicAccuracyMidrange, @"accuracy_dynamic_accuracy_midrange")
UPDATE3(NSInteger, accuracyDynamicAccuracyFar, @"accuracy_dynamic_accuracy_far")
UPDATE3(NSInteger, accuracyDynamicDeltaDNear, @"accuracy_dynamic_deltad_near")
UPDATE3(NSInteger, accuracyDynamicDeltaDMidrange, @"accuracy_dynamic_deltad_midrange")
UPDATE3(NSInteger, accuracyDynamicDeltaDFar, @"accuracy_dynamic_deltad_far")
UPDATE3(NSInteger, accuracyDynamicDistanceNearToMidrange, @"accuracy_dynamic_distance_neartomidrange")
UPDATE3(NSInteger, accuracyDynamicDistanceMidrangeToFar, @"accuracy_dynamic_distance_midrangetofar")
UPDATE3(NSInteger, accuracyStaticAccuracyNavigating, @"accuracy_static_accuracy_navigating")
UPDATE3(NSInteger, accuracyStaticAccuracyNonNavigating, @"accuracy_static_accuracy_nonnavigating")
UPDATE3(NSInteger, accuracyStaticDeltaDNavigating, @"accuracy_static_deltad_navigating")
UPDATE3(NSInteger, accuracyStaticDeltaDNonNavigating, @"accuracy_static_deltad_nonnavigating")
UPDATE3(NSInteger, currentPage, @"page_current")
UPDATE3(NSInteger, currentPageTab, @"pagetab_current")
UPDATE3(NSInteger, lastImportGroup, @"lastimport_group")
UPDATE3(NSInteger, lastAddedGroup, @"lastadded_group")
UPDATE3(NSInteger, lastImportSource, @"lastimport_source")
UPDATE3(NSInteger, mapExternal, @"map_external")
UPDATE3(NSInteger, compassType, @"compass_type")
UPDATE3(NSInteger, themeType, @"theme_type")
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
UPDATE3(NSInteger, mapSearchMaximumNumberGCA, @"mapsearchmaximum_numbergca")
UPDATE3(NSInteger, mapSearchMaximumDistanceGS, @"mapsearchmaximum_distancegs")
UPDATE3(NSInteger, mapSearchMaximumDistanceOKAPI, @"mapsearchmaximum_distanceokapi")
UPDATE3(NSInteger, mapSearchMaximumDistanceGCA, @"mapsearchmaximum_distancegca")
UPDATE3(NSInteger, waypointListSortBy, @"waypointlist_sortby")
UPDATE3(NSInteger, listSortBy, @"list_sortby")
UPDATE3(NSInteger, locationlessListSortBy, @"locationless_sortby")
UPDATE3(NSInteger, configUpdateLastTime, @"configupdate_lasttime")
UPDATE3(NSInteger, automaticDatabaseBackupPeriod, @"automaticdatabasebackup_period")
UPDATE3(NSInteger, automaticDatabaseBackupRotate, @"automaticdatabasebackup_rotate")

UPDATE3(float, keeptrackTimeDeltaMin, @"keeptrack_timedelta_min")
UPDATE3(float, keeptrackTimeDeltaMax, @"keeptrack_timedelta_max")
UPDATE3(float, mapClustersZoomLevel, @"map_clusters_zoomlevel")

UPDATE4(NSString *, NSString, currentWaypoint, @"waypoint_current")
UPDATE4(NSString *, NSString, mapBrandDefault, @"map_branddefault")
UPDATE4(NSString *, NSString, logTemporaryText, @"log_temporary_text")
UPDATE4(NSString *, NSString, opencageKey, @"opencage_key")
UPDATE4(NSString *, NSString, configUpdateLastVersion, @"configupdate_lastversion")

UPDATE4(NSTimeInterval, double, automaticDatabaseBackupLast, @"automaticdatabasebackup_last")

UPDATE5(dbTrack *, NSId, currentTrack, @"track_current", _id)

///////

- (void)mapTrackColourUpdate:(NSString *)value
{
    self.mapTrackColour = [ImageLibrary RGBtoColor:value];
    [self NSStringUpdate:@"map_track_colour" value:value];
}
- (void)mapDestinationColourUpdate:(NSString *)value
{
    self.mapDestinationColour = [ImageLibrary RGBtoColor:value];
    [self NSStringUpdate:@"map_destination_colour" value:value];
}

@end
