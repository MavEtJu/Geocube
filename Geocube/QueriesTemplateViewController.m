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
    NSArray *qs;
    NSArray *qis;
}

@end

@implementation QueriesTemplateViewController

enum {
    menuReload,
    menuMax
};

#define THISCELL @"QueriesTableViewCells"

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuReload label:@"Reload"];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:@"QueriesTableViewCell" bundle:nil] forCellReuseIdentifier:THISCELL];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;

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

NEEDS_OVERLOADING(reloadQueries)

- (void)reloadQueries:(NSInteger)protocol
{
    account = nil;

    __block BOOL failure = NO;
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol_id == protocol) {
            account = a;
            if (a.canDoRemoteStuff == YES) {
                NSArray *queries = nil;
                RemoteAPIResult rv = [a.remoteAPI listQueries:&queries infoViewer:nil ivi:0];
                if (rv != REMOTEAPI_OK)
                    failure = YES;
                qs = queries;
            } else {
                failure = YES;
            }
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
    return [qs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueriesTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    NSString *name = [pq objectForKey:@"Name"];
    cell.labelQueryname.text = name;

    NSInteger size = 0;
    cell.labelWaypoints.text = @"";
    if ([pq objectForKey:@"Count"] != nil) {
        NSInteger count = [[pq objectForKey:@"Count" ] integerValue];
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
        if (qi.account_id == account._id &&
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

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    [self performSelectorInBackground:@selector(doRunRetrieveQuery:) withObject:pq];

    // Update historical data for this query.
    __block dbQueryImport *foundqi = nil;
    [qis enumerateObjectsUsingBlock:^(dbQueryImport *qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account_id == account._id &&
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
        qi.account_id = account._id;
        qi.lastimport = time(NULL);
        [dbQueryImport dbCreate:qi];
    } else {
        foundqi.lastimport = time(NULL);
        [foundqi dbUpdate];
    }
    qis = [dbQueryImport dbAll];

    return;
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
        NSId _id = [dbGroup dbCreate:name isUser:YES];
        group = [dbGroup dbGet:_id];
        [dbc Group_add:group];
    }

    return group;
}

- (void)doRunRetrieveQuery:(NSDictionary *)pq
{
    dbGroup *group = [self makeGroupExist:[pq objectForKey:@"Name"]];
    BOOL failure = [self runRetrieveQuery:pq group:group];

    if (failure == YES)
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.remoteAPI.lastError];

    [self reloadDataMainQueue];
}

NEEDS_OVERLOADING_BOOL(runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group)
NEEDS_OVERLOADING(remoteAPI_objectReadyToImport:(InfoViewer *)iv ivi:(InfoItemID)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account)
NEEDS_OVERLOADING(remoteAPI_finishedDownloads:(InfoViewer *)iv numberOfChunks:(NSInteger)numberOfChunks)

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
