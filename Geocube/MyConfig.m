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

@synthesize distanceMetric;

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

    c = [dbConfig dbGetByKey:@"distance_metric"];
    if (c == nil)
        [dbConfig dbUpdateOrInsert:@"distance_metric" value:@"1"];
}

- (void)loadValues
{
    distanceMetric = [[dbConfig dbGetByKey:@"distance_metric"].value boolValue];
}

- (void)metricUpdate:(BOOL)value
{
    distanceMetric = value;
    dbConfig *c = [dbConfig dbGetByKey:@"distance_metric"];
    c.value = [NSString stringWithFormat:@"%ld", (long)value];
    [c dbUpdate];
}

@end
