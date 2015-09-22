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

@synthesize distanceMetric, currentWaypoint, currentPage, currentPageTab;
@synthesize lastImportGroup, lastImportSource;
@synthesize compassType, themeType;
@synthesize soundDirection, soundDistance;
@synthesize GCLabelFont, GCSmallFont, GCTextblockFont;

- (instancetype)init
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
    CHECK(@"waypoint_current", @"");
    CHECK(@"page_current", @"0");
    CHECK(@"pagetab_current", @"0");
    CHECK(@"lastimport_group", @"0");
    CHECK(@"lastimport_source", @"0");
    CHECK(@"compass_type", @"0");
    CHECK(@"theme_type", @"0");
    CHECK(@"sound_direction", @"0");
    CHECK(@"sound_distance", @"0");
}

- (void)loadValues
{
    distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
    currentWaypoint = [dbConfig dbGetByKey:@"waypoint_current"].value;
    currentPage = [[dbConfig dbGetByKey:@"page_current"].value integerValue];
    currentPageTab = [[dbConfig dbGetByKey:@"pagetab_current"].value integerValue];
    lastImportSource = [[dbConfig dbGetByKey:@"lastimport_source"].value integerValue];
    lastImportGroup = [[dbConfig dbGetByKey:@"lastimport_group"].value integerValue];
    compassType = [[dbConfig dbGetByKey:@"compass_type"].value integerValue];
    themeType = [[dbConfig dbGetByKey:@"theme_type"].value integerValue];
    soundDirection = [[dbConfig dbGetByKey:@"sound_direction"].value boolValue];
    soundDistance = [[dbConfig dbGetByKey:@"sound_distance"].value boolValue];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_resetpage"] == TRUE) {
        NSLog(@"Erasing page settings.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_resetpage"];

        [self currentPageUpdate:0];
        [self currentPageTabUpdate:0];
    }
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

@end
