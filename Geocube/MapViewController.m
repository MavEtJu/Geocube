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
    UIButton *labelMapFindMe;
    UIButton *labelMapFindTarget;

    NSInteger showType; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    NSInteger showWhom; /* SHOW_CACHE | SHOW_ME | SHOW_BOTH */
    NSInteger showBrand; /* MAPBRAND_GOOGLEMAPS | MAPBRAND_APPLEMAPS | MAPBRAND_OPENSTREETMAPS */

    CLLocationCoordinate2D meLocation;
    BOOL useGPS;

    NSInteger waypointCount;
    NSArray *waypointsArray;

    NSInteger loadWaypointsCountWaypoints;
    NSInteger loadWaypointsTotalWaypoints;
    NSInteger loadWaypointsCountLogs;
    NSString *loadWaypointsCountSitename;
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
    menuLoadWaypoints,
    menuDirections,
    menuAutoZoom,
    menuRecenter,
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
    if (showBrand == MAPBRAND_GOOGLEMAPS && (myConfig.keyGMS ==nil || [myConfig.keyGMS isEqualToString:@""] == YES))
        showBrand = MAPBRAND_APPLEMAPS;

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

            [lmi disableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;
        case MAPBRAND_APPLEMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"Satellite"];
            [lmi addItem:menuHybrid label:@"Hybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];

            [lmi enableItem:menuMapGoogle];
            [lmi disableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            [lmi addItem:menuMap label:@"Map"];
            [lmi addItem:menuSatellite label:@"XSatellite"];
            [lmi addItem:menuHybrid label:@"XHybrid"];
            [lmi addItem:menuTerrain label:@"XTerrain"];

            [lmi enableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi disableItem:menuMapOSM];
            break;
    }
    [lmi addItem:menuLoadWaypoints label:@"Load Waypoints"];
    [lmi addItem:menuDirections label:@"Directions"];
    if (myConfig.dynamicmapEnable == YES) {
        [lmi addItem:menuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi addItem:menuAutoZoom label:@"Auto Zoom"];
    }

    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi addItem:menuRecenter label:@"Recenter"];
    else
        [lmi addItem:menuRecenter label:@"Use GPS"];

    if (myConfig.keyGMS == nil || [myConfig.keyGMS isEqualToString:@""] == YES)
        [lmi disableItem:menuMapGoogle];

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
    [map initCamera:LM.coords];
    [map mapViewDidLoad];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi changeItem:menuRecenter label:@"Recenter"];
    else
        [lmi changeItem:menuRecenter label:@"Use GPS"];

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
        labelMapFindTarget.userInteractionEnabled = NO;
        labelMapFindTarget.enabled = NO;
    } else {
        labelMapShowBoth.userInteractionEnabled = YES;
        labelMapShowBoth.enabled = YES;
        labelMapSeeTarget.userInteractionEnabled = YES;
        labelMapSeeTarget.enabled = YES;
        labelMapFindTarget.userInteractionEnabled = YES;
        labelMapFindTarget.enabled = YES;
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

    labelMapFindMe.frame = CGRectMake(width - 6 * 28 - 3, 3, imgwidth , imgheight);

    labelMapFollowMe.frame = CGRectMake(width - 4.5 * 28 - 3, 3, imgwidth , imgheight);
    labelMapShowBoth.frame = CGRectMake(width - 3.5 * 28 - 3, 3, imgwidth , imgheight);
    labelMapSeeTarget.frame = CGRectMake(width - 2.5 * 28 - 3, 3, imgwidth , imgheight);

    labelMapFindTarget.frame = CGRectMake(width - 1 * 28 - 3, 3, imgwidth , imgheight);
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
    [labelMapFollowMe addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    labelMapFollowMe.userInteractionEnabled = YES;
    [labelMapFollowMe setImage:[imageLibrary get:ImageIcon_FollowMe] forState:UIControlStateNormal];
    [self.view addSubview:labelMapFollowMe];

    labelMapShowBoth = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapShowBoth.layer.borderWidth = 1;
    labelMapShowBoth.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapShowBoth addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    labelMapShowBoth.userInteractionEnabled = YES;
    [labelMapShowBoth setImage:[imageLibrary get:ImageIcon_ShowBoth] forState:UIControlStateNormal];
    [self.view addSubview:labelMapShowBoth];

    labelMapSeeTarget = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapSeeTarget.layer.borderWidth = 1;
    labelMapSeeTarget.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapSeeTarget addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    labelMapSeeTarget.userInteractionEnabled = YES;
    [labelMapSeeTarget setImage:[imageLibrary get:ImageIcon_SeeTarget] forState:UIControlStateNormal];
    [self.view addSubview:labelMapSeeTarget];

    labelMapFindMe = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapFindMe.layer.borderWidth = 1;
    labelMapFindMe.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapFindMe addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    labelMapFindMe.userInteractionEnabled = YES;
    [labelMapFindMe setImage:[imageLibrary get:ImageIcon_FindMe] forState:UIControlStateNormal];
    [self.view addSubview:labelMapFindMe];

    labelMapFindTarget = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    labelMapFindTarget.layer.borderWidth = 1;
    labelMapFindTarget.layer.borderColor = [UIColor blackColor].CGColor;
    [labelMapFindTarget addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    labelMapFindTarget.userInteractionEnabled = YES;
    [labelMapFindTarget setImage:[imageLibrary get:ImageIcon_FindTarget] forState:UIControlStateNormal];
    [self.view addSubview:labelMapFindTarget];

    switch (showWhom) {
        case SHOW_FOLLOWME:
            [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SHOWBOTH:
            [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SEETARGET:
            [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
            [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
    }
}

- (void)removeDistanceLabel
{
    distanceLabel = nil;
    labelMapFollowMe = nil;
    labelMapShowBoth = nil;
    labelMapSeeTarget = nil;
    labelMapFindMe = nil;
    labelMapFindTarget = nil;
}

- (void)chooseMapFollow:(UIButton *)button
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
    if (button == labelMapFindMe) {
        [self menuFindMe];
        return;
    }
    if (button == labelMapFindTarget) {
        [self menuFindTarget];
        return;
    }

}


/* Delegated from GCLocationManager */
- (void)updateLocationManagerLocation
{
    if (useGPS == NO)
        return;

    meLocation = [LM coords];

    // Move the map around to match current location
    if (showWhom == SHOW_FOLLOWME)
        [map moveCameraTo:meLocation zoom:NO];
    if (showWhom == SHOW_SHOWBOTH)
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];

    [map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools niceDistance:[Coordinates coordinates2distance:meLocation to:waypointManager.currentWaypoint.coordinates]];
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
    [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
}

- (void)menuShowWhom:(NSInteger)whom
{
    if (whom == SHOW_FOLLOWME) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:meLocation zoom:NO];
        [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
        [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
        [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    }
    if (whom == SHOW_SEETARGET && waypointManager.currentWaypoint != nil) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:NO];
        [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
        [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
        [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        showWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
        [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
        [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
        [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)menuFindMe
{
    meLocation = [LM coords];
    showWhom = SHOW_NEITHER;
    [labelMapFindMe setBackgroundColor:[UIColor grayColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    [map moveCameraTo:meLocation zoom:YES];
}

- (void)menuFindTarget
{
    meLocation = [LM coords];
    showWhom = SHOW_SEETARGET;
    [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor grayColor]];
    [map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:YES];
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

            [lmi disableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;;
        case MAPBRAND_APPLEMAPS:
            NSLog(@"Switching to Apple Maps");
            map = [[MapApple alloc] init:self];

            [lmi enableItem:menuMap];
            [lmi enableItem:menuSatellite];
            [lmi enableItem:menuHybrid];
            [lmi disableItem:menuTerrain];

            [lmi enableItem:menuMapGoogle];
            [lmi disableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            NSLog(@"Switching to OpenStreet Maps");
            map = [[MapOSM alloc] init:self];

            [lmi enableItem:menuMap];
            [lmi disableItem:menuSatellite];
            [lmi disableItem:menuHybrid];
            [lmi disableItem:menuTerrain];

            [lmi enableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi disableItem:menuMapOSM];
            break;
    }
    showBrand = brand;
    [myConfig mapBrandUpdate:brand];

    if (myConfig.keyGMS == nil || [myConfig.keyGMS isEqualToString:@""] == YES)
        [lmi disableItem:menuMapGoogle];

    [self refreshMenu];

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera:LM.coords];

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

- (void)menuAutoZoom
{
    myConfig.dynamicmapEnable = !myConfig.dynamicmapEnable;
    if (myConfig.dynamicmapEnable == YES) {
        [lmi changeItem:menuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi changeItem:menuAutoZoom label:@"AutoZoom"];
    }
    [self refreshMenu];
}

- (void)menuLoadWaypoints
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    wp.coordinates = [map currentCenter];
    loadWaypointsCountWaypoints = 0;
    loadWaypointsCountLogs = 0;
    [self performSelectorInBackground:@selector(runLoadWaypoints:) withObject:wp];
}

- (void)remoteAPILoadWaypointsImportWaypointCount:(NSInteger)count
{
    loadWaypointsCountWaypoints = count;
    [self updateActivityViewerImportWaypoints];
}

- (void)remoteAPILoadWaypointsImportLogsCount:(NSInteger)count
{
    loadWaypointsCountLogs = count;
    [self updateActivityViewerImportWaypoints];
}

- (void)remoteAPILoadWaypointsImportWaypointsTotal:(NSInteger)count
{
    loadWaypointsTotalWaypoints = count;
    [self updateActivityViewerImportWaypoints];
}

- (void)updateActivityViewerImportWaypoints
{
    NSMutableString *s = [NSMutableString stringWithString:@""];

    if (loadWaypointsCountSitename != nil)
        [s appendFormat:@"Load waypoints for %@.\n", loadWaypointsCountSitename];
    if (loadWaypointsTotalWaypoints != 0)
        [s appendFormat:@"Loaded %ld / %ld waypoints.\n", loadWaypointsCountWaypoints, loadWaypointsTotalWaypoints];
    else
        [s appendFormat:@"Loaded %ld waypoints.\n", loadWaypointsCountWaypoints];
    [s appendFormat:@"Loaded %ld logs.\n", loadWaypointsCountLogs];
    [map updateActivityViewer:s];
}

- (void)runLoadWaypoints:(dbWaypoint *)wp
{
    [map startActivityViewer:@"Load waypoints for Groundspeak Geocaching.com.\nLoaded 0 caches.\nLoaded 0 logs."]; // Currently the longest name

    NSArray *accounts = [dbc Accounts];
    [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
        account.remoteAPI.delegateLoadWaypoints = self;
        loadWaypointsCountSitename = account.site;
        [map updateActivityViewer:[NSString stringWithFormat:@"Load waypoints for %@.\nLoaded 0 caches.\nLoaded 0 logs.", loadWaypointsCountSitename]];
        [account.remoteAPI loadWaypoints:wp.coordinates];
        account.remoteAPI.delegateLoadWaypoints = nil;
    }];
    [MyTools playSound:playSoundImportComplete];

    [map stopActivityViewer];
}

- (void)menuRecenter
{
    if (useGPS == NO) {
        [lmi changeItem:menuRecenter label:@"Recenter"];
        useGPS = YES;
        [LM useGPS:YES coordinates:CLLocationCoordinate2DMake(0, 0)];
    } else {
        [lmi changeItem:menuRecenter label:@"Use GPS"];
        useGPS = NO;
        [LM useGPS:NO coordinates:[map currentCenter]];
    }
    [self refreshMenu];

    meLocation = [map currentCenter];
    showWhom = SHOW_NEITHER;
    [waypointManager needsRefresh];
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
        case menuAutoZoom:
            [self menuAutoZoom];
            return;
        case menuLoadWaypoints:
            [self menuLoadWaypoints];
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

        case menuRecenter:
            [self menuRecenter];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end