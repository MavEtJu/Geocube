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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

@import GoogleMaps;

#import "Geocube-Prefix.pch"

@implementation MapGoogleViewController

- (id)init:(NSInteger)_type
{
    self = [super init];
    [self whichCachesToSnow:_type whichCache:nil];
    [self showWhom:(_type == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_CACHE];

    menuItems = [NSMutableArray arrayWithArray:@[@"Map", @"Satellite", @"Hybrid", @"Terrain",
                  @"Show target", @"Show me", @"Show both"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:LM.coords.latitude
                                                            longitude:LM.coords.longitude
                                                                 zoom:15];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.mapType = kGMSTypeNormal;
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;

    /* Me (not on the map) */
    me = [[GMSMarker alloc] init];
    CLLocationCoordinate2D coord = LM.coords;
    me.position = coord;
    me.title = @"*";

    self.view = mapView;
}

- (void)loadMarkers
{
    // Creates a marker in the center of the map.
    [self refreshCachesData:nil];
    NSEnumerator *e = [caches objectEnumerator];
    dbCache *cache;
    while ((cache = [e nextObject]) != nil) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = cache.coordinates;
        switch (rand() % 3) {
            case 0: marker.icon = [imageLibrary getFound:cache.cache_type.pin]; break;
            case 1: marker.icon = [imageLibrary getDNF:cache.cache_type.pin]; break;
            case 2: marker.icon = [imageLibrary getNormal:cache.cache_type.pin]; break;
        }
        marker.title = cache.name;
        marker.snippet = cache.description;
        marker.map = mapView;
    }
}

- (void)updateMe
{
    if (showWhom != SHOW_ME && showWhom != SHOW_BOTH)
        return;

    me.position = [LM coords];
    
    if (showWhom == SHOW_ME)
        [self showMe];
    if (showWhom == SHOW_BOTH)
        [self showCacheAndMe];
}

#pragma mark - Local menu related functions

- (void)showCache
{
    if (currentCache == nil)
        return;

    [super showCache];
    CLLocationCoordinate2D t = currentCache.coordinates;
    NSLog(@"Move camera to %f %f", t.latitude, t.longitude);
    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:t];
    [mapView animateWithCameraUpdate:currentCam];
}

- (void)showMe
{
    [super showMe];
    GMSCameraUpdate *currentCam = [GMSCameraUpdate setTarget:me.position];
    [mapView animateWithCameraUpdate:currentCam];
}

- (void)showCacheAndMe
{
    if (currentCache == nil)
        return;

    [super showCacheAndMe];
    CLLocationCoordinate2D cache = currentCache.coordinates;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:me.position coordinate:cache];

//    for (GMSMarker *marker in _markers)
//        bounds = [bounds includingCoordinate:marker.position];

    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:15.0f]];
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    switch (index) {
        case 0: /* Map view */
            mapView.mapType = kGMSTypeNormal;
            return;
        case 1: /* Satellite view */
            mapView.mapType = kGMSTypeSatellite;
            return;
        case 2: /* Hybrid view */
            mapView.mapType = kGMSTypeHybrid;
            return;
        case 3: /* Terrain view */
            mapView.mapType = kGMSTypeTerrain;
            return;

        case 4: /* Show cache */
            [self showCache];
            return;
        case 5: /* Show Me */
            [self showMe];
            return;
        case 6: /* Show Both */
            [self showCacheAndMe];
            return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
