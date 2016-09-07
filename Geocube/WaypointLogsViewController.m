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

@interface WaypointLogsViewController ()
{
    BOOL mineOnly;
    dbWaypoint *waypoint;
    NSArray *logs;

    dbLog *selectedLog;
}

@end

#define THISCELL @"WaypointLogsViewControllerCell"

@implementation WaypointLogsViewController

enum {
    menuScanForWaypoints,
    menuCopyLog,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super initWithStyle:UITableViewStylePlain];
    waypoint = _wp;
    mineOnly = NO;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[LogTableViewCell class] forCellReuseIdentifier:THISCELL];

    logs = [dbLog dbAllByWaypoint:waypoint._id];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuScanForWaypoints label:@"Extract Waypoints"];
    [lmi addItem:menuCopyLog label:@"Copy log to clipboard"];
    [lmi disableItem:menuScanForWaypoints];
    [lmi disableItem:menuCopyLog];

    return self;
}

- (instancetype)initMine:(dbWaypoint *)_wp
{
    self = [self init:_wp];

    mineOnly = YES;
    logs = [dbLog dbAllByWaypointLogged:waypoint._id];

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = YES;
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
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbLog *l = [logs objectAtIndex:indexPath.row];
    cell.datetimeLabel.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:l.datetime_epoch];
    cell.loggerLabel.text = l.logger.name;
    cell.logtypeImage.image = [imageLibrary get:l.logstring.icon];

    [cell setLogString:l.log];
    [cell.contentView sizeToFit];
    [cell setUserInteractionEnabled:YES];

    cell.log = l;
    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbLog *l = [logs objectAtIndex:indexPath.row];
    return l.cellHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLog = [logs objectAtIndex:indexPath.row];
    [lmi enableItem:menuScanForWaypoints];
    [lmi enableItem:menuCopyLog];
}

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLog = nil;
    [lmi disableItem:menuScanForWaypoints];
    [lmi disableItem:menuCopyLog];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuScanForWaypoints:
            [self scanForWaypoints];
            return;
        case menuCopyLog:
            [self menuCopyLog];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)scanForWaypoints
{
    if (selectedLog == nil)
        return;

    NSArray *lines = [selectedLog.log componentsSeparatedByString:@"\n"];
    [Coordinates scanForWaypoints:lines waypoint:waypoint view:self];
}

- (void)menuCopyLog
{
    if (selectedLog == nil)
        return;

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = selectedLog.log;
    [MyTools messageBox:self header:@"Copy successful" text:@"The text of the selected log has been copied to the clipboard"];
}

@end
