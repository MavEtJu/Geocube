/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface MoveablesTemplateViewController ()

@property (nonatomic        ) SortOrderWaypoints currentSortOrder;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation MoveablesTemplateViewController

enum {
    menuSortBy,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.currentSortOrder = configManager.moveablesListSortBy;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuSortBy label:_(@"moveablestemplateviewcontroller-Sort by")];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOCATIONLESSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOCATIONLESSTABLEVIEWCELL];

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
    [self loadWaypoints];
    self.waypoints = [NSMutableArray arrayWithArray:[WaypointSorter resortWaypoints:self.waypoints waypointsSortOrder:self.currentSortOrder]];

    [self.tableView reloadData];
}

- NEEDS_OVERLOADING_VOID(loadWaypoints)

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.waypoints count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%ld %@", (long)[self.waypoints count], _(@"moveablestemplateviewcontroller-moveables")];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationlessTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_LOCATIONLESSTABLEVIEWCELL forIndexPath:indexPath];

    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    cell.icon.image = [imageManager getType:wp];
    cell.name.text = wp.wpt_urlname;
    cell.owner.text = wp.gs_owner.name;
    cell.code.text = wp.wpt_name;
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:wp.wpt_name];
    cell.note.text = pn.note;

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

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuSortBy:
            [self menuSortBy];
            return;
    }
    [super performLocalMenuAction:index];
}

- (void)menuSortBy
{
    NSArray<NSString *> *orders = [WaypointSorter waypointsSortOrders];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"moveablestemplateviewcontroller-Sort by")
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < SORTORDERWP_MAX; i++) {
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:[orders objectAtIndex:i]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     self.currentSortOrder = i;
                                     self.waypoints = [NSMutableArray arrayWithArray:[WaypointSorter resortWaypoints:self.waypoints waypointsSortOrder:self.currentSortOrder]];
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

#pragma mark - SearchBar related functions

- (void)refreshWaypoints:(NSString *)searchString
{
    [self loadWaypoints];
    if (searchString != nil) {
        searchString = [searchString lowercaseString];
        NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:[self.waypoints count]];
        [self.waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[wp.description lowercaseString] containsString:searchString] == NO &&
                [[wp.wpt_name lowercaseString] containsString:searchString] == NO)
                return;
            [wps addObject:wp];
        }];
        self.waypoints = wps;
    } else {
        // Hide the search window by default
        if ([self.waypoints count] != 0) {
            MAINQUEUE(
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            )
        }
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""] == YES)
        searchString = nil;
    [self refreshWaypoints:searchString];
    [self.tableView reloadData];
}

@end
