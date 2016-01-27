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

    if (pqs == nil)
        [self reloadPQs];
}

- (void)reloadPQs
{
    pqs = nil;

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol == ProtocolLiveAPI) {
            pqs = [a.remoteAPI listQueries];
            *stop = YES;
            return;
        }
    }];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (pqs == nil)
        return @"";
    NSInteger c = [pqs count];
    return [NSString stringWithFormat:@"%ld Pocket Quer%@", (unsigned long)c, c == 1 ? @"y" : @"ies"];
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self reloadPQs];
            [self.tableView reloadData];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}



@end
