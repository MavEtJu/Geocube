//
//  CachesOfflineListViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 6/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "CachesOfflineListViewController.h"
#import "Geocube.h"
#import "database.h"

@implementation CachesOfflineListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.scopeButtonTitles = @[];
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
 //   [self.searchController.searchBar sizeToFit];
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
    NSEnumerator *e = [Waypoints objectEnumerator];
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
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    dbObjectWaypoint *wp = [wps objectAtIndex:indexPath.row];
    cell.textLabel.text = wp.description;
    cell.detailTextLabel.text = wp.name;
    
    return cell;
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
