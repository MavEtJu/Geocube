/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface MapLiveViewController ()
{
    struct timeval lastMapUpdate;
    BOOL updateCountIsActive;
    CLLocationCoordinate2D lastMapBottomLeft, lastMapTopRight;
}

@end

@implementation MapLiveViewController

- (instancetype)init
{
    self = [super init];
    self.followWhom = SHOW_FOLLOWME;

    [lmi disableItem:MVCmenuExportVisible];
    self.waypointsArray = [NSMutableArray arrayWithCapacity:100];

    updateCountIsActive = NO;

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated isNavigating:YES];

    [self startUpdateCount];
}

- (void)remoteAPI_loadWaypointsByBoundingBox_returned:(InfoViewer *)iv ivi:(InfoItemID)ivi object:(NSObject *)o account:(dbAccount *)account
{
    NSLog(@"remoteAPI_loadWaypointsByBoundingBox_returned:%@", [o class]);

    if ([o isKindOfClass:[GCDictionaryGCA2 class]] == YES)
        [self importGCDictionaryGCA2:(GCDictionaryGCA2 *)o infoViewer:iv ivi:ivi account:account];
    else if ([o isKindOfClass:[GCDictionaryLiveAPI class]] == YES)
        [self importGCDictionaryLiveAPI:(GCDictionaryLiveAPI *)o infoViewer:iv ivi:ivi account:account];

    [iv removeItem:ivi];
    if ([iv hasItems] == NO)
        [self hideInfoView];
}

- (void)importGCDictionaryGCA2:(GCDictionaryGCA2 *)d infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi account:(dbAccount *)account
{
    NSArray *wps = [d objectForKey:@"waypoints"];
    [wps enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        LiveWaypoint *wp = [[LiveWaypoint alloc] init];
        NSLog(@"wptname: %ld", idx);
        DICT_NSSTRING_KEY(dict, wp.name, @"name");
        DICT_NSSTRING_KEY(dict, wp.code, @"code");

        NSString *l;
        DICT_NSSTRING_KEY(dict, l, @"location");
        NSArray *ls = [l componentsSeparatedByString:@"|"];
        wp.coords_lat = [ls objectAtIndex:0];
        wp.coords_lon = [ls objectAtIndex:1];

        wp.account = account;
        [wp finish];
        [self.waypointsArray addObject:wp];
    }];

    [self refreshWaypointsData];
}

- (void)importGCDictionaryLiveAPI:(GCDictionaryLiveAPI *)d infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi account:(dbAccount *)account
{
    NSArray *wps = [d objectForKey:@"Geocaches"];
    [wps enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        LiveWaypoint *wp = [[LiveWaypoint alloc] init];
        NSLog(@"wptname: %ld", idx);
        DICT_NSSTRING_KEY(dict, wp.name, @"Name");
        DICT_NSSTRING_KEY(dict, wp.code, @"Code");

        DICT_NSSTRING_KEY(dict, wp.coords_lat, @"Latitude");
        DICT_NSSTRING_KEY(dict, wp.coords_lon, @"Longitude");

        wp.account = account;
        [wp finish];
        [self.waypointsArray addObject:wp];

    }];

    [self refreshWaypointsData];
}

- (void)runUpdateLiveMaps:(NSDictionary *)dict
{
    GCBoundingBox *bb = [dict objectForKey:@"bb"];
    InfoItemID iid = [[dict objectForKey:@"iid"] integerValue];
    dbAccount *account = [dict objectForKey:@"account"];

    NSObject *retObj;

    if ([account.remoteAPI loadWaypointsByBoundingBox:bb retObj:&retObj infoViewer:infoView ivi:iid callback:self] != REMOTEAPI_OK)
        [infoView removeItem:iid];
}

