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

@interface BrowserAccountsViewController ()
{
    NSMutableArray *accounts;
}

@end

@implementation BrowserAccountsViewController

#define THISCELL    @"BookmarksAccountsTableViewCell"

- (instancetype)init
{
    self = [super init];

    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    accounts = [NSMutableArray arrayWithCapacity:20];
    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        if (a.accountname_string != nil && [a.accountname_string isEqualToString:@""] == NO)
            [accounts addObject:a];
    }];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [accounts count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbAccount *a = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = a.site;

    cell.userInteractionEnabled = YES;
    if (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES) {
        cell.userInteractionEnabled = NO;
        cell.textLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.detailTextLabel.text = a.accountname_string;
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbAccount *a = [accounts objectAtIndex:indexPath.row];

    BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
    UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
    BrowserBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];

    [btc makeTabViewCurrent:VC_BROWSER_BROWSER];
    [bbvc loadURL:a.url_queries];
}


@end
