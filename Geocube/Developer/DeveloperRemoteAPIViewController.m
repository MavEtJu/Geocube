/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the  warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DeveloperRemoteAPIViewController.h"

@interface DeveloperRemoteAPIViewController ()

@property (nonatomic, retain) NSArray<NSMutableDictionary *> *tests;
@property (nonatomic        ) NSInteger identifier;
@property (nonatomic, retain) NSOperationQueue *runqueue;

@end

@implementation DeveloperRemoteAPIViewController

typedef NS_ENUM(NSInteger, TestStatus) {
    TESTSTATUS_IDLE = 0,
    TESTSTATUS_RUNNING,
    TESTSTATUS_FINISHED,
};

typedef NS_ENUM(NSInteger, TestResult) {
    TESTRESULT_NA = 0,
    TESTRESULT_FAILED,
    TESTRESULT_SUCCESSFUL,
    TESTRESULT_NOTSUPPORTED,
};

- (instancetype)init
{
    self = [super init];

    [self makeInfoView];
    [self loadTests];

    return self;
}

- (void)loadTests
{
    NSMutableArray<NSMutableDictionary *> *tests = [NSMutableArray arrayWithCapacity:10];
    NSDictionary *d;

    if ([dbAccount dbGetByGeocubeID:ACCOUNT_LIVEAPI_GS] == nil)
        return;

    /* Groundspeak LiveaAPI */
    d = @{@"description": @"Cricket and Soccer 2",
          @"wpt_name": @"GC6N4RD",
          @"waypoints": @"GC6N4RD,GC5GNW7",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_LIVEAPI_GS],
          @"coordinates": [[Coordinates alloc] initWithDegrees:-34.04550 longitude:151.12010],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          @"travelbug": @"TB8NG8J,ARN7EA",
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* Geocaching.com website */
    d = @{@"description": @"Cricket and Soccer 2",
          @"wpt_name": @"GC6N4RD",
          @"waypoints": @"GC6N4RD,GC5GNW7",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_WEB_GCCOM],
          @"coordinates": [[Coordinates alloc] initWithDegrees:-34.04550 longitude:151.12010],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          @"travelbug": @"TB8NG8J,ARN7EA",
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* Geocaching Australia */
    d = @{@"description": @"GA Cacher APP test",
          @"wpt_name": @"GA4068",
          @"waypoints": @"GA4068,GA7968",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_GCA2_GCA],
          @"coordinates": [[Coordinates alloc] initWithDegrees:-29.3242 longitude:143.08183333333332],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          @"query": @"9115",
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCaching Benelux */
    d = @{@"description": @"Een testcache",
          @"wpt_name": @"OB1A60",
          @"waypoints": @"OB1A60,OB1A6E",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCNL],
          @"coordinates": [[Coordinates alloc] initWithDegrees:51.738116666667 longitude:5.95515],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCaching Deutschland */
    d = @{@"description": @"Quelle des Müggelsees",
          @"wpt_name": @"OC2CAA",
          @"waypoints": @"OC2CAA,OC10DB7",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCDE],
          @"coordinates": [[Coordinates alloc] initWithDegrees:52.42527 longitude:13.60113],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCaching Poland */
    d = @{@"description": @"Pałacyk Bieżuń",
          @"wpt_name": @"OP2A2F",
          @"waypoints": @"OP2A2F,OP81DM",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCPL],
          @"coordinates": [[Coordinates alloc] initWithDegrees:52.96652 longitude:19.88642],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCaching North America */
    d = @{@"description": @"Tri State Peak",
          @"wpt_name": @"OU0387",
          @"waypoints": @"OU0387,OU0A3B",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCNA],
          @"coordinates": [[Coordinates alloc] initWithDegrees:36.60077 longitude:-83.67533],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCaching Romenia */
    d = @{@"description": @"[LALEA5] Trivale 1-07",
          @"wpt_name": @"OR01B2",
          @"waypoints": @"OR01B2,OR01B1",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCRO],
          @"coordinates": [[Coordinates alloc] initWithDegrees:44.85508 longitude:24.85238],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    /* OpenCache UK */
    d = @{@"description": @"Whistler's Glen",
          @"wpt_name": @"OK041B",
          @"waypoints": @"OK041B,OK041C",
          @"account": [dbAccount dbGetByGeocubeID:ACCOUNT_OKAPI_OCUK],
          @"coordinates": [[Coordinates alloc] initWithDegrees:56.02365 longitude:4.78265],
          @"status": [NSNumber numberWithInteger:TESTSTATUS_IDLE],
          };
    [tests addObject:[NSMutableDictionary dictionaryWithDictionary:d]];

    self.tests = tests;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_DEVELOPERREMOTEAPITABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_DEVELOPERREMOTEAPITABLEVIEWCELL];

    self.runqueue = [[NSOperationQueue alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.tests count] == 0)
        [self loadTests];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.tests count] != 0)
        return [self.tests count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tests count] == 0) {
        GCTableViewCell *cell = [[GCTableViewCell alloc] initWithFrame:CGRectZero];
        cell.textLabel.text = @"No accounts found yet.";
        return cell;
    }

    DeveloperRemoteAPITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_DEVELOPERREMOTEAPITABLEVIEWCELL forIndexPath:indexPath];

    NSDictionary *test = [self.tests objectAtIndex:indexPath.row];
    dbAccount *a = [test objectForKey:@"account"];

    cell.labelTest.text = a.site;
    if ([[test objectForKey:@"status"] integerValue] == TESTSTATUS_IDLE)
        cell.labelStatus.text = @"Status: Idle";
    if ([[test objectForKey:@"status"] integerValue] == TESTSTATUS_RUNNING)
        cell.labelStatus.text = @"Status: Running";
    if ([[test objectForKey:@"status"] integerValue] == TESTSTATUS_FINISHED)
        cell.labelStatus.text = @"Status: Finished";

    if (a.canDoRemoteStuff == NO) {
        cell.labelStatus.text = @"Status: No remote API available";
        cell.userInteractionEnabled = NO;
        cell.labelTest.textColor = currentStyleTheme.labelTextColorDisabled;
    } else {
        cell.userInteractionEnabled = YES;
        cell.labelTest.textColor = currentStyleTheme.labelTextColor;
    }

