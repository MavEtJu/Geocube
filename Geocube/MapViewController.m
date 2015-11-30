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

@interface MapViewController ()
{
    MapTemplate *map;

    UILabel *distanceLabel;
    UIButton *labelMapFollowMe;
    UIButton *labelMapShowBoth;
    UIButton *labelMapSeeTarget;

    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */
    NSInteger showBrand; /* MAPBRAND_GOOGLEMAPS | MAPBRAND_APPLEMAPS | MAPBRAND_OPENSTREETMAPS */

    CLLocationCoordinate2D meLocation;

    NSInteger waypointCount;
    NSArray *waypointsArray;
}

@end

@implementation MapViewController

@synthesize waypointsArray;

enum {
    menuMapGoogle,
    menuMapApple,
    menuMapOSM,
    menuMap,
    menuSatellite,
    menuHybrid,
    menuTerrain,
    menuDirections,
    menuMax,
    menuFollowMe,
    menuShowBoth,
    menuShowTarget,
};

- (instancetype)init
{
    NSAssert(FALSE, @"Don't call this one");
    return nil;
}

- (instancetype)init:(NSInteger)maptype
{
    self = [super init];

    showBrand = myConfig.mapBrand;
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            map = [[MapGoogle alloc] init:self];
            break;
        case MAPBRAND_APPLEMAPS:
            map = [[MapApple alloc] init:self];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            map = [[MapOSM alloc] init:self];
            break;
    }

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMapGoogle label:@"Google Maps"];
    [lmi addItem:menuMapApple label:@"Apple Maps"];
    [lmi addItem:menuMapOSM label:@"OSM"];
    //[lmi addItem:menuShowTarget label:@"Show target"];
    //[lmi addItem:menuFollowMe label:@"Follow me"];
    //[lmi addItem:menuShowBoth label:@"Show both"];
    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"Satellite"];
            [lmi addItem:menuHybrid label:@"Hybrid"];
            [lmi addItem:menuTerrain label:@"Terrain"];
            break;
        case MAPBRAND_APPLEMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"Satellite"];
            [lmi addItem:menuHybrid label:@"Hybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"XSatellite"];
            [lmi addItem:menuHybrid label:@"XHybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];
            break;
    }
    [lmi addItem:menuDirections label:@"Directions"];

    showType = maptype; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    showWhom = (showType == SHOW_ONECACHE) ? SHOW_SHOWBOTH : SHOW_FOLLOWME;

    waypointsArray = nil;
    waypointCount = 0;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera];
    [map mapViewDidLoad];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [map mapViewWillAppear];
    [map removeMarkers];
    [self refreshWaypointsData:nil];
    [map placeMarkers];
    [waypointManager startDelegation:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [map mapViewDidAppear];
    [LM startDelegation:self isNavigating:(showType == SHOW_ONECACHE)];
    if (meLocation.longitude == 0 && meLocation.latitude == 0)
        [self updateLocationManagerLocation];

    if (waypointManager.currentWaypoint == nil) {
        labelMapShowBoth.userInteractionEnabled = NO;
        labelMapShowBoth.enabled = NO;
        labelMapSeeTarget.userInteractionEnabled = NO;
        labelMapSeeTarget.enabled = NO;
    } else {
        labelMapShowBoth.userInteractionEnabled = YES;
        labelMapShowBoth.enabled = YES;
        labelMapSeeTarget.userInteractionEnabled = YES;
        labelMapSeeTarget.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
    [map mapViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [map removeMarkers];
    [waypointManager stopDelegation:self];
    [super viewDidDisappear:animated];
    [map mapViewDidDisappear];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self recalculateRects];
                                 }
     ];
}

- (void)recalculateRects
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
//    NSInteger height = applicationFrame.size.height - 50;

    distanceLabel.frame = CGRectMake(3, 3, 250, 20);

    UIImage *img = [imageLibrary get:ImageIcon_FollowMe];
    NSInteger imgwidth = img.size.width;
    NSInteger imgheight = img.size.height;

    labelMapFollowMe.frame = CGRectMake(width - 3 * 28 - 3, 3, imgwidth , imgheight);
    labelMapShowBoth.frame = CGRectMake(width - 2 * 28 - 3, 3, imgwidth , imgheight);
    labelMapSeeTarget.frame = CGRectMake(width - 1 * 28 - 3, 3, imgwidth , imgheight);
}

