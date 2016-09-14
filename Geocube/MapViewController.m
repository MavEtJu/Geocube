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

@interface MapViewController ()
{
    MapTemplate *map;

    THLabel *distanceLabel;
    UIButton *labelMapFollowMe;
    UIButton *labelMapShowBoth;
    UIButton *labelMapSeeTarget;
    UIButton *labelMapFindMe;
    UIButton *labelMapFindTarget;

    GCMapHowMany showWhat; /* SHOW_ONECACHE | SHOW_ALLCACHES */
    GCMapFollow followWhom; /* FOLLOW_ME | FOLLOW_TARGET | FOLLOW_BOTH */
    GCMapBrand showBrand; /* MAPBRAND_GOOGLEMAPS | MAPBRAND_APPLEMAPS | MAPBRAND_OPENSTREETMAPS */

    CLLocationCoordinate2D meLocation;
    CLLocationDirection meBearing;
    BOOL useGPS;

    NSInteger waypointCount;

    BOOL hasGMS;
    BOOL showBoundaries;

    BOOL isVisible;
    BOOL needsRefresh;
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
    menuUseGPS,
    menuRemoveTarget,
    menuShowBoundaries,
    menuExportVisible,
    menuMax,
};

- (instancetype)init
{
    NSAssert(FALSE, @"Don't call this one");
    return nil;
}

- (instancetype)init:(GCMapHowMany)mapWhat
{
    self = [super init];

    // Disable GoogleMaps if there is no key
    hasGMS = YES;
    if (configManager.keyGMS == nil || [configManager.keyGMS isEqualToString:@""] == YES)
        hasGMS = NO;

    showBrand = configManager.mapBrand;
    if (showBrand == MAPBRAND_GOOGLEMAPS && hasGMS == NO)
        showBrand = MAPBRAND_APPLEMAPS;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMapGoogle label:@"Google Maps"];
    [lmi addItem:menuMapApple label:@"Apple Maps"];
    [lmi addItem:menuMapOSM label:@"OSM"];

    [lmi addItem:menuMap label:@"Map"];
    [lmi addItem:menuSatellite label:@"Satellite"];
    [lmi addItem:menuHybrid label:@"Hybrid"];
    [lmi addItem:menuTerrain label:@"Terrain"];

    [lmi addItem:menuLoadWaypoints label:@"Load Waypoints"];
    [lmi addItem:menuDirections label:@"Directions"];
    [lmi addItem:menuRemoveTarget label:@"Remove Target"];
    [lmi addItem:menuRecenter label:@"Recenter"];
    [lmi addItem:menuUseGPS label:@"Use GPS"];
    [lmi addItem:menuExportVisible label:@"Export Visible"];

    showBoundaries = NO;
    [lmi addItem:menuShowBoundaries label:@"Show Boundaries"];

    switch (showBrand) {
        case MAPBRAND_GOOGLEMAPS:
            map = [[MapGoogle alloc] init:self];
            [lmi disableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;
        case MAPBRAND_APPLEMAPS:
            map = [[MapApple alloc] init:self];
            [lmi enableItem:menuMapGoogle];
            [lmi disableItem:menuMapApple];
            [lmi enableItem:menuMapOSM];
            break;
        case MAPBRAND_OPENSTREETMAPS:
            map = [[MapOSM alloc] init:self];
            [lmi enableItem:menuMapGoogle];
            [lmi enableItem:menuMapApple];
            [lmi disableItem:menuMapOSM];
            break;
    }

    // Various map view options
    if ([map mapHasViewMap] == FALSE)
        [lmi disableItem:menuMap];
    if ([map mapHasViewSatellite] == FALSE)
        [lmi disableItem:menuSatellite];
    if ([map mapHasViewHybrid] == FALSE)
        [lmi disableItem:menuHybrid];
    if ([map mapHasViewTerrain] == FALSE)
        [lmi disableItem:menuTerrain];

    if (waypointManager.currentWaypoint == nil)
        [lmi disableItem:menuRemoveTarget];

    if (configManager.dynamicmapEnable == YES) {
        [lmi addItem:menuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi addItem:menuAutoZoom label:@"Auto Zoom"];
    }

    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi disableItem:menuUseGPS];
    else
        [lmi disableItem:menuUseGPS];

    if (configManager.keyGMS == nil || [configManager.keyGMS isEqualToString:@""] == YES)
        [lmi disableItem:menuMapGoogle];

    showWhat = mapWhat; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    followWhom = (showWhat == SHOW_ONEWAYPOINT) ? SHOW_SHOWBOTH : SHOW_FOLLOWME;
    if (showWhat == SHOW_ONEWAYPOINT) {
        [lmi disableItem:menuLoadWaypoints];
        [lmi disableItem:menuExportVisible];
    }

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

    [self makeInfoView];

    needsRefresh = YES;
    isVisible = NO;
    [waypointManager startDelegation:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Appear GoogleMaps if it came back
    if (hasGMS == NO) {
        if (configManager.keyGMS != nil && [configManager.keyGMS isEqualToString:@""] == NO) {
            hasGMS = YES;
            [lmi enableItem:menuMapGoogle];
            [GMSServices provideAPIKey:configManager.keyGMS];
        }
    }

    // Enable GPS Menu?
    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi disableItem:menuUseGPS];
    else
        [lmi enableItem:menuUseGPS];

    // Enable Remove Target menu only if there is a target
    if (waypointManager.currentWaypoint == nil)
        [lmi disableItem:menuRemoveTarget];
    else
        [lmi enableItem:menuRemoveTarget];

    [map mapViewWillAppear];
    [map removeMarkers];
    [map placeMarkers];
}


- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [map mapViewDidAppear];
    [LM startDelegation:self isNavigating:(showWhat == SHOW_ONEWAYPOINT)];
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

    isVisible = YES;
    if (needsRefresh == YES) {
        [self refreshWaypointsData];
        [map removeMarkers];
        [map placeMarkers];
        needsRefresh = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
    [map mapViewWillDisappear];
    isVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [map removeMarkers];
    [super viewDidDisappear:animated];
    [map mapViewDidDisappear];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
                                     [self recalculateRects];
                                     [map recalculateRects];
                                     [self viewWilltransitionToSize];
    }
                                 completion:nil
     ];
}

- (void)recalculateRects
{
    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    NSInteger width = applicationFrame.size.width;

    distanceLabel.frame = CGRectMake(3, 3, 250, 20);

    UIImage *img = [imageLibrary get:ImageIcon_FollowMe];
    NSInteger imgwidth = img.size.width;
    NSInteger imgheight = img.size.height;

    labelMapFindMe.frame = CGRectMake(width - 6 * 28 - 3, 3, imgwidth , imgheight);

    labelMapFollowMe.frame = CGRectMake(width - 4.5 * 28 - 3, 3, imgwidth , imgheight);
    labelMapShowBoth.frame = CGRectMake(width - 3.5 * 28 - 3, 3, imgwidth , imgheight);
    labelMapSeeTarget.frame = CGRectMake(width - 2.5 * 28 - 3, 3, imgwidth , imgheight);

    labelMapFindTarget.frame = CGRectMake(width - 1 * 28 - 3, 3, imgwidth , imgheight);

    [map recalculateRects];
    [map updateMapScaleView];
}

