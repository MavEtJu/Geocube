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
    BOOL distanceLabelLocked;
    NSInteger distanceLabelCounter;

    UIButton *labelMapFollowMe;
    UIButton *labelMapShowBoth;
    UIButton *labelMapSeeTarget;
    UIButton *labelMapFindMe;
    UIButton *labelMapFindTarget;
    MapWaypointInfoView *wpInfoView;

    CLLocationCoordinate2D meLocation;
    CLLocationDirection meBearing;
    BOOL useGNSS;

    BOOL hasGMS;
    BOOL showBoundaries;

    BOOL isVisible;
    BOOL needsRefresh;

    NSArray<MapBrand *> *mapBrands;
}

@end

@implementation MapTemplateViewController

+ (NSArray<MapBrand *> *)initMapBrands
{
    NSMutableArray<MapBrand *> *mapBrands = [NSMutableArray arrayWithCapacity:5];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapGoogle class] defaultString:@"google" menuLabel:@"Google Maps" key:MAPBRAND_GOOGLEMAPS]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapApple class] defaultString:@"apple" menuLabel:@"Apple Maps" key:MAPBRAND_APPLEMAPS]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapOSM class] defaultString:@"osm" menuLabel:@"OSM" key:MAPBRAND_OSM]];
    [mapBrands addObject:[MapBrand mapBrandWithData:[MapESRIWorldTopo class] defaultString:@"esri_worldtopo" menuLabel:@"ESRI WorldTopo" key:MAPBRAND_ESRI_WORLDTOPO]];

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
    [mapBrands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([configManager.mapBrandDefault isEqualToString:mb.defaultString] == YES) {
            self.currentMapBrand = mb;
            *stop = YES;
        }
    }];
    if (self.currentMapBrand == nil)
        self.currentMapBrand = [MapBrand findMapBrand:MAPBRAND_APPLEMAPS brands:mapBrands];

    // Disable GoogleMaps if there is no key
    hasGMS = YES;
    if (keyManager.googlemaps == nil || [keyManager.googlemaps isEqualToString:@""] == YES)
        hasGMS = NO;
    if ([self.currentMapBrand.key isEqualToString:MAPBRAND_GOOGLEMAPS] == YES && hasGMS == NO)
        self.currentMapBrand = [MapBrand findMapBrand:MAPBRAND_APPLEMAPS brands:mapBrands];

    lmi = [[LocalMenuItems alloc] init:MVCmenuMax];
    [lmi addItem:MVCmenuBrandChange label:_(@"maptemplaceviewcontroller-Map Change")];
    [lmi addItem:MVCmenuMapType label:_(@"maptemplateviewcontroller-Map Type")];

    [lmi addItem:MVCmenuLoadWaypoints label:_(@"maptemplateviewcontroller-Load waypoints")];
    [lmi addItem:MVCmenuDirections label:_(@"maptemplateviewcontroller-Directions")];
    [lmi addItem:MVCmenuRemoveTarget label:_(@"maptemplateviewcontroller-Remove target")];
    [lmi addItem:MVCmenuRecenter label:_(@"maptemplateviewcontroller-Recenter")];
    [lmi addItem:MVCmenuUseGNSS label:_(@"maptemplateviewcontroller-Use GNSS")];
    [lmi addItem:MVCmenuExportVisible label:_(@"maptemplateviewcontroller-Export visible")];

    showBoundaries = NO;
    [lmi addItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Show boundaries")];

    [lmi addItem:MVCmenuRemoveHistory label:_(@"maptemplateviewcontroller-Remove history")];

    self.map = [[self.currentMapBrand.mapObject alloc] initMapObject:self];
    self.map.staticHistory = self.staticHistory;

    if (waypointManager.currentWaypoint == nil)
        [lmi disableItem:MVCmenuRemoveTarget];

    if (configManager.dynamicmapEnable == YES) {
        [lmi addItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-No autozoom")];
    } else {
        [lmi addItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-Autozoom")];
    }

    useGNSS = LM.useGNSS;
    if (useGNSS == YES)
        [lmi disableItem:MVCmenuUseGNSS];
    else
        [lmi disableItem:MVCmenuUseGNSS];

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
            [GMSServices provideAPIKey:keyManager.googlemaps];
        }
    }

    // Enable GNSS Menu?
    useGNSS = LM.useGNSS;
    if (useGNSS == YES)
        [lmi disableItem:MVCmenuUseGNSS];
    else
        [lmi enableItem:MVCmenuUseGNSS];

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
        [LM startDelegationLocation:self isNavigating:isNavigating];
        [LM startDelegationHistory:self];
        if (meLocation.longitude == 0 && meLocation.latitude == 0)
            [self updateLocationManagerLocation];
    }

    [self updateMapButtons];

    isVisible = YES;
    if (needsRefresh == YES) {
        [self refreshWaypointsData];
        needsRefresh = NO;
    }
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

    if (self.staticHistory == NO) {
        [LM stopDelegationLocation:self];
        [LM stopDelegationHistory:self];
    }
    [super viewWillDisappear:animated];
    [self.map mapViewWillDisappear];
    isVisible = NO;
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

    distanceLabel.frame = CGRectMake(3, 3, 250, 20);

    UIImage *img = [imageLibrary get:ImageIcon_FollowMe];
    NSInteger imgwidth = img.size.width;
    NSInteger imgheight = img.size.height;

    labelMapFindMe.frame = CGRectMake(width - 6 * 28 - 3, 3, imgwidth, imgheight);

    labelMapFollowMe.frame = CGRectMake(width - 4.5 * 28 - 3, 3, imgwidth, imgheight);
    labelMapShowBoth.frame = CGRectMake(width - 3.5 * 28 - 3, 3, imgwidth, imgheight);
    labelMapSeeTarget.frame = CGRectMake(width - 2.5 * 28 - 3, 3, imgwidth, imgheight);

    labelMapFindTarget.frame = CGRectMake(width - 1 * 28 - 3, 3, imgwidth, imgheight);

    [self showWaypointInfo:wpInfoView.waypoint];

    [self.map recalculateRects];
    [self.map updateMapScaleView];
}

