/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017 Edwin Groothuis
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

@property (nonatomic, retain) NSMutableArray<dbWaypoint *> *waypointsOld;
@property (nonatomic, retain) NSMutableArray<NSString *> *waypointsNew;

@property (nonatomic, retain) RemoteAPIProcessingGroup *processing;
@property (nonatomic        ) NSInteger currentRun;

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

    self.processing = [[RemoteAPIProcessingGroup alloc] init];
    self.currentRun = RUN_NONE;

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
    [bezelManager setText:_(@"mapallwpviewcontroller-Refreshing database")];

    [waypointManager applyFilters:LM.coords];

    self.waypointsArray = [waypointManager currentWaypoints];

    MAINQUEUE(
        [self.map removeMarkers];
        [self.map placeMarkers];
    )

    [bezelManager removeBezel];
}

- (void)menuLoadWaypoints
{
    CLLocationCoordinate2D bl, tr;

    self.currentRun = RUN_BOUNDINGBOX;

    [self.map currentRectangle:&bl topRight:&tr];
    NSInteger dist = [Coordinates coordinates2distance:bl to:tr];
    if ([Coordinates coordinates2distance:bl to:tr] > MAXSIZE) {
        [MyTools messageBox:self header:_(@"mapallwpviewcontroller-Adjustment") text:[NSString stringWithFormat:_(@"mapallwpviewcontroller-The distance to the top right of the map and the bottom left of the map has been reduced from %@ to a maximum of %@"), [MyTools niceDistance:dist], [MyTools niceDistance:MAXSIZE]]];
        do {
            CLLocationCoordinate2D tbl = bl;
            CLLocationCoordinate2D ttr = tr;
            // Adjust at 5% per side for every iteration
            bl.longitude = (tbl.longitude * 19 + ttr.longitude) / 20;
            bl.latitude = (tbl.latitude * 19 + ttr.latitude) / 20;
            tr.longitude = (tbl.longitude + ttr.longitude * 19) / 20;
            tr.latitude = (tbl.latitude + ttr.latitude * 19) / 20;
        } while ([Coordinates coordinates2distance:bl to:tr] > MAXSIZE);
    }

    GCBoundingBox *bb = [[GCBoundingBox alloc] init];
    bb.leftLon = bl.longitude;
    bb.rightLon = tr.longitude;
    bb.topLat = tr.latitude;
    bb.bottomLat = bl.latitude;

    NSLog(@"Boundingbox: %@ x %@", [Coordinates niceCoordinates:bl], [Coordinates niceCoordinates:tr]);

    self.waypointsOld = [NSMutableArray arrayWithArray:[dbWaypoint dbAllInRect:bl RT:tr]];
    self.waypointsNew = [NSMutableArray arrayWithCapacity:[self.waypointsOld count]];

    [self showInfoView];
    [self.processing clearAll];

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoItem:nil];

    NSArray<dbAccount *> *accounts = dbc.accounts;
    __block NSInteger accountsFound = 0;
    [accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([account.remoteAPI supportsLoadWaypointsByBoundaryBox] == NO)
            return;
        if ([account canDoRemoteStuff] == NO)
            return;
        accountsFound++;

        InfoItem *iid = [self.infoView addDownload];
        [iid changeDescription:account.site];

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
        [d setObject:bb forKey:@"boundingbox"];
        [d setObject:iid forKey:@"iid"];
        [d setObject:account forKey:@"account"];

        BACKGROUND(runLoadWaypoints:, d);
    }];

    if (accountsFound == 0) {
        [MyTools messageBox:self header:_(@"mapallwpviewcontroller-Nothing imported") text:_(@"mapallwpviewcontroller-No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account.")];
        return;
    }

    BACKGROUND(waitForDownloadsToFinish, nil);
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    while ([self.processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    if (self.currentRun == RUN_BOUNDINGBOX) {
        // Now need to find all the waypoints which weren't found
        NSMutableArray<dbWaypoint *> *waypoints = [NSMutableArray arrayWithArray:self.waypointsOld];
        [self.waypointsNew enumerateObjectsUsingBlock:^(NSString * _Nonnull wpn, NSUInteger nidx, BOOL * _Nonnull stop) {
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wpo, NSUInteger oidx, BOOL * _Nonnull stop) {
                if ([wpo.wpt_name isEqualToString:wpn] == YES) {
                    [waypoints removeObjectAtIndex:oidx];
                    *stop = YES;
                }
            }];
        }];

        // Clean up if there is nothing to see
        if ([waypoints count] == 0) {
            [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoItem:nil];
            [waypointManager needsRefreshAll];
            self.currentRun = RUN_NONE;
            [self hideInfoView];
            return;
        };

        self.currentRun = RUN_INDIVIDUAL;
        NSLog(@"Picking up the leftovers");
        [self.processing clearAll];

        // Deal with the waypoints by account
        NSArray<dbAccount *> *accounts = dbc.accounts;
        [accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([account canDoRemoteStuff] == NO)
                return;

            NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:[waypoints count]];
            [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                if (wp.account._id == account._id)
                    [wps addObject:wp];
            }];

            if ([wps count] == 0)
                return;

            InfoItem *iid = [self.infoView addDownload];
            [iid changeDescription:account.site];
            NSMutableArray<NSString *> *wpnames = [NSMutableArray arrayWithCapacity:[wps count]];
            [wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                [wpnames addObject:wp.wpt_name];
            }];
            [self.processing addIdentifier:(long)account._id];
            [account.remoteAPI loadWaypointsByCodes:wpnames infoItem:iid identifier:(long)account._id group:dbc.groupLiveImport callback:self];
        }];

        BACKGROUND(waitForDownloadsToFinish, nil);

        return;
    }

    if (self.currentRun == RUN_INDIVIDUAL) {
        [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoItem:nil];
        [waypointManager needsRefreshAll];
        self.currentRun = RUN_NONE;
        [self hideInfoView];

        return;
    }
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    // We are already in a background thread, but don't want to delay the next request until this one is processed.

    [self.processing increaseDownloadedChunks:identifier];
    NSLog(@"PROCESSING: Downloaded #%ld - %@", (long)identifier, [self.processing description:identifier]);

    if (o == nil)
        o = [NSNull null];

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    [dict setObject:iii forKey:@"iii"];
    [dict setObject:o forKey:@"object"];
    [dict setObject:dbc.groupLiveImport forKey:@"group"];
    [dict setObject:account forKey:@"account"];
    [dict setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
    BACKGROUND(importObjectBG:, dict);
}

