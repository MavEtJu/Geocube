//
//  CacheLogsViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL @"CacheLogsViewControllerCell"

@implementation CacheLogsViewController

- (id)init:(dbCache *)_wp
{
    self = [super init];
    wp = _wp;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[LogTableViewCell class] forCellReuseIdentifier:THISCELL];

    logs = [db Logs_all_bycacheid:_wp._id];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [logs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[LogTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    dbLog *l = [logs objectAtIndex:indexPath.row];
    cell.datetime.text = l.datetime;
    cell.logger.text = l.logger;
    cell.log.text = l.log;
    cell.log.lineBreakMode = NSLineBreakByWordWrapping;
    dbLogType *lt = [dbc LogType_get:l.logtype_id];
    cell.logtype.image = [imageLibrary get:lt.icon];

    [cell.log sizeToFit];
    [cell.contentView sizeToFit];
    [cell setUserInteractionEnabled:NO];

    /* Save the height for later */
    l.cellHeight = cell.logger.frame.size.height + cell.log.frame.size.height + 10;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbLog *l = [logs objectAtIndex:indexPath.row];
    return l.cellHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
