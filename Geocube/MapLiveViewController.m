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

@end

@implementation MapLiveViewController

- (instancetype)init:(GCMapHowMany)mapWhat
{
    self = [super init:mapWhat];

    [lmi disableItem:MVCmenuExportVisible];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateLiveMaps];
}

- (void)remoteAPI_loadWaypointsByBoundingBox_returned:(InfoViewer *)iv ivi:(InfoItemID)ivi object:(NSObject *)o
{
    NSLog(@"remoteAPI_loadWaypointsByBoundingBox_returned");
}

- (void)runUpdateLiveMaps:(NSDictionary *)dict
{
    GCBoundingBox *bb = [dict objectForKey:@"bb"];
    InfoItemID iid = [[dict objectForKey:@"iid"] integerValue];
    dbAccount *account = [dict objectForKey:@"account"];

    NSObject *retObj;

    [account.remoteAPI loadWaypointsByBoundingBox:bb retObj:&retObj infoViewer:infoView ivi:iid callback:self];
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
    [bezelManager setText:@"Refreshing database"];

    [waypointManager applyFilters:LM.coords];

    self.waypointsArray = [NSMutableArray array];
    self.waypointCount = 0;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.map removeMarkers];
        [self.map placeMarkers];
    }];

    [bezelManager removeBezel];
}

@end
