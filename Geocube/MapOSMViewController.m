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

@interface MapOSMViewController ()

@end

@implementation MapOSMViewController

enum {
    menuMap,
    menuShowTarget,
    menuFollowMe,
    menuShowBoth,
    menuMax
};

- (void)initMenu
{
    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMap label:@"Map"];
    [lmi addItem:menuShowTarget label:@"Show target"];
    [lmi addItem:menuFollowMe label:@"Follow me"];
    [lmi addItem:menuShowBoth label:@"Show both"];
    menuItems = [lmi makeMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:template];
    overlay.canReplaceMapContent = YES;
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    mapView.delegate = self;
}


// From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    return nil;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuMap: /* Map view */
            [super menuMapType:MAPTYPE_NORMAL];
            return;

        case menuShowTarget: /* Show cache */
            [super menuShowWhom:SHOW_CACHE];
            return;
        case menuFollowMe: /* Show Me */
            [super menuShowWhom:SHOW_ME];
            return;
        case menuShowBoth: /* Show Both */
            [super menuShowWhom:SHOW_BOTH];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end
