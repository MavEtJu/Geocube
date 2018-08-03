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

@property (nonatomic, retain) MapGoogleCache *layer;
@property (nonatomic, retain) NSString *cachePrefix;
@property (nonatomic, retain) NSString *tileServerTemplate;

@end

@implementation MapGoogleOSM

+ (NSArray<NSString *> *)cachePrefixes
{
    return @[@"GoogleOSM"];
}

- (void)initMap
{
    [super initMap];

    self.mapView.mapType = kGMSTypeNone;
    self.mapView.buildingsEnabled = NO;
    self.mapView.indoorEnabled = NO;

    self.tileServerTemplate = @"https://tile.openstreetmap.org/{z}/{x}/{y}.png";
    self.tileServerTemplate = @"https://tile.openstreetmap.org/%ld/%ld/%ld.png";
    self.cachePrefix = [[MapGoogleOSM cachePrefixes] objectAtIndex:0];

    self.layer = [[MapGoogleCache alloc] initWithPrefix:self.cachePrefix tileServerTemplate:self.tileServerTemplate];

    self.layer.zIndex = 1;
    self.layer.opacity= 0.5;

    self.layer.map = self.mapView;
}

@end