#define LABEL(__field__, __name__) \
    if ([test objectForKey:__name__] == nil) { \
        cell.__field__.text = [NSString stringWithFormat:@"%@: n/a", __name__]; \
    } else { \
        NSString *s = nil; \
        UIColor *color = nil; \
        switch ([[test objectForKey:__name__] integerValue]) { \
        case TESTRESULT_NA: \
            s = @"n/a"; \
            color = currentStyleTheme.labelTextColor; \
            break; \
        case TESTRESULT_FAILED: \
            s = @"Failed"; \
            color = [UIColor redColor]; \
            break; \
        case TESTRESULT_SUCCESSFUL: \
            s = @"Successful"; \
            color = [UIColor greenColor]; \
            break; \
        case TESTRESULT_NOTSUPPORTED: \
            s = @"Not supported"; \
            color = currentStyleTheme.labelTextColorDisabled; \
            break; \
        } \
        cell.__field__.text = [NSString stringWithFormat:@"%@: %@", __name__, s]; \
        cell.__field__.textColor = color; \
    }

    LABEL(labelLoadWaypoint, @"loadWaypoint")
    LABEL(labelLoadWaypointsByCodes, @"loadWaypointsByCodes")
    LABEL(labelLoadWaypointsByBoundingBox, @"loadWaypointsByBoundingBox")
    LABEL(labelUserStatistics, @"userStatistics")
    LABEL(labelUpdatePersonalNote, @"updatePersonalNote")
    LABEL(labelListQueries, @"listQueries")
    LABEL(labelRetrieveQuery, @"retrieveQuery")
    LABEL(labelTrackablesMine, @"trackablesMine")
    LABEL(labelTrackablesInventory, @"trackablesInventory")
    LABEL(labelTrackableFind, @"trackableFind")
    LABEL(labelTrackableDrop, @"trackableDrop")
    LABEL(labelTrackableGrab, @"trackableGrab")
    LABEL(labelTrackableDiscover, @"trackableDiscover")

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSMutableDictionary *test = [self.tests objectAtIndex:indexPath.row];
    [test setObject:indexPath forKey:@"indexPath"];
    [self.runqueue addOperationWithBlock:^{
        [self tryTest:test];
    }];
}

