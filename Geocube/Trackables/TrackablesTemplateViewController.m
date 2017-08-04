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

@interface TrackablesTemplateViewController ()

@end

@implementation TrackablesTemplateViewController

enum {
    menuUpdate = 0,
    menuMax,
};

- NEEDS_OVERLOADING_VOID(remoteAPILoadTrackables:(dbAccount *)a infoView:(InfoViewer *)iv infoItemID:(InfoItemID)iid)
- NEEDS_OVERLOADING_VOID(loadTrackables)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_TRACKABLETABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_TRACKABLETABLEVIEWCELL];

    [self loadTrackables];

    [self makeInfoView];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUpdate label:NSLocalizedString(@"trackablestemplateviewcontroller-update", nil)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tbs count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_TRACKABLETABLEVIEWCELL forIndexPath:indexPath];

    dbTrackable *tb = [self.tbs objectAtIndex:indexPath.row];

    cell.name.text = nil;
    cell.code.text = nil;
    cell.carrier.text = nil;
    cell.waypoint.text = nil;
    cell.owner.text = nil;

    cell.name.text = tb.name;
    if (!IS_EMPTY(tb.ref) && !IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:@"Code: %@ / %@", tb.ref, tb.code];
    if ( IS_EMPTY(tb.ref) && !IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:@"Code: %@", tb.code];
    if (!IS_EMPTY(tb.ref) &&  IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:@"Code: %@", tb.ref];
    if (tb.carrier != nil)
        cell.carrier.text = [NSString stringWithFormat:@"Carried by %@", tb.carrier.name];
    if (!IS_EMPTY(tb.waypoint_name))
        cell.waypoint.text = [NSString stringWithFormat:@"Stored in %@", tb.waypoint_name];
    if (tb.owner != nil)
        cell.owner.text = [NSString stringWithFormat:@"Owned by %@", tb.owner.name];

    cell.userInteractionEnabled = NO;

    return cell;
}

#pragma mark - Local menu related functions

- (void)menuUpdate
{
    [self showInfoView];
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:@"Download trackables information"];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.remoteAPI.supportsTrackables == YES && a.canDoRemoteStuff == YES) {
            // Get rid of any old data
            [self.tbs enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
                tb.carrier = nil;
                tb.waypoint_name = nil;
                [tb dbUpdate];
            }];
            [self remoteAPILoadTrackables:a infoView:infoView infoItemID:iid];
            [self loadTrackables];
            [self reloadDataMainQueue];
            *stop = YES;
        }
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
