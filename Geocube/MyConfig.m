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

@interface MyConfig ()
{
    NSMutableArray *delegates;

    BOOL distanceMetric;

    NSString *currentWaypoint;
    NSInteger currentPage;
    NSInteger currentPageTab;

    NSId currentTrack;

    NSInteger lastImportSource;
    NSInteger lastImportGroup;
    NSInteger lastAddedGroup;

    NSInteger mapExternal;
    NSInteger mapBrand;
    NSInteger compassType;
    NSInteger themeType;

    BOOL soundDirection;
    BOOL soundDistance;

    BOOL mapClustersEnable;
    float mapClustersZoomLevel;

    UIFont *GCLabelFont;
    UIFont *GCSmallFont;
    UIFont *GCTextblockFont;

    BOOL dynamicmapEnable;
    NSInteger dynamicmapWalkingSpeed;
    NSInteger dynamicmapWalkingDistance;
    NSInteger dynamicmapCyclingSpeed;
    NSInteger dynamicmapCyclingDistance;
    NSInteger dynamicmapDrivingSpeed;
    NSInteger dynamicmapDrivingDistance;
}

@end

@implementation MyConfig

@synthesize distanceMetric, currentWaypoint, currentPage, currentPageTab, currentTrack;
@synthesize lastImportGroup, lastImportSource, lastAddedGroup;
@synthesize mapExternal, mapBrand, compassType, themeType;
@synthesize soundDirection, soundDistance;
@synthesize mapClustersEnable, mapClustersZoomLevel;
@synthesize GCLabelFont, GCSmallFont, GCTextblockFont;
@synthesize dynamicmapEnable, dynamicmapWalkingSpeed, dynamicmapWalkingDistance, dynamicmapCyclingSpeed, dynamicmapCyclingDistance, dynamicmapDrivingSpeed, dynamicmapDrivingDistance;

- (instancetype)init
{
    self = [super init];

    delegates = [[NSMutableArray alloc] initWithCapacity:3];

    [self checkDefaults];
    [self loadValues];

    UITableViewCell *tvc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    GCLabelFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    GCTextblockFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    GCSmallFont = [UIFont systemFontOfSize:11];

    NSLog(@"%@ initialized", [self class]);

    return self;
}

- (void)addDelegate:(id)destination
{
    __block BOOL alreadythere = NO;
    [delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        if (delegate == destination) {
            alreadythere = YES;
            *stop = YES;
        }
    }];
    if (alreadythere == YES)
        return;
    [delegates addObject:destination];
    NSLog(@"%@: adding delegate to %@", [self class], [destination class]);
}

- (void)deleteDelegate:(id)destination;
{
    __block BOOL isthere = NO;
    [delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        if (delegate == destination) {
            isthere = YES;
            *stop = YES;
        }
    }];
    if (isthere == NO) {
        NSLog(@"%@: delegate %@ not found for removal", [self class], [destination class]);
        return;
    }
    [delegates removeObject:destination];
    NSLog(@"%@: removing delegate %@", [self class], [destination class]);
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
    CHECK(@"map_external", @"0");
    CHECK(@"map_brand", @"0");
    CHECK(@"compass_type", @"0");
    CHECK(@"theme_type", @"0");
    CHECK(@"sound_direction", @"0");
    CHECK(@"sound_distance", @"0");
    CHECK(@"map_clusters_enable", @"0");
    CHECK(@"map_clusters_zoomlevel", @"11.0");

    CHECK(@"dynamicmap_enable", @"1");
    CHECK(@"dynamicmap_speed_walking", @"7");
    CHECK(@"dynamicmap_speed_cycling", @"40");
    CHECK(@"dynamicmap_speed_driving", @"120");
    CHECK(@"dynamicmap_distance_walking", @"100");
    CHECK(@"dynamicmap_distance_cycling", @"1000");
    CHECK(@"dynamicmap_distance_driving", @"5000");
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
    compassType = [[dbConfig dbGetByKey:@"compass_type"].value integerValue];
    themeType = [[dbConfig dbGetByKey:@"theme_type"].value integerValue];
    soundDirection = [[dbConfig dbGetByKey:@"sound_direction"].value boolValue];
    soundDistance = [[dbConfig dbGetByKey:@"sound_distance"].value boolValue];
    mapClustersEnable = [[dbConfig dbGetByKey:@"map_clusters_enable"].value boolValue];
    mapClustersZoomLevel = [[dbConfig dbGetByKey:@"map_clusters_zoomlevel"].value floatValue];
    dynamicmapEnable = [[dbConfig dbGetByKey:@"dynamicmap_enable"].value boolValue];
    dynamicmapWalkingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_walking"].value floatValue];
    dynamicmapCyclingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_cycling"].value floatValue];
    dynamicmapDrivingDistance = [[dbConfig dbGetByKey:@"dynamicmap_distance_driving"].value floatValue];
    dynamicmapWalkingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_walking"].value integerValue];
    dynamicmapCyclingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_cycling"].value integerValue];
    dynamicmapDrivingSpeed = [[dbConfig dbGetByKey:@"dynamicmap_speed_driving"].value integerValue];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_resetpage"] == TRUE) {
        NSLog(@"Erasing page settings.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_resetpage"];

        [self currentPageUpdate:0];
        [self currentPageTabUpdate:0];
    }
}

- (void)sendDelegatesMapClusters
{
    [delegates enumerateObjectsUsingBlock:^(id delegate, NSUInteger idx, BOOL * _Nonnull stop) {
        [delegate changeMapClusters:mapClustersEnable zoomLevel:mapClustersZoomLevel];
    }];
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

- (void)mapClustersUpdateEnable:(BOOL)value
{
    mapClustersEnable = value;
    [self BOOLUpdate:@"map_clusters_enable" value:value];
    [self sendDelegatesMapClusters];
}
- (void)mapClustersUpdateZoomLevel:(float)value
{
    mapClustersZoomLevel = value;
    [self FloatUpdate:@"map_clusters_zoomlevel" value:value];
    [self sendDelegatesMapClusters];
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

@end
