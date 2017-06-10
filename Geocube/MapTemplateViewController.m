/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface MapTemplateViewController ()
{
    THLabel *distanceLabel;
    UIButton *labelMapFollowMe;
    UIButton *labelMapShowBoth;
    UIButton *labelMapSeeTarget;
    UIButton *labelMapFindMe;
    UIButton *labelMapFindTarget;

    CLLocationCoordinate2D meLocation;
    CLLocationDirection meBearing;
    BOOL useGPS;

    BOOL hasGMS;
    BOOL showBoundaries;

    BOOL isVisible;
    BOOL needsRefresh;

    NSDictionary *mapBrands;
}

@end

@implementation MapTemplateViewController

+ (NSDictionary *)initMapBrands
{
    NSMutableDictionary *mapBrands = [NSMutableDictionary dictionaryWithCapacity:10];
    [mapBrands setObject:[MapBrand mapBrandWithData:[MapGoogle class] menuItem:MVCmenuBrandGoogle defaultString:@"google" menuLabel:@"Google Maps" key:MAPBRAND_GOOGLEMAPS] forKey:MAPBRAND_GOOGLEMAPS];
    [mapBrands setObject:[MapBrand mapBrandWithData:[MapApple class] menuItem:MVCmenuBrandApple defaultString:@"apple" menuLabel:@"Apple Maps" key:MAPBRAND_APPLEMAPS] forKey:MAPBRAND_APPLEMAPS];
    [mapBrands setObject:[MapBrand mapBrandWithData:[MapOSM class] menuItem:MVCmenuBrandOSM defaultString:@"osm" menuLabel:@"OSM" key:MAPBRAND_OSM] forKey:MAPBRAND_OSM];
    [mapBrands setObject:[MapBrand mapBrandWithData:[MapESRIWorldTopo class] menuItem:MVCmenuBrandESRIWorldTopo defaultString:@"esri_worldtopo" menuLabel:@"ESRI WorldTopo" key:MAPBRAND_ESRI_WORLDTOPO] forKey:MAPBRAND_ESRI_WORLDTOPO];

    return mapBrands;
}

- (instancetype)init
{
    NSAssert(FALSE, @"This should not be called");
    return nil;
}

