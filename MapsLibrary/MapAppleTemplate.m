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

@interface MapAppleTemplate ()

@property (nonatomic, retain) MKTileOverlay *overlay;
@property (nonatomic, retain) UILabel *creditsLabel;

@end

@implementation MapAppleTemplate

- (void)initMap:(MapBrandTemplate *)mapBrand
{
    self.tileServerTemplate = [[self.mapBrand tileServices] objectAtIndex:0];
    self.cachePrefix = [[self.mapBrand cachePrefixes] objectAtIndex:0];

    [super initMap:mapBrand];

    /* Credits label for map provider */
    self.creditsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.creditsLabel.font = [UIFont systemFontOfSize:10];
    self.creditsLabel.text = [self.mapBrand credits];
    [self.creditsLabel sizeToFit];
    [self.mapvc.view addSubview:self.creditsLabel];
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

- (void)mapViewDidLoad
{
    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = self.tileServerTemplate;

    if (self.overlay != nil)
        [self.mapView removeOverlay:self.overlay];

    // template = @"https://api.mapbox.com/v4/mapbox.dark/{z}/{x}/{y}.png?access_token=...";
    self.overlay = [[MapCacheApple alloc] initWithURLTemplate:template prefix:self.cachePrefix];
    self.overlay.canReplaceMapContent = YES;
    // Instead of adding it, put them at the bottom so other overlays
    // will be rendered over it.
    //[self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    [self.mapView insertOverlay:self.overlay atIndex:0];

    self.mapView.delegate = self;
}

// From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
- (MKOverlayRenderer *)mapView:(MKMapView *)mv rendererForOverlay:(id<MKOverlay>)ol
{
    if (ol == self.overlay)
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:self.overlay];
    return [super mapView:mv rendererForOverlay:ol];
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
            *stop = YES;
        }
    }];
    [self mapViewDidLoad];
}

@end
