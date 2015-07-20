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
    [self refreshCachesData:nil];
    [self.tableView reloadData];
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [[dbCache dbAll] objectEnumerator];
    dbCache *wp;

    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:LM.coords];

        [_wps addObject:wp];
    }
    wps = [_wps sortedArrayUsingComparator: ^(dbCache *obj1, dbCache *obj2) {

        if (obj1.calculatedDistance > obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedDescending;
        }

        if (obj1.calculatedDistance < obj2.calculatedDistance) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];


    wpCount = [wps count];
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
    return wpCount;
}

// Return a cell for the index path
- (CacheTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CacheTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[CacheTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbCache *wp = [wps objectAtIndex:indexPath.row];
    cell.description.text = wp.description;
    cell.name.text = wp.name;
    cell.icon.image = [imageLibrary get:wp.cache_type.icon];

    [cell setRatings:wp.gc_favourites terrain:wp.gc_rating_terrain difficulty:wp.gc_rating_difficulty];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [Coordinates NiceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];
    cell.stateCountry.text = [NSString stringWithFormat:@"%@, %@", wp.gc_state, wp.gc_country];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CacheTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbCache *wp = [wps objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    CacheViewController *newController = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [newController showCache:wp];
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
