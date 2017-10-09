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

#import "WaypointLogsViewController.h"

#import "MapsLibrary/MapLogsViewController.h"
#import "ManagersLibrary/LocalizationManager.h"
#import "ToolsLibrary/MyTools.h"
#import "ToolsLibrary/Coordinates.h"

@interface WaypointLogsViewController ()
{
    BOOL mineOnly;
    dbWaypoint *waypoint;
    NSMutableArray<dbLog *> *logs;

    dbLog *selectedLog;
}

@end

@implementation WaypointLogsViewController

enum {
    menuMapLogs,
    menuScanForWaypoints,
    menuCopyLog,
    menuDeleteLog,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super initWithStyle:UITableViewStylePlain];
    waypoint = _wp;
    mineOnly = NO;

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOGTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOGTABLEVIEWCELL];

    logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypoint:waypoint]];
    __block BOOL foundAnyCoordinates = NO;
    [logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
        if (log.latitude != 0 && log.longitude != 0) {
            *stop = YES;
            foundAnyCoordinates = YES;
        }
    }];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMapLogs label:_(@"waypointlogsviewcontroller-Map logs")];
    [lmi addItem:menuScanForWaypoints label:_(@"waypointlogsviewcontroller-Extract waypoints")];
    [lmi addItem:menuCopyLog label:_(@"waypointlogsviewcontroller-Copy log to clipboard")];
    [lmi addItem:menuDeleteLog label:_(@"waypointlogsviewcontroller-Delete log")];
    [lmi disableItem:menuScanForWaypoints];
    [lmi disableItem:menuCopyLog];
    [lmi disableItem:menuDeleteLog];
    if (foundAnyCoordinates == NO)
        [lmi disableItem:menuMapLogs];

    return self;
}

- (instancetype)initMine:(dbWaypoint *)_wp
{
    self = [self init:_wp];

    mineOnly = YES;
    logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypointLogged:waypoint]];

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = YES;
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
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_LOGTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbLog *l = [logs objectAtIndex:indexPath.row];
    [cell setLog:l];
    [cell setUserInteractionEnabled:YES];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLog = [logs objectAtIndex:indexPath.row];
    [lmi enableItem:menuScanForWaypoints];
    [lmi enableItem:menuCopyLog];
    [lmi enableItem:menuDeleteLog];
}

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedLog = nil;
    [lmi disableItem:menuScanForWaypoints];
    [lmi disableItem:menuCopyLog];
    [lmi disableItem:menuDeleteLog];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbLog *l = [logs objectAtIndex:indexPath.row];
    if (l.localLog == YES)
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbLog *l = [logs objectAtIndex:indexPath.row];
        if (l.localLog == NO)
            return;

        [l dbDelete];
        [logs removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.delegateWaypoint WaypointLogs_refreshTable];
        [self.tableView reloadData];
    }
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuMapLogs:
            [self mapLogs];
            return;
        case menuScanForWaypoints:
            [self scanForWaypoints];
            return;
        case menuCopyLog:
            [self menuCopyLog];
            return;
        case menuDeleteLog:
            [self menuDeleteLog];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)mapLogs
{
    [_AppDelegate switchController:RC_LOCATIONSLESS];
    [locationlessMapTabController setSelectedIndex:VC_LOCATIONLESS_MAP animated:YES];
    [locationlessMapViewController showLogLocations:waypoint];
    return;
}

- (void)scanForWaypoints
{
    if (selectedLog == nil)
        return;

    NSArray<NSString *> *lines = [selectedLog.log componentsSeparatedByString:@"\n"];
    [Coordinates scanForWaypoints:lines waypoint:waypoint view:self];
    [self.delegateWaypoint WaypointLogs_refreshTable];
}

- (void)menuCopyLog
{
    if (selectedLog == nil)
        return;

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = selectedLog.log;
    [MyTools messageBox:self header:_(@"waypointlogsviewcontroller-Copy successful") text:_(@"waypointlogsviewcontroller-The text of the selected log has been copied to the clipboard")];
}

- (void)menuDeleteLog
{
    if (selectedLog == nil)
        return;

    [selectedLog dbDelete];
    logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypoint:waypoint]];
    [self reloadDataMainQueue];

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointLogs_refreshTable];
}

@end
