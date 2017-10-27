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

@interface QueriesTemplateViewController ()

@property (nonatomic, retain) NSArray<NSDictionary *> *qs;
@property (nonatomic, retain) NSArray<dbQueryImport *> *qis;

@property (nonatomic, retain) RemoteAPIProcessingGroup *processing;

@end

@implementation QueriesTemplateViewController

enum {
    menuReload,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuReload label:_(@"queriestemplateviewcontroller-Reload")];

    self.processing = [[RemoteAPIProcessingGroup alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_QUERIESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_QUERIESTABLEVIEWCELL];

    [self makeInfoView2];

    self.qs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.qs == nil) {
        self.qs = @[];
        BACKGROUND(reloadQueries, nil);
    }
    self.qis = [dbQueryImport dbAll];
}

- NEEDS_OVERLOADING_VOID(reloadQueries)

- (void)reloadQueries:(NSInteger)protocol
{
    self.account = nil;

    __block BOOL failure = NO;
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol._id == protocol && a.remoteAPI.supportsListQueries == YES) {
            self.account = a;
            if (a.canDoRemoteStuff == NO) {
                *stop = YES;
                return;
            }

            NSArray<NSDictionary *> *queries = nil;
            RemoteAPIResult rv = [a.remoteAPI listQueries:&queries infoItem:nil public:self.isPublic];
            if (rv != REMOTEAPI_OK)
                failure = YES;
            self.qs = queries;
            *stop = YES;
        }
    }];

    if (failure == YES)
        [MyTools messageBox:self header:self.account.site text:_(@"queriesemplateviewcontroller-Unable to retrieve the list of queries") error:self.account.remoteAPI.lastError];

    [self reloadDataMainQueue];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Alert if this option isn't available.
    if (self.account.canDoRemoteStuff == NO)
        return _(@"queriestemplateviewcontroller-This account cannot be polled right now.");

    if (self.qs == nil)
        return @"";
    NSInteger c = [self.qs count];
    return [NSString stringWithFormat:_(@"queriestemplateviewcontroller-%ld available %@"), (unsigned long)c, c == 1 ? self.queryString : self.queriesString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (self.account.canDoRemoteStuff == NO)
        return 0;
    return [self.qs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueriesTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_QUERIESTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *pq = [self.qs objectAtIndex:indexPath.row];
    NSString *name = [pq objectForKey:@"Name"];
    cell.labelQueryname.text = name;

    NSInteger size = 0;
    cell.labelWaypoints.text = @"";
    if ([pq objectForKey:@"Count"] != nil) {
        NSInteger count = [[pq objectForKey:@"Count"] integerValue];
        size = count;
        if (count >= 0)
            cell.labelWaypoints.text = [NSString stringWithFormat:@"%@ %@", [MyTools niceNumber:count], count == 1 ? _(@"waypoint") : _(@"waypoints")];
    }
    cell.labelSize.text = @"";
    if ([pq objectForKey:@"Size"] != nil) {
        size = [[pq objectForKey:@"Size"] integerValue];
        cell.labelSize.text = [NSString stringWithFormat:_(@"queriestemplateviewcontroller-Download size: %@"), [MyTools niceFileSize:size]];
    }
    cell.labelDateTime.text = @"";
    if ([pq objectForKey:@"DateTime"] != nil) {
        NSString *date = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:[[pq objectForKey:@"DateTime"] integerValue]];
        cell.labelDateTime.text = [NSString stringWithFormat:_(@"queriestemplateviewcontroller-Date created: %@"), date];
    }

    cell.labelLastImport.text = @"";
    [self.qis enumerateObjectsUsingBlock:^(dbQueryImport * _Nonnull qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account._id == self.account._id &&
            [qi.name isEqualToString:name] == YES &&
            qi.filesize == size) {
            cell.labelLastImport.text = [NSString stringWithFormat:_(@"queriestemplateviewcontroller-Last import: %@"), [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:qi.lastimport]];
            *stop = YES;
        }
    }];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (configManager.downloadQueriesMobile == NO && [MyTools hasWifiNetwork] == NO) {
        [MyTools messageBox:self header:_(@"queriestemplateviewcontroller-Failure") text:[NSString stringWithFormat:_(@"queriestemplateviewcontroller-Your settings don't allow download of %@ if Wi-Fi is not available"), self.queriesString]];
        return;
    }

    [self.processing clearAll];
    [self showInfoView2];

    NSDictionary *pq = [self.qs objectAtIndex:indexPath.row];
    BACKGROUND(doRunRetrieveQuery:, pq);
    BACKGROUND(waitForDownloadsToFinish, nil);

    // Update historical data for this query.
    __block dbQueryImport *foundqi = nil;
    [self.qis enumerateObjectsUsingBlock:^(dbQueryImport * _Nonnull qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account._id == self.account._id &&
            [qi.name isEqualToString:[pq objectForKey:@"Name"]] == YES &&
            qi.filesize == [[pq objectForKey:@"Size"] integerValue]) {
            foundqi = qi;
            *stop = YES;
        }
    }];

    if (foundqi == nil) {
        dbQueryImport *qi = [[dbQueryImport alloc] init];
        qi.filesize = [[pq objectForKey:@"Size"] integerValue];
        qi.name = [pq objectForKey:@"Name"];
        qi.account = self.account;
        qi.lastimport = time(NULL);
        [qi dbCreate];
    } else {
        foundqi.lastimport = time(NULL);
        [foundqi dbUpdate];
    }
    self.qis = [dbQueryImport dbAll];
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    while ([self.processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoItem:nil];

    [self reloadDataMainQueue];
    [audioManager playSound:PLAYSOUND_IMPORTCOMPLETE];
    [waypointManager needsRefreshAll];

    [self hideInfoView2];
}

