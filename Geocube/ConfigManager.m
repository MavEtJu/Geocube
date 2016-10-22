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

@interface ConfigManager ()

@end

@implementation ConfigManager

@synthesize keyGMS, keyMapbox;
@synthesize distanceMetric, currentWaypoint, currentPage, currentPageTab, currentTrack;
@synthesize lastImportGroup, lastImportSource, lastAddedGroup;
@synthesize mapExternal, mapBrand, mapTrackColour, mapDestinationColour, compassType, themeType, orientationsAllowed;
@synthesize soundDirection, soundDistance;
@synthesize keeptrackAutoRotate, keeptrackTimeDeltaMin, keeptrackTimeDeltaMax, keeptrackDistanceDeltaMin, keeptrackDistanceDeltaMax, keeptrackPurgeAge, keeptrackSync;
@synthesize mapClustersEnable, mapClustersZoomLevel, mapRotateToBearing;
@synthesize GCLabelFont, GCSmallFont, GCTextblockFont;
@synthesize dynamicmapEnable, dynamicmapWalkingSpeed, dynamicmapWalkingDistance, dynamicmapCyclingSpeed, dynamicmapCyclingDistance, dynamicmapDrivingSpeed, dynamicmapDrivingDistance;
@synthesize mapcacheEnable, mapcacheMaxAge, mapcacheMaxSize;
@synthesize downloadImagesLogs, downloadImagesWaypoints, downloadImagesMobile, downloadQueriesMobile;
@synthesize mapSearchMaximumDistanceGS, mapSearchMaximumDistanceOKAPI, mapSearchMaximumNumberGCA;
@synthesize downloadTimeoutQuery, downloadTimeoutSimple;
@synthesize markasFoundDNFClearsTarget, markasFoundMarksAllWaypoints, loggingRemovesMarkedAsFoundDNF;
@synthesize compassAlwaysInPortraitMode, showCountryAsAbbrevation, showStateAsAbbrevation, showStateAsAbbrevationIfLocaleExists;
@synthesize waypointListSortBy;
@synthesize refreshWaypointAfterLog;
@synthesize accountsSaveAuthenticationName, accountsSaveAuthenticationPassword;
@synthesize gpsAdjustmentEnable, gpsAdjustmentLatitude, gpsAdjustmentLongitude;

- (instancetype)init
{
    self = [super init];

    [self checkDefaults];
    [self loadValues];

    UITableViewCell *tvc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    GCLabelFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    GCTextblockFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    GCSmallFont = [UIFont systemFontOfSize:11];

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
    CHECK(@"waypoint_current", @"");
    CHECK(@"page_current", @"0");
    CHECK(@"pagetab_current", @"0");
    CHECK(@"track_current", @"0");
    CHECK(@"lastimport_group", @"0");
    CHECK(@"lastadded_group", @"0");
    CHECK(@"lastimport_source", @"0");

    CHECK(@"key_gms", @"");
    CHECK(@"key_mapbox", @"");

    CHECK(@"map_external", @"1");
    CHECK(@"map_brand", @"0");
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

    CHECK(@"accounts_save_authenticationname", @"1");
    CHECK(@"accounts_save_authenticationpassword", @"0");

    CHECK(@"gpsadjustment_enable", @"0");
    CHECK(@"gpsadjustment_latitude", @"0");
    CHECK(@"gpsadjustment_longitude", @"0");
}

