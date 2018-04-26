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
{
    MKTileOverlay *overlay;
    UILabel *creditsLabel;
}

@end

@implementation MapAppleTemplate

- (BOOL)mapHasViewMap
{
    return YES;
}

- (BOOL)mapHasViewAerial
{
    return NO;
}

- (BOOL)mapHasViewHybridMapAerial
{
    return NO;
}

- (BOOL)mapHasViewTerrain;
{
    return NO;
}

+ NEEDS_OVERLOADING_NSSTRING(cachePrefix)

- (void)initMap
{
    [super initMap];

    /* Credits label for OSM */
    creditsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    creditsLabel.font = [UIFont systemFontOfSize:10];
    creditsLabel.text = self.creditsText;
    [self.mapvc.view addSubview:creditsLabel];
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
    creditsLabel.frame = CGRectMake(2, r.size.height - 20, 200, 20);
}

- (void)mapViewDidLoad
{
    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = self.tileServerTemplate;

    // template = @"https://api.mapbox.com/v4/mapbox.dark/{z}/{x}/{y}.png?access_token=...";
    overlay = [[MapAppleCache alloc] initWithURLTemplate:template prefix:self.cachePrefix];
    overlay.canReplaceMapContent = YES;
    // Instead of adding it, put them at the bottom so other overlays
    // will be rendered over it.
    //[self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    [self.mapView insertOverlay:overlay atIndex:0];

    self.mapView.delegate = self;
}

// From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
- (MKOverlayRenderer *)mapView:(MKMapView *)mv rendererForOverlay:(id<MKOverlay>)ol
{
    if (ol == overlay)
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    return [super mapView:mv rendererForOverlay:ol];
}

@end
