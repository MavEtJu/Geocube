/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface MapOSM ()
{
    MKTileOverlay *overlay;
    UILabel *creditsLabel;
}

@end

@implementation MapOSM

- (BOOL)mapHasViewMap
{
    return YES;
}

- (BOOL)mapHasViewSatellite
{
    return NO;
}

- (BOOL)mapHasViewHybrid
{
    return NO;
}

- (BOOL)mapHasViewTerrain;
{
    return NO;
}

- (void)initMap
{
    [super initMap];

    /* Credits label for OSM */
    creditsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    creditsLabel.font = [UIFont systemFontOfSize:10];
    creditsLabel.text = @"© OpenStreetMap";
    [self.mapvc.view addSubview:creditsLabel];
}

- (void)recalculateRects
{
    CGRect r = self.mapvc.view.frame;
    NSLog(@"%@", [MyTools niceCGRect:r]);
    creditsLabel.frame = CGRectMake(2, r.size.height - 20, 200, 20);
}

- (void)mapViewWillAppear
{
    [super mapViewWillAppear];
    [self recalculateRects];
}

- (void)mapViewDidLoad
{
    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";

    // template = @"https://api.mapbox.com/v4/mapbox.dark/{z}/{x}/{y}.png?access_token=...";
    overlay = [[MapAppleCache alloc] initWithURLTemplate:template prefix:@"OSM"];
    overlay.canReplaceMapContent = YES;
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];

    mapView.delegate = self;
}


// From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
- (MKOverlayRenderer *)mapView:(MKMapView *)mv rendererForOverlay:(id)ol
{
    if (ol == overlay) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    return [super mapView:mv rendererForOverlay:ol];
}

@end
