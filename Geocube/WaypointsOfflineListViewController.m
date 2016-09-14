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

@interface WaypointsOfflineListViewController ()
{
    NSMutableArray *waypoints;

    NSInteger currentSortOrder;

    BOOL needsRefresh;
    BOOL isVisible;
}

@end

#define THISCELL @"cachetableviewcell"
#define THISCELL_HEADER @"cachetableviewcellHeader"

@implementation WaypointsOfflineListViewController

enum {
    menuAddWaypoint,
    menuExportGPX,
    menuSortBy,
    menuReloadWaypoints,
    menuMax
};

enum {
    SORTORDER_DISTANCE_ASC = 0,
    SORTORDER_DISTANCE_DESC,
    SORTORDER_DIRECTION_ASC,
    SORTORDER_DIRECTION_DESC,
    SORTORDER_TYPE,
    SORTORDER_CONTAINER,
    SORTORDER_FAVOURITES_ASC,
    SORTORDER_FAVOURITES_DESC,
    SORTORDER_TERRAIN_ASC,
    SORTORDER_TERRAIN_DESC,
    SORTORDER_DIFFICULTY_ASC,
    SORTORDER_DIFFICULTY_DESC,
    SORTORDER_NAME_ASC,
    SORTORDER_NAME_DESC,
    SORTORDER_CODE_ASC,
    SORTORDER_CODE_DESC,
    SORTORDER_DATE_FOUND_OLDESTFIRST,
    SORTORDER_DATE_FOUND_NEWESTFIRST,
    SORTORDER_DATE_LASTLOG_OLDESTFIRST,
    SORTORDER_DATE_LASTLOG_NEWESTFIRST,
    SORTORDER_DATE_HIDDEN_OLDESTFIRST,
    SORTORDER_DATE_HIDDEN_NEWESTFIRST,
    SORTORDER_MAX,
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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[WaypointTableViewCell class] forCellReuseIdentifier:THISCELL];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];

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
        waypoints = [self resortCachesData:waypoints];
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
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    MyClock *clock = [[MyClock alloc] initClock:@"refreshCachesData"];

    [waypointManager applyFilters:LM.coords];
    [clock clockShowAndReset];

    [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            return;
        [_wps addObject:wp];
    }];

    waypoints = [self resortCachesData:_wps];

    [self reloadDataMainQueue];
}

- (NSMutableArray *)resortCachesData:(NSMutableArray *)wps
{
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:LM.coords];
        wp.calculatedBearing = [Coordinates coordinates2bearing:wp.coordinates to:LM.coords];
    }];

#define NCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedDescending; \
            if (O1 W O2) \
                return (NSComparisonResult)NSOrderedAscending; \
            return (NSComparisonResult)NSOrderedSame; \
        }]]; \
        break;
