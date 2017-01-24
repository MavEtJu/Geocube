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

@interface MapAllWPViewController ()

@end

// The maximum size for the bounding box is from the Groundspeak LiveAPI where it is 100km max.
#define MAXSIZE 95000

@implementation MapAllWPViewController

- (instancetype)init
{
    self = [super init];
    self.followWhom = SHOW_SHOWBOTH;

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // The analyze feature of Xcode will throw here a false positive on:
    // The 'viewDidAppear:' instance method in UIViewController subclass 'MapAllWPViewController' is missing a [super viewDidAppear:] call
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
    CLLocationCoordinate2D bl, tr;

    [self.map currentRectangle:&bl topRight:&tr];
    NSInteger dist = [Coordinates coordinates2distance:bl to:tr];
    if ([Coordinates coordinates2distance:bl to:tr] > MAXSIZE) {
        [MyTools messageBox:self header:@"Adjustment" text:[NSString stringWithFormat:@"The distance to the top right of the map and the bottom left of the map has been reduced from %@ to a maximum of %@", [MyTools niceDistance:dist], [MyTools niceDistance:MAXSIZE]]];
        do {
            CLLocationCoordinate2D tbl = bl;
            CLLocationCoordinate2D ttr = tr;
            // Adjust at 5% per side for every iteration
            bl.longitude = (tbl.longitude * 19 + ttr.longitude) / 20;
            bl.latitude = (tbl.latitude * 19 + ttr.latitude) / 20;
            tr.longitude = (tbl.longitude + ttr.longitude * 19) / 20;
            tr.latitude = (tbl.latitude + ttr.latitude * 19) / 20;
            dist = [Coordinates coordinates2distance:bl to:tr];
        } while ([Coordinates coordinates2distance:bl to:tr] > MAXSIZE);
    }

    GCBoundingBox *bb = [[GCBoundingBox alloc] init];
    bb.leftLon = bl.longitude;
    bb.rightLon = tr.longitude;
    bb.topLat = tr.latitude;
    bb.bottomLat = bl.latitude;

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
        [d setObject:bb forKey:@"boundingbox"];
        [d setObject:[NSNumber numberWithInteger:iid] forKey:@"iid"];
        [d setObject:account forKey:@"account"];

        [self performSelectorInBackground:@selector(runLoadWaypoints:) withObject:d];
    }];

    if (accountsFound == 0) {
        [MyTools messageBox:self header:@"Nothing imported" text:@"No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account."];
        return;
    }
}

- (void)remoteAPI_loadWaypointsByBoundingBox_returned:(InfoViewer *)iv ivi:(InfoItemID)ivi object:(NSObject *)o account:(dbAccount *)account
{
    // We are already in a background thread, but don't want to delay the next request until this one is processed.

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setObject:[NSNumber numberWithInteger:ivi] forKey:@"iii"];
    [dict setObject:iv forKey:@"infoViewer"];
    [dict setObject:o forKey:@"object"];
    [dict setObject:dbc.Group_LiveImport forKey:@"group"];
    [dict setObject:account forKey:@"account"];
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
    GCBoundingBox *bb = [dict objectForKey:@"boundingbox"];
    dbAccount *account = [dict objectForKey:@"account"];

    NSObject *d;
    NSInteger rv = [account.remoteAPI loadWaypointsByBoundingBox:bb retObj:&d infoViewer:infoView ivi:iid callback:self];

    [infoView removeItem:iid];

    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the data" error:account.remoteAPI.lastError];
        return;
    }

    if ([infoView hasItems] == NO)
        [self hideInfoView];
}

@end
