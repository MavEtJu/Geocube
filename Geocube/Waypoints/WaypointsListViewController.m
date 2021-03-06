/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface WaypointsListViewController ()

@property (nonatomic, retain) NSArray<dbWaypoint *> *waypoints;

@property (nonatomic        ) SortOrderWaypoints currentSortOrder;

@property (nonatomic        ) BOOL needsRefresh;
@property (nonatomic        ) BOOL isVisible;

@property (nonatomic, retain) RemoteAPIProcessingGroup *processing;

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation WaypointsListViewController

enum {
    menuAddWaypoint,
    menuExportGPX,
    menuSortBy,
    menuReloadWaypoints,
    menuDeleteAll,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.currentSortOrder = configManager.waypointListSortBy;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuAddWaypoint label:_(@"waypointslistviewcontroller-Add waypoint")];
    [self.lmi addItem:menuExportGPX label:_(@"waypointslistviewcontroller-Export GPX")];
    [self.lmi addItem:menuSortBy label:_(@"waypointslistviewcontroller-Sort by")];
    [self.lmi addItem:menuReloadWaypoints label:_(@"waypointslistviewcontroller-Reload waypoints")];
    [self.lmi addItem:menuDeleteAll label:_(@"waypointslistviewcontroller-Delete all")];

    self.processing = [[RemoteAPIProcessingGroup alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_WAYPOINTTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_WAYPOINTTABLEVIEWCELL];

    [self makeInfoView];

    self.isVisible = NO;
    self.needsRefresh = YES;
    [waypointManager startDelegationWaypoints:self];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;

    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.needsRefresh == YES) {
        BACKGROUND(refreshCachesData, nil);
    } else {
        self.waypoints = [WaypointSorter resortWaypoints:self.waypoints waypointsSortOrder:self.currentSortOrder];
        [self.tableView reloadData];
    }
    self.needsRefresh = NO;
    self.isVisible = YES;
}

- (void)refreshCachesData
{
    [bezelManager showBezel:self];
    [bezelManager setText:_(@"waypointslistviewcontroller-Refreshing database")];

    [self refreshCachesData:nil];

    [bezelManager removeBezel];

    if ([self.waypoints count] == 0)
        [self.lmi disableItem:menuExportGPX];
    else {
        [self.lmi enableItem:menuExportGPX];

        // Hide the search window by default
        MAINQUEUE(
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        )
    }
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray<dbWaypoint *> *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    MyClock *clock = [[MyClock alloc] initClock:@"refreshCachesData"];

    [waypointManager applyFilters:LM.coords];
    [clock clockShowAndReset];

    searchString = [searchString lowercaseString];
    [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        if (searchString != nil &&
            [[wp.description lowercaseString] containsString:searchString] == NO &&
            [[wp.wpt_name lowercaseString] containsString:searchString] == NO)
            return;
        [_wps addObject:wp];
    }];

    self.waypoints = [WaypointSorter resortWaypoints:_wps waypointsSortOrder:self.currentSortOrder];

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
    return [self.waypoints count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.waypoints == nil)
        return @"";
    NSInteger c = [self.waypoints count];
    return [NSString stringWithFormat:@"%ld %@", (unsigned long)c, c == 1 ? _(@"waypointslistviewcontroller-Waypoint") : _(@"waypointslistviewcontroller-Waypoints")];
}

// Return a cell for the index path
- (WaypointTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTTABLEVIEWCELL];
    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    [cell setWaypoint:wp];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    WaypointViewController *newController = [[WaypointViewController alloc] init];
    newController.hasCloseButton = YES;
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

- (void)waypointManagerRefreshWaypoints
{
    self.needsRefresh = YES;
    if (self.isVisible == YES)
        [self refreshCachesData:nil];
}

- (void)waypointManagerRemoveWaypoint:(dbWaypoint *)wp
{
    self.waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints waypointsSortOrder:self.currentSortOrder];
    [self reloadDataMainQueue];
}

- (void)waypointManagerAddWaypoint:(dbWaypoint *)wp
{
    self.waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints waypointsSortOrder:self.currentSortOrder];
    [self reloadDataMainQueue];
}

