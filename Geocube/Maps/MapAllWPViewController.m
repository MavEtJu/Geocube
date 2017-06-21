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
{
    NSMutableArray<dbWaypoint *> *oldWaypoints;
    NSMutableArray<NSString *> *newWaypoints;

    RemoteAPIProcessingGroup *processing;
    NSInteger currentRun;
}

@end

// The maximum size for the bounding box is from the Groundspeak LiveAPI where it is 100km max.
#define MAXSIZE 95000

@implementation MapAllWPViewController

enum {
    RUN_NONE = 0,
    RUN_BOUNDINGBOX,
    RUN_INDIVIDUAL,
};

- (instancetype)init
{
    self = [super init:NO];
    self.followWhom = SHOW_SHOWBOTH;

    processing = [[RemoteAPIProcessingGroup alloc] init];
    currentRun = RUN_NONE;

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

    currentRun = RUN_BOUNDINGBOX;

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

    NSLog(@"Boundingbox: %@ x %@", [Coordinates NiceCoordinates:bl], [Coordinates NiceCoordinates:tr]);

    oldWaypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllInRect:bl RT:tr]];
    newWaypoints = [NSMutableArray arrayWithCapacity:[oldWaypoints count]];

    [self showInfoView];
    [processing clearAll];

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoViewer:nil iiImport:0];

    NSArray<dbAccount *> *accounts = [dbc Accounts];
    __block NSInteger accountsFound = 0;
    [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account.remoteAPI supportsLoadWaypointsByBoundaryBox] == NO)
            return;
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

    [self performSelectorInBackground:@selector(waitForDownloadsToFinish) withObject:nil];
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    while ([processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    if (currentRun == RUN_BOUNDINGBOX) {
        // Now need to find all the waypoints which weren't found
        NSMutableArray<dbWaypoint *> *waypoints = [NSMutableArray arrayWithArray:oldWaypoints];
        [newWaypoints enumerateObjectsUsingBlock:^(NSString *wpn, NSUInteger nidx, BOOL *stop) {
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wpo, NSUInteger oidx, BOOL *stop) {
                if ([wpo.wpt_name isEqualToString:wpn] == YES) {
                    [waypoints removeObjectAtIndex:oidx];
                    *stop = YES;
                }
            }];
        }];

        // Clean up if there is nothing to see
        if ([waypoints count] == 0) {
            [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoViewer:nil iiImport:0];
            [waypointManager needsRefreshAll];
            currentRun = RUN_NONE;
            [self hideInfoView];
            return;
        };

        currentRun = RUN_INDIVIDUAL;

        // Deal with the waypoints by account
        NSArray<dbAccount *> *accounts = [dbc Accounts];
        [accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([account canDoRemoteStuff] == NO)
                return;

            NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:[waypoints count]];
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.account._id == account._id)
                    [wps addObject:wp];
            }];

            if ([wps count] == 0)
                return;

            InfoItemID iid = [infoView addDownload:YES];
            [infoView setDescription:iid description:account.site];
            NSMutableArray<NSString *> *wpnames = [NSMutableArray arrayWithCapacity:[wps count]];
            [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
                [wpnames addObject:wp.wpt_name];
            }];
            [processing addIdentifier:(long)account._id];
            [account.remoteAPI loadWaypointsByCodes:wpnames infoViewer:infoView iiDownload:iid identifier:(long)account._id group:dbc.Group_LiveImport callback:self];
        }];

        [self performSelectorInBackground:@selector(waitForDownloadsToFinish) withObject:nil];

        return;
    }

    if (currentRun == RUN_INDIVIDUAL) {
        [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoViewer:nil iiImport:0];
        [waypointManager needsRefreshAll];
        currentRun = RUN_NONE;
        [self hideInfoView];

        return;
    }
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier iiImport:(InfoItemID)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    // We are already in a background thread, but don't want to delay the next request until this one is processed.

    NSLog(@"PROCESSING: Downloaded %ld", (long)identifier);
    [processing increaseDownloadedChunks:identifier];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setObject:[NSNumber numberWithInteger:iii] forKey:@"iii"];
    [dict setObject:o forKey:@"object"];
    [dict setObject:dbc.Group_LiveImport forKey:@"group"];
    [dict setObject:account forKey:@"account"];
    [dict setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
    [self performSelectorInBackground:@selector(importObjectBG:) withObject:dict];
}

- (void)importObjectBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    dbAccount *a = [dict objectForKey:@"account"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItemID iii = [[dict objectForKey:@"iii"] integerValue];
    NSInteger identifier = [[dict objectForKey:@"identifier"] integerValue];

    NSArray<NSString *> *wps = [importManager process:o group:g account:a options:IMPORTOPTION_NOPOST|IMPORTOPTION_NOPRE infoViewer:infoView iiImport:iii];
    @synchronized (newWaypoints) {
        [newWaypoints addObjectsFromArray:wps];
    }

    NSLog(@"PROCESSING: Processed %ld", (long)identifier);
    [processing increaseProcessedChunks:identifier];
    [infoView removeItem:iii];

    if ([processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [processing removeIdentifier:identifier];
    }
}

- (void)runLoadWaypoints:(NSMutableDictionary *)dict
{
    InfoItemID iid = [[dict objectForKey:@"iid"] integerValue];
    GCBoundingBox *bb = [dict objectForKey:@"boundingbox"];
    dbAccount *account = [dict objectForKey:@"account"];

    [processing addIdentifier:(long)account._id];

    NSInteger rv = [account.remoteAPI loadWaypointsByBoundingBox:bb infoViewer:infoView iiDownload:iid identifier:(long)account._id callback:self];

    [infoView removeItem:iid];

    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the data" error:account.remoteAPI.lastError];
        return;
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"PROCESSING: Expecting %ld for %ld", (long)numberOfChunks, (long)identifier);
    [processing expectedChunks:identifier chunks:numberOfChunks];
    if ([processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", (long)identifier);
    [processing removeIdentifier:identifier];
}

@end
