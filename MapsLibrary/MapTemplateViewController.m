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

@interface MapTemplateViewController ()

@property (nonatomic, retain) THLabel *distanceLabel;
@property (nonatomic        ) BOOL distanceLabelLocked;
@property (nonatomic        ) NSInteger distanceLabelCounter;

@property (nonatomic, retain) UIButton *labelMapFollowMe;
@property (nonatomic, retain) UIButton *labelMapShowBoth;
@property (nonatomic, retain) UIButton *labelMapSeeTarget;
@property (nonatomic, retain) UIButton *labelMapFindMe;
@property (nonatomic, retain) UIButton *labelMapFindTarget;
@property (nonatomic, retain) UIImageView *labelMapGNSS;
@property (nonatomic, retain) MapWaypointInfoView *wpInfoView;

@property (nonatomic        ) CLLocationCoordinate2D meLocation;
@property (nonatomic        ) CLLocationDirection meBearing;
@property (nonatomic        ) BOOL useGNSS;

@property (nonatomic        ) BOOL hasGMS;
@property (nonatomic        ) BOOL hasMapbox;
@property (nonatomic        ) BOOL showBoundaries;

@property (nonatomic        ) BOOL isVisible;
@property (nonatomic        ) BOOL needsRefresh;

@property (nonatomic, retain) NSArray<MapBrand *> *mapBrands;

@property (nonatomic, retain) UITapGestureRecognizer *tap;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPress;

@end

@implementation MapTemplateViewController