- (void)waypointManagerUpdateWaypoint:(dbWaypoint *)wp
{
    self.waypoints = [WaypointSorter resortWaypoints:waypointManager.currentWaypoints waypointsSortOrder:self.currentSortOrder];
    [self reloadDataMainQueue];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuAddWaypoint:
            [self addWaypoint];
            return;
        case menuExportGPX: {
            NSString *filename = [ExportGPX exportWaypoints:self.waypoints];
            [MyTools messageBox:self header:_(@"waypointslistviewcontroller-Export successful") text:[NSString stringWithFormat:_(@"waypointslistviewcontroller-The exported file '%@' can be found in the Files section"), filename]];
            return;
            }
        case menuSortBy:
            [self menuSortBy];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
        case menuDeleteAll:
            [self menuDeleteAll];
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
    NSArray<NSString *> *orders = [WaypointSorter waypointsSortOrders];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointslistviewcontroller-Sort by")
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < SORTORDERWP_MAX; i++) {
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:[orders objectAtIndex:i]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     self.currentSortOrder = i;
                                     self.waypoints = [WaypointSorter resortWaypoints:self.waypoints waypointsSortOrder:self.currentSortOrder];
                                     [self.tableView reloadData];
                                 }];
        [alert addAction:action];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuDeleteAll
{
    NSArray<dbWaypoint *> *wps = waypointManager.currentWaypoints;
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointslistviewcontroller-Delete waypoints")
                                message:_(@"waypointslistviewcontroller-Are you sure?")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:_(@"Yes")
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction *action) {
                              [wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                                  [wp dbDelete];
                              }];
                              [db cleanupAfterDelete];
                              [waypointManager needsRefreshAll];
                              [self.navigationController popViewControllerAnimated:YES];
                          }];

    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:_(@"NO!") style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:yes];
    [alert addAction:no];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

////////////////////////

- (void)menuReloadWaypoints
{
    [self showInfoView];

    [self.processing clearAll];
    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoItem:nil];

    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[self.waypoints count]];
        [self.waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if (wp.account._id == account._id)
                [wps addObject:wp.wpt_name];
        }];
        if ([wps count] == 0)
            return;

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setObject:wps forKey:@"waypoints"];
        [dict setObject:account forKey:@"account"];

        [self.processing addIdentifier:(long)account._id];
        BACKGROUND(runReloadWaypoints:, dict);
    }];

    BACKGROUND(waitForDownloadsToFinish, nil);
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    while ([self.processing hasIdentifiers] == YES) {
        [NSThread sleepForTimeInterval:0.1];
    }
    NSLog(@"PROCESSING: Nothing pending");

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoItem:nil];

    [waypointManager needsRefreshAll];
    [self reloadDataMainQueue];
    [audioManager playSound:PLAYSOUND_IMPORTCOMPLETE];

    [self hideInfoView];
}

- (void)runReloadWaypoints:(NSDictionary *)dict
{
    NSArray<NSString *> *wps = [dict objectForKey:@"waypoints"];
    dbAccount *account = [dict objectForKey:@"account"];

    InfoItem *iid = [self.infoView addDownload];
    [iid changeChunksTotal:[wps count]];
    [iid changeDescription:[NSString stringWithFormat:_(@"waypointslistviewcontroller-Downloading for %@"), account.site]];

    NSLog(@"PROCESSING: Adding %ld (%@)", (long)account._id, account.site);
    NSInteger rv = [account.remoteAPI loadWaypointsByCodes:wps infoItem:iid identifier:(long)account._id group:dbc.groupLastImport callback:self];
    if (rv != REMOTEAPI_OK)
        [MyTools messageBox:self header:_(@"waypointslistviewcontroller-Reload waypoints") text:_(@"waypointslistviewcontroller-Update failed") error:account.remoteAPI.lastError];
    [iid removeFromInfoViewer];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    NSLog(@"PROCESSING: Downloaded %ld", (long)identifier);
    [self.processing increaseDownloadedChunks:identifier];

    [importManager process:o group:group account:account options:IMPORTOPTION_NOPRE|IMPORTOPTION_NOPOST infoItem:iii];
    [iii removeFromInfoViewer];

    NSLog(@"PROCESSING: Processed %ld", (long)identifier);
    [self.processing increaseProcessedChunks:identifier];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"PROCESSING: Expecting %ld for %ld", (long)numberOfChunks, (long)identifier);
    [self.processing expectedChunks:identifier chunks:numberOfChunks];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", (long)identifier);
    [self.processing removeIdentifier:identifier];
}

@end
