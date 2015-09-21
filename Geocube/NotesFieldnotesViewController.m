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

@implementation NotesFieldnotesViewController

#define THISCELL @"NotesFieldnotesViewcell"

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[LogTableViewCell class] forCellReuseIdentifier:THISCELL];
    menuItems = nil;

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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self.tableView reloadData];
                                 }
     ];
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
    return [NSString stringWithFormat:@"%@ %@", wp.name, wp.urlname];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[LogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointLogged:wp._id] objectAtIndex:indexPath.row];

    cell.datetimeLabel.text = [NSString stringWithFormat:@"%@ %@", [MyTools datetimePartDate:l.datetime], [MyTools datetimePartTime:l.datetime]];
    cell.loggerLabel.text = l.logger.name;
    cell.logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    dbLogType *lt = [dbc LogType_get:l.logtype_id];
    cell.logtypeImage.image = [imageLibrary get:lt.icon];

    [cell setLogString:l.log];
    [cell.contentView sizeToFit];
    [cell setUserInteractionEnabled:NO];

    cell.log = l;

    /* Save the height for later */
    [cell viewWillTransitionToSize];
    [logs addObject:l];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointLogged:wp._id] objectAtIndex:indexPath.row];

    __block CGFloat height = 0;

    [logs enumerateObjectsUsingBlock:^(dbLog *ls, NSUInteger idx, BOOL *stop) {
        if (ls._id == l._id && ls.cellHeight != 0) {
            height = ls.cellHeight;
            *stop = YES;
        }
    }];

    return height;
}

@end
