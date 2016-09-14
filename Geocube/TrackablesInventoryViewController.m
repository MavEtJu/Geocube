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

@interface TrackablesInventoryViewController ()
{
    NSArray *tbs;
}

@end

@implementation TrackablesInventoryViewController

#define THISCELL @"TrackablesInventoryViewControllerCell"

enum {
      menuUpdate = 0,
      menuMax,
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    tbs = [dbTrackable dbAllInventory];
    [self makeInfoView];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUpdate label:@"Update"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
    return [tbs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbTrackable *tb = [tbs objectAtIndex:indexPath.row];

    NSString *text;
    if (tb.owner != nil)
        text = tb.owner_str;
    else
        text = tb.waypoint_name;

        cell.textLabel.text = tb.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", tb.ref, text];
    cell.userInteractionEnabled = NO;

    return cell;
}

#pragma mark - Local menu related functions

- (void)menuUpdate
{
    [self showInfoView];
    InfoItemDowload *iid = [infoView addDownload];
    [iid setDescription:@"Update trackables"];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.protocol == PROTOCOL_LIVEAPI) {
            // Get rid of any old data
            [tbs enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
                tb.carrier = nil;
                tb.carrier_id = 0;
                tb.carrier_str = @"";
                tb.waypoint_name = nil;
                [tb dbUpdate];
            }];

            [a.remoteAPI trackablesInventory:iid];
            tbs = [dbTrackable dbAllInventory];
            [self reloadDataMainQueue];
            *stop = YES; }
    }];

    [infoView removeItem:iid];
    [self hideInfoView];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuUpdate:
            [self performSelectorInBackground:@selector(menuUpdate) withObject:nil];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
