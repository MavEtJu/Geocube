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
{
    NSArray<NSDictionary *> *qs;
    NSArray<dbQueryImport *> *qis;

    RemoteAPIProcessingGroup *processing;
}

@end

@implementation QueriesTemplateViewController

enum {
    menuReload,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuReload label:@"Reload"];

    processing = [[RemoteAPIProcessingGroup alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_QUERIESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_QUERIESTABLEVIEWCELL];

    [self makeInfoView];

    qs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (qs == nil) {
        qs = @[];
        [self performSelectorInBackground:@selector(reloadQueries) withObject:nil];
    }
    qis = [dbQueryImport dbAll];
}

- NEEDS_OVERLOADING_VOID(reloadQueries)

- (void)reloadQueries:(NSInteger)protocol
{
    account = nil;

    __block BOOL failure = NO;
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol._id == protocol && a.remoteAPI.supportsListQueries == YES) {
            account = a;
            if (a.canDoRemoteStuff == NO) {
                *stop = YES;
                return;
            }

            NSArray<NSDictionary *> *queries = nil;
            RemoteAPIResult rv = [a.remoteAPI listQueries:&queries infoViewer:nil iiDownload:0];
            if (rv != REMOTEAPI_OK)
                failure = YES;
            qs = queries;
            *stop = YES;
        }
    }];

    if (failure == YES)
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the list of queries" error:account.remoteAPI.lastError];

    [self reloadDataMainQueue];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Alert if this option isn't available.
    if (account.canDoRemoteStuff == NO)
        return @"This account cannot be polled right now.";

    if (qs == nil)
        return @"";
    NSInteger c = [qs count];
    return [NSString stringWithFormat:@"%ld Available %@", (unsigned long)c, c == 1 ? self.queryString : self.queriesString];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (account.canDoRemoteStuff == NO)
        return 0;
    return [qs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueriesTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_QUERIESTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    NSString *name = [pq objectForKey:@"Name"];
    cell.labelQueryname.text = name;

    NSInteger size = 0;
    cell.labelWaypoints.text = @"";
    if ([pq objectForKey:@"Count"] != nil) {
        NSInteger count = [[pq objectForKey:@"Count"] integerValue];
        size = count;
        if (count >= 0)
            cell.labelWaypoints.text = [NSString stringWithFormat:@"%@ waypoint%@", [MyTools niceNumber:count], count == 1 ? @"" : @"s"];
    }
    cell.labelSize.text = @"";
    if ([pq objectForKey:@"Size"] != nil) {
        size = [[pq objectForKey:@"Size"] integerValue];
        cell.labelSize.text = [NSString stringWithFormat:@"Download size: %@", [MyTools niceFileSize:size]];
    }
    cell.labelDateTime.text = @"";
    if ([pq objectForKey:@"DateTime"] != nil) {
        NSString *date = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:[[pq objectForKey:@"DateTime"] integerValue]];
        cell.labelDateTime.text = [NSString stringWithFormat:@"Date created: %@", date];
    }

    cell.labelLastImport.text = @"";
    [qis enumerateObjectsUsingBlock:^(dbQueryImport *qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account._id == account._id &&
            [qi.name isEqualToString:name] == YES &&
            qi.filesize == size) {
            cell.labelLastImport.text = [NSString stringWithFormat:@"Last import: %@", [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:qi.lastimport]];
            *stop = YES;
        }
    }];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (configManager.downloadQueriesMobile == NO && [MyTools hasWifiNetwork] == NO) {
        [MyTools messageBox:self header:@"Failure" text:[NSString stringWithFormat:@"Your settings don't allow download of %@ if Wi-Fi is not available", self.queriesString]];
        return;
    }

    [processing clearAll];
    [self showInfoView];

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    [self performSelectorInBackground:@selector(doRunRetrieveQuery:) withObject:pq];
    [self performSelectorInBackground:@selector(waitForDownloadsToFinish) withObject:nil];

    // Update historical data for this query.
    __block dbQueryImport *foundqi = nil;
    [qis enumerateObjectsUsingBlock:^(dbQueryImport *qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account._id == account._id &&
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
        qi.account = account;
        qi.lastimport = time(NULL);
        [dbQueryImport dbCreate:qi];
    } else {
        foundqi.lastimport = time(NULL);
        [foundqi dbUpdate];
    }
    qis = [dbQueryImport dbAll];
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    while ([processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoViewer:nil iiImport:0];

    [self reloadDataMainQueue];
    [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];
    [waypointManager needsRefreshAll];

    [self hideInfoView];
}

- (dbGroup *)makeGroupExist:(NSString *)name
{
    // Find the group to import to
    __block dbGroup *group = nil;
    [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *g, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [dbc Group_add:group];
    }

    return group;
}

- (void)doRunRetrieveQuery:(NSDictionary *)pq
{
    [processing addIdentifier:0];
    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoViewer:nil iiImport:0];

    dbGroup *group = [self makeGroupExist:[pq objectForKey:@"Name"]];

    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:[pq objectForKey:@"Name"]];

    [processing addIdentifier:0];
    RemoteAPIResult rv = [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group infoViewer:infoView iiDownload:iid identifier:0 callback:self];
    if (rv != REMOTEAPI_OK)
        [MyTools messageBox:self header:@"Error" text:@"Unable to retrieve the data from the query" error:account.remoteAPI.lastError];

    [infoView removeItem:iid];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier iiImport:(InfoItemID)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)a
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    [d setObject:group forKey:@"group"];
    [d setObject:o forKey:@"object"];
    [d setObject:[NSNumber numberWithInteger:iii] forKey:@"iii"];
    [d setObject:a forKey:@"account"];
    [d setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];

    NSLog(@"PROCESSING: Downloaded %ld", (long)identifier);
    [processing increaseDownloadedChunks:identifier];
    [self performSelectorInBackground:@selector(parseQueryBG:) withObject:d];
}

- (void)parseQueryBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItemID iii = [[dict objectForKey:@"iii"] integerValue];
    dbAccount *a = [dict objectForKey:@"account"];
    NSInteger identifier = [[dict objectForKey:@"identifier"] integerValue];

    [importManager process:o group:g account:a options:IMPORTOPTION_NOPRE|IMPORTOPTION_NOPOST infoViewer:infoView iiImport:iii];
    [infoView removeItem:iii];

    NSLog(@"PROCESSING: Processed %ld", (long)identifier);
    [processing increaseProcessedChunks:identifier];
    if ([processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [processing removeIdentifier:identifier];
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

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self performSelectorInBackground:@selector(reloadQueries) withObject:nil];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