- (void)initDistanceLabel
{
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    //distanceLabel.textAlignment = NSTextAlignmentRight;
    distanceLabel.text = @"Nothing yet";
    [self.view addSubview:distanceLabel];
}

- (void)initMapIcons
{
    labelMapFollowMe = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapFollowMe.layer.borderWidth = 1;
    labelMapFollowMe.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapFollowMe addTarget:self action:@selector(chooseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapFollowMe.userInteractionEnabled = YES;
    [labelMapFollowMe setImage:[imageLibrary get:ImageIcon_FollowMe] forState:UIControlStateNormal];
//  [labelMapFollowMe setTitle:@"Me" forState:UIControlStateNormal];;
//  [labelMapFollowMe setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapFollowMe];

    labelMapShowBoth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapShowBoth.layer.borderWidth = 1;
    labelMapShowBoth.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapShowBoth addTarget:self action:@selector(chooseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapShowBoth.userInteractionEnabled = YES;
    [labelMapShowBoth setImage:[imageLibrary get:ImageIcon_ShowBoth] forState:UIControlStateNormal];
//  [labelMapShowBoth setTitle:@"Both" forState:UIControlStateNormal];;
//  [labelMapShowBoth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapShowBoth];

    labelMapSeeTarget = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapSeeTarget.layer.borderWidth = 1;
    labelMapSeeTarget.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapSeeTarget addTarget:self action:@selector(chooseMapBrand:) forControlEvents:UIControlEventTouchDown];
    labelMapSeeTarget.userInteractionEnabled = YES;
    [labelMapSeeTarget setImage:[imageLibrary get:ImageIcon_SeeTarget] forState:UIControlStateNormal];
//  [labelMapSeeTarget setTitle:@"Target" forState:UIControlStateNormal];;
//  [labelMapSeeTarget setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:labelMapSeeTarget];

    switch (showWhom) {
        case SHOW_FOLLOWME:
            [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SHOWBOTH:
            [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SEETARGET:
            [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
            break;
    }
}

- (void)removeDistanceLabel
{
    distanceLabel = nil;
    labelMapFollowMe = nil;
    labelMapShowBoth = nil;
    labelMapSeeTarget = nil;
}

- (void)chooseMapBrand:(UIButton *)button
{
    if (button == labelMapFollowMe) {
        [self menuShowWhom:SHOW_FOLLOWME];
        return;
    }
    if (button == labelMapShowBoth) {
        [self menuShowWhom:SHOW_SHOWBOTH];
        return;
    }
    if (button == labelMapSeeTarget) {
        [self menuShowWhom:SHOW_SEETARGET];
        return;
    }

}


/* Delegated from GCLocationManager */
- (void)updateLocationManagerLocation
{
    meLocation = [LM coords];

    // Move the map around to match current location
    if (showWhom == SHOW_FOLLOWME)
        [map moveCameraTo:meLocation];
    if (showWhom == SHOW_SHOWBOTH)
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];

    [map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools NiceDistance:[Coordinates coordinates2distance:meLocation to:waypointManager.currentWaypoint.coordinates]];
        distanceLabel.text = distance;
    } else {
        distanceLabel.text = @"";
    }
}

- (void)updateLocationManagerHistory
{
    [map removeHistory];
    [map addHistory];
}

- (void)refreshWaypoints
{
    [self refreshWaypointsData:nil];
    [map removeMarkers];
    [map placeMarkers];
}

- (void)refreshWaypointsData:(NSString *)searchString
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    [waypointManager applyFilters:LM.coords];

    if (showType == SHOW_ONECACHE) {
        if (waypointManager.currentWaypoint != nil) {
            waypointManager.currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:waypointManager.currentWaypoint.coordinates to:LM.coords];
            waypointsArray = @[waypointManager.currentWaypoint];
            waypointCount = [waypointsArray count];
        } else {
            waypointsArray = nil;
            waypointCount = 0;
        }
        return;
    }

    if (showType == SHOW_ALLCACHES) {
        [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
            if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                return;
            [wps addObject:wp];
        }];
        waypointsArray = [wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) {

            if (obj1.calculatedDistance > obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            if (obj1.calculatedDistance < obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];

        waypointCount = [waypointsArray count];
        return;
    }
}

- (void)refreshWaypointsData
{
    [self refreshWaypointsData:nil];
}

#pragma mark -- Menu related functions

- (void)userInteraction
{
    showWhom = SHOW_NEITHER;
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
}

- (void)menuShowWhom:(NSInteger)whom
{
    if (whom == SHOW_FOLLOWME) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:meLocation];
        [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    }
    if (whom == SHOW_SEETARGET && waypointManager.currentWaypoint != nil) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates];
        [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
        [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)menuMapType:(NSInteger)maptype
{
    [map setMapType:maptype];
}

- (void)menuChangeMapbrand:(NSInteger)brand
{
    [self removeDistanceLabel];
    [map removeMarkers];
    [map removeCamera];
    [map removeMap];

    for (UIView* b in self.view.subviews) {
        [b removeFromSuperview];
    }

    switch (brand) {
        case MAPBRAND_GOOGLEMAPS:
            NSLog(@"Switching to Google Maps");
            map = [[MapGoogle alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi enableItem:menuSatellite];
            [lmi enableItem:menuHybrid];
            [lmi enableItem:menuTerrain];
            break;;
        case MAPBRAND_APPLEMAPS:
            NSLog(@"Switching to Apple Maps");
            map = [[MapApple alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi enableItem:menuSatellite];
            [lmi enableItem:menuHybrid];
            [lmi disableItem:menuTerrain];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            NSLog(@"Switching to OpenStreet Maps");
            map = [[MapOSM alloc] init:self];
            [lmi enableItem:menuMap];
            [lmi disableItem:menuSatellite];
            [lmi disableItem:menuHybrid];
            [lmi disableItem:menuTerrain];
            break;
    }
    showBrand = brand;
    [myConfig mapBrandUpdate:brand];

    [self refreshMenu];

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];

    [self refreshWaypointsData:nil];
    [map placeMarkers];

    [map mapViewDidAppear];
    [self menuShowWhom:showWhom];

    [self updateLocationManagerLocation];
}

- (void)menuDirections
{
    if (myConfig.mapExternal == MAPEXTERNAL_APPLEMAPS) {
        if (waypointManager.currentWaypoint == nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(LM.coords.latitude, LM.coords.longitude);

            //create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                [destination openInMapsWithLaunchOptions:nil];
            return;
        }

        if (waypointManager.currentWaypoint != nil) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float);

            //create MKMapItem out of coordinates
            MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
            if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        }
        return;
    }

    if (myConfig.mapExternal == MAPBRAND_GOOGLEMAPS) {
        if (waypointManager.currentWaypoint == nil) {
            NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=Current+Location&daddr=%f,%f", waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuMap: /* Map view */
            [self menuMapType:MAPTYPE_NORMAL];
            return;
        case menuSatellite: /* Satellite view */
            [self menuMapType:MAPTYPE_SATELLITE];
            return;
        case menuHybrid: /* Hybrid view */
            [self menuMapType:MAPTYPE_HYBRID];
            return;
        case menuTerrain: /* Terrain view */
            [self menuMapType:MAPTYPE_TERRAIN];
            return;

        case menuShowTarget: /* Show cache */
            [self menuShowWhom:SHOW_SEETARGET];
            return;
        case menuFollowMe: /* Show Me */
            [self menuShowWhom:SHOW_FOLLOWME];
            return;
        case menuShowBoth: /* Show Both */
            [self menuShowWhom:SHOW_SHOWBOTH];
            return;
        case menuDirections:
            [self menuDirections];
            return;

        case menuMapGoogle:
            [self menuChangeMapbrand:MAPBRAND_GOOGLEMAPS];
            return;
        case menuMapApple:
            [self menuChangeMapbrand:MAPBRAND_APPLEMAPS];
            return;
        case menuMapOSM:
            [self menuChangeMapbrand:MAPBRAND_OPENSTREETMAPS];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end