- (void)initDistanceLabel
{
    distanceLabel = [[THLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    distanceLabel.strokeColor = [UIColor whiteColor];
    distanceLabel.layer.shadowColor = [[UIColor redColor] CGColor];
    distanceLabel.layer.shadowRadius = 1;
    distanceLabel.strokeSize = 1;
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
    if (useGNSS == NO)
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
                [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) c2:meLocation];
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
        NSString *distance = [MyTools niceDistance:[Coordinates coordinates2distance:meLocation toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude]];
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
        distanceLabelLocked = NO;
    if (distanceLabelLocked == YES)
        return;
    if (seconds != 0)
        distanceLabelLocked = YES;
    distanceLabel.text = d;
    if (seconds != 0) {
        distanceLabelCounter++;
        BACKGROUND(showDistanceHide:, [NSNumber numberWithInteger:seconds]);
    }
}

- (void)showDistanceHide:(NSNumber *)seconds
{
    NSInteger i = distanceLabelCounter;
    [NSThread sleepForTimeInterval:[seconds integerValue]];
    MAINQUEUE(
        if (distanceLabelLocked == YES && i == distanceLabelCounter) {
            distanceLabelLocked = NO;
            distanceLabel.text = @"";
            [self.map removeLineTapToMe];
        }
    )
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
            [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) zoom:NO];
        [labelMapSeeTarget setBackgroundColor:[UIColor grayColor]];
    }
    if (whom == SHOW_SHOWBOTH && waypointManager.currentWaypoint != nil) {
        self.followWhom = whom;
        meLocation = [LM coords];
        if (self.staticHistory == NO)
            [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) c2:meLocation];
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
    [self.map moveCameraTo:CLLocationCoordinate2DMake(waypointManager.currentWaypoint.wpt_latitude, waypointManager.currentWaypoint.wpt_longitude) zoom:YES];
}

#pragma mark - Waypoint manager callbacks

- (void)refreshWaypoints
{
    needsRefresh = YES;
    if (isVisible == YES) {
        needsRefresh = NO;
        BACKGROUND(refreshWaypointsData, nil);
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

/*
 * WaypointInfo related stuff
 */

- (void)removeWaypointInfo
{
    [wpInfoView removeFromSuperview];
    wpInfoView = nil;
}

- (void)initWaypointInfo
{
    /* Add the info window */
    CGRect maprect = self.view.frame;
    maprect.origin.y = maprect.size.height - [MapWaypointInfoView viewHeight];
    maprect.size.height = [MapWaypointInfoView viewHeight];
    wpInfoView = [[MapWaypointInfoView alloc] initWithFrame:maprect];
    wpInfoView.parentMap = self.map;
    [self.view addSubview:wpInfoView];
}

- (void)showWaypointInfo:(dbWaypoint *)wp
{
    if (wp == nil)
        return;
    if (wpInfoView != nil)
        [self removeWaypointInfo];
    [self initWaypointInfo];
    [wpInfoView showWaypoint:wp];
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

    [mapBrands enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        // Do not enable Google Maps until available
        if ([mb.key isEqualToString:MAPBRAND_GOOGLEMAPS] == YES && (keyManager.googlemaps == nil || [keyManager.googlemaps isEqualToString:@""] == YES))
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
                                    [lmi disableItem:MVCmenuMapType];
                                else
                                    [lmi enableItem:MVCmenuMapType];
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

    [self.map showBoundaries:showBoundaries];

    [self updateLocationManagerLocation];
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
        [lmi changeItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-No autozoom")];
    } else {
        [lmi changeItem:MVCmenuAutoZoom label:_(@"maptemplateviewcontroller-Autozoom")];
    }
}

- (void)menuRecenter
{
    [lmi enableItem:MVCmenuUseGNSS];

    useGNSS = NO;
    [LM useGNSS:NO coordinates:[self.map currentCenter]];

    meLocation = [self.map currentCenter];
    self.followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuUseGNSS
{
    [lmi disableItem:MVCmenuUseGNSS];

    useGNSS = YES;
    [LM useGNSS:YES coordinates:CLLocationCoordinate2DZero];

    meLocation = [self.map currentCenter];
    self.followWhom = SHOW_NEITHER;
    [waypointManager needsRefreshAll];
}

- (void)menuShowBoundaries
{
    if (showBoundaries == NO) {
        showBoundaries = YES;
        [lmi changeItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Hide boundaries")];
    } else {
        showBoundaries = NO;
        [lmi changeItem:MVCmenuShowBoundaries label:_(@"maptemplateviewcontroller-Show boundaries")];
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
        case MVCmenuMapType: /* Map view */
            [self menuMapType];
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
        case MVCmenuUseGNSS:
            [self menuUseGNSS];
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
