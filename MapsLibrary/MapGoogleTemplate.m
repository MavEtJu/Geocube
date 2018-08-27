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

@interface MapGoogleTemplate ()

@property (nonatomic, retain) UILabel *creditsLabel;
@property (nonatomic, retain) MapCacheGoogle *layer;

@end

@implementation MapGoogleTemplate

- (void)initMap:(MapBrandTemplate *)mapBrand
{
    self.tileServerTemplate = [[mapBrand tileServices] objectAtIndex:0];
    self.cachePrefix = [[mapBrand cachePrefixes] objectAtIndex:0];

    [super initMap:mapBrand];

    /* Credits label for map provider */
    self.creditsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.creditsLabel.font = [UIFont systemFontOfSize:10];
    self.creditsLabel.text = [self.mapBrand credits];
    [self.creditsLabel sizeToFit];
    [self.mapvc.view addSubview:self.creditsLabel];

    self.mapView.mapType = kGMSTypeNone;
    self.mapView.buildingsEnabled = NO;

    self.layer = [[MapCacheGoogle alloc] initWithPrefix:self.cachePrefix tileServerTemplate:self.tileServerTemplate];
    self.layer.map = self.mapView;
}

- (void)recalculateRects
{
    [super recalculateRects];
    [self redrawCreditsLabel];
}

- (void)mapViewDidAppear
{
    [self redrawCreditsLabel];
}

- (void)redrawCreditsLabel
{
    CGRect r = self.mapvc.view.frame;
    self.creditsLabel.frame = CGRectMake(r.size.width - self.creditsLabel.frame.size.width - 10, r.size.height - 15, self.creditsLabel.frame.size.width, self.creditsLabel.frame.size.height);
}

- (BOOL)menuOpenInSupported
{
    return NO;
}

- (void)setMapType:(GCMapType)mapType
{
    [[self.mapBrand mapHasViews] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull mt, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([mt integerValue] == mapType) {
            self.tileServerTemplate = [[self.mapBrand tileServices] objectAtIndex:idx];
            self.cachePrefix = [[self.mapBrand cachePrefixes] objectAtIndex:idx];

            self.layer = [[MapCacheGoogle alloc] initWithPrefix:self.cachePrefix tileServerTemplate:self.tileServerTemplate];
            self.layer.map = self.mapView;

            *stop = YES;
        }
    }];
    [self mapViewDidLoad];
}

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView
{
    [self.KMLrenderers enumerateObjectsUsingBlock:^(GMUGeometryRenderer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj render];
    }];
}

@end
