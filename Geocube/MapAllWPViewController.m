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

@interface MapAllWPViewController ()

@end

@implementation MapAllWPViewController

- (instancetype)init
{
    self = [super init];
    self.followWhom = SHOW_SHOWBOTH;

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated isNavigating:NO];
}

- (void)refreshWaypointsData
{
    [bezelManager showBezel:self];
    [bezelManager setText:@"Refreshing database"];

    [waypointManager applyFilters:LM.coords];

    self.waypointsArray = [waypointManager currentWaypoints];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.map removeMarkers];
        [self.map placeMarkers];
    }];

    [bezelManager removeBezel];
}

- (void)menuLoadWaypoints
{
    dbWaypoint *wp = [[dbWaypoint alloc] init];
    wp.coordinates = [self.map currentCenter];
    [self showInfoView];

    NSArray *accounts = [dbc Accounts];
    __block NSInteger accountsFound = 0;
    [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account canDoRemoteStuff] == NO)
            return;
        accountsFound++;

        InfoItemID iid = [infoView addDownload];
        [infoView setDescription:iid description:account.site];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
        [d setObject:wp forKey:@"wp"];
        [d setObject:[NSNumber numberWithInteger:iid] forKey:@"iid"];
        [d setObject:account forKey:@"account"];

        [self performSelectorInBackground:@selector(runLoadWaypoints:) withObject:d];
    }];


    if (accountsFound == 0) {
        [MyTools messageBox:self header:@"Nothing imported" text:@"No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account."];
        return;
    }
}

- (void)remoteAPI_objectReadyToImport:(InfoViewer *)iv ivi:(InfoItemID)ivi object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)a
{
    // We are already in a background thread, but don't want to delay the next request until this one is processed.

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setObject:[NSNumber numberWithInteger:ivi] forKey:@"iii"];
    [dict setObject:iv forKey:@"infoViewer"];
    [dict setObject:o forKey:@"object"];
    [dict setObject:group forKey:@"group"];
    [dict setObject:a forKey:@"account"];
    [self performSelectorInBackground:@selector(importObjectBG:) withObject:dict];
}

- (void)importObjectBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    dbAccount *a = [dict objectForKey:@"account"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoViewer *iv = [dict objectForKey:@"infoViewer"];
    InfoItemID iii = [[dict objectForKey:@"iii"] integerValue];

    [importManager process:o group:g account:a options:RUN_OPTION_NONE infoViewer:iv ivi:iii];

    [infoView removeItem:iii];
    if ([infoView hasItems] == NO) {
        [self hideInfoView];

        [dbWaypoint dbUpdateLogStatus];
        [waypointManager needsRefreshAll];
    }
}

- (void)runLoadWaypoints:(NSMutableDictionary *)dict
{
    InfoItemID iid = [[dict objectForKey:@"iid"] integerValue];
    dbWaypoint *wp = [dict objectForKey:@"wp"];
    dbAccount *account = [dict objectForKey:@"account"];

    NSObject *d;
    NSInteger rv = [account.remoteAPI loadWaypoints:wp.coordinates retObj:&d infoViewer:infoView ivi:iid group:dbc.Group_LiveImport callback:self];

    [infoView removeItem:iid];

    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the data" error:account.remoteAPI.lastError];
        return;
    }

    if ([infoView hasItems] == NO)
        [self hideInfoView];
}

@end