- (void)loadValues
{
    distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
    currentTrack = [[dbConfig dbGetByKey:@"track_current"].value integerValue];
    lastImportSource = [[dbConfig dbGetByKey:@"lastimport_source"].value integerValue];
    lastImportGroup = [[dbConfig dbGetByKey:@"lastimport_group"].value integerValue];
    lastAddedGroup = [[dbConfig dbGetByKey:@"lastadded_group"].value integerValue];
    mapExternal = [[dbConfig dbGetByKey:@"map_external"].value integerValue];
    mapBrand = [[dbConfig dbGetByKey:@"map_brand"].value integerValue];
    mapTrackColour = [ImageLibrary RGBtoColor:[dbConfig dbGetByKey:@"map_track_colour"].value];
    mapDestinationColour = [ImageLibrary RGBtoColor:[dbConfig dbGetByKey:@"map_destination_colour"].value];
    compassType = [[dbConfig dbGetByKey:@"compass_type"].value integerValue];
    themeType = [[dbConfig dbGetByKey:@"theme_type"].value integerValue];
    orientationsAllowed = [[dbConfig dbGetByKey:@"orientations_allowed"].value integerValue];
    soundDirection = [[dbConfig dbGetByKey:@"sound_direction"].value boolValue];
    soundDistance = [[dbConfig dbGetByKey:@"sound_distance"].value boolValue];
    keeptrackAutoRotate = [[dbConfig dbGetByKey:@"keeptrack_autorotate"].value boolValue];
    keeptrackTimeDeltaMin = [[dbConfig dbGetByKey:@"keeptrack_timedelta_min"].value floatValue];
    keeptrackTimeDeltaMax = [[dbConfig dbGetByKey:@"keeptrack_timedelta_max"].value floatValue];
    keeptrackDistanceDeltaMin = [[dbConfig dbGetByKey:@"keeptrack_distancedelta_min"].value floatValue];
    keeptrackDistanceDeltaMax = [[dbConfig dbGetByKey:@"keeptrack_distancedelta_max"].value floatValue];
    keeptrackPurgeAge = [[dbConfig dbGetByKey:@"keeptrack_purgeage"].value integerValue];
    keeptrackSync = [[dbConfig dbGetByKey:@"keeptrack_sync"].value integerValue];
    mapClustersEnable = [[dbConfig dbGetByKey:@"map_clusters_enable"].value boolValue];
    mapClustersZoomLevel = [[dbConfig dbGetByKey:@"map_clusters_zoomlevel"].value floatValue];
    mapRotateToBearing = [[dbConfig dbGetByKey:@"map_rotate_to_bearing"].value boolValue];
    dynamicmapEnable = [[dbConfig dbGetByKey:@"dynamicmap_enable"].value boolValue];
    dynamicmapWalkingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_walking"].value floatValue];
    dynamicmapCyclingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_cycling"].value floatValue];
    dynamicmapDrivingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_driving"].value floatValue];
    dynamicmapWalkingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_walking"].value integerValue];
    dynamicmapCyclingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_cycling"].value integerValue];
    dynamicmapDrivingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_driving"].value integerValue];
    mapcacheEnable = [[dbConfig dbGetByKey:@"mapcache_enable"].value boolValue];
    mapcacheMaxAge = [[dbConfig dbGetByKey:@"mapcache_maxage"].value integerValue];
    mapcacheMaxSize = [[dbConfig dbGetByKey:@"mapcache_maxsize"].value integerValue];
    keyGMS = [dbConfig dbGetByKey:@"key_gms"].value;
    keyMapbox = [dbConfig dbGetByKey:@"key_mapbox"].value;
    downloadImagesLogs = [[dbConfig dbGetByKey:@"download_images_logs"].value boolValue];
    downloadImagesWaypoints = [[dbConfig dbGetByKey:@"download_images_waypoints"].value boolValue];
    downloadImagesMobile = [[dbConfig dbGetByKey:@"download_images_mobile"].value boolValue];
    downloadQueriesMobile = [[dbConfig dbGetByKey:@"download_queries_mobile"].value boolValue];
    downloadTimeoutSimple = [[dbConfig dbGetByKey:@"download_timeout_simple"].value integerValue];
    downloadTimeoutQuery = [[dbConfig dbGetByKey:@"download_timeout_query"].value integerValue];
    mapSearchMaximumNumberGCA = [[dbConfig dbGetByKey:@"mapsearchmaximum_numbergca"].value integerValue];
    mapSearchMaximumDistanceGS = [[dbConfig dbGetByKey:@"mapsearchmaximum_distancegs"].value integerValue];
    mapSearchMaximumDistanceOKAPI = [[dbConfig dbGetByKey:@"mapsearchmaximum_distanceokapi"].value integerValue];
    markasFoundDNFClearsTarget = [[dbConfig dbGetByKey:@"markas_founddnf_clearstarget"].value boolValue];
    markasFoundMarksAllWaypoints = [[dbConfig dbGetByKey:@"markas_foundmarksallwaypoints"].value boolValue];
    loggingRemovesMarkedAsFoundDNF = [[dbConfig dbGetByKey:@"logging_removesmarkedasfounddnf"].value boolValue];
    compassAlwaysInPortraitMode = [[dbConfig dbGetByKey:@"compass_alwaysinportraitmode"].value boolValue];
    showCountryAsAbbrevation = [[dbConfig dbGetByKey:@"showasabbrevation_country"].value boolValue];
    showStateAsAbbrevation = [[dbConfig dbGetByKey:@"showasabbrevation_state"].value boolValue];
    showStateAsAbbrevationIfLocaleExists = [[dbConfig dbGetByKey:@"showasabbrevation_statewithlocale"].value boolValue];
    waypointListSortBy = [[dbConfig dbGetByKey:@"waypointlist_sortby"].value integerValue];
    refreshWaypointAfterLog = [[dbConfig dbGetByKey:@"waypoint_refreshafterlog"].value boolValue];
    accountsSaveAuthenticationName = [[dbConfig dbGetByKey:@"accounts_save_authenticationname"].value boolValue];
    accountsSaveAuthenticationPassword = [[dbConfig dbGetByKey:@"accounts_save_authenticationpassword"].value boolValue];
    gpsAdjustmentEnable = [[dbConfig dbGetByKey:@"gpsadjustment_enable"].value boolValue];
    gpsAdjustmentLongitude = [[dbConfig dbGetByKey:@"gpsadjustment_longitude"].value integerValue];
    gpsAdjustmentLatitude = [[dbConfig dbGetByKey:@"gpsadjustment_latitude"].value integerValue];

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
    distanceMetric = value;
    [self BOOLUpdate:@"distance_metric" value:value];
}

