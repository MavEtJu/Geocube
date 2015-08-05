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

@synthesize distanceMetric, themeGeosphere, currentWaypoint, currentPage, currentPageTab;

- (id)init
{
    self = [super init];

    [self checkDefaults];
    [self loadValues];

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
}

- (void)loadValues
{
    distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    themeGeosphere = [[dbConfig dbGetByKey:@"theme_geosphere"].value boolValue];
    currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
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

@end
