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

#define THISCELL @"cachetableviewcell"

@implementation CachesOfflineListViewController

- (id)init
{
    self = [super init];

    menuItems = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[CacheTableViewCell class] forCellReuseIdentifier:THISCELL];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(refreshCachesData) withObject:nil];
    [DejalBezelActivityView activityViewForView:self.view withLabel:@"Refreshing database"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    NSEnumerator *e = [[waypointManager currentWaypoints] objectEnumerator];

    [clock clockShowAndReset];
    dbWaypoint *wp;

    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        [_wps addObject:wp];
    }

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

// Return a cell for the index path
- (CacheTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CacheTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[CacheTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    dbGroundspeak *gs = wp.groundspeak;
    cell.description.text = wp.description;
    cell.name.text = wp.name;
    if (wp.logStatus == LOGSTATUS_NOTLOGGED)
        cell.icon.image = [imageLibrary getTypeNormal:wp.type.icon];
    if (wp.logStatus == LOGSTATUS_NOTFOUND)
        cell.icon.image = [imageLibrary getTypeDNF:wp.type.icon];
    if (wp.logStatus == LOGSTATUS_FOUND)
        cell.icon.image = [imageLibrary getTypeFound:wp.type.icon];

    [cell setRatings:gs.favourites terrain:gs.rating_terrain difficulty:gs.rating_difficulty size:gs.container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [Coordinates NiceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];

    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (gs.state != nil)
        [s appendFormat:@"%@", gs.state.name];
    if (gs.country != nil) {
         if ([s compare:@""] != NSOrderedSame)
             [s appendFormat:@", "];
        [s appendFormat:@"%@", gs.country.code];
    }
    cell.stateCountry.text = s;
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

    CacheViewController *newController = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [newController showWaypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = newTitle;
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - SearchBar related functions

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString compare:@""] == NSOrderedSame)
        searchString = nil;
    [self refreshCachesData:searchString];
    //    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