- (void)importObjectBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    dbAccount *a = [dict objectForKey:@"account"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItem *iii = [dict objectForKey:@"iii"];
    NSInteger identifier = [[dict objectForKey:@"identifier"] integerValue];

    if ([o isKindOfClass:[NSNull class]] == NO) {
        NSArray<NSString *> *wps = [importManager process:o group:g account:a options:IMPORTOPTION_NOPOST|IMPORTOPTION_NOPRE infoItem:iii];
        @synchronized(self.waypointsNew) {
            [self.waypointsNew addObjectsFromArray:wps];
        }
    }

    [self.processing increaseProcessedChunks:identifier];
    NSLog(@"PROCESSING: Processed #%ld - %@", (long)identifier, [self.processing description:identifier]);
    [iii removeFromInfoViewer];

    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for #%ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)runLoadWaypoints:(NSMutableDictionary *)dict
{
    InfoItem *iid = [dict objectForKey:@"iid"];
    GCBoundingBox *bb = [dict objectForKey:@"boundingbox"];
    dbAccount *account = [dict objectForKey:@"account"];

    [self.processing addIdentifier:(long)account._id];

    NSInteger rv = [account.remoteAPI loadWaypointsByBoundingBox:bb infoItem:iid identifier:(long)account._id callback:self];

    [iid removeFromInfoViewer];

    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:account.site text:_(@"mapallwpviewcontroller-Unable to retrieve the data") error:account.remoteAPI.lastError];
        return;
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    [self.processing expectedChunks:identifier chunks:numberOfChunks];
    NSLog(@"PROCESSING: Expecting %ld for #%ld - %@", (long)numberOfChunks, (long)identifier, [self.processing description:identifier]);
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for #%ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", (long)identifier);
    [self.processing removeIdentifier:identifier];
}

@end
