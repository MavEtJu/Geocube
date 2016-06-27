/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface QueriesTemplateViewController ()
{
    NSArray *qs;
    NSArray *qis;
}

@end

@implementation QueriesTemplateViewController

@synthesize queriesString, queryString, account;

enum {
    menuReload,
    menuMax
};

#define THISCELL @"QueriesTableCells"

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
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

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
NEEDS_OVERLOADING_BOOL(parseRetrievedQuery:(NSObject *)query group:(dbGroup *)group)

- (void)reloadQueries:(NSInteger)protocol
{
    qs = nil;
    account = nil;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading %@ List", queryString]];
    }];

    __block BOOL failure = NO;
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol == protocol) {
            account = a;
            if (a.canDoRemoteStuff == YES) {
                [a.remoteAPI listQueries:qs];
                if (qs == nil)
                    failure = YES;
            } else {
                failure = YES;
                if (account.lastError == nil)
                    account.lastError = @"Account is currently not active";
            }
            *stop = YES;
        }
    }];

    if (failure == YES)
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the list of queries" error:account.lastError];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
        [self.tableView reloadData];
    }];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (qs == nil)
        return @"";
    NSInteger c = [qs count];
    return [NSString stringWithFormat:@"%ld Available %@", (unsigned long)c, c == 1 ? queryString : queriesString];
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
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    NSString *name = [pq objectForKey:@"Name"];
    cell.textLabel.text = name;

    NSInteger size = 0;
    NSMutableString *detail = [NSMutableString stringWithString:@""];
    if ([pq objectForKey:@"Count"] != nil) {
        NSInteger count = [[pq objectForKey:@"Count" ] integerValue];
        if ([detail isEqualToString:@""] == NO)
            [detail appendString:@" - "];
        size = count;
        if (count >= 0)
            [detail appendFormat:@"%@ waypoint%@", [MyTools niceNumber:count], count == 1 ? @"" : @"s"];
    }
    if ([pq objectForKey:@"Size"] != nil) {
        if ([detail isEqualToString:@""] == NO)
            [detail appendString:@" - "];
        size = [[pq objectForKey:@"Size"] integerValue];
        [detail appendString:[MyTools niceFileSize:size]];
    }
    if ([pq objectForKey:@"DateTime"] != nil) {
        if ([detail isEqualToString:@""] == NO)
            [detail appendString:@" - "];
        NSString *date = [MyTools dateTimeString:[[pq objectForKey:@"DateTime"] integerValue]];
        [detail appendString:date];
    }

    [qis enumerateObjectsUsingBlock:^(dbQueryImport *qi, NSUInteger idx, BOOL * _Nonnull stop) {
        if (qi.account_id == account._id &&
            [qi.name isEqualToString:name] == YES &&
            qi.filesize == size) {
            if ([detail isEqualToString:@""] == NO)
                [detail appendString:@" - "];
            [detail appendFormat:@"Last import on %@", [MyTools dateTimeString:qi.lastimport]];
            *stop = YES;
        }
    }];

    cell.detailTextLabel.text = detail;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (myConfig.downloadQueriesMobile == NO && [MyTools hasWifiNetwork] == NO) {
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
        [dbc loadWaypointData];
        group = [dbGroup dbGet:_id];
    }

    return group;
}

- (void)doRunRetrieveQuery:(NSDictionary *)pq
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading %@\n0 / 0", queryString]];
    }];

    dbGroup *group = [self makeGroupExist:[pq objectForKey:@"Name"]];
    BOOL failure = [self runRetrieveQuery:pq group:group];

    if (failure == YES)
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.lastError];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
        [self.tableView reloadData];
    }];
}

- (bool)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    __block BOOL failure = NO;
    account.remoteAPI.delegateQueries = self;

    // Download the query
    NSObject *ret;
    [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group retObj:ret];
    if (ret == nil) {
        failure = YES;
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.lastError];
    } else
        [self parseRetrievedQuery:ret group:group];

    return failure;
}

- (void)remoteAPIQueriesDownloadUpdate:(NSInteger)offset max:(NSInteger)max
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Loading %@\n%ld / %ld", queryString, (long)offset, (long)max];
    }];
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