#define SCMP(I, O1, O2, W) \
    case I: \
        wps = [NSMutableArray arrayWithArray:[wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) { \
            if (W == NSOrderedAscending) \
                return (NSComparisonResult)[O1 compare:O2 options:NSCaseInsensitiveSearch]; \
            else \
                return (NSComparisonResult)(-[O1 compare:O2 options:NSCaseInsensitiveSearch]); \
        }]]; \
        break;
    switch (currentSortOrder) {
        NCMP(SORTORDER_DISTANCE_ASC, obj1.calculatedDistance, obj2.calculatedDistance, >)
        NCMP(SORTORDER_DISTANCE_DESC, obj1.calculatedDistance, obj2.calculatedDistance, <)
        NCMP(SORTORDER_DIRECTION_ASC, obj1.calculatedBearing, obj2.calculatedBearing, <)
        NCMP(SORTORDER_DIRECTION_DESC, obj1.calculatedBearing, obj2.calculatedBearing, >)
        NCMP(SORTORDER_TYPE, obj1.wpt_type_id, obj2.wpt_type_id, >)
        NCMP(SORTORDER_CONTAINER, obj1.gs_container_id, obj2.gs_container_id, >)
        NCMP(SORTORDER_FAVOURITES_ASC, obj1.gs_favourites, obj2.gs_favourites, >)
        NCMP(SORTORDER_FAVOURITES_DESC, obj1.gs_favourites, obj2.gs_favourites, <)
        NCMP(SORTORDER_TERRAIN_ASC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, >)
        NCMP(SORTORDER_TERRAIN_DESC, obj1.gs_rating_terrain, obj2.gs_rating_terrain, <)
        NCMP(SORTORDER_DIFFICULTY_ASC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, >)
        NCMP(SORTORDER_DIFFICULTY_DESC, obj1.gs_rating_difficulty, obj2.gs_rating_difficulty, <)
        SCMP(SORTORDER_CODE_ASC, obj1.wpt_name, obj2.wpt_name, NSOrderedAscending)
        SCMP(SORTORDER_CODE_DESC, obj1.wpt_name, obj2.wpt_name, NSOrderedDescending)
        SCMP(SORTORDER_NAME_ASC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedAscending)
        SCMP(SORTORDER_NAME_DESC, obj1.wpt_urlname, obj2.wpt_urlname, NSOrderedDescending)
        NCMP(SORTORDER_DATE_HIDDEN_OLDESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, >)
        NCMP(SORTORDER_DATE_HIDDEN_NEWESTFIRST, obj1.wpt_date_placed_epoch, obj2.wpt_date_placed_epoch, <)
        NCMP(SORTORDER_DATE_FOUND_OLDESTFIRST, obj1.gs_date_found, obj2.gs_date_found, >)
        NCMP(SORTORDER_DATE_FOUND_NEWESTFIRST, obj1.gs_date_found, obj2.gs_date_found, <)
        NCMP(SORTORDER_DATE_LASTLOG_OLDESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, >)
        NCMP(SORTORDER_DATE_LASTLOG_NEWESTFIRST, obj1.date_lastlog_epoch, obj2.date_lastlog_epoch, <)
        default:
            NSAssert(NO, @"Unknown sort order");
    }

    return wps;
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
    cell.description.text = wp.wpt_urlname;
    cell.name.text = wp.wpt_name;
    cell.icon.image = [imageLibrary getType:wp];
    if (wp.flag_highlight == YES)
        cell.description.backgroundColor = [UIColor yellowColor];
    else
        cell.description.backgroundColor = [UIColor clearColor];

    [cell setRatings:wp.gs_favourites terrain:wp.gs_rating_terrain difficulty:wp.gs_rating_difficulty size:wp.gs_container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];

    cell.labelSize.text = wp.wpt_type.type_minor;
    if (wp.gs_container.icon == 0) {
        cell.labelSize.hidden = NO;
        cell.imageSize.hidden = YES;
    } else {
        cell.labelSize.hidden = YES;
        cell.imageSize.hidden = NO;
    }

    cell.stateCountry.text = [wp makeLocaleStateCountry];

    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WaypointTableViewCell cellHeight];
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
    NSUInteger idx = [waypoints indexOfObject:wp];
    if (idx == NSNotFound)
        return;
    [waypoints removeObjectAtIndex:idx];
    waypoints = [self resortCachesData:waypoints];
    [self reloadDataMainQueue];
}

- (void)addWaypoint:(dbWaypoint *)wp
{
    if ([waypoints indexOfObject:wp] != NSNotFound)
        return;
    [waypoints addObject:wp];
    waypoints = [self resortCachesData:waypoints];
    [self reloadDataMainQueue];
}

