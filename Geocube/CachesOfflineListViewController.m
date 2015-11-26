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

@interface CachesOfflineListViewController ()
{
    NSArray *waypoints;
    NSInteger waypointCount;
}

@end

#define THISCELL @"cachetableviewcell"
#define THISCELL_HEADER @"cachetableviewcellHeader"

@implementation CachesOfflineListViewController

enum {
    menuAddWaypoint,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddWaypoint label:@"Add waypoint"];
    menuItems = [lmi makeMenu];

    return self;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self.tableView reloadData];
                                 }
     ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[CacheTableViewCell class] forCellReuseIdentifier:THISCELL];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];

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
    [waypointManager startDelegation:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Refreshing database"];
    [self performSelectorInBackground:@selector(refreshCachesData) withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [waypointManager stopDelegation:self];
}

- (void)refreshCachesData
{
    [self refreshCachesData:nil];
    [DejalBezelActivityView removeView];
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    MyTools *clock = [[MyTools alloc] initClock:@"refreshCachesData"];

    [waypointManager applyFilters:LM.coords];
    [clock clockShowAndReset];

    [[waypointManager currentWaypoints] enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            return;
        [_wps addObject:wp];
    }];

    waypoints = [_wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) {
        if (obj1.calculatedDistance > obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedDescending;
        }

        if (obj1.calculatedDistance < obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    waypointCount = [waypoints count];
    [self.tableView reloadData];
}

/* Delegated from CacheFilterManager */
- (void)refreshWaypoints
{
    [self refreshCachesData:nil];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return waypointCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (waypoints == nil)
        return @"";
    return [NSString stringWithFormat:@"%ld waypoints", (unsigned long)[waypoints count]];
}

// Return a cell for the index path
- (CacheTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CacheTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[CacheTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    cell.description.text = wp.urlname;
    cell.name.text = wp.name;
    cell.icon.image = [imageLibrary getType:wp];
    if (wp.highlight == YES)
        cell.description.backgroundColor = [UIColor yellowColor];
    else
        cell.description.backgroundColor = [UIColor clearColor];

    [cell setRatings:wp.gs_favourites terrain:wp.gs_rating_terrain difficulty:wp.gs_rating_difficulty size:wp.gs_container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [MyTools NiceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];

    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (wp.gs_state != nil)
        [s appendFormat:@"%@", wp.gs_state.name];
    if (wp.gs_country != nil) {
         if ([s isEqualToString:@""] == NO)
             [s appendFormat:@", "];
        [s appendFormat:@"%@", wp.gs_country.code];
    }
    cell.stateCountry.text = s;

    //[cell showGroundspeak:(gs != nil)]; Not yet sure

    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CacheTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    CacheViewController *newController = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:YES];
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

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuAddWaypoint:
            [self addWaypoint];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)addWaypoint
{
    CacheAddViewController *newController = [[CacheAddViewController alloc] init];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
}

@end
