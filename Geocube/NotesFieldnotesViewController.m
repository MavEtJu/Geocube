/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface NotesFieldnotesViewController ()
{
    NSArray<dbWaypoint *> *waypointsWithLogs;
    NSMutableArray<dbLog *> *logs;
}

@end

@implementation NotesFieldnotesViewController

#define THISCELL @"LogTableViewCell"

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOGTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:THISCELL];

    lmi = nil;

    waypointsWithLogs = [dbWaypoint waypointsWithMyLogs];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    logs = [NSMutableArray arrayWithCapacity:100];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    logs = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    waypointsWithLogs = [dbWaypoint waypointsWithMyLogs];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [waypointsWithLogs count];
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:section];
    return [[dbLog dbAllByWaypointLogged:wp._id] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ %@", wp.wpt_name, wp.wpt_urlname];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointLogged:wp._id] objectAtIndex:indexPath.row];

    [cell setLog:l];
    [cell setUserInteractionEnabled:NO];

    /* Save the height for later */
    [cell viewWillTransitionToSize];
    [logs addObject:l];

    return cell;
}

@end
