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

    CHECK(@"distance_metric", @"1");
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

    CHECK(@"gpsadjustment_enable", @"0");
    CHECK(@"gpsadjustment_latitude", @"0");
    CHECK(@"gpsadjustment_longitude", @"0");

    CHECK(@"intro_seen", @"0");

    CHECK(@"log_temporary_text", @"");

    CHECK(@"locationless_showfound", @"1");
    CHECK(@"locationless_sortby", @"0");
}

- (void)loadValues
{
    self.distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    self.sendTweets = [[dbConfig dbGetByKey:@"send_tweets"].value boolValue];
    self.currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    self.currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    self.currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
    self.currentTrack = [[dbConfig dbGetByKey:@"track_current"].value integerValue];
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
    self.showStateAsAbbrevationIfLocaleExists = [[dbConfig dbGetByKey:@"showasabbrevation_statewithlocale"].value boolValue];
    self.waypointListSortBy = [[dbConfig dbGetByKey:@"waypointlist_sortby"].value integerValue];
    self.refreshWaypointAfterLog = [[dbConfig dbGetByKey:@"waypoint_refreshafterlog"].value boolValue];
    self.listSortBy = [[dbConfig dbGetByKey:@"list_sortby"].value integerValue];
    self.accountsSaveAuthenticationName = [[dbConfig dbGetByKey:@"accounts_save_authenticationname"].value boolValue];
    self.accountsSaveAuthenticationPassword = [[dbConfig dbGetByKey:@"accounts_save_authenticationpassword"].value boolValue];
    self.gpsAdjustmentEnable = [[dbConfig dbGetByKey:@"gpsadjustment_enable"].value boolValue];
    self.gpsAdjustmentLongitude = [[dbConfig dbGetByKey:@"gpsadjustment_longitude"].value integerValue];
    self.gpsAdjustmentLatitude = [[dbConfig dbGetByKey:@"gpsadjustment_latitude"].value integerValue];
    self.introSeen = [[dbConfig dbGetByKey:@"intro_seen"].value boolValue];
    self.logTemporaryText = [dbConfig dbGetByKey:@"log_temporary_text"].value;
    self.locationlessShowFound = [[dbConfig dbGetByKey:@"locationless_showfound"].value boolValue];
    self.locationlessListSortBy = [[dbConfig dbGetByKey:@"locationless_sortby"].value integerValue];

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

- (void)FloatUpdate:(NSString *)key value:(float)value
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

- (void)distanceMetricUpdate:(BOOL)value
{
    self.distanceMetric = value;
    [self BOOLUpdate:@"distance_metric" value:value];
}

- (void)sendTweetsUpdate:(BOOL)value
{
    self.sendTweets = value;
    [self BOOLUpdate:@"send_tweets" value:value];
}

- (void)currentWaypointUpdate:(NSString *)value
{
    self.currentWaypoint = value;
    [self NSStringUpdate:@"waypoint_current" value:value];
}

- (void)currentPageUpdate:(NSInteger)value
{
    self.currentPage = value;
    [self NSIntegerUpdate:@"page_current" value:value];
}
- (void)currentPageTabUpdate:(NSInteger)value
{
    self.currentPageTab = value;
    [self NSIntegerUpdate:@"pagetab_current" value:value];
}

- (void)currentTrackUpdate:(NSId)value
{
    self.currentTrack = value;
    [self NSIdUpdate:@"track_current" value:value];
}

- (void)lastImportGroupUpdate:(NSInteger)value
{
    self.lastImportGroup = value;
    [self NSIntegerUpdate:@"lastimport_group" value:value];
}
- (void)lastAddedGroupUpdate:(NSInteger)value
{
    self.lastAddedGroup = value;
    [self NSIntegerUpdate:@"lastadded_group" value:value];
}
- (void)lastImportSourceUpdate:(NSInteger)value
{
    self.lastImportSource = value;
    [self NSIntegerUpdate:@"lastimport_source" value:value];
}

- (void)mapExternalUpdate:(NSInteger)value
{
    self.mapExternal = value;
    [self NSIntegerUpdate:@"map_external" value:value];
}
- (void)mapBrandDefaultUpdate:(NSString *)value
{
    self.mapBrandDefault = value;
    [self NSStringUpdate:@"map_branddefault" value:value];
}
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
- (void)compassTypeUpdate:(NSInteger)value
{
    self.compassType = value;
    [self NSIntegerUpdate:@"compass_type" value:value];
}
- (void)themeTypeUpdate:(NSInteger)value
{
    self.themeType = value;
    [self NSIntegerUpdate:@"theme_type" value:value];
}
- (void)orientationsAllowedUpdate:(NSInteger)value
{
    self.orientationsAllowed = value;
    [self NSIntegerUpdate:@"orientations_allowed" value:value];
}

- (void)soundDirectionUpdate:(BOOL)value
{
    self.soundDirection = value;
    [self BOOLUpdate:@"sound_direction" value:value];
}
- (void)soundDistanceUpdate:(BOOL)value
{
    self.soundDistance = value;
    [self BOOLUpdate:@"sound_distance" value:value];
}

- (void)keeptrackAutoRotateUpdate:(BOOL)value
{
    self.keeptrackAutoRotate = value;
    [self BOOLUpdate:@"keeptrack_autorotate" value:value];
}

- (void)keeptrackTimeDeltaMinUpdate:(float)value
{
    self.keeptrackTimeDeltaMin = value;
    [self FloatUpdate:@"keeptrack_timedelta_min" value:value];
}
- (void)keeptrackTimeDeltaMaxUpdate:(float)value
{
    self.keeptrackTimeDeltaMax = value;
    [self FloatUpdate:@"keeptrack_timedelta_max" value:value];
}
- (void)keeptrackDistanceDeltaMinUpdate:(NSInteger)value
{
    self.keeptrackDistanceDeltaMin = value;
    [self NSIntegerUpdate:@"keeptrack_distancedelta_min" value:value];
}
- (void)keeptrackDistanceDeltaMaxUpdate:(NSInteger)value
{
    self.keeptrackDistanceDeltaMax = value;
    [self NSIntegerUpdate:@"keeptrack_distancedelta_max" value:value];
}
- (void)keeptrackPurgeAgeUpdate:(NSInteger)value
{
    self.keeptrackPurgeAge = value;
    [self NSIntegerUpdate:@"keeptrack_purgeage" value:value];
}
- (void)keeptrackSync:(NSInteger)value
{
    self.keeptrackSync = value;
    [self NSIntegerUpdate:@"keeptrack_sync" value:value];
}

- (void)mapClustersUpdateEnable:(BOOL)value
{
    self.mapClustersEnable = value;
    [self BOOLUpdate:@"map_clusters_enable" value:value];
}
- (void)mapClustersUpdateZoomLevel:(float)value
{
    self.mapClustersZoomLevel = value;
    [self FloatUpdate:@"map_clusters_zoomlevel" value:value];
}
- (void)mapRotateToBearingUpdate:(BOOL)value
{
    self.mapRotateToBearing = value;
    [self BOOLUpdate:@"map_rotate_to_bearing" value:value];
}

- (void)dynamicmapEnableUpdate:(BOOL)value
{
    self.dynamicmapEnable = value;
    [self BOOLUpdate:@"dynamicmap_enable" value:value];
}
- (void)dynamicmapWalkingSpeedUpdate:(NSInteger)value
{
    self.dynamicmapWalkingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_walking" value:value];
}
- (void)dynamicmapWalkingDistanceUpdate:(NSInteger)value
{
    self.dynamicmapWalkingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_walking" value:value];
}
- (void)dynamicmapCyclingSpeedUpdate:(NSInteger)value
{
    self.dynamicmapCyclingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_cycling" value:value];
}
- (void)dynamicmapCyclingDistanceUpdate:(NSInteger)value
{
    self.dynamicmapCyclingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_cycling" value:value];
}
- (void)dynamicmapDrivingSpeedUpdate:(NSInteger)value
{
    self.dynamicmapDrivingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_driving" value:value];
}
- (void)dynamicmapDrivingDistanceUpdate:(NSInteger)value
{
    self.dynamicmapDrivingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_driving" value:value];
}

- (void)mapcacheEnableUpdate:(BOOL)value
{
    self.mapcacheEnable = value;
    [self BOOLUpdate:@"mapcache_enable" value:value];
}
- (void)mapcacheMaxSizeUpdate:(NSInteger)value
{
    self.mapcacheMaxSize = value;
    [self NSIntegerUpdate:@"mapcache_maxsize" value:value];
}
- (void)mapcacheMaxAgeUpdate:(NSInteger)value
{
    self.mapcacheMaxAge = value;
    [self NSIntegerUpdate:@"mapcache_maxage" value:value];
}

- (void)downloadImagesLogsUpdate:(BOOL)value
{
    self.downloadImagesLogs = value;
    [self BOOLUpdate:@"download_images_logs" value:value];
}

- (void)downloadImagesWaypointsUpdate:(BOOL)value
{
    self.downloadImagesWaypoints = value;
    [self BOOLUpdate:@"download_images_waypoints" value:value];
}

- (void)downloadImagesMobileUpdate:(BOOL)value
{
    self.downloadImagesMobile = value;
    [self BOOLUpdate:@"download_images_mobile" value:value];
}

- (void)downloadQueriesMobileUpdate:(BOOL)value;
{
    self.downloadQueriesMobile = value;
    [self BOOLUpdate:@"download_queries_mobile" value:value];
}
- (void)downloadTimeoutSimpleUpdate:(NSInteger)value
{
    self.downloadTimeoutSimple = value;
    [self NSIntegerUpdate:@"download_timeout_simple" value:value];
}
- (void)downloadTimeoutQueryUpdate:(NSInteger)value
{
    self.downloadTimeoutQuery = value;
    [self NSIntegerUpdate:@"download_timeout_query" value:value];
}

- (void)mapSearchMaximumNumberGCAUpdate:(NSInteger)value
{
    self.mapSearchMaximumNumberGCA = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_numbergca" value:value];
}
- (void)mapSearchMaximumDistanceGSUpdate:(NSInteger)value
{
    self.mapSearchMaximumDistanceGS = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_distancegs" value:value];
}
- (void)mapSearchMaximumDistanceOKAPIUpdate:(NSInteger)value
{
    self.mapSearchMaximumDistanceOKAPI = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_distanceokapi" value:value];
}
- (void)mapSearchMaximumDistanceGCAUpdate:(NSInteger)value
{
    self.mapSearchMaximumDistanceOKAPI = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_distancegca" value:value];
}

- (void)markasFoundDNFClearsTargetUpdate:(BOOL)value
{
    self.markasFoundDNFClearsTarget = value;
    [self BOOLUpdate:@"markas_founddnf_clearstarget" value:value];
}
- (void)markasFoundMarksAllWaypointsUpdate:(BOOL)value
{
    self.markasFoundMarksAllWaypoints = value;
    [self BOOLUpdate:@"markas_foundmarksallwaypoints" value:value];
}
- (void)loggingRemovesMarkedAsFoundDNFUpdate:(BOOL)value
{
    self.loggingRemovesMarkedAsFoundDNF = value;
    [self BOOLUpdate:@"logging_removesmarkedasfounddnf" value:value];
}

- (void)compassAlwaysInPortraitModeUpdate:(BOOL)value
{
    self.compassAlwaysInPortraitMode = value;
    [self BOOLUpdate:@"compass_alwaysinportraitmode" value:value];
}
- (void)showStateAsAbbrevationUpdate:(BOOL)value
{
    self.showStateAsAbbrevation = value;
    [self BOOLUpdate:@"showasabbrevation_state" value:value];
}
- (void)showStateAsAbbrevationIfLocaleExistsUpdate:(BOOL)value
{
    self.showStateAsAbbrevationIfLocaleExists = value;
    [self BOOLUpdate:@"showasabbrevation_statewithlocale" value:value];
}
- (void)showCountryAsAbbrevationUpdate:(BOOL)value
{
    self.showCountryAsAbbrevation = value;
    [self BOOLUpdate:@"showasabbrevation_country" value:value];
}

- (void)waypointListSortByUpdate:(NSInteger)value
{
    self.waypointListSortBy = value;
    [self NSIntegerUpdate:@"waypointlist_sortby" value:value];
}

- (void)refreshWaypointAfterLogUpdate:(BOOL)value
{
    self.refreshWaypointAfterLog = value;
    [self BOOLUpdate:@"waypoint_refreshafterlog" value:value];
}

- (void)listSortByUpdate:(NSInteger)value
{
    self.listSortBy = value;
    [self NSIntegerUpdate:@"list_sortby" value:value];
}

- (void)accountsSaveAuthenticationNameUpdate:(BOOL)value
{
    self.accountsSaveAuthenticationName = value;
    [self BOOLUpdate:@"accounts_save_authenticationname" value:value];
}
- (void)accountsSaveAuthenticationPasswordUpdate:(BOOL)value
{
    self.accountsSaveAuthenticationPassword = value;
    [self BOOLUpdate:@"accounts_save_authenticationpassword" value:value];
}

- (void)gpsAdjustmentEnableUpdate:(BOOL)value
{
    self.gpsAdjustmentEnable = value;
    [self BOOLUpdate:@"gpsadjustment_enable" value:value];
}
- (void)gpsAdjustmentLongitudeUpdate:(NSInteger)value
{
    self.gpsAdjustmentLongitude = value;
    [self NSIntegerUpdate:@"gpsadjustment_longitude" value:value];
}
- (void)gpsAdjustmentLatitudeUpdate:(NSInteger)value
{
    self.gpsAdjustmentLatitude = value;
    [self NSIntegerUpdate:@"gpsadjustment_latitude" value:value];
}

- (void)introSeenUpdate:(BOOL)value
{
    self.introSeen = value;
    [self BOOLUpdate:@"intro_seen" value:value];
}

- (void)logTemporaryTextUpdate:(NSString *)value
{
    self.logTemporaryText = value;
    [self NSStringUpdate:@"log_temporary_text" value:value];
}

- (void)locationlessShowFoundUpdate:(BOOL)value
{
    self.locationlessShowFound = value;
    [self BOOLUpdate:@"locationless_showfound" value:value];
}
- (void)locationlessListSortByUpdate:(NSInteger)value
{
    self.locationlessListSortBy = value;
    [self NSIntegerUpdate:@"locationless_sortby" value:value];
}

@end