- (void)updateWaypoint:(dbWaypoint *)wp
{
    NSUInteger idx = [waypoints indexOfObject:wp];
    if (idx == NSNotFound)
        return;
    [waypoints replaceObjectAtIndex:idx withObject:wp];
    waypoints = [self resortCachesData:waypoints];
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

+ (NSArray *)sortByOrder
{
    NSMutableArray *orders = [NSMutableArray arrayWithCapacity:SORTORDER_MAX];
    for (NSInteger i = 0; i < SORTORDER_MAX; i++) {
#define CASE(__order__, __title__) \
    case __order__: \
        [orders addObject:__title__]; \
        break;
        switch (i) {
            CASE(SORTORDER_DISTANCE_ASC, @"Distance (ascending)")
            CASE(SORTORDER_DISTANCE_DESC, @"Distance (descending)")
            CASE(SORTORDER_DIRECTION_ASC, @"Direction (ascending)")
            CASE(SORTORDER_DIRECTION_DESC, @"Direction (descending)")
            CASE(SORTORDER_TYPE, @"Type")
            CASE(SORTORDER_CONTAINER, @"Container")
            CASE(SORTORDER_FAVOURITES_ASC, @"Favourites (ascending)")
            CASE(SORTORDER_FAVOURITES_DESC, @"Favourites (descending)")
            CASE(SORTORDER_TERRAIN_ASC, @"Terrain (ascending)")
            CASE(SORTORDER_TERRAIN_DESC, @"Terrain (descending)")
            CASE(SORTORDER_DIFFICULTY_ASC, @"Difficulty (ascending)")
            CASE(SORTORDER_DIFFICULTY_DESC, @"Difficulty (descending)")
            CASE(SORTORDER_NAME_ASC, @"Name (ascending)")
            CASE(SORTORDER_NAME_DESC, @"Name (descending)")
            CASE(SORTORDER_CODE_ASC, @"Code (ascending)")
            CASE(SORTORDER_CODE_DESC, @"Code (descending)")
            CASE(SORTORDER_DATE_LASTLOG_OLDESTFIRST, @"Last log date (oldest first)")
            CASE(SORTORDER_DATE_LASTLOG_NEWESTFIRST, @"Last log date (newest first)")
            CASE(SORTORDER_DATE_HIDDEN_OLDESTFIRST, @"Hidden date (oldest first)")
            CASE(SORTORDER_DATE_HIDDEN_NEWESTFIRST, @"Hidden date (newest first)")
            CASE(SORTORDER_DATE_FOUND_OLDESTFIRST, @"Found date (oldest first)")
            CASE(SORTORDER_DATE_FOUND_NEWESTFIRST, @"Found date (newest first)")
            default:
                NSAssert(NO, @"Unknown sort order");
        }
    }
    return orders;
}

- (void)menuSortBy
{
    NSArray *orders = [WaypointsOfflineListViewController sortByOrder];

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Sort by"
                               message:nil
                               preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < SORTORDER_MAX; i++) {
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:[orders objectAtIndex:i]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     currentSortOrder = i;
                                     waypoints = [self resortCachesData:waypoints];
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

- (void)menuReloadWaypoints
{
    [self performSelectorInBackground:@selector(runReloadWaypoints) withObject:nil];
}

- (void)runReloadWaypoints
{
    NSArray *wps = [NSArray arrayWithArray:waypoints];

    // XXX group them by account
    [self showInfoView];
    InfoItemDowload *iid = [infoView addDownload];

    __block BOOL failure = NO;
    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [iid setDescription:[NSString stringWithFormat:@"Updating %@", wp.wpt_name]];
        [infoView setHeaderSuffix:[NSString stringWithFormat:@"%ld / %ld", (long)(idx + 1), (long)[wps count]]];
        [iid resetBytesChunks];

        // Just ignore this stuff
        if (wp.account == nil)
            return;

        if ([wp.account canDoRemoteStuff] == NO)
            return;

        NSInteger rv = [wp.account.remoteAPI loadWaypoint:wp downloadInfoItem:iid];
        if (rv != REMOTEAPI_OK) {
            [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:wp.account.lastError];
            failure = YES;
            *stop = YES;
        }

        [waypointManager needsRefreshUpdate:wp];
    }];

    [self reloadDataMainQueue];

    [infoView removeItem:iid];
    [self hideInfoView];

    if (failure == NO)
        [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];
}

@end
