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

@interface MapAppleOSM ()

@end

@implementation MapAppleOSM

+ (NSArray<NSString *> *)cachePrefixes
{
    return @[
             @"OSM",
             ];
}

- (NSArray<NSString *> *)tileServices
{
    return @[
             @"https://tile.openstreetmap.org/{z}/{x}/{y}.png",
             ];
}

- (NSArray<NSNumber *> *)mapHasViews
{
    return @[
             [NSNumber numberWithInteger:MAPTYPE_NORMAL],
             ];
}

- (void)initMap
{
    self.creditsText = @"© OpenStreetMap";
    self.tileServerTemplate = [[self tileServices] objectAtIndex:0];
    self.cachePrefix = [[[self class] cachePrefixes] objectAtIndex:0];
    [super initMap];
    self.minimumAltitude = 287;
}

- (BOOL)menuOpenInSupported
{
    return [MWMApi isApiSupported];
}

- (void)menuOpenIn
{
    NSMutableArray<MWMPin *> *pins = [NSMutableArray array];

    [waypointManager.currentWaypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        MWMPin *pin = [[MWMPin alloc] initWithLat:wp.wpt_latitude lon:wp.wpt_longitude title:[NSString stringWithFormat:@"%@ - %@", wp.wpt_name, wp.wpt_urlname] idOrUrl:nil];
        [pins addObject:pin];
    }];
    [MWMApi showPins:pins];
}

@end
