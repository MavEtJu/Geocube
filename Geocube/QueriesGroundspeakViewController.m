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

@interface QueriesGroundspeakViewController ()
{
    NSArray *pqs;
    dbAccount *account;
}

@end

@implementation QueriesGroundspeakViewController

enum {
    menuReload,
    menuMax
};

#define THISCELL @"QueriesGroundspeakTableCells"

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

    pqs = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (pqs == nil) {
        pqs = @[];
        [self performSelectorInBackground:@selector(reloadPQs) withObject:nil];
    }
}

- (void)reloadPQs
{
    pqs = nil;
    account = nil;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading Pocket Query List"];
    }];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol == ProtocolLiveAPI) {
            pqs = [a.remoteAPI listQueries];
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
    if (pqs == nil)
        return @"";
    NSInteger c = [pqs count];
    return [NSString stringWithFormat:@"%ld Available Pocket Quer%@", (unsigned long)c, c == 1 ? @"y" : @"ies"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [pqs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSDictionary *pq = [pqs objectAtIndex:indexPath.row];
    cell.textLabel.text = [pq objectForKey:@"Name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [MyTools niceFileSize:[[pq objectForKey:@"Size"] integerValue]]];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *pq = [pqs objectAtIndex:indexPath.row];
    [self performSelectorInBackground:@selector(runRetrieveQuery:) withObject:pq];
    return;
}

- (void)runRetrieveQuery:(NSDictionary *)pq
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:@"Loading Pocket Query\n0 / 0"];
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
        [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Loading Pocket Query\n%ld / %ld", offset, max];
    }];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self performSelectorInBackground:@selector(reloadPQs) withObject:nil];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}



@end
