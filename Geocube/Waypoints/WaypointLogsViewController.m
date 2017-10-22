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

@interface WaypointLogsViewController ()

@property (nonatomic        ) BOOL mineOnly;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) NSMutableArray<dbLog *> *logs;

@property (nonatomic, retain) dbLog *selectedLog;

@end

@implementation WaypointLogsViewController

enum {
    menuMapLogs,
    menuScanForWaypoints,
    menuCopyLog,
    menuDeleteLog,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.waypoint = wp;
    self.mineOnly = NO;

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOGTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOGTABLEVIEWCELL];

    self.logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypoint:self.waypoint]];
    __block BOOL foundAnyCoordinates = NO;
    [self.logs enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
        if (log.latitude != 0 && log.longitude != 0) {
            *stop = YES;
            foundAnyCoordinates = YES;
        }
    }];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuMapLogs label:_(@"waypointlogsviewcontroller-Map logs")];
    [self.lmi addItem:menuScanForWaypoints label:_(@"waypointlogsviewcontroller-Extract waypoints")];
    [self.lmi addItem:menuCopyLog label:_(@"waypointlogsviewcontroller-Copy log to clipboard")];
    [self.lmi addItem:menuDeleteLog label:_(@"waypointlogsviewcontroller-Delete log")];
    [self.lmi disableItem:menuScanForWaypoints];
    [self.lmi disableItem:menuCopyLog];
    [self.lmi disableItem:menuDeleteLog];
    if (foundAnyCoordinates == NO)
        [self.lmi disableItem:menuMapLogs];

    return self;
}

- (instancetype)initMine:(dbWaypoint *)wp
{
    self = [self init:wp];

    self.mineOnly = YES;
    self.logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypointLogged:self.waypoint]];

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
    return [self.logs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_LOGTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbLog *l = [self.logs objectAtIndex:indexPath.row];
    [cell setLog:l];
    [cell setUserInteractionEnabled:YES];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLog = [self.logs objectAtIndex:indexPath.row];
    [self.lmi enableItem:menuScanForWaypoints];
    [self.lmi enableItem:menuCopyLog];
    [self.lmi enableItem:menuDeleteLog];
}

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedLog = nil;
    [self.lmi disableItem:menuScanForWaypoints];
    [self.lmi disableItem:menuCopyLog];
    [self.lmi disableItem:menuDeleteLog];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbLog *l = [self.logs objectAtIndex:indexPath.row];
    if (l.localLog == YES)
        return YES;
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbLog *l = [self.logs objectAtIndex:indexPath.row];
        if (l.localLog == NO)
            return;

        [l dbDelete];
        [self.logs removeObjectAtIndex:indexPath.row];
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
    [locationlessMapViewController showLogLocations:self.waypoint];
    return;
}

- (void)scanForWaypoints
{
    if (self.selectedLog == nil)
        return;

    NSArray<NSString *> *lines = [self.selectedLog.log componentsSeparatedByString:@"\n"];
    [Coordinates scanForWaypoints:lines waypoint:self.waypoint view:self];
    [self.delegateWaypoint WaypointLogs_refreshTable];
}

- (void)menuCopyLog
{
    if (self.selectedLog == nil)
        return;

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.selectedLog.log;
    [MyTools messageBox:self header:_(@"waypointlogsviewcontroller-Copy successful") text:_(@"waypointlogsviewcontroller-The text of the selected log has been copied to the clipboard")];
}

- (void)menuDeleteLog
{
    if (self.selectedLog == nil)
        return;

    [self.selectedLog dbDelete];
    self.logs = [NSMutableArray arrayWithArray:[dbLog dbAllByWaypoint:self.waypoint]];
    [self reloadDataMainQueue];

    if (self.delegateWaypoint != nil)
        [self.delegateWaypoint WaypointLogs_refreshTable];
}

@end
