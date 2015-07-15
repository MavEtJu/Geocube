//
//  CachesOfflineListViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 6/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
    NSEnumerator *e = [dbc.Caches objectEnumerator];
    dbCache *wp;

    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:[Coordinates myLocation]];

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

    coordinate_type cMe, cThere;
    cThere.lat = wp.lat_float;
    cThere.lon = wp.lon_float;
    cMe = [Coordinates myLocation];
    NSInteger bearing = [Coordinates coordinates2bearing:cMe to:cThere];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [Coordinates NiceDistance:[Coordinates coordinates2distance:cMe to:cThere]];
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