+ (NSArray<MapBrand *> *)initMapBrands
{
    NSMutableArray<MapBrand *> *mapBrands = [NSMutableArray arrayWithCapacity:5];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapGoogle class] defaultString:@"google" menuLabel:@"Google Maps" key:MAPBRAND_GOOGLEMAPS]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapApple class] defaultString:@"apple" menuLabel:@"Apple Maps" key:MAPBRAND_APPLEMAPS]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapOSM class] defaultString:@"osm" menuLabel:@"OSM" key:MAPBRAND_OSM]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapESRIWorldTopo class] defaultString:@"esri_worldtopo" menuLabel:@"ESRI WorldTopo" key:MAPBRAND_ESRI_WORLDTOPO]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapMapbox class] defaultString:@"mapbox" menuLabel:@"Mapbox" key:MAPBRAND_MAPBOX]];

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

    self.mapBrands = [MapTemplateViewController initMapBrands];

    // Default map brand
    self.currentMapBrand = nil;
    [self.mapBrands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([configManager.mapBrandDefault isEqualToString:mb.defaultString] == YES) {
            self.currentMapBrand = mb;
            *stop = YES;
        }
    }];
    if (self.currentMapBrand == nil)
        self.currentMapBrand = [MapBrand findMapBrand:MAPBRAND_APPLEMAPS brands:self.mapBrands];

    // Disable GoogleMaps if there is no key
    self.hasGMS = YES;
    if (IS_EMPTY(keyManager.googlemaps) == YES)
        self.hasGMS = NO;
    self.hasMapbox = YES;
    if (IS_EMPTY(configManager.mapboxKey) == YES)
        self.hasMapbox = NO;
    if ([self.currentMapBrand.key isEqualToString:MAPBRAND_MAPBOX] == YES && self.hasMapbox == NO)
        self.currentMapBrand = [MapBrand findMapBrand:MAPBRAND_APPLEMAPS brands:self.mapBrands];
    if ([self.currentMapBrand.key isEqualToString:MAPBRAND_GOOGLEMAPS] == YES && self.hasGMS == NO)
        self.currentMapBrand = [MapBrand findMapBrand:MAPBRAND_APPLEMAPS brands:self.mapBrands];

    self.lmi = [[LocalMenuItems alloc] init:MVCmenuMax];
    [self.lmi addItem:MVCmenuBrandChange label:_(@"maptemplaceviewcontroller-Map Change")];
    [self.lmi addItem:MVCmenuMapType label:_(@"maptemplateviewcontroller-Map Type")];

    [self.lmi addItem:MVCmenuLoadWaypoints label:_(@"maptemplateviewcontroller-Load waypoints")];
    [self.lmi addItem:MVCmenuRemoveTarget label:_(@"maptemplateviewcontroller-Remove target")];
    [self.lmi addItem:MVCmenuRecenter label:_(@"maptemplateviewcontroller-Recenter")];
    [self.lmi addItem:MVCmenuExportVisible label:_(@"maptemplateviewcontroller-Export visible")];

    [self.lmi addItem:MVCmenuDirections label:_(@"maptemplateviewcontroller-Directions")];
    [self.lmi addItem:MVCmenuOpenIn label:_(@"maptemplateviewcontroller-Open in...")];
    if ([self.map menuOpenInSupported] == NO)
        [self.lmi disableItem:MVCmenuOpenIn];

    self.showBoundaries = NO;
    [self.lmi addItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Show boundaries")];

    [self.lmi addItem:MVCmenuRemoveHistory label:_(@"maptemplateviewcontroller-Remove history")];

    self.map = [[self.currentMapBrand.mapObject alloc] initMapObject:self];
    self.map.staticHistory = self.staticHistory;

    if (waypointManager.currentWaypoint == nil)
        [self.lmi disableItem:MVCmenuRemoveTarget];

    if (configManager.dynamicmapEnable == YES) {
        [self.lmi addItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-No autozoom")];
    } else {
        [self.lmi addItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-Autozoom")];
    }

    self.useGNSS = LM.useGNSS;
    if (self.useGNSS == YES)
        self.labelMapGNSS.image = currentTheme.mapGNSSOn;
    else
        self.labelMapGNSS.image = currentTheme.mapGNSSOff;

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

    self.needsRefresh = YES;
    self.isVisible = NO;
    if (self.staticHistory == NO)
        [waypointManager startDelegationWaypoints:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Appear GoogleMaps if it came back
    if (self.hasGMS == NO) {
        if (IS_EMPTY(keyManager.googlemaps) == NO) {
            self.hasGMS = YES;
            [GMSServices provideAPIKey:keyManager.googlemaps];
        }
    }
    // Appear Mapbox if it came back
    if (self.hasMapbox == NO) {
        if (IS_EMPTY(configManager.mapboxKey) == NO) {
            self.hasMapbox = YES;
            [MGLAccountManager setAccessToken:configManager.mapboxKey];
        }
    }

    // Enable GNSS Menu?
    self.useGNSS = LM.useGNSS;
    if (self.useGNSS == YES)
        self.labelMapGNSS.image = currentTheme.mapGNSSOn;
    else
        self.labelMapGNSS.image = currentTheme.mapGNSSOff;

    // Enable Remove Target menu only if there is a target
    if (waypointManager.currentWaypoint == nil)
        [self.lmi disableItem:MVCmenuRemoveTarget];
    else
        [self.lmi enableItem:MVCmenuRemoveTarget];

    [self.map mapViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated isNavigating:(BOOL)isNavigating
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [self.map mapViewDidAppear];

    if (self.staticHistory == NO) {
        [LM startDelegationLocation:self isNavigating:isNavigating];
        [LM startDelegationHistory:self];
        if (self.meLocation.longitude == 0 && self.meLocation.latitude == 0)
            [self locationManagerUpdateLocation];
    }

    [self updateMapButtons];

    self.isVisible = YES;
    if (self.needsRefresh == YES) {
        [self refreshWaypointsData];
        self.needsRefresh = NO;
    }
}

- (void)updateMapButtons
{
    if (waypointManager.currentWaypoint == nil) {
        self.labelMapShowBoth.userInteractionEnabled = NO;
        self.labelMapShowBoth.enabled = NO;
        self.labelMapSeeTarget.userInteractionEnabled = NO;
        self.labelMapSeeTarget.enabled = NO;
        self.labelMapFindTarget.userInteractionEnabled = NO;
        self.labelMapFindTarget.enabled = NO;
    } else {
        self.labelMapShowBoth.userInteractionEnabled = YES;
        self.labelMapShowBoth.enabled = YES;
        self.labelMapSeeTarget.userInteractionEnabled = YES;
        self.labelMapSeeTarget.enabled = YES;
        self.labelMapFindTarget.userInteractionEnabled = YES;
        self.labelMapFindTarget.enabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);

    if (self.staticHistory == NO) {
        [LM stopDelegationLocation:self];
        [LM stopDelegationHistory:self];
    }
    [super viewWillDisappear:animated];
    [self.map mapViewWillDisappear];
    self.isVisible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
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
    NSLog(@"New size %@", [MyTools niceCGRect:applicationFrame]);
    NSInteger width = applicationFrame.size.width;

    self.distanceLabel.frame = CGRectMake(3, 3, 250, 20);

    UIImage *img = currentTheme.mapFollowMe;
    NSInteger imgwidth = img.size.width;
    NSInteger imgheight = img.size.height;

    self.labelMapGNSS.frame = CGRectMake(width - 7.5 * imgwidth - 3, 3, imgwidth, imgheight);

    self.labelMapFindMe.frame = CGRectMake(width - 6 * imgwidth - 3, 3, imgwidth, imgheight);

    self.labelMapFollowMe.frame = CGRectMake(width - 4.5 * imgwidth - 3, 3, imgwidth, imgheight);
    self.labelMapShowBoth.frame = CGRectMake(width - 3.5 * imgwidth - 3, 3, imgwidth, imgheight);
    self.labelMapSeeTarget.frame = CGRectMake(width - 2.5 * imgwidth - 3, 3, imgwidth, imgheight);

    self.labelMapFindTarget.frame = CGRectMake(width - 1 * imgwidth - 3, 3, imgwidth, imgheight);

    [self showWaypointInfo:self.wpInfoView.waypoint];

    [self.map recalculateRects];
    [self.map updateMapScaleView];
}

- (void)initDistanceLabel
{
    self.distanceLabel = [[THLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.distanceLabel.strokeColor = [UIColor whiteColor];
    self.distanceLabel.layer.shadowColor = [[UIColor redColor] CGColor];
    self.distanceLabel.layer.shadowRadius = 1;
    self.distanceLabel.strokeSize = 1;
    [self.view addSubview:self.distanceLabel];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)initMapIcons
{
    self.labelMapGNSS = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.labelMapGNSS.layer.borderWidth = 1;
    self.labelMapGNSS.layer.borderColor = [UIColor blackColor].CGColor;
    self.labelMapGNSS.userInteractionEnabled = YES;
    self.labelMapGNSS.image = currentTheme.mapGNSSOn;
    [self.view addSubview:self.labelMapGNSS];

    [self.labelMapGNSS removeGestureRecognizer:self.tap];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapGNSS:)];
    self.tap.delegate = self;
    [self.labelMapGNSS addGestureRecognizer:self.tap];
    [self.labelMapGNSS removeGestureRecognizer:self.longPress];
    self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(menuLongPressGNSS:)];
    self.longPress.delegate = self;
    self.longPress.minimumPressDuration = 1;
    [self.labelMapGNSS addGestureRecognizer:self.longPress];

    self.labelMapFollowMe = [[UIButton alloc] initWithFrame:CGRectZero];
    self.labelMapFollowMe.layer.borderWidth = 1;
    self.labelMapFollowMe.layer.borderColor = [UIColor blackColor].CGColor;
    [self.labelMapFollowMe addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    self.labelMapFollowMe.userInteractionEnabled = YES;
    [self.labelMapFollowMe setImage:currentTheme.mapFollowMe forState:UIControlStateNormal];
    [self.view addSubview:self.labelMapFollowMe];

    self.labelMapShowBoth = [[UIButton alloc] initWithFrame:CGRectZero];
    self.labelMapShowBoth.layer.borderWidth = 1;
    self.labelMapShowBoth.layer.borderColor = [UIColor blackColor].CGColor;
    [self.labelMapShowBoth addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    self.labelMapShowBoth.userInteractionEnabled = YES;
    [self.labelMapShowBoth setImage:currentTheme.mapShowBoth forState:UIControlStateNormal];
    [self.view addSubview:self.labelMapShowBoth];

    self.labelMapSeeTarget = [[UIButton alloc] initWithFrame:CGRectZero];
    self.labelMapSeeTarget.layer.borderWidth = 1;
    self.labelMapSeeTarget.layer.borderColor = [UIColor blackColor].CGColor;
    [self.labelMapSeeTarget addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    self.labelMapSeeTarget.userInteractionEnabled = YES;
    [self.labelMapSeeTarget setImage:currentTheme.mapSeeTarget forState:UIControlStateNormal];
    [self.view addSubview:self.labelMapSeeTarget];

    self.labelMapFindMe = [[UIButton alloc] initWithFrame:CGRectZero];
    self.labelMapFindMe.layer.borderWidth = 1;
    self.labelMapFindMe.layer.borderColor = [UIColor blackColor].CGColor;
    [self.labelMapFindMe addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    self.labelMapFindMe.userInteractionEnabled = YES;
    [self.labelMapFindMe setImage:currentTheme.mapFindMe forState:UIControlStateNormal];
    [self.view addSubview:self.labelMapFindMe];

    self.labelMapFindTarget = [[UIButton alloc] initWithFrame:CGRectZero];
    self.labelMapFindTarget.layer.borderWidth = 1;
    self.labelMapFindTarget.layer.borderColor = [UIColor blackColor].CGColor;
    [self.labelMapFindTarget addTarget:self action:@selector(chooseMapFollow:) forControlEvents:UIControlEventTouchDown];
    self.labelMapFindTarget.userInteractionEnabled = YES;
    [self.labelMapFindTarget setImage:currentTheme.mapFindTarget forState:UIControlStateNormal];
    [self.view addSubview:self.labelMapFindTarget];

    [self updateMapButtons];

    switch (self.followWhom) {
        case SHOW_FOLLOWME:
            [self.labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [self.labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
            [self.labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [self.labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            [self.labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SHOWBOTH:
            [self.labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [self.labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [self.labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
            [self.labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
            [self.labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
        case SHOW_SEETARGET:
            [self.labelMapFindMe setBackgroundColor:[UIColor clearColor]];
            [self.labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
            [self.labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
            [self.labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
            [self.labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
            break;
        default:
            break;
    }
}

- (void)removeDistanceLabel
{
    self.distanceLabel = nil;
    self.labelMapFollowMe = nil;
    self.labelMapShowBoth = nil;
    self.labelMapSeeTarget = nil;
    self.labelMapFindMe = nil;
    self.labelMapFindTarget = nil;
}

- (void)chooseMapFollow:(UIButton *)button
{
    if (button == self.labelMapFollowMe) {
        [self menuShowWhom:SHOW_FOLLOWME];
        return;
    }
    if (button == self.labelMapShowBoth) {
        [self menuShowWhom:SHOW_SHOWBOTH];
        return;
    }
    if (button == self.labelMapSeeTarget) {
        [self menuShowWhom:SHOW_SEETARGET];
        return;
    }
    if (button == self.labelMapFindMe) {
        [self menuFindMe];
        return;
    }
    if (button == self.labelMapFindTarget) {
        [self menuFindTarget];
        return;
    }
}

/* Delegated from GCLocationManager */
- (void)locationManagerUpdateLocation
{
    if (self.useGNSS == NO)
        return;
    if (self.staticHistory == YES)
        return;

    self.meLocation = [LM coords];

    if (fabs(self.meBearing - [LM direction]) > 5)
        self.meBearing = [LM direction];

    // Move the map around to match current location
    switch (self.followWhom) {
        case SHOW_FOLLOWMEZOOM:
            [self.map moveCameraTo:self.meLocation zoom:YES];
            break;
        case SHOW_FOLLOWME:
            [self.map moveCameraTo:self.meLocation zoom:NO];
            break;
        case SHOW_SHOWBOTH:
            if (waypointManager.currentWaypoint != nil)
                [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) c2:self.meLocation];
            else {
                [self menuShowWhom:SHOW_FOLLOWME];
                [self.map moveCameraTo:self.meLocation zoom:NO];
            }
            break;
        default:
            break;
    }

    [self.map removeLineMeToWaypoint];
    if (waypointManager.currentWaypoint != nil)
        [self.map addLineMeToWaypoint];

    if (waypointManager.currentWaypoint != nil) {
        NSString *distance = [MyTools niceDistance:[Coordinates coordinates2distance:self.meLocation toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude]];
        [self showDistance:distance];
    } else {
        [self showDistance:@""];
    }
}

- (void)showDistance:(NSString *)d
{
    [self showDistance:d timeout:0 unlock:NO];
}

- (void)showDistance:(NSString *)d timeout:(NSTimeInterval)seconds unlock:(BOOL)unlock
{
    if (unlock == YES)
        self.distanceLabelLocked = NO;
    if (self.distanceLabelLocked == YES)
        return;
    if (seconds != 0)
        self.distanceLabelLocked = YES;
    self.distanceLabel.text = d;
    if (seconds != 0) {
        self.distanceLabelCounter++;
        BACKGROUND(showDistanceHide:, [NSNumber numberWithInteger:seconds]);
    }
}

- (void)showDistanceHide:(NSNumber *)seconds
{
    NSInteger i = self.distanceLabelCounter;
    [NSThread sleepForTimeInterval:[seconds integerValue]];
    MAINQUEUE(
        if (self.distanceLabelLocked == YES && i == self.distanceLabelCounter) {
            self.distanceLabelLocked = NO;
            self.distanceLabel.text = @"";
            [self.map removeLineTapToMe];
        }
    )
}

- (void)locationManagerUpdateHistory:(GCCoordsHistorical *)ch
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
    [self.labelMapFindMe setBackgroundColor:[UIColor clearColor]];
    [self.labelMapFollowMe setBackgroundColor:[UIColor clearColor]];
    [self.labelMapShowBoth setBackgroundColor:[UIColor clearColor]];
    [self.labelMapSeeTarget setBackgroundColor:[UIColor clearColor]];
    [self.labelMapFindTarget setBackgroundColor:[UIColor clearColor]];
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
        self.meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:self.meLocation zoom:NO];
        [self.labelMapFollowMe setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SEETARGET && waypointManager.currentWaypoint != nil) {
        self.followWhom = whom;
        self.meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) zoom:NO];
        [self.labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        self.followWhom = whom;
        self.meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) c2:self.meLocation];
        [self.labelMapShowBoth setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)menuFindMe
{
    self.meLocation = [LM coords];
    self.followWhom = SHOW_FOLLOWMEZOOM;
    [self labelClearAll];
    [self.labelMapFindMe setBackgroundColor:[UIColor grayColor]];
    [self.map moveCameraTo:self.meLocation zoom:YES];
}

- (void)menuFindTarget
{
    self.meLocation = [LM coords];
    self.followWhom = SHOW_SEETARGET;
    [self labelClearAll];
    [self.labelMapFindTarget setBackgroundColor:[UIColor grayColor]];
    [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) zoom:YES];
}

#pragma mark - Waypoint manager callbacks

- (void)waypointManagerRefreshWaypoints
{
    self.needsRefresh = YES;
    if (self.isVisible == YES) {
        self.needsRefresh = NO;
        BACKGROUND(refreshWaypointsData, nil);
    }
}

- NEEDS_OVERLOADING_VOID(refreshWaypointsData)

- (void)waypointManagerRemoveWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx != NSNotFound)
        [self.waypointsArray removeObject:wp];
    [self.map removeMarker:wp];
}

- (void)waypointManagerAddWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        [self.waypointsArray addObject:wp];
    [self.map placeMarker:wp];
}

- (void)waypointManagerUpdateWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [self.waypointsArray indexOfObject:wp];
    if (idx == NSNotFound)
        [self.waypointsArray addObject:wp];
    [self.map updateMarker:wp];
}

/*
 * WaypointInfo related stuff
 */

- (void)removeWaypointInfo
{
    [self.wpInfoView removeSelf];
    [self.wpInfoView removeFromSuperview];
    self.wpInfoView = nil;
}

- (void)initWaypointInfo
{
    /* Add the info window */
    CGRect maprect = self.view.frame;
    maprect.origin.y = maprect.size.height - [MapWaypointInfoView viewHeight];
    maprect.size.height = [MapWaypointInfoView viewHeight];
    self.wpInfoView = [[MapWaypointInfoView alloc] initWithFrame:maprect];
    self.wpInfoView.parentMap = self.map;
    [self.view addSubview:self.wpInfoView];
}

- (void)showWaypointInfo:(dbWaypoint *)wp
{
    if (wp == nil)
        return;
    if (self.wpInfoView != nil)
        [self removeWaypointInfo];
    [self initWaypointInfo];
    [self.wpInfoView showWaypoint:wp];
}

#pragma mark - Local menu related functions

- (void)menuChangeMapbrand
{
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:_(@"maptemplateviewcontroller-Choose your map")
                               message:nil
                               preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    [self.mapBrands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        // Do not enable Google Maps until available
        if ([mb.key isEqualToString:MAPBRAND_GOOGLEMAPS] == YES && (IS_EMPTY(keyManager.googlemaps) == YES))
            return;
        // Do not enable Mapbox until available
        if ([mb.key isEqualToString:MAPBRAND_MAPBOX] == YES && (IS_EMPTY(configManager.mapboxKey) == YES))
            return;

        UIAlertAction *a = [UIAlertAction
                            actionWithTitle:mb.key
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self menuChangeMapbrand:mb];
                                [view dismissViewControllerAnimated:YES completion:nil];

                                NSInteger count = 0;
                                if ([self.map mapHasViewMap] == TRUE) count++;
                                if ([self.map mapHasViewAerial] == TRUE) count++;
                                if ([self.map mapHasViewHybridMapAerial] == TRUE) count++;
                                if ([self.map mapHasViewTerrain] == TRUE) count++;
                                if (count <= 1)
                                    [self.lmi disableItem:MVCmenuMapType];
                                else
                                    [self.lmi enableItem:MVCmenuMapType];

                                if ([self.map menuOpenInSupported] == NO)
                                    [self.lmi disableItem:MVCmenuOpenIn];
                                else
                                    [self.lmi enableItem:MVCmenuOpenIn];
                            }];
        [view addAction:a];
    }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    [view addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
}

- (void)menuChangeMapbrand:(MapBrand *)mapBrand
{
    CLLocationCoordinate2D currentCoords = [self.map currentCenter];
    double currentZoom = [self.map currentZoom];
    NSLog(@"currentCoords: %@", [Coordinates niceCoordinates:currentCoords]);
    NSLog(@"currentZoom: %f", currentZoom);

    [self removeDistanceLabel];
    [self.map removeCamera];
    [self.map removeMap];

    for (UIView *b in self.view.subviews) {
        [b removeFromSuperview];
    }

    NSLog(@"Switching to %@", mapBrand.key);
    self.map = [[mapBrand.mapObject alloc] initMapObject:self];
    self.map.staticHistory = self.staticHistory;
    self.currentMapBrand = mapBrand;

    [self.map initMap];
    [self.map mapViewDidLoad];
    [self.map initCamera:currentCoords];
    [self.map moveCameraTo:currentCoords zoomLevel:currentZoom];

    [self initDistanceLabel];
    [self initMapIcons];
    [self recalculateRects];

    [self refreshWaypointsData];

    [self.map mapViewDidAppear];
    [self menuShowWhom:self.followWhom];

    [self.map showBoundaries:self.showBoundaries];

    [self locationManagerUpdateLocation];
}

- (void)menuMapType
{
    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:_(@"maptemplateviewcontroller-Choose the map type")
                               message:nil
                               preferredStyle:UIAlertControllerStyleActionSheet];
    view.popoverPresentationController.sourceView = self.view;
    view.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);

    if ([self.map mapHasViewMap] == TRUE) {
        UIAlertAction *a = [UIAlertAction
                            actionWithTitle:_(@"maptemplateviewcontroller-Map")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self.map setMapType:MAPTYPE_NORMAL];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];
        [view addAction:a];
    }
    if ([self.map mapHasViewAerial] == TRUE) {
        UIAlertAction *a = [UIAlertAction
                            actionWithTitle:_(@"maptemplateviewcontroller-Aerial")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self.map setMapType:MAPTYPE_AERIAL];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];
        [view addAction:a];
    }
    if ([self.map mapHasViewHybridMapAerial] == TRUE) {
        UIAlertAction *a = [UIAlertAction
                            actionWithTitle:_(@"maptemplateviewcontroller-Map/Aerial")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self.map setMapType:MAPTYPE_HYBRIDMAPAERIAL];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];
        [view addAction:a];
    }
    if ([self.map mapHasViewTerrain] == TRUE) {
        UIAlertAction *a = [UIAlertAction
                            actionWithTitle:_(@"maptemplateviewcontroller-Terrain")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self.map setMapType:MAPTYPE_TERRAIN];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];
        [view addAction:a];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    [view addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
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
            urlString = [NSString stringWithFormat:url.url, waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude];
            break;
        case 4:
            urlString = [NSString stringWithFormat:url.url, LM.coords.latitude, LM.coords.longitude, waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude];
            break;
        case 5:
            urlString = [NSString stringWithFormat:url.url, waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude,  LM.coords.latitude, LM.coords.longitude];
            break;
        case 6:
            urlString = [NSString stringWithFormat:url.url, LM.coords.longitude, LM.coords.latitude];
            break;
        case 7:
            urlString = [NSString stringWithFormat:url.url, waypointManager.currentWaypoint.wpt_longitude, waypointManager.currentWaypoint.wpt_latitude];
            break;
    }

    return urlString;
}

- (void)menuDirections
{
    [[dbExternalMap dbAll] enumerateObjectsUsingBlock:^(dbExternalMap * _Nonnull em, NSUInteger idx, BOOL * _Nonnull stop) {
        if (em.geocube_id != configManager.mapExternal)
            return;

        *stop = YES;

        NSLog(@"Opening %@ for external navigation", em.name);

        NSArray<dbExternalMapURL *> *urls = [dbExternalMapURL dbAllByExternalMap:em];
        __block dbExternalMapURL *urlCurrent = nil;
        __block dbExternalMapURL *urlDestination = nil;

        [urls enumerateObjectsUsingBlock:^(dbExternalMapURL * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
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
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude);

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

        NSLog(@"URL used: %@", url);

        if ([[UIApplication sharedApplication] canOpenURL:url] == NO) {
            [MyTools messageBox:self header:_(@"maptemplateviewcontroller-Open external application") text:[NSString stringWithFormat:_(@"maptemplateviewcontroller-Unable to open the %@ application: URL not recognized"), em.name]];
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
        [self.lmi changeItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-No autozoom")];
    } else {
        [self.lmi changeItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-Autozoom")];
    }
}

- (void)menuRecenter
{
    self.useGNSS = NO;
    [LM useGNSS:NO coordinates:[self.map currentCenter]];

    self.labelMapGNSS.image = currentTheme.mapGNSSOff;

    self.meLocation = [self.map currentCenter];
    self.followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuTapGNSS:(UIButton *)b
{
    if (self.useGNSS == NO) {
        self.useGNSS = YES;
        [LM useGNSS:YES coordinates:CLLocationCoordinate2DZero];

        self.labelMapGNSS.image = currentTheme.mapGNSSOn;

        self.meLocation = LM.coords;
        self.followWhom = SHOW_NEITHER;
    } else {
        self.useGNSS = NO;
        [LM useGNSS:NO coordinates:[self.map currentCenter]];

        self.labelMapGNSS.image = currentTheme.mapGNSSOff;

        self.meLocation = [self.map currentCenter];
        self.followWhom = SHOW_FOLLOWME;
    }

    [self.map showCenteredCoordinates:self.useGNSS coords:self.meLocation];
    [waypointManager needsRefreshAll];
}

- (void)menuLongPressGNSS:(id)sender
{
    if (self.useGNSS != NO)
        return;

    [LM useGNSS:NO coordinates:[self.map currentCenter]];

    self.meLocation = [self.map currentCenter];
    self.followWhom = SHOW_FOLLOWME;
    [waypointManager needsRefreshAll];
}

- (void)menuShowBoundaries
{
    if (self.showBoundaries == NO) {
        self.showBoundaries = YES;
        [self.lmi changeItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Hide boundaries")];
    } else {
        self.showBoundaries = NO;
        [self.lmi changeItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Show boundaries")];
    }
    [self.map showBoundaries:self.showBoundaries];
}

- (void)menuRemoveTarget
{
    [self.lmi disableItem:MVCmenuRemoveTarget];
    [self updateMapButtons];
    [waypointManager setTheCurrentWaypoint:nil];
    [self.map removeLineMeToWaypoint];
}

- (void)menuExportVisible
{
    CLLocationCoordinate2D bottomLeft, topRight;
    [self.map currentRectangle:&bottomLeft topRight:&topRight];
    NSLog(@"bottomLeft: %@", [Coordinates niceCoordinates:bottomLeft]);
    NSLog(@"topRight: %@", [Coordinates niceCoordinates:topRight]);

    NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:200];
    [self.waypointsArray enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (wp.wpt_latitude > bottomLeft.latitude &&
            wp.wpt_latitude < topRight.latitude &&
            wp.wpt_longitude > bottomLeft.longitude &&
            wp.wpt_longitude < topRight.longitude) {
            [wps addObject:wp];
        }
    }];
    if ([wps count] > 0) {
        NSString *filename = [ExportGPX exportWaypoints:wps];
        [MyTools messageBox:self header:_(@"maptemplateviewcontroller-Export successful") text:[NSString stringWithFormat:_(@"maptemplateviewcontroller-The exported file '%@' can be found in the Files section"), filename]];
    }
}

- (void)menuRemoveHistory
{
    [LM clearCoordsHistorical];
    [self.map removeHistory];
}

- (void)menuOpenIn
{
    [self.map menuOpenIn];
}

- NEEDS_OVERLOADING_VOID(menuLoadWaypoints)

- (void)performLocalMenuAction:(NSInteger)index
{
    MVMenuItem item = index;
    switch (item) {
        case MVCmenuMapType: /* Map view */
            [self menuMapType];
            return;

        case MVCmenuOpenIn:
            [self menuOpenIn];
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

        case MVCmenuBrandChange:
            [self menuChangeMapbrand];
            return;

        case MVCmenuMax:
            break;
    }

    [super performLocalMenuAction:index];
}

@end
