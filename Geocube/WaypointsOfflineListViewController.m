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

@interface WaypointsOfflineListViewController ()
{
    NSArray<dbWaypoint *> *waypoints;

    SortOrder currentSortOrder;

    BOOL needsRefresh;
    BOOL isVisible;

    RemoteAPIProcessingGroup *processing;
}

@end

#define THISCELL @"WaypointTableViewCell"

@implementation WaypointsOfflineListViewController

enum {
    menuAddWaypoint,
    menuExportGPX,
    menuSortBy,
    menuReloadWaypoints,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    currentSortOrder = configManager.waypointListSortBy;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddWaypoint label:@"Add waypoint"];
    [lmi addItem:menuExportGPX label:@"Export GPX"];
    [lmi addItem:menuSortBy label:@"Sort By"];
    [lmi addItem:menuReloadWaypoints label:@"Reload waypoints"];

    processing = [[RemoteAPIProcessingGroup alloc] init];

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

    isVisible = NO;
    needsRefresh = YES;
    [waypointManager startDelegation:self];

    /*
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;

    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (needsRefresh == YES) {
        [self performSelectorInBackground:@selector(refreshCachesData) withObject:nil];
    } else {
        waypoints = [WaypointSorter resortWaypoints:waypoints sortOrder:currentSortOrder];
        [self.tableView reloadData];
    }
    needsRefresh = NO;
    isVisible = YES;
}

- (void)refreshCachesData
{
    [bezelManager showBezel:self];
    [bezelManager setText:@"Refreshing database"];

    [self refreshCachesData:nil];

    [bezelManager removeBezel];

    if ([waypoints count] == 0)
        [lmi disableItem:menuExportGPX];
    else
        [lmi enableItem:menuExportGPX];
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray<dbWaypoint *> *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    MyClock *clock = [[MyClock alloc] initClock:@"refreshCachesData"];

    [waypointManager applyFilters:LM.coords];
    [clock clockShowAndReset];

    [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            return;
        [_wps addObject:wp];
    }];

    waypoints = [WaypointSorter resortWaypoints:_wps sortOrder:currentSortOrder];

    [self reloadDataMainQueue];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [waypoints count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (waypoints == nil)
        return @"";
    NSInteger c = [waypoints count];
    return [NSString stringWithFormat:@"%ld waypoint%@", (unsigned long)c, c == 1 ? @"" : @"s"];
}

// Return a cell for the index path
- (WaypointTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - SearchBar related functions

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""] == YES)
        searchString = nil;
    [self refreshCachesData:searchString];
    //    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

#pragma mark - Waypoint manager callbacks

- (void)refreshWaypoints
{
    needsRefresh = YES;
    if (isVisible == YES)
        [self refreshCachesData:nil];
}

- (void)removeWaypoint:(dbWaypoint *)wp
{
    waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints sortOrder:currentSortOrder];
    [self reloadDataMainQueue];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints sortOrder:currentSortOrder];
    [self reloadDataMainQueue];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints sortOrder:currentSortOrder];
    [self reloadDataMainQueue];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuAddWaypoint:
            [self addWaypoint];
            return;
        case menuExportGPX:
            [ExportGPX exports:waypoints];
            [MyTools messageBox:self header:@"Export successful" text:@"The exported file can be found in the Files section"];
            return;
        case menuSortBy:
            [self menuSortBy];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)addWaypoint
{
    WaypointAddViewController *newController = [[WaypointAddViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)menuSortBy
{
    NSArray<NSString *> *orders = [WaypointSorter sortOrders];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Sort by"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < SORTORDER_MAX; i++) {
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:[orders objectAtIndex:i]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     currentSortOrder = i;
                                     waypoints = [WaypointSorter resortWaypoints:waypoints sortOrder:currentSortOrder];
                                     [self.tableView reloadData];
                                 }];
        [alert addAction:action];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

//- (void)menuReloadWaypoints
//{
//    [self performSelectorInBackground:@selector(runReloadWaypoints) withObject:nil];
//}
//
//- (void)runReloadWaypoints
//{
//    NSArray<dbWaypoint *> *wps = [NSArray arrayWithArray:waypoints];
//
//    // XXX group them by account
//    [self showInfoView];
//    InfoItemID iid = [infoView addDownload];
//
//    __block BOOL failure = NO;
//    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
//        [infoView setDescription:iid description:[NSString stringWithFormat:@"Updating %@", wp.wpt_name]];
//        [infoView setDownloadHeaderSuffix:[NSString stringWithFormat:@"%ld / %ld", (long)(idx + 1), (long)[wps count]]];
//        [infoView resetBytesChunks:iid];
//
//        // Just ignore this stuff
//        if (wp.account == nil)
//            return;
//
//        if ([wp.account canDoRemoteStuff] == NO)
//            return;
//
//        NSInteger rv = [wp.account.remoteAPI loadWaypoint:wp infoViewer:infoView ivi:iid identifier:0 callback:self];
//        if (rv != REMOTEAPI_OK) {
//            [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:wp.account.remoteAPI.lastError];
//            failure = YES;
//            *stop = YES;
//        }
//
//    }];
//
//    [infoView removeItem:iid];
//}
//
//- (void)remoteAPI_objectReadyToImport:(InfoViewer *)iv ivi:(InfoItemID)ivi identifier:(NSInteger)identifier object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
//{
//    [importManager process:o group:group account:account options:IMPORTOPTION_NONE infoViewer:iv ivi:ivi];
//    [waypointManager needsRefreshAll];
//
//    [self reloadDataMainQueue];
//
//    [infoView removeItem:ivi];
//    [self hideInfoView];
//
//    [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];
//}


////////////////////////

- (void)menuReloadWaypoints
{
    [self showInfoView];

    [processing clearAll];
    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoViewer:nil ivi:0];

    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *account, NSUInteger idx, BOOL *stop) {
        NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[waypoints count]];
        [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if (wp.account_id == account._id)
                [wps addObject:wp.wpt_name];
        }];
        if ([wps count] == 0)
            return;

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setObject:wps forKey:@"waypoints"];
        [dict setObject:account forKey:@"account"];

        [processing addIdentifier:account._id];
        [self performSelectorInBackground:@selector(runReloadWaypoints:) withObject:dict];
    }];

    [self performSelectorInBackground:@selector(waitForDownloadsToFinish) withObject:nil];
}

- (void)waitForDownloadsToFinish
{
    while ([processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoViewer:nil ivi:0];

    [waypointManager needsRefreshAll];
    [self reloadDataMainQueue];
    [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];

    [self hideInfoView];
}

- (void)runReloadWaypoints:(NSDictionary *)dict
{
    NSArray<NSString *> *wps = [dict objectForKey:@"waypoints"];
    dbAccount *account = [dict objectForKey:@"account"];

    InfoItemID iid = [infoView addDownload];
    [infoView setChunksTotal:iid total:[wps count]];
    [infoView setDescription:iid description:[NSString stringWithFormat:@"Downloading for %@", account.site]];

    NSLog(@"PROCESSING: Adding %ld (%@)", (long)account._id, account.site);
    NSInteger rv = [account.remoteAPI loadWaypointsByCodes:wps infoViewer:infoView ivi:iid identifier:account._id group:dbc.Group_LastImport callback:self];
    if (rv != REMOTEAPI_OK)
        [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:account.remoteAPI.lastError];
    [infoView removeItem:iid];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier ivi:(InfoItemID)ivi object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    NSLog(@"PROCESSING: Downloaded %ld", identifier);
    [processing increaseDownloadedChunks:identifier];

    [importManager process:o group:group account:account options:IMPORTOPTION_NOPRE|IMPORTOPTION_NOPOST infoViewer:infoView ivi:ivi];
    [infoView removeItem:ivi];

    NSLog(@"PROCESSING: Processed %ld", identifier);
    [processing increaseProcessedChunks:identifier];
    if ([processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", identifier);
        [processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"PROCESSING: Expecting %ld for %ld", numberOfChunks, identifier);
    [processing expectedChunks:identifier chunks:numberOfChunks];
    if ([processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", identifier);
        [processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", identifier);
    [processing removeIdentifier:identifier];
}

@end
