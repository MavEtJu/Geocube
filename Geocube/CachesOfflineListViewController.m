//
//  CachesOfflineListViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 6/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "CachesOfflineListViewController.h"
#import "Geocube.h"
#import "My Tools.h"
#import "database.h"
#import "WaypointTableViewCell.h"

#define THISCELL @"waypointtableviewcell"

@implementation CachesOfflineListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerClass:[WaypointTableViewCell class] forCellReuseIdentifier:THISCELL];
    
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
    NSLog(@"CachesOfflineListViewController/viewWillAppear");
    [super viewWillAppear:animated];
    [self refreshWaypointsData:nil];
    [self.tableView reloadData];
}

- (void)refreshWaypointsData:(NSString *)searchString
{
    NSMutableArray *_wps = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.Waypoints objectEnumerator];
    dbObjectWaypoint *wp;
    
    while ((wp = [e nextObject]) != nil) {
        if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
            continue;
        [_wps addObject:wp];
    }
    wps = _wps;
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
- (WaypointTableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[WaypointTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    dbObjectWaypoint *wp = [wps objectAtIndex:indexPath.row];
    cell.description.text = wp.description;
    cell.name.text = wp.name;
    cell.icon.image = [imageLibrary get:wp.wp_type.icon];

    [cell setRatings:wp.favourites terrain:wp.rating_terrain difficulty:wp.rating_difficulty];
    
    coordinate_type cMe, cThere;
    cThere.lat = wp.lat_float;
    cThere.lon = wp.lon_float;
    cMe = [MyTools myLocation];
    NSInteger bearing = [MyTools coordinates2bearing:cMe to:cThere];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", bearing];
    cell.compass.text = [MyTools bearing2compass:bearing];
    cell.distance.text = [MyTools NiceDistance:[MyTools coordinates2distance:cMe to:cThere]];
    cell.stateCountry.text = [NSString stringWithFormat:@"%@, %@", wp.state, wp.country];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WaypointTableViewCell cellHeight];
}

#pragma mark - SearchBar related functions

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString compare:@""] == NSOrderedSame)
        searchString = nil;
    [self refreshWaypointsData:searchString];
//    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
