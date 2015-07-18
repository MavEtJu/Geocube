//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapOSMViewController

- (id)init:(NSInteger)_type
{
    self = [super init];
    [self whichCachesToSnow:_type whichCache:nil];

    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"XSatellite", @"XHybrid", @"XTerrain", @"Show target", @"Show me", @"Show both"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // From http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
    NSString *template = @"http://tile.openstreetmap.org/{z}/{x}/{y}.png";         // (1)
    MKTileOverlay *overlay = [[MKTileOverlay alloc] initWithURLTemplate:template]; // (2)
    overlay.canReplaceMapContent = YES;                        // (3)
    [mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];         // (4)
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    switch (index) {
        case 0: /* Map view */
            mapView.mapType = MKMapTypeStandard;
            return;

        case 4: /* Show cache */
            [self showCache];
            return;
        case 5: /* Show me */
            [self showMe];
            return;
        case 6: /* Show cache and me */
            [self showCacheAndMe];
            return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
