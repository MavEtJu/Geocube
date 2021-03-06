/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSArray<dbWaypoint *> *waypointsWithLogs;
@property (nonatomic, retain) NSMutableArray<dbLog *> *logs;

@end

@implementation NotesFieldnotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOGTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOGTABLEVIEWCELL];

    self.lmi = nil;

    self.waypointsWithLogs = [dbWaypoint dbAllWaypointsWithMyLogs];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.logs = [NSMutableArray arrayWithCapacity:100];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.logs = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.waypointsWithLogs = [dbWaypoint dbAllWaypointsWithMyLogs];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [self.waypointsWithLogs count];
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    dbWaypoint *wp = [self.waypointsWithLogs objectAtIndex:section];
    return [[dbLog dbAllByWaypointLoggedByMe:wp] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    dbWaypoint *wp = [self.waypointsWithLogs objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ - %@", wp.wpt_name, wp.wpt_urlname];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_LOGTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [self.waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointLoggedByMe:wp] objectAtIndex:indexPath.row];

    [cell setLog:l];
    [cell setUserInteractionEnabled:NO];

    /* Save the height for later */
    [cell viewWillTransitionToSize];
    [self.logs addObject:l];

    return cell;
}

@end
