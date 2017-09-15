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

#import "MapBrand.h"

@interface MapBrand ()

@end

@implementation MapBrand

+ (MapBrand *)mapBrandWithData:(Class)mapClass defaultString:(NSString *)defaultString menuLabel:(NSString *)menuLabel key:(NSString *)key
{
    MapBrand *mp = [[MapBrand alloc] init];

    mp.menuLabel = menuLabel;
    mp.key = key;
    mp.defaultString = defaultString;
    mp.mapObject = mapClass;

    return mp;
}

+ (MapBrand *)findMapBrand:(NSString *)key brands:(NSArray<MapBrand *> *)brands
{
    __block MapBrand *m = nil;
    [brands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([mb.key isEqualToString:key] == YES) {
            m = mb;
            *stop = YES;
        }
    }];
    return m;
}

@end
