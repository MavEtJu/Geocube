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

@implementation MyConfig

@synthesize GCLabelFont, GCSmallFont, GCTextblockFont;
@synthesize distanceMetric, themeGeosphere, currentWaypoint, currentPage, currentPageTab;
@synthesize lastImportGroup, lastImportSource;
@synthesize GeocachingLive_API1, GeocachingLive_API2, GeocachingLive_staging;
@synthesize compassType;

- (id)init
{
    self = [super init];

    [self checkDefaults];
    [self loadValues];

    UITableViewCell *tvc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    GCLabelFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];
    GCTextblockFont = [UIFont systemFontOfSize:tvc.detailTextLabel.font.pointSize];
    GCSmallFont = [UIFont systemFontOfSize:11];

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
    CHECK(@"theme_geosphere", @"0");
    CHECK(@"waypoint_current", @"");
    CHECK(@"page_current", @"0");
    CHECK(@"pagetab_current", @"0");
    CHECK(@"lastimport_group", @"0");
    CHECK(@"lastimport_source", @"0");
    CHECK(@"geocachinglive_staging", @"1");
    CHECK(@"geocachinglive_API1", @"");
    CHECK(@"geocachinglive_API2", @"");
    CHECK(@"compass_type", @"0");
}

- (void)loadValues
{
    distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    themeGeosphere = [[dbConfig dbGetByKey:@"theme_geosphere"].value boolValue];
    currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
    lastImportSource = [[dbConfig dbGetByKey:@"lastimport_source"].value integerValue];
    lastImportGroup = [[dbConfig dbGetByKey:@"lastimport_group"].value integerValue];
    GeocachingLive_staging = [[dbConfig dbGetByKey:@"geocachinglive_staging"].value boolValue];
    GeocachingLive_API1 = [dbConfig dbGetByKey:@"geocachinglive_API1"].value;
    GeocachingLive_API2 = [dbConfig dbGetByKey:@"geocachinglive_API2"].value;
    compassType = [[dbConfig dbGetByKey:@"compass_type"].value integerValue];
}

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

- (void)NSStringUpdate:(NSString *)key value:(NSString *)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    c.value = value;
    [c dbUpdate];
}

- (void)distanceMetricUpdate:(BOOL)value
{
    distanceMetric = value;
    [self BOOLUpdate:@"distance_metric" value:value];
}

- (void)themeGeosphereUpdate:(BOOL)value
{
    themeGeosphere = value;
    [self BOOLUpdate:@"theme_geosphere" value:value];
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

- (void)lastImportGroupUpdate:(NSInteger)value
{
    lastImportGroup = value;
    [self NSIntegerUpdate:@"lastimport_group" value:value];
}

- (void)lastImportSourceUpdate:(NSInteger)value
{
    lastImportSource = value;
    [self NSIntegerUpdate:@"lastimport_source" value:value];
}

- (void)geocachingLive_staging:(BOOL)value
{
    GeocachingLive_staging = value;
    [self BOOLUpdate:@"geocachinglive_staging" value:value];
}

- (void)geocachingLive_API1Update:(NSString *)value
{
    GeocachingLive_API1 = value;
    [self NSStringUpdate:@"geocachinglive_API1" value:value];
}

- (void)geocachingLive_API2Update:(NSString *)value
{
    GeocachingLive_API2 = value;
    [self NSStringUpdate:@"geocachinglive_API2" value:value];
}

- (void)compassTypeUpdate:(NSInteger)value
{
    compassType = value;
    [self NSIntegerUpdate:@"compass_type" value:value];
}


@end
