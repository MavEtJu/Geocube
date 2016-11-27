/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface ListTemplateViewController ()
{
    NSInteger waypointCellHeight;
}

@end

@implementation ListTemplateViewController

enum {
    menuClearFlags,
    menuReloadWaypoints,
    menuExportGPX,
    menuMax
};

#define THISCELL @"CacheTableViewCell"

NEEDS_OVERLOADING(clearFlags)

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuClearFlags label:@"Clear list"];
    [lmi addItem:menuReloadWaypoints label:@"Reload Waypoints"];
    [lmi addItem:menuExportGPX label:@"Export GPX"];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[WaypointTableViewCell class] forCellReuseIdentifier:THISCELL];

    WaypointTableViewCell *cell = [[WaypointTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
    waypointCellHeight = [cell cellHeight];


    [self makeInfoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    waypoints = [dbWaypoint dbAllByFlag:flag];
    [self.tableView reloadData];

    if ([waypoints count] == 0)
        [lmi disableItem:menuExportGPX];
    else
        [lmi enableItem:menuExportGPX];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (waypoints == nil)
        return @"";
    NSInteger c = [waypoints count];
    return [NSString stringWithFormat:@"%ld waypoint%@", (unsigned long)c, c == 1 ? @"" : @"s"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [waypoints count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];

    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    [cell setWaypoint:wp];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return waypointCellHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    WaypointViewController *newController = [[WaypointViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:YES];
    [newController showWaypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = newTitle;
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - Local menu related functions

- (void)menuClearFlags
{
    [self clearFlags];
    waypoints = @[];
    [self.tableView reloadData];
    [waypointManager needsRefreshAll];
}

- (void)menuReloadWaypoints
{
    [self performSelectorInBackground:@selector(runReloadWaypoints) withObject:nil];
}

- (void)runReloadWaypoints
{
    [self showInfoView];
    InfoItemID iid = [infoView addDownload];
    [infoView setChunksTotal:iid total:[waypoints count]];

    __block BOOL failure = NO;
    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [infoView resetBytes:iid];
        [infoView setHeaderSuffix:[NSString stringWithFormat:@"%ld / %ld", (long)(idx + 1), (long)[waypoints count]]];
        [infoView setDescription:iid description:[NSString stringWithFormat:@"Downloading %@", wp.wpt_name]];

        NSInteger rv = [wp.account.remoteAPI loadWaypoint:wp infoViewer:infoView ivi:iid];
        if (rv != REMOTEAPI_OK) {
            [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:wp.account.remoteAPI.lastError];
            failure = YES;
            *stop = YES;
        }
    }];

    [infoView removeItem:iid];
    [self hideInfoView];

    waypoints = [dbWaypoint dbAllByFlag:flag];

    [self reloadDataMainQueue];
    [waypointManager needsRefreshAll];

    if (failure == NO)
        [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuClearFlags:
            [self menuClearFlags];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
        case menuExportGPX:
            [ExportGPX exports:waypoints];
            [MyTools messageBox:self header:@"Export successful" text:@"The exported file can be found in the Files section"];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