- (void)currentWaypointUpdate:(NSString *)value
{
    currentWaypoint = value;
    [self NSStringUpdate:@"waypoint_current" value:value];
}

- (void)currentPageUpdate:(NSInteger)value
{
    currentPage = value;
    [self NSIntegerUpdate:@"page_current" value:value];
}
- (void)currentPageTabUpdate:(NSInteger)value
{
    currentPageTab = value;
    [self NSIntegerUpdate:@"pagetab_current" value:value];
}

- (void)currentTrackUpdate:(NSId)value
{
    currentTrack = value;
    [self NSIdUpdate:@"track_current" value:value];
}

- (void)lastImportGroupUpdate:(NSInteger)value
{
    lastImportGroup = value;
    [self NSIntegerUpdate:@"lastimport_group" value:value];
}
- (void)lastAddedGroupUpdate:(NSInteger)value
{
    lastAddedGroup = value;
    [self NSIntegerUpdate:@"lastadded_group" value:value];
}
- (void)lastImportSourceUpdate:(NSInteger)value
{
    lastImportSource = value;
    [self NSIntegerUpdate:@"lastimport_source" value:value];
}

- (void)mapExternalUpdate:(NSInteger)value
{
    mapExternal = value;
    [self NSIntegerUpdate:@"map_external" value:value];
}
- (void)mapBrandUpdate:(NSInteger)value
{
    mapBrand = value;
    [self NSIntegerUpdate:@"map_brand" value:value];
}
- (void)mapTrackColourUpdate:(NSString *)value
{
    mapTrackColour = [ImageLibrary RGBtoColor:value];
    [self NSStringUpdate:@"map_track_colour" value:value];
}
- (void)mapDestinationColourUpdate:(NSString *)value
{
    mapDestinationColour = [ImageLibrary RGBtoColor:value];
    [self NSStringUpdate:@"map_destination_colour" value:value];
}
- (void)compassTypeUpdate:(NSInteger)value
{
    compassType = value;
    [self NSIntegerUpdate:@"compass_type" value:value];
}
- (void)themeTypeUpdate:(NSInteger)value
{
    themeType = value;
    [self NSIntegerUpdate:@"theme_type" value:value];
}
- (void)orientationsAllowedUpdate:(NSInteger)value
{
    orientationsAllowed = value;
    [self NSIntegerUpdate:@"orientations_allowed" value:value];
}

- (void)soundDirectionUpdate:(BOOL)value
{
    soundDirection = value;
    [self BOOLUpdate:@"sound_direction" value:value];
}
- (void)soundDistanceUpdate:(BOOL)value
{
    soundDistance = value;
    [self BOOLUpdate:@"sound_distance" value:value];
}

- (void)keeptrackAutoRotateUpdate:(BOOL)value
{
    keeptrackAutoRotate = value;
    [self BOOLUpdate:@"keeptrack_autorotate" value:value];
}

