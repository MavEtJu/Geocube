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

@interface MapEsri()

@end

@implementation MapEsri

+ (NSArray<NSString *> *)cachePrefixes
{
    return @[
             @"ESRIWorldTopo",
             @"ESRIWorldImagery",
             ];
}

- (NSArray<NSString *> *)tileServices
{
    return @[
            @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}.png",
            @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}.png",
            ];
}

- (NSArray<NSNumber *> *)mapHasViews
{
    return @[
             [NSNumber numberWithInteger:MAPTYPE_NORMAL],
             [NSNumber numberWithInteger:MAPTYPE_AERIAL],
             ];
}

- (void)initMap
{
    self.creditsText = @"© Esri";
    self.tileServerTemplate = [[self tileServices] objectAtIndex:0];
    self.cachePrefix = [[MapEsri cachePrefixes] objectAtIndex:0];
    [super initMap];
    self.minimumAltitude = 287;
}

- (void)setMapType:(GCMapType)mapType
{
    switch (mapType) {
        case MAPTYPE_TERRAIN:
            self.tileServerTemplate = [[self tileServices] objectAtIndex:0];
            self.cachePrefix = [[MapEsri cachePrefixes] objectAtIndex:0];
            break;
        case MAPTYPE_AERIAL:
            self.tileServerTemplate = [[self tileServices] objectAtIndex:1];
            self.cachePrefix = [[MapEsri cachePrefixes] objectAtIndex:1];
            break;
        default:
            NSAssert1(NO, @"Invalid mapType: %ld", mapType);
    }
    [self mapViewDidLoad];
}

@end
