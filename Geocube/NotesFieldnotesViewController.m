//
//  NotesFieldnotesViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 18/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
    return wp.urlname;
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

    cell.datetime.text = [NSString stringWithFormat:@"%@ %@", [MyTools datetimePartDate:l.datetime], [MyTools datetimePartTime:l.datetime]];
    cell.logger.text = l.logger.name;
    cell.log.text = l.log;
    cell.log.lineBreakMode = NSLineBreakByWordWrapping;
    dbLogType *lt = [dbc LogType_get:l.logtype_id];
    cell.logtype.image = [imageLibrary get:lt.icon];

    [cell.log sizeToFit];
    [cell.contentView sizeToFit];
    [cell setUserInteractionEnabled:NO];

    /* Save the height for later */
    l.cellHeight = cell.logger.frame.size.height + cell.log.frame.size.height + 10;
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