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

@interface MapGoogleOSM ()

@end

@implementation MapGoogleOSM

- (void)initMap:(MapBrandTemplate *)mapBrandTemplate
{
    self.mapBrand = [[MapBrandOSM alloc] init];
    [super initMap:self.mapBrand];
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
