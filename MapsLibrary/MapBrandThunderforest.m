/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface MapBrandThunderforest ()

@end

@implementation MapBrandThunderforest

+ (NSArray<NSString *> *)cachePrefixes
{
    return @[
             @"ThunderforestNeighbourhood",
             @"ThunderforestOutdoors",
             @"ThunderforestLandscape",
             @"ThunderforestSpinalTap",
             @"ThunderforestCycling",
             @"ThunderforestTransport",
             ];
}

- (NSArray<NSString *> *)tileServices
{
    NSMutableArray<NSString *> *tss = [NSMutableArray arrayWithArray:@[
             @"https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png",
             @"https://tile.thunderforest.com/outdoors/{z}/{x}/{y}.png",
             @"https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png",
             @"https://tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png",
             @"https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png",
             @"https://tile.thunderforest.com/transport/{z}/{x}/{y}.png",
             ]];

    [tss enumerateObjectsUsingBlock:^(NSString * _Nonnull ts, NSUInteger idx, BOOL * _Nonnull stop) {
        ts = [ts stringByAppendingString:[NSString stringWithFormat:@"?apikey=%@", configManager.thunderforestKey]];
        [tss replaceObjectAtIndex:idx withObject:ts];
    }];

    return tss;
}

- (NSArray<NSNumber *> *)mapHasViews
{
    return @[
             [NSNumber numberWithInteger:MAPTYPE_NEIGHBOURHOOD],
             [NSNumber numberWithInteger:MAPTYPE_OUTDOORS],
             [NSNumber numberWithInteger:MAPTYPE_LANDSCAPE],
             [NSNumber numberWithInteger:MAPTYPE_SPINALMAP],
             [NSNumber numberWithInteger:MAPTYPE_CYCLING],
             [NSNumber numberWithInteger:MAPTYPE_PUBLICTRANSPORT],
             ];
}

- (NSString *)credits
{
    return @"© Thunderforest";
}

@end
