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
    dbAccount *account;
}

@end

@implementation QueriesTemplateViewController

@synthesize queriesString, queryString;

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

- (void)viewDidLoad {
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
}

NEEDS_OVERLOADING(reloadQueries)

- (void)reloadQueries:(NSInteger)protocol
{
    qs = nil;
    account = nil;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading %@ List", queryString]];
    }];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol == protocol && a.canDoRemoteStuff == YES) {
            qs = [a.remoteAPI listQueries];
            account = a;
            *stop = YES;
        }
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
    }];
    [self.tableView reloadData];
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
    if (cell == nil) {
        cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    cell.textLabel.text = [pq objectForKey:@"Name"];
    if ([pq objectForKey:@"Count"] != nil) {
        NSInteger count = [[pq objectForKey:@"Count" ] integerValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ waypoint%@", [MyTools niceNumber:count], count == 1 ? @"" : @"s"];
    }
    if ([pq objectForKey:@"Size"] != nil) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceFileSize:[[pq objectForKey:@"Size"] integerValue]]];
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pq = [qs objectAtIndex:indexPath.row];
    [self performSelectorInBackground:@selector(runRetrieveQuery:) withObject:pq];
    return;
}

- (void)runRetrieveQuery:(NSDictionary *)pq
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading %@\n0 / 0", queryString]];
    }];

    __block dbGroup *group = nil;
    NSString *name = [pq objectForKey:@"Name"];
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

    account.remoteAPI.delegateQueries = self;
    [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
    }];
    [self.tableView reloadData];
    [MyTools playSound:playSoundImportComplete];
}

- (void)remoteAPIQueriesDownloadUpdate:(NSInteger)offset max:(NSInteger)max
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Loading %@\n%ld / %ld", queryString, offset, max];
    }];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self performSelectorInBackground:@selector(reloadQueries) withObject:nil];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end