- (void)keeptrackTimeDeltaMinUpdate:(float)value
{
    keeptrackTimeDeltaMin = value;
    [self FloatUpdate:@"keeptrack_timedelta_min" value:value];
}
- (void)keeptrackTimeDeltaMaxUpdate:(float)value
{
    keeptrackTimeDeltaMax = value;
    [self FloatUpdate:@"keeptrack_timedelta_max" value:value];
}
- (void)keeptrackDistanceDeltaMinUpdate:(NSInteger)value
{
    keeptrackDistanceDeltaMin = value;
    [self NSIntegerUpdate:@"keeptrack_distancedelta_min" value:value];
}
- (void)keeptrackDistanceDeltaMaxUpdate:(NSInteger)value
{
    keeptrackDistanceDeltaMax = value;
    [self NSIntegerUpdate:@"keeptrack_distancedelta_max" value:value];
}
- (void)keeptrackPurgeAgeUpdate:(NSInteger)value
{
    keeptrackPurgeAge = value;
    [self NSIntegerUpdate:@"keeptrack_purgeage" value:value];
}
- (void)keeptrackSync:(NSInteger)value
{
    keeptrackSync = value;
    [self NSIntegerUpdate:@"keeptrack_sync" value:value];
}

- (void)mapClustersUpdateEnable:(BOOL)value
{
    mapClustersEnable = value;
    [self BOOLUpdate:@"map_clusters_enable" value:value];
}
- (void)mapClustersUpdateZoomLevel:(float)value
{
    mapClustersZoomLevel = value;
    [self FloatUpdate:@"map_clusters_zoomlevel" value:value];
}
- (void)mapRotateToBearingUpdate:(BOOL)value
{
    mapRotateToBearing = value;
    [self BOOLUpdate:@"map_rotate_to_bearing" value:value];
}

- (void)dynamicmapEnableUpdate:(BOOL)value
{
    dynamicmapEnable = value;
    [self BOOLUpdate:@"dynamicmap_enable" value:value];
}
- (void)dynamicmapWalkingSpeedUpdate:(NSInteger)value
{
    dynamicmapWalkingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_walking" value:value];
}
- (void)dynamicmapWalkingDistanceUpdate:(NSInteger)value
{
    dynamicmapWalkingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_walking" value:value];
}
- (void)dynamicmapCyclingSpeedUpdate:(NSInteger)value
{
    dynamicmapCyclingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_cycling" value:value];
}
- (void)dynamicmapCyclingDistanceUpdate:(NSInteger)value
{
    dynamicmapCyclingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_cycling" value:value];
}
- (void)dynamicmapDrivingSpeedUpdate:(NSInteger)value
{
    dynamicmapDrivingSpeed = value;
    [self NSIntegerUpdate:@"dynamicmap_speed_driving" value:value];
}
- (void)dynamicmapDrivingDistanceUpdate:(NSInteger)value
{
    dynamicmapDrivingDistance = value;
    [self NSIntegerUpdate:@"dynamicmap_distance_driving" value:value];
}

- (void)mapcacheEnableUpdate:(BOOL)value
{
    mapcacheEnable = value;
    [self BOOLUpdate:@"mapcache_enable" value:value];
}
- (void)mapcacheMaxSizeUpdate:(NSInteger)value
{
    mapcacheMaxSize = value;
    [self NSIntegerUpdate:@"mapcache_maxsize" value:value];
}
- (void)mapcacheMaxAgeUpdate:(NSInteger)value
{
    mapcacheMaxAge = value;
    [self NSIntegerUpdate:@"mapcache_maxage" value:value];
}

- (void)keyGMSUpdate:(NSString *)value
{
    keyGMS = value;
    [self NSStringUpdate:@"key_gms" value:value];
}
- (void)keyMapboxUpdate:(NSString *)value
{
    keyMapbox = value;
    [self NSStringUpdate:@"key_mapbox" value:value];
}

- (void)downloadImagesLogsUpdate:(BOOL)value
{
    downloadImagesLogs = value;
    [self BOOLUpdate:@"download_images_logs" value:value];
}

- (void)downloadImagesWaypointsUpdate:(BOOL)value
{
    downloadImagesWaypoints = value;
    [self BOOLUpdate:@"download_images_waypoints" value:value];
}

