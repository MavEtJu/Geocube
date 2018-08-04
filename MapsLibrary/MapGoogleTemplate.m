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

@property (nonatomic, retain) MKTileOverlay *overlay;
@property (nonatomic, retain) UILabel *creditsLabel;

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
    [self.mapvc.view addSubview:self.creditsLabel];

    self.mapView.mapType = kGMSTypeNone;
    self.mapView.buildingsEnabled = NO;
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
    NSLog(@"%@", [MyTools niceCGRect:r]);
    self.creditsLabel.frame = CGRectMake(2, r.size.height - 15, 200, 20);
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
            self.cachePrefix = [[[self class] cachePrefixes] objectAtIndex:idx];
            *stop = YES;
        }
    }];
    [self mapViewDidLoad];
}

@end