- (void)updateLiveMaps
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    wp.coordinates = [self.map currentCenter];
    [self showInfoView];

    CLLocationCoordinate2D bl, tr;
    [self.map currentRectangle:&bl topRight:&tr];
    GCBoundingBox *bb = [[GCBoundingBox alloc] init];
    bb.leftLon = bl.longitude;
    bb.rightLon = tr.longitude;
    bb.topLat = tr.latitude;
    bb.bottomLat = bl.latitude;

    NSArray *accounts = [dbc Accounts];
    __block NSInteger accountsFound = 0;
    [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account canDoRemoteStuff] == NO)
            return;
        accountsFound++;

        InfoItemID iid = [infoView addDownload];
        [infoView setDescription:iid description:account.site];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
        [d setObject:account forKey:@"account"];
        [d setObject:bb forKey:@"bb"];
        [d setObject:[NSNumber numberWithInteger:iid] forKey:@"iid"];

        [self performSelectorInBackground:@selector(runUpdateLiveMaps:) withObject:d];
    }];

    if (accountsFound == 0) {
        [MyTools messageBox:self header:@"Nothing imported" text:@"No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account."];
        return;
    }
}

- (void)refreshWaypointsData
{
    [bezelManager showBezel:self];
    [bezelManager setText:@"Refreshing map"];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.map removeMarkers];
        [self.map placeMarkers];
    }];

    [bezelManager removeBezel];
}

- (void)userInteractionFinished
{
    [super userInteractionFinished];
    [self startUpdateCount];
}

- (void)startUpdateCount
{
    @synchronized (self) {
        gettimeofday(&lastMapUpdate, NULL);
        if (updateCountIsActive == NO)
            [self performSelectorInBackground:@selector(updateCountTimeout) withObject:nil];
    }
}

- (void)updateCountTimeout
{
    struct timeval now;
    struct timeval diff;

    updateCountIsActive = YES;
    while (TRUE) {
        [NSThread sleepForTimeInterval:0.1];
        @synchronized ((self)) {
            gettimeofday(&now, NULL);
            diff = [MyTools timevalDifference:lastMapUpdate t1:now];
            if (diff.tv_sec >= 1)
                break;
        }
    }

    CLLocationCoordinate2D bl, tr;

    [self.map currentRectangle:&bl topRight:&tr];
    if ([self hasMovedMoreThanEnough:lastMapBottomLeft prevTopRight:lastMapTopRight newBottomLeft:bl newTopRight:tr] == YES) {
        lastMapBottomLeft = bl;
        lastMapTopRight = tr;
        [self updateLiveMaps];
    }

    updateCountIsActive = NO;
}

- (BOOL)hasMovedMoreThanEnough:(CLLocationCoordinate2D)blo prevTopRight:(CLLocationCoordinate2D)tro newBottomLeft:(CLLocationCoordinate2D)bln newTopRight:(CLLocationCoordinate2D)trn
{
    // Centers
    CLLocationCoordinate2D cn = CLLocationCoordinate2DMake((bln.latitude + trn.latitude) / 2, (bln.longitude + trn.longitude) / 2);
    CLLocationCoordinate2D co = CLLocationCoordinate2DMake((blo.latitude + tro.latitude) / 2, (blo.longitude + tro.longitude) / 2);
    // Difference in centers
    CLLocationCoordinate2D cdiff = CLLocationCoordinate2DMake(fabs(co.latitude - cn.latitude), fabs(co.longitude - cn.longitude));
    // Size of boundary boxes
    CLLocationCoordinate2D sizenew = CLLocationCoordinate2DMake(fabs(bln.latitude - cn.latitude), fabs(bln.longitude - cn.longitude));
    CLLocationCoordinate2D sizeold = CLLocationCoordinate2DMake(fabs(blo.latitude - co.latitude), fabs(blo.longitude - co.longitude));

    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    NSLog(@"sizenew:(%@)", [Coordinates NiceCoordinates:sizenew]);
    NSLog(@"sizeold:(%@)", [Coordinates NiceCoordinates:sizeold]);
    NSLog(@"cdiff:  (%@)", [Coordinates NiceCoordinates:cdiff]);
    // If the difference in center
    if (cdiff.latitude > sizenew.latitude || cdiff.latitude > sizeold.latitude)
        return YES;
    if (cdiff.longitude > sizenew.longitude || cdiff.longitude > sizeold.longitude)
        return YES;

    return NO;
}

@end