- (void)tryTest:(NSMutableDictionary *)test
{
    [test removeObjectForKey:@"loadWaypoint"];
    [test removeObjectForKey:@"loadWaypointsByCodes"];
    [test removeObjectForKey:@"loadWaypointsByBoundingBox"];
    [test removeObjectForKey:@"listQueries"];
    [test removeObjectForKey:@"userStatistics"];
    [test removeObjectForKey:@"updatePersonalNote"];
    [test removeObjectForKey:@"listQueries"];
    [test removeObjectForKey:@"retrieveQuery"];
    [test removeObjectForKey:@"trackablesMine"];
    [test removeObjectForKey:@"trackablesInventory"];
    [test removeObjectForKey:@"trackableFind"];
    [test removeObjectForKey:@"trackableDrop"];
    [test removeObjectForKey:@"trackableGrab"];
    [test removeObjectForKey:@"trackableDiscover"];

    [test setObject:[NSNumber numberWithInteger:TESTSTATUS_RUNNING] forKey:@"status"];
    [self reloadDataMainQueue];

    dbAccount *a = [test objectForKey:@"account"];
    NSString *testname;

    // loadWaypoint
    testname = @"loadWaypoint";
    if (a.remoteAPI.supportsLoadWaypoint == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        dbWaypoint *wp = [[dbWaypoint alloc] init];
        wp.wpt_name = [test objectForKey:@"wpt_name"];
        wp.wpt_urlname = [test objectForKey:@"description"];
        wp.account = [test objectForKey:@"account"];

        [a.remoteAPI loadWaypoint:wp infoItem:nil identifier:identifier callback:self];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // loadWaypointByCodes
    testname = @"loadWaypointsByCodes";
    if (a.remoteAPI.supportsLoadWaypointsByCodes == YES &&
        [test objectForKey:@"waypoints"] != nil) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        NSArray<NSString *> *wps = [[test objectForKey:@"waypoints"] componentsSeparatedByString:@","];

        [a.remoteAPI loadWaypointsByCodes:wps infoItem:nil identifier:identifier group:dbc.groupLiveImport callback:self];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // loadWaypointByBoundingBox
    testname = @"loadWaypointsByBoundingBox";
    if (a.remoteAPI.supportsLoadWaypointsByBoundaryBox == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        GCBoundingBox *bb = [[GCBoundingBox alloc] init];
        Coordinates *c = [test objectForKey:@"coordinates"];
        bb.bottomLat = c.latitude - 0.001;
        bb.topLat = c.latitude + 0.001;
        bb.leftLon = c.longitude - 0.001;
        bb.rightLon = c.longitude + 0.001;

        [a.remoteAPI loadWaypointsByBoundingBox:bb infoItem:nil identifier:identifier callback:self];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // userStatistics
    testname = @"userStatistics";
    if (a.remoteAPI.supportsUserStatistics == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        NSDictionary *dict;

        RemoteAPIResult rv = [a.remoteAPI UserStatistics:&dict infoItem:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // listQueries
    testname = @"listQueries";
    NSArray<NSDictionary *> *queries = nil;
    if (a.remoteAPI.supportsListQueries == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        RemoteAPIResult rv = [a.remoteAPI listQueries:&queries infoItem:nil public:NO];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // retrieveQuery
    testname = @"retrieveQuery";
    if ([test objectForKey:@"query"] == nil &&
        [queries count] != 0) {
        [test setObject:[[queries objectAtIndex:0] objectForKey:@"Id"] forKey:@"query"];
    }
    if (a.remoteAPI.supportsListQueries == YES &&
        [test objectForKey:@"query"] != nil) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        RemoteAPIResult rv = [a.remoteAPI retrieveQuery:[test objectForKey:@"query"] group:dbc.groupLiveImport infoItem:nil identifier:identifier callback:self];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // trackablesMine
    testname = @"trackablesMine";
    if (a.remoteAPI.supportsTrackablesRetrieve == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        //

        RemoteAPIResult rv = [a.remoteAPI trackablesMine:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // trackablesInventory
    testname = @"trackablesInventory";
    if (a.remoteAPI.supportsTrackablesRetrieve == YES) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        //

        RemoteAPIResult rv = [a.remoteAPI trackablesInventory:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // trackableFind
    testname = @"trackableFind";
    if (a.remoteAPI.supportsTrackablesRetrieve == YES &&
        [test objectForKey:@"travelbug"] != nil) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        dbTrackable *tb;
        NSArray<NSString *> *data = [[test objectForKey:@"travelbug"] componentsSeparatedByString:@","];

        RemoteAPIResult rv = [a.remoteAPI trackableFind:[data objectAtIndex:1] trackable:&tb infoItem:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // trackableDiscover
    testname = @"trackableDiscover";
    if (a.remoteAPI.supportsTrackablesRetrieve == YES &&
        [test objectForKey:@"travelbug"] != nil) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        NSArray<NSString *> *data = [[test objectForKey:@"travelbug"] componentsSeparatedByString:@","];

        RemoteAPIResult rv = [a.remoteAPI trackableDiscover:[data objectAtIndex:1] infoItem:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    // trackableGrab
    testname = @"trackableGrab";
    if (a.remoteAPI.supportsTrackablesRetrieve == YES &&
        [test objectForKey:@"travelbug"] != nil) {
        NSInteger identifier = ++self.identifier;
        [test setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];
        [test setObject:testname forKey:@"testname"];
        [self reloadDataMainQueue];

        NSArray<NSString *> *data = [[test objectForKey:@"travelbug"] componentsSeparatedByString:@","];

        RemoteAPIResult rv = [a.remoteAPI trackableGrab:[data objectAtIndex:1] infoItem:nil];
        if (rv == REMOTEAPI_OK)
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
        else
            [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    } else {
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_NOTSUPPORTED] forKey:testname];
    }

    [test setObject:[NSNumber numberWithInteger:TESTSTATUS_FINISHED] forKey:@"status"];
    [self reloadDataMainQueue];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    NSLog(@"objectReadyToImport: %ld", (long)identifier);
    @synchronized(self.tests) {
        __block NSMutableDictionary *test;
        [self.tests enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[t objectForKey:@"identifier"] integerValue] == identifier) {
                test = t;
                *stop = YES;
            }
        }];
        NSString *testname = [test objectForKey:@"testname"];
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_SUCCESSFUL] forKey:testname];
    }

    [self reloadDataMainQueue];
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"failed: %ld", (long)identifier);
    @synchronized(self.tests) {
        __block NSMutableDictionary *test;
        [self.tests enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[t objectForKey:@"identifier"] integerValue] == identifier) {
                test = t;
                *stop = YES;
            }
        }];
        NSString *testname = [test objectForKey:@"testname"];
        [test setObject:[NSNumber numberWithInteger:TESTRESULT_FAILED] forKey:testname];
    }

    [self reloadDataMainQueue];
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"finishedDownloads: %ld", (long)identifier);
}

@end