- (instancetype)init:(BOOL)staticHistory
{
    self = [super init];

    self.staticHistory = staticHistory;

    mapBrands = [MapTemplateViewController initMapBrands];

    // Default map brand
    self.currentMapBrand = nil;
    [mapBrands enumerateKeysAndObjectsUsingBlock:^(NSString *key, MapBrand *mb, BOOL *stop) {
        if ([configManager.mapBrandDefault isEqualToString:mb.defaultString] == YES) {
            self.currentMapBrand = mb;
            *stop = YES;
        }
    }];
    if (self.currentMapBrand == nil)
        self.currentMapBrand = [mapBrands objectForKey:@"applemaps"];

    // Disable GoogleMaps if there is no key
    hasGMS = YES;
    if (keyManager.googlemaps == nil || [keyManager.googlemaps isEqualToString:@""] == YES)
        hasGMS = NO;
    if ([self.currentMapBrand.key isEqualToString:MAPBRAND_GOOGLEMAPS] == YES && hasGMS == NO)
        self.currentMapBrand = [mapBrands objectForKey:@"applemaps"];

    lmi = [[LocalMenuItems alloc] init:MVCmenuMax];
    [mapBrands enumerateKeysAndObjectsUsingBlock:^(NSString *key, MapBrand *mb, BOOL * _Nonnull stop) {
        [lmi addItem:mb.menuItem label:mb.menuLabel];
    }];

    [lmi addItem:MVCmenuMapMap label:@"Map"];
    [lmi addItem:MVCmenuMapAerial label:@"Aerial"];
    [lmi addItem:MVCmenuMapHybridMapAerial label:@"Map/Aerial"];
    [lmi addItem:MVCmenuMapTerrain label:@"Terrain"];

    [lmi addItem:MVCmenuLoadWaypoints label:@"Load Waypoints"];
    [lmi addItem:MVCmenuDirections label:@"Directions"];
    [lmi addItem:MVCmenuRemoveTarget label:@"Remove Target"];
    [lmi addItem:MVCmenuRecenter label:@"Recenter"];
    [lmi addItem:MVCmenuUseGPS label:@"Use GPS"];
    [lmi addItem:MVCmenuExportVisible label:@"Export Visible"];

    showBoundaries = NO;
    [lmi addItem:MVCmenuShowBoundaries label:@"Show Boundaries"];

    [lmi addItem:MVCmenuRemoveHistory label:@"Remove History"];

    self.map = [[self.currentMapBrand.mapObject alloc] initMapObject:self];
    self.map.staticHistory = self.staticHistory;
    [lmi disableItem:self.currentMapBrand.menuItem];

    // Various map view options
    if ([self.map mapHasViewMap] == FALSE)
        [lmi disableItem:MVCmenuMapMap];
    if ([self.map mapHasViewAerial] == FALSE)
        [lmi disableItem:MVCmenuMapAerial];
    if ([self.map mapHasViewHybridMapAerial] == FALSE)
        [lmi disableItem:MVCmenuMapHybridMapAerial];
    if ([self.map mapHasViewTerrain] == FALSE)
        [lmi disableItem:MVCmenuMapTerrain];

    if (waypointManager.currentWaypoint == nil)
        [lmi disableItem:MVCmenuRemoveTarget];

    if (configManager.dynamicmapEnable == YES) {
        [lmi addItem:MVCmenuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi addItem:MVCmenuAutoZoom label:@"Auto Zoom"];
    }

    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi disableItem:MVCmenuUseGPS];
    else
        [lmi disableItem:MVCmenuUseGPS];

    if (keyManager.googlemaps == nil || [keyManager.googlemaps isEqualToString:@""] == YES)
        [lmi disableItem:MVCmenuBrandGoogle];

    self.waypointsArray = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.map initMap];
    [self.map initCamera:LM.coords];
    [self.map mapViewDidLoad];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];

    [self makeInfoView];

    // This has to happen as last as it isn't initialized until the map is shown
    switch ([self.map mapType]) {
        case MAPTYPE_NORMAL:
            [lmi disableItem:MVCmenuMapMap];
            break;
        case MAPTYPE_AERIAL:
            [lmi disableItem:MVCmenuMapAerial];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            [lmi disableItem:MVCmenuMapHybridMapAerial];
            break;
        case MAPTYPE_TERRAIN:
            [lmi disableItem:MVCmenuMapTerrain];
            break;
    }

    needsRefresh = YES;
    isVisible = NO;
    if (self.staticHistory == NO)
        [waypointManager startDelegation:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Appear GoogleMaps if it came back
    if (hasGMS == NO) {
        if (keyManager.googlemaps != nil && [keyManager.googlemaps isEqualToString:@""] == NO) {
            hasGMS = YES;
            [lmi enableItem:MVCmenuBrandGoogle];
            [GMSServices provideAPIKey:keyManager.googlemaps];
        }
    }

    // Enable GPS Menu?
    useGPS = LM.useGPS;
    if (useGPS == YES)
        [lmi disableItem:MVCmenuUseGPS];
    else
        [lmi enableItem:MVCmenuUseGPS];

    // Enable Remove Target menu only if there is a target
    if (waypointManager.currentWaypoint == nil)
        [lmi disableItem:MVCmenuRemoveTarget];
    else
        [lmi enableItem:MVCmenuRemoveTarget];

    [self.map mapViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated isNavigating:(BOOL)isNavigating
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [self.map mapViewDidAppear];

    if (self.staticHistory == NO) {
        [LM startDelegation:self isNavigating:isNavigating];
        if (meLocation.longitude == 0 && meLocation.latitude == 0)
            [self updateLocationManagerLocation];
    }

    [self updateMapButtons];

    isVisible = YES;
    if (needsRefresh == YES) {
        [self refreshWaypointsData];
        needsRefresh = NO;
    }

    if ([self.map waypointInfoViewIsShown] == YES)
        [self.map showWaypointInfo];
}

- (void)updateMapButtons
{
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

    if (self.staticHistory == NO)
        [LM stopDelegation:self];
    [super viewWillDisappear:animated];
    [self.map mapViewWillDisappear];
    isVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
//    [self.map removeMarkers];
    [super viewDidDisappear:animated];
    [self.map mapViewDidDisappear];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
                                     [self recalculateRects];
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

    labelMapFindMe.frame = CGRectMake(width - 6 * 28 - 3, 3, imgwidth, imgheight);

    labelMapFollowMe.frame = CGRectMake(width - 4.5 * 28 - 3, 3, imgwidth, imgheight);
    labelMapShowBoth.frame = CGRectMake(width - 3.5 * 28 - 3, 3, imgwidth, imgheight);
    labelMapSeeTarget.frame = CGRectMake(width - 2.5 * 28 - 3, 3, imgwidth, imgheight);

    labelMapFindTarget.frame = CGRectMake(width - 1 * 28 - 3, 3, imgwidth, imgheight);

    [self.map recalculateRects];
    [self.map updateMapScaleView];
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

    [self updateMapButtons];

    switch (self.followWhom) {
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
    if (self.staticHistory == YES)
        return;

    meLocation = [LM coords];

    if (fabs(meBearing - [LM direction]) > 5) {
        meBearing = [LM direction];
        if (configManager.mapRotateToBearing == YES)
            [self.map updateMyBearing:meBearing];
    }

    // Move the map around to match current location
    switch (self.followWhom) {
        case SHOW_FOLLOWMEZOOM:
            [self.map moveCameraTo:meLocation zoom:YES];
            break;
        case SHOW_FOLLOWME:
            [self.map moveCameraTo:meLocation zoom:NO];
            break;
        case SHOW_SHOWBOTH:
            if (waypointManager.currentWaypoint != nil)
                [self.map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
            else {
                [self menuShowWhom:SHOW_FOLLOWME];
                [self.map moveCameraTo:meLocation zoom:NO];
            }
            break;
        default:
            break;
    }

    [self.map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [self.map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools niceDistance:[Coordinates coordinates2distance:meLocation to:waypointManager.currentWaypoint.coordinates]];
        distanceLabel.text = distance;
        distanceLabel.layer.shadowColor = [[UIColor redColor] CGColor];
        distanceLabel.layer.shadowRadius = 1;
    } else {
        distanceLabel.text = @"";
    }
}

- (void)updateLocationManagerHistory:(GCCoordsHistorical *)ch
{
    if (ch == nil) {
        [self.map removeHistory];
        [self.map showHistory];
    } else {
        [self.map addHistory:ch];
    }
}

- (void)addNewWaypoint:(CLLocationCoordinate2D)coords
{
    WaypointAddViewController *newController = [[WaypointAddViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    [newController setCoordinates:coords];
}

#pragma mark -- Map menu related functions

- (void)labelClearAll
{
    [labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
}

- (void)userInteractionFinished
{
}

- (void)userInteractionStart
{
    self.followWhom = SHOW_NEITHER;
    [self labelClearAll];
}

- (void)menuShowWhom:(NSInteger)whom
{
    [self labelClearAll];

    if (whom == SHOW_FOLLOWME) {
        self.followWhom = whom;
        meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:meLocation zoom:NO];
        [labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SEETARGET && waypointManager.currentWaypoint != nil) {
        self.followWhom = whom;
        meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:NO];
        [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        self.followWhom = whom;
        meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:waypointManager.currentWaypoint.coordinates c2:meLocation];
        [labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)menuFindMe
{
    meLocation = [LM coords];
    self.followWhom = SHOW_FOLLOWMEZOOM;
    [self labelClearAll];
    [labelMapFindMe setBackgroundColor:[UIColor grayColor]];
    [self.map moveCameraTo:meLocation zoom:YES];
}

- (void)menuFindTarget
{
    meLocation = [LM coords];
    self.followWhom = SHOW_SEETARGET;
    [self labelClearAll];
    [labelMapFindTarget setBackgroundColor:[UIColor grayColor]];
    [self.map moveCameraTo:waypointManager.currentWaypoint.coordinates zoom:YES];
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

- NEEDS_OVERLOADING_VOID(refreshWaypointsData)

- (void)removeWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx != NSNotFound)
        [self.waypointsArray removeObject:wp];
    [self.map removeMarker:wp];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        [self.waypointsArray addObject:wp];
    [self.map placeMarker:wp];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        [self.waypointsArray addObject:wp];
    [self.map updateMarker:wp];
}

#pragma mark - Local menu related functions

- (void)menuChangeMapbrand:(MapBrand *)mapBrand
{
    CLLocationCoordinate2D currentCoords = [self.map currentCenter];
    double currentZoom = [self.map currentZoom];
    NSLog(@"currentCoords: %@", [Coordinates NiceCoordinates:currentCoords]);
    NSLog(@"currentZoom: %f", currentZoom);

    [self removeDistanceLabel];
//    [map removeMarkers];
    [self.map removeCamera];
    [self.map removeMap];

    for (UIView *b in self.view.subviews) {
        [b removeFromSuperview];
    }

    [mapBrands enumerateKeysAndObjectsUsingBlock:^(NSString *key, MapBrand *mb, BOOL * _Nonnull stop) {
        [lmi enableItem:mb.menuItem];
    }];
    NSLog(@"Switching to %@", mapBrand.key);
    self.map = [[mapBrand.mapObject alloc] initMapObject:self];
    self.map.staticHistory = self.staticHistory;
    [lmi disableItem:mapBrand.menuItem];
    self.currentMapBrand = mapBrand;

    // Various map view options
    if ([self.map mapHasViewMap] == FALSE)
        [lmi disableItem:MVCmenuMapMap];
    else
        [lmi enableItem:MVCmenuMapMap];
    if ([self.map mapHasViewAerial] == FALSE)
        [lmi disableItem:MVCmenuMapAerial];
    else
        [lmi enableItem:MVCmenuMapAerial];
    if ([self.map mapHasViewHybridMapAerial] == FALSE)
        [lmi disableItem:MVCmenuMapHybridMapAerial];
    else
        [lmi enableItem:MVCmenuMapHybridMapAerial];
    if ([self.map mapHasViewTerrain] == FALSE)
        [lmi disableItem:MVCmenuMapTerrain];
    else
        [lmi enableItem:MVCmenuMapTerrain];

    // Just check if we can do this...
    if (keyManager.googlemaps == nil || [keyManager.googlemaps isEqualToString:@""] == YES)
        [lmi disableItem:MVCmenuBrandGoogle];

    [self.map initMap];
    [self.map mapViewDidLoad];
    [self.map initCamera:currentCoords];
    [self.map moveCameraTo:currentCoords zoomLevel:currentZoom];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];

    [self refreshWaypointsData];
//    [map placeMarkers];

    [self.map mapViewDidAppear];
    [self menuShowWhom:self.followWhom];

    [self.map showBoundaries:showBoundaries];

    [self updateLocationManagerLocation];

    // This has to happen as last as it isn't initialized until the map is shown
    switch ([self.map mapType]) {
        case MAPTYPE_NORMAL:
            [lmi disableItem:MVCmenuMapMap];
            break;
        case MAPTYPE_AERIAL:
            [lmi disableItem:MVCmenuMapAerial];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            [lmi disableItem:MVCmenuMapHybridMapAerial];
            break;
        case MAPTYPE_TERRAIN:
            [lmi disableItem:MVCmenuMapTerrain];
            break;
    }

}

- (void)menuMapType:(GCMapType)maptype
{
    switch ([self.map mapType]) {
        case MAPTYPE_NORMAL:
            [lmi enableItem:MVCmenuMapMap];
            break;
        case MAPTYPE_AERIAL:
            [lmi enableItem:MVCmenuMapAerial];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            [lmi enableItem:MVCmenuMapHybridMapAerial];
            break;
        case MAPTYPE_TERRAIN:
            [lmi enableItem:MVCmenuMapTerrain];
            break;
    }

    [self.map setMapType:maptype];

    switch ([self.map mapType]) {
        case MAPTYPE_NORMAL:
            [lmi disableItem:MVCmenuMapMap];
            break;
        case MAPTYPE_AERIAL:
            [lmi disableItem:MVCmenuMapAerial];
            break;
        case MAPTYPE_HYBRIDMAPAERIAL:
            [lmi disableItem:MVCmenuMapHybridMapAerial];
            break;
        case MAPTYPE_TERRAIN:
            [lmi disableItem:MVCmenuMapTerrain];
            break;
    }
}

- (NSString *)translateURLType:(dbExternalMapURL *)url
{
    /*
     * Types:
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

        NSArray<dbExternalMapURL *> *urls = [dbExternalMapURL dbAllByExternalMap:em._id];
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

        [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
        return;
    }];
}

- (void)menuAutoZoom
{
    configManager.dynamicmapEnable = !configManager.dynamicmapEnable;
    if (configManager.dynamicmapEnable == YES) {
        [lmi changeItem:MVCmenuAutoZoom label:@"No AutoZoom"];
    } else {
        [lmi changeItem:MVCmenuAutoZoom label:@"AutoZoom"];
    }
}

- (void)menuRecenter
{
    [lmi enableItem:MVCmenuUseGPS];

    useGPS = NO;
    [LM useGPS:NO coordinates:[self.map currentCenter]];

    meLocation = [self.map currentCenter];
    self.followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuUseGPS
{
    [lmi disableItem:MVCmenuUseGPS];

    useGPS = YES;
    [LM useGPS:YES coordinates:CLLocationCoordinate2DMake(0, 0)];

    meLocation = [self.map currentCenter];
    self.followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuShowBoundaries
{
    if (showBoundaries == NO) {
        showBoundaries = YES;
        [lmi changeItem:MVCmenuShowBoundaries label:@"Hide boundaries"];
    } else {
        showBoundaries = NO;
        [lmi changeItem:MVCmenuShowBoundaries label:@"Show boundaries"];
    }
    [self.map showBoundaries:showBoundaries];
}

- (void)menuRemoveTarget
{
    [lmi disableItem:MVCmenuRemoveTarget];
    [self updateMapButtons];
    [waypointManager setTheCurrentWaypoint:nil];
}

- (void)menuExportVisible
{
    CLLocationCoordinate2D bottomLeft, topRight;
    [self.map currentRectangle:&bottomLeft topRight:&topRight];
    NSLog(@"bottomLeft: %@", [Coordinates NiceCoordinates:bottomLeft]);
    NSLog(@"topRight: %@", [Coordinates NiceCoordinates:topRight]);

    NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:200];
    [self.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)menuRemoveHistory
{
    [LM clearCoordsHistorical];
    [self.map removeHistory];
}

- NEEDS_OVERLOADING_VOID(menuLoadWaypoints)

- (void)performLocalMenuAction:(NSInteger)index
{
    MVMenuItem item = index;
    switch (item) {
        case MVCmenuMapMap: /* Map view */
            [self menuMapType:MAPTYPE_NORMAL];
            return;
        case MVCmenuMapAerial: /* Aerial view */
            [self menuMapType:MAPTYPE_AERIAL];
            return;
        case MVCmenuMapHybridMapAerial: /* Hybrid view */
            [self menuMapType:MAPTYPE_HYBRIDMAPAERIAL];
            return;
        case MVCmenuMapTerrain: /* Terrain view */
            [self menuMapType:MAPTYPE_TERRAIN];
            return;

        case MVCmenuDirections:
            [self menuDirections];
            return;
        case MVCmenuAutoZoom:
            [self menuAutoZoom];
            return;
        case MVCmenuLoadWaypoints:
            [self menuLoadWaypoints];
            return;

        case MVCmenuRecenter:
            [self menuRecenter];
            return;
        case MVCmenuUseGPS:
            [self menuUseGPS];
            return;

        case MVCmenuShowBoundaries:
            [self menuShowBoundaries];
            return;
        case MVCmenuRemoveTarget:
            [self menuRemoveTarget];
            return;
        case MVCmenuExportVisible:
            [self menuExportVisible];
            return;
        case MVCmenuRemoveHistory:
            [self menuRemoveHistory];
            return;

        case MVCmenuMax:
            break;

        default:
            [mapBrands enumerateKeysAndObjectsUsingBlock:^(NSString *key, MapBrand * _Nonnull mb, BOOL * _Nonnull stop) {
                if (item == mb.menuItem) {
                    [self menuChangeMapbrand:mb];
                    *stop = YES;
                }
            }];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