- (void)initDistanceLabel
{
    distanceLabel = [[THLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    distanceLabel.strokeColor = [UIColor whiteColor];
    distanceLabel.strokeSize = 1;
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

    switch (followWhom) {
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
        default:
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

    if (fabs(meBearing - [LM direction]) > 5) {
        meBearing = [LM direction];
        if (configManager.mapRotateToBearing == YES)
            [map updateMyBearing:meBearing];
    }

    // Move the map around to match current location
    switch (followWhom) {
        case SHOW_FOLLOWMEZOOM:
            [map moveCameraTo:meLocation zoom:YES];
            break;
        case SHOW_FOLLOWME:
            [map moveCameraTo:meLocation zoom:NO];
            break;
        case SHOW_SHOWBOTH:
            [map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
            break;
        default:
            break;
    }

    [map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools niceDistance:[Coordinates coordinates2distance:meLocation to:waypointManager.currentWaypoint.coordinates]];
        distanceLabel.text = distance;
        distanceLabel.layer.shadowColor = [[UIColor redColor] CGColor];
        distanceLabel.layer.shadowRadius = 1;
    } else {
        distanceLabel.text = @"";
    }
}

- (void)updateLocationManagerHistory
{
    [map removeHistory];
    [map addHistory];
}

- (void)addNewWaypoint:(CLLocationCoordinate2D)coords
{
    WaypointAddViewController *newController = [[WaypointAddViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    [newController setCoordinates:coords];
}

#pragma mark -- Map menu related functions

- (void)userInteraction
{
    followWhom = SHOW_NEITHER;
    [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
}

- (void)menuShowWhom:(NSInteger)whom
{
    if (whom == SHOW_FOLLOWME) {
        followWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:meLocation zoom:NO];
        [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
        [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
        [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    }
    if (whom == SHOW_SEETARGET && waypointManager.currentWaypoint != nil) {
        followWhom = whom;
        meLocation = [LM coords];
        [map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:NO];
        [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
        [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
        [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
        [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
        [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        followWhom = whom;
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
    followWhom = SHOW_FOLLOWMEZOOM;
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
    followWhom = SHOW_SEETARGET;
    [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor grayColor]];
    [map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:YES];
}

#pragma mark - Waypoint manager callbacks

- (void)refreshWaypoints
{
    needsRefresh = YES;
    if (isVisible == YES) {
        needsRefresh = NO;
        [self performSelectorInBackground:@selector(refreshWaypointsData) withObject:nil];
    }
}

- (void)refreshWaypointsData
{
    [bezelManager showBezel:self];
    [bezelManager setText:@"Refreshing database"];

    [waypointManager applyFilters:LM.coords];

    if (showWhat == SHOW_ONEWAYPOINT) {
        if (waypointManager.currentWaypoint != nil) {
            waypointManager.currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:waypointManager.currentWaypoint.coordinates to:LM.coords];
            waypointsArray = [NSMutableArray arrayWithArray:@[waypointManager.currentWaypoint]];
            waypointCount = [waypointsArray count];
        } else {
            waypointsArray = nil;
            waypointCount = 0;
        }
    }

    if (showWhat == SHOW_ALLWAYPOINTS) {
        waypointsArray = [waypointManager currentWaypoints];
        waypointCount = [waypointsArray count];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [map removeMarkers];
        [map placeMarkers];
    }];

    [bezelManager removeBezel];
}

- (void)removeWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        return;
    [waypointsArray removeObjectAtIndex:idx];
    [map removeMarker:wp];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [waypointsArray indexOfObject:wp];
    if (idx != NSNotFound)
        return;
    [waypointsArray addObject:wp];
    [map addMarker:wp];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        return;
    [waypointsArray replaceObjectAtIndex:idx withObject:wp];
    [map updateMarker:wp];
}

#pragma mark - Local menu related functions

- (void)menuMapType:(GCMapType)maptype
{
    [map setMapType:maptype];
}

- (void)menuChangeMapbrand:(GCMapBrand)brand
{
    CLLocationCoordinate2D currentCoords = [map currentCenter];
    double currentZoom = [map currentZoom];
    NSLog(@"currentCoords: %@", [Coordinates NiceCoordinates:currentCoords]);
    NSLog(@"currentZoom: %f", currentZoom);

    [self removeDistanceLabel];
    [map removeMarkers];
    [map removeCamera];
    [map removeMap];

    for (UIView *b in self.view.subviews) {
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
            break;

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
    [configManager mapBrandUpdate:brand];

    if (configManager.keyGMS == nil || [configManager.keyGMS isEqualToString:@""] == YES)
        [lmi disableItem:menuMapGoogle];

    [map initMap];
    [map mapViewDidLoad];
    [map initCamera:currentCoords];
    [map moveCameraTo:currentCoords zoomLevel:currentZoom];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];

    [self refreshWaypointsData];
    [map placeMarkers];

    [map mapViewDidAppear];
    [self menuShowWhom:followWhom];

    [map showBoundaries:showBoundaries];

    [self updateLocationManagerLocation];
}

- (NSString *)translateURLType:(dbExternalMapURL *)url
{
    /*
     *	Types:
     * 0: Handled internally.
     * 1: Do not provide any coordinates.
     * 2: Do provide coordinates for current location.
     * 3: Do provide coordinates for destination.
     * 4: Do provide coordinates for current location and destination.
     * 5: Do provide coordinates for destination and current location.
     */

    NSString *urlString = nil;

    switch (url.type) {
        case 0:
            // Not dealt with here
            break;
        case 1:
            urlString = url.url;
            break;
        case 2:
            urlString = [NSString stringWithFormat:url.url, LM.coords.latitude, LM.coords.longitude];
            break;
        case 3:
             urlString = [NSString stringWithFormat:url.url, waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float];
            break;
        case 4:
            urlString = [NSString stringWithFormat:url.url, LM.coords.latitude, LM.coords.longitude, waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float];
            break;
        case 5:
            urlString = [NSString stringWithFormat:url.url, waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float,  LM.coords.latitude, LM.coords.longitude];
            break;
    }

    return urlString;
}

- (void)menuDirections
{
    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap *em, NSUInteger idx, BOOL * _Nonnull stop) {
        if (em.geocube_id != configManager.mapExternal)
            return;

        *stop = YES;

        NSLog(@"Opening %@ for external navigation", em.name);

        NSArray *urls = [dbExternalMapURL dbAllByExternalMap:em._id];
        __block dbExternalMapURL *urlCurrent = nil;
        __block dbExternalMapURL *urlDestination = nil;

        [urls enumerateObjectsUsingBlock:^(dbExternalMapURL *url, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([url.model isEqualToString:@"current"] == YES)
                urlCurrent = url;
            if ([url.model isEqualToString:@"directions"] == YES)
                urlDestination = url;
        }];

        NSURL *url = nil;

        if (waypointManager.currentWaypoint == nil) {
            if (urlCurrent.type == 0) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(LM.coords.latitude, LM.coords.longitude);

                //create MKMapItem out of coordinates
                MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
                MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placeMark];
                if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                    [destination openInMapsWithLaunchOptions:nil];
                return;
            }
            NSString *urlString = [self translateURLType:urlCurrent];
            url = [NSURL URLWithString:urlString];
        }

        if (waypointManager.currentWaypoint != nil) {
            if (urlDestination.type == 0) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_lat_float, waypointManager.currentWaypoint.wpt_lon_float);

                //create MKMapItem out of coordinates
                MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
                MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placeMark];
                if ([destination respondsToSelector:@selector(openInMapsWithLaunchOptions:)] == YES)
                    [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
                return;
            }

            NSString *urlString = [self translateURLType:urlDestination];
            url = [NSURL URLWithString:urlString];
        }

        if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
            [MyTools messageBox:self header:@"Open external application" text:[NSString stringWithFormat:@"Unable to open the %@ application: URL not recognized", em.name]];
            return;
        }

        [[UIApplication sharedApplication] openURL:url];
        return;
    }];
}

- (void)menuAutoZoom
{
    configManager.dynamicmapEnable = !configManager.dynamicmapEnable;
    if (configManager.dynamicmapEnable == YES) {
        [lmi changeItem:menuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi changeItem:menuAutoZoom label:@"AutoZoom"];
    }
}

- (void)menuLoadWaypoints
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    wp.coordinates = [map currentCenter];
    [self showInfoView];

    NSArray *accounts = [dbc Accounts];
    __block NSInteger accountsFound = 0;
    [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account canDoRemoteStuff] == NO)
            return;
        accountsFound++;

        InfoItemDowload *iid = [infoView addDownload];
        [iid setDescription:account.site];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
        [d setObject:wp forKey:@"wp"];
        [d setObject:iid forKey:@"iid"];
        [d setObject:account forKey:@"account"];

        [self performSelectorInBackground:@selector(runLoadWaypoints:) withObject:d];
    }];


    if (accountsFound == 0) {
        [MyTools messageBox:self header:@"Nothing imported" text:@"No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account."];
        return;
    }
}

