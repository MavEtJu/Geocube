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

@interface ListTemplateViewController ()
{
    NSInteger chunksProcessed;
    NSInteger chunksDownloaded;
}

@end

@implementation ListTemplateViewController

enum {
    menuClearFlags,
    menuReloadWaypoints,
    menuExportGPX,
    menuMax
};

#define THISCELL @"WaypointTableViewCell"

NEEDS_OVERLOADING(clearFlags)
NEEDS_OVERLOADING(removeMark:(NSInteger)idx)

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

    [self.tableView registerNib:[UINib nibWithNibName:@"WaypointTableViewCell" bundle:nil] forCellReuseIdentifier:THISCELL];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;

    [self makeInfoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllByFlag:flag]];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
        [waypointManager needsRefreshUpdate:wp];

        [self removeMark:indexPath.row];
        [waypoints removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove mark";
}

#pragma mark - Local menu related functions

- (void)menuClearFlags
{
    [self clearFlags];
    [waypoints removeAllObjects];
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

    chunksProcessed = 0;
    chunksDownloaded = 0;

    __block BOOL failure = NO;
    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL *stop) {
        NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if (wp.account_id == account._id)
                [wps addObject:wp.wpt_name];
        }];
        if ([wps count] == 0)
            return;

        InfoItemID iid = [infoView addDownload];
        [infoView setChunksTotal:iid total:[wps count]];
        [infoView setDescription:iid description:[NSString stringWithFormat:@"Downloading for %@", account.site]];

        NSInteger rv = [account.remoteAPI loadWaypointsByCodes:wps infoViewer:infoView ivi:iid group:dbc.Group_LastImport callback:self];
        if (rv != REMOTEAPI_OK) {
            [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:account.remoteAPI.lastError];
            failure = YES;
            *stop = YES;
        }
        [infoView removeItem:iid];
    }];
}

- (void)remoteAPI_objectReadyToImport:(InfoViewer *)iv ivi:(InfoItemID)ivi object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    @synchronized (self) {
        chunksDownloaded++;
    }

    [importManager process:o group:group account:account options:RUN_OPTION_NONE infoViewer:iv ivi:ivi];
    [iv removeItem:ivi];

    @synchronized (self) {
        chunksProcessed++;
    }
}

- (void)remoteAPI_finishedDownloads:(InfoViewer *)iv numberOfChunks:(NSInteger)numberOfChunks
{
    while (chunksProcessed != numberOfChunks) {
        [NSThread sleepForTimeInterval:0.1];
    }

    waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllByFlag:flag]];
    [waypointManager needsRefreshAll];
    [self reloadDataMainQueue];
    [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];

    [self hideInfoView];
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
