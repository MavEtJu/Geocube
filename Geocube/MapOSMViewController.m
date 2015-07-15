//
//  CachesOfflineAppleMaps.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapOSMViewController

- (id)init
{
    self = [super init];

    menuItems = @[@"Map"];

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
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