- (void)runLoadWaypoints:(NSMutableDictionary *)dict
{
    InfoItemDowload *iid = [dict objectForKey:@"iid"];
    dbWaypoint *wp = [dict objectForKey:@"wp"];
    dbAccount *account = [dict objectForKey:@"account"];

    NSObject *d;
    [account.remoteAPI loadWaypoints:wp.coordinates retObj:&d downloadInfoItem:iid];

    [infoView removeItem:iid];

    if (d == nil) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the data" error:account.lastError];
        return;
    }

    [importManager addToQueue:d group:dbc.Group_LiveImport account:account options:RUN_OPTION_NONE];

    if ([infoView hasItems] == NO) {
        [self hideInfoView];

        [dbWaypoint dbUpdateLogStatus];
        [waypointManager needsRefreshAll];
    }
}

- (void)menuRecenter
{
    [lmi enableItem:menuUseGPS];

    useGPS = NO;
    [LM useGPS:NO coordinates:[map currentCenter]];

    meLocation = [map currentCenter];
    followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuUseGPS
{
    [lmi disableItem:menuUseGPS];

    useGPS = YES;
    [LM useGPS:YES coordinates:CLLocationCoordinate2DMake(0, 0)];

    meLocation = [map currentCenter];
    followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuShowBoundaries
{
    if (showBoundaries == NO) {
        showBoundaries = YES;
        [lmi changeItem:menuShowBoundaries label:@"Hide boundaries"];
    } else {
        showBoundaries = NO;
        [lmi changeItem:menuShowBoundaries label:@"Show boundaries"];
    }
    [map showBoundaries:showBoundaries];
}

- (void)menuRemoveTarget
{
    [lmi disableItem:menuRemoveTarget];
    [waypointManager setCurrentWaypoint:nil];
}

- (void)menuExportVisible
{
    CLLocationCoordinate2D bottomLeft, topRight;
    [map currentRectangle:&bottomLeft topRight:&topRight];
    NSLog(@"bottomLeft: %@", [Coordinates NiceCoordinates:bottomLeft]);
    NSLog(@"topRight: %@", [Coordinates NiceCoordinates:topRight]);

    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:200];
    [waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp.coordinates.latitude > bottomLeft.latitude &&
            wp.coordinates.latitude < topRight.latitude &&
            wp.coordinates.longitude > bottomLeft.longitude &&
            wp.coordinates.longitude < topRight.longitude) {
            [wps addObject:wp];
        }
    }];
    if ([wps count] > 0)
        [ExportGPX exports:wps];
}

- (void)performLocalMenuAction:(NSInteger)index
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
        case menuUseGPS:
            [self menuUseGPS];
            return;

        case menuShowBoundaries:
            [self menuShowBoundaries];
            return;
        case menuRemoveTarget:
            [self menuRemoveTarget];
            return;
        case menuExportVisible:
            [self menuExportVisible];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
