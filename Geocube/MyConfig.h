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

@interface MyConfig : NSObject {
    BOOL distanceMetric;
    BOOL themeGeosphere;
    NSString *currentWaypoint;
    NSInteger currentPage;
    NSInteger currentPageTab;

    NSInteger compassType;

    BOOL GeocachingLive_staging;
    NSString *GeocachingLive_API1;
    NSString *GeocachingLive_API2;

    UIFont *GCLabelFont;
    CGFloat GCLabelHeight;
}

@property (nonatomic) BOOL distanceMetric;
@property (nonatomic) BOOL themeGeosphere;

@property (nonatomic, retain) NSString *currentWaypoint;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger currentPageTab;

@property (nonatomic) BOOL GeocachingLive_staging;
@property (nonatomic, retain) NSString *GeocachingLive_API1;
@property (nonatomic, retain) NSString *GeocachingLive_API2;

@property (nonatomic) NSInteger compassType;

@property (nonatomic, readonly, retain) UIFont *GCLabelFont;
@property (nonatomic, readonly) CGFloat GCLabelHeight;

- (void)distanceMetricUpdate:(BOOL)value;
- (void)themeGeosphereUpdate:(BOOL)value;
- (void)currentWaypointUpdate:(NSString *)name;
- (void)currentPageUpdate:(NSInteger)value;
- (void)currentPageTabUpdate:(NSInteger)value;
- (void)compassTypeUpdate:(NSInteger)value;
- (void)geocachingLive_staging:(BOOL)value;
- (void)geocachingLive_API1Update:(NSString *)value;
- (void)geocachingLive_API2Update:(NSString *)value;

@end