- (dbGroup *)makeGroupExist:(NSString *)name
{
    // Find the group to import to
    __block dbGroup *group = nil;
    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([g.name isEqualToString:name] == YES) {
            group = g;
            *stop = YES;
        }
    }];
    if (group == nil) {
        group = [[dbGroup alloc] init];
        group.name = name;
        group.usergroup = YES;
        group.deletable = YES;
        [group dbCreate];
        [dbc groupAdd:group];
    }

    return group;
}

- (void)doRunRetrieveQuery:(NSDictionary *)pq
{
    [self.processing addIdentifier:0];
    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoItem:nil];

    dbGroup *group = [self makeGroupExist:[pq objectForKey:@"Name"]];

    InfoItem2 *iid = [self.infoView2 addDownload];
    [iid changeDescription:[pq objectForKey:@"Name"]];

    [self.processing addIdentifier:0];
    RemoteAPIResult rv = [self.account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group infoItem:iid identifier:0 callback:self];
    if (rv != REMOTEAPI_OK)
        [MyTools messageBox:self header:_(@"Error") text:_(@"queriestemplateviewcontroller-Unable to retrieve the data from the query") error:self.account.remoteAPI.lastError];

    [self.infoView2 removeDownload:iid];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem2 *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)a
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    [d setObject:group forKey:@"group"];
    [d setObject:o forKey:@"object"];
    [d setObject:iii forKey:@"infoItem"];
    [d setObject:a forKey:@"account"];
    [d setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];

    NSLog(@"PROCESSING: Downloaded %ld", (long)identifier);
    [self.processing increaseDownloadedChunks:identifier];
    BACKGROUND(parseQueryBG:, d);
}

- (void)parseQueryBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItem2 *iii = [dict objectForKey:@"infoItem"];
    dbAccount *a = [dict objectForKey:@"account"];
    NSInteger identifier = [[dict objectForKey:@"identifier"] integerValue];

    [importManager process:o group:g account:a options:IMPORTOPTION_NOPRE|IMPORTOPTION_NOPOST infoItem:iii];
    [self.infoView2 removeImport:iii];

    NSLog(@"PROCESSING: Processed %ld", (long)identifier);
    [self.processing increaseProcessedChunks:identifier];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"PROCESSING: Expecting %ld for %ld", (long)numberOfChunks, (long)identifier);
    [self.processing expectedChunks:identifier chunks:numberOfChunks];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}
- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", (long)identifier);
    [self.processing removeIdentifier:identifier];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuReload:
            BACKGROUND(reloadQueries, nil);
            return;
    }

    [super performLocalMenuAction:index];
}

@end
