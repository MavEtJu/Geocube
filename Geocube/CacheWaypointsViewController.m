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

#define THISCELL @"CacheWaypointsViewController"

@implementation CacheWaypointsViewController

- (id)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    wps = [waypoint hasWaypoints];
    hasCloseButton = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [wps count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    cell.textLabel.text = wp.urlname;
    cell.detailTextLabel.text = wp.name;
    cell.imageView.image = [imageLibrary get:wp.type.icon];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [wps objectAtIndex:indexPath.row];

    [self.navigationController popViewControllerAnimated:YES];
    CacheViewController *cvc = (CacheViewController *)self.navigationController.topViewController;
    [cvc showWaypoint:wp];
    return;
}

@end
