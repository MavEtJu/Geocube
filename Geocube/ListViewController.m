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

@interface ListViewController ()

@end

@implementation ListViewController

enum {
    menuClearFlags,
    menuReloadWaypoints,
    menuMax
};

#define THISCELL @"CacheTableViewCell"

NEEDS_OVERLOADING(clearFlags)

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuClearFlags label:@"Clear list"];
    [lmi addItem:menuReloadWaypoints label:@"Reload Waypoints"];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[CacheTableViewCell class] forCellReuseIdentifier:THISCELL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    waypoints = [dbWaypoint dbAllByFlag:flag];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (waypoints == nil)
        return @"";
    NSInteger c = [waypoints count];
    return [NSString stringWithFormat:@"%ld waypoint%@", (unsigned long)c, c == 1 ? @"" : @"s"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [waypoints count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CacheTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[CacheTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

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

    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (wp.gs_state != nil)
        [s appendFormat:@"%@", wp.gs_state.name];
    if (wp.gs_country != nil) {
        if ([s isEqualToString:@""] == NO)
            [s appendFormat:@", "];
        [s appendFormat:@"%@", wp.gs_country.code];
    }
    cell.stateCountry.text = s;

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

#pragma mark - Local menu related functions

- (void)menuClearFlags
{
    [self clearFlags];

    waypoints = @[];
    [self.tableView reloadData];

    [waypointManager needsRefresh];
}

- (void)menuReloadWaypoints
{
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuClearFlags:
            [self menuClearFlags];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end