- (void)downloadImagesMobileUpdate:(BOOL)value
{
    downloadImagesMobile = value;
    [self BOOLUpdate:@"download_images_mobile" value:value];
}

- (void)downloadQueriesMobileUpdate:(BOOL)value;
{
    downloadQueriesMobile = value;
    [self BOOLUpdate:@"download_queries_mobile" value:value];
}
- (void)downloadTimeoutSimpleUpdate:(NSInteger)value
{
    downloadTimeoutSimple = value;
    [self NSIntegerUpdate:@"download_timeout_simple" value:value];
}
- (void)downloadTimeoutQueryUpdate:(NSInteger)value
{
    downloadTimeoutQuery = value;
    [self NSIntegerUpdate:@"download_timeout_query" value:value];
}

- (void)mapSearchMaximumNumberGCAUpdate:(NSInteger)value
{
    mapSearchMaximumNumberGCA = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_numbergca" value:value];
}
- (void)mapSearchMaximumDistanceGSUpdate:(NSInteger)value
{
    mapSearchMaximumDistanceGS = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_distancegs" value:value];
}
- (void)mapSearchMaximumDistanceOKAPIUpdate:(NSInteger)value
{
    mapSearchMaximumDistanceOKAPI = value;
    [self NSIntegerUpdate:@"mapsearchmaximum_distanceokapi" value:value];
}

- (void)markasFoundDNFClearsTargetUpdate:(BOOL)value
{
    markasFoundDNFClearsTarget = value;
    [self BOOLUpdate:@"markas_founddnf_clearstarget" value:value];
}
- (void)markasFoundMarksAllWaypointsUpdate:(BOOL)value
{
    markasFoundMarksAllWaypoints = value;
    [self BOOLUpdate:@"markas_foundmarksallwaypoints" value:value];
}
- (void)loggingRemovesMarkedAsFoundDNFUpdate:(BOOL)value
{
    loggingRemovesMarkedAsFoundDNF = value;
    [self BOOLUpdate:@"logging_removesmarkedasfounddnf" value:value];
}

- (void)compassAlwaysInPortraitModeUpdate:(BOOL)value
{
    compassAlwaysInPortraitMode = value;
    [self BOOLUpdate:@"compass_alwaysinportraitmode" value:value];
}
- (void)showStateAsAbbrevationUpdate:(BOOL)value
{
    showStateAsAbbrevation = value;
    [self BOOLUpdate:@"showasabbrevation_state" value:value];
}
- (void)showStateAsAbbrevationIfLocaleExistsUpdate:(BOOL)value
{
    showStateAsAbbrevationIfLocaleExists = value;
    [self BOOLUpdate:@"showasabbrevation_statewithlocale" value:value];
}
- (void)showCountryAsAbbrevationUpdate:(BOOL)value
{
    showCountryAsAbbrevation = value;
    [self BOOLUpdate:@"showasabbrevation_country" value:value];
}

- (void)waypointListSortByUpdate:(NSInteger)value
{
    waypointListSortBy = value;
    [self NSIntegerUpdate:@"waypointlist_sortby" value:value];
}

- (void)refreshWaypointAfterLogUpdate:(BOOL)value
{
    refreshWaypointAfterLog = value;
    [self BOOLUpdate:@"waypoint_refreshafterlog" value:value];
}

- (void)accountsSaveAuthenticationNameUpdate:(BOOL)value
{
    accountsSaveAuthenticationName = value;
    [self BOOLUpdate:@"accounts_save_authenticationname" value:value];
}
- (void)accountsSaveAuthenticationPasswordUpdate:(BOOL)value
{
    accountsSaveAuthenticationPassword = value;
    [self BOOLUpdate:@"accounts_save_authenticationpassword" value:value];
}

- (void)gpsAdjustmentEnableUpdate:(BOOL)value
{
    gpsAdjustmentEnable = value;
    [self BOOLUpdate:@"gpsadjustment_enable" value:value];
}
- (void)gpsAdjustmentLongitudeUpdate:(NSInteger)value
{
    gpsAdjustmentLongitude = value;
    [self NSIntegerUpdate:@"gpsadjustment_longitude" value:value];
}
- (void)gpsAdjustmentLatitudeUpdate:(NSInteger)value
{
    gpsAdjustmentLatitude = value;
    [self NSIntegerUpdate:@"gpsadjustment_latitude" value:value];
}

@end
