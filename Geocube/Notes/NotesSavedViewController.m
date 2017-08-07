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

@interface NotesSavedViewController ()
{
    NSArray<dbWaypoint *> *waypointsWithLogs;
    NSMutableArray<dbLog *> *logs;
    NSIndexPath *selected;
}

@end

@implementation NotesSavedViewController

enum {
    menuDelete = 0,
    menuSubmit,
    menuDeleteAll,
    menuSubmitAll,
    menuMax,
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuDelete label:_(@"notessavedviewcontroller-Remove")];
    [lmi addItem:menuSubmit label:_(@"notessavedviewcontroller-Submit")];
    [lmi addItem:menuDeleteAll label:_(@"notessavedviewcontroller-Remove all")];
    [lmi addItem:menuSubmitAll label:_(@"notessavedviewcontroller-Submit all")];
    [lmi disableItem:menuDelete];
    [lmi disableItem:menuSubmit];
    [lmi disableItem:menuSubmitAll];

    selected = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOGTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOGTABLEVIEWCELL];
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
    [self reloadLogs];
    [self.tableView reloadData];

    selected = nil;
    [lmi disableItem:menuDelete];
    [lmi disableItem:menuSubmit];
}

- (void)reloadLogs
{
    waypointsWithLogs = [dbWaypoint dbAllWaypointsWithLogsUnsubmitted];
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
    return [[dbLog dbAllByWaypointUnsubmitted:wp] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ %@", wp.wpt_name, wp.wpt_urlname];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_LOGTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointUnsubmitted:wp] objectAtIndex:indexPath.row];

    [cell setLog:l];
    [cell setUserInteractionEnabled:YES];

    [logs addObject:l];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = indexPath;

    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    if (wp.account.remoteAPI.supportsLogging == YES &&
        wp.account.canDoRemoteStuff == YES)
        [lmi enableItem:menuSubmit];

    [lmi enableItem:menuDelete];
}

- (void)tableView:(UITableView *)aTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = nil;
    [lmi disableItem:menuDelete];
    [lmi disableItem:menuSubmit];
}

- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *remove =
        [UITableViewRowAction
            rowActionWithStyle:UITableViewRowActionStyleDefault
            title:_(@"Remove")
            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                [self menuDelete:indexPath];
            }
         ];
    remove.backgroundColor = [UIColor redColor];

    UITableViewRowAction *submit =
        [UITableViewRowAction
            rowActionWithStyle:UITableViewRowActionStyleDefault
            title:_(@"Submit")
            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                [self menuDelete:indexPath];
            }
         ];
    submit.backgroundColor = [UIColor greenColor];

    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    if (wp.account.remoteAPI.supportsLogging == YES &&
        wp.account.canDoRemoteStuff == YES) {
        return @[submit, remove];
    } else {
        return @[remove];
    }
}

#pragma mark - Local menu related functions

- (void)menuDeleteAll
{
    [waypointsWithLogs enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [[dbLog dbAllByWaypointUnsubmitted:wp] enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
            [log dbDelete];
        }];
    }];
    [self reloadLogs];
    [self reloadDataMainQueue];
}

- (void)menuDelete
{
    if (selected != nil)
        [self menuDelete:selected];
}

- (void)menuDelete:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointUnsubmitted:wp] objectAtIndex:indexPath.row];

    l.needstobelogged = NO;
    [l dbUpdate];
    [self reloadLogs];
    [self reloadDataMainQueue];
}

- (void)menuSubmitAll
{
    [waypointsWithLogs enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [[dbLog dbAllByWaypointUnsubmitted:wp] enumerateObjectsUsingBlock:^(dbLog * _Nonnull log, NSUInteger idx, BOOL * _Nonnull stop) {
            // Something
        }];
    }];
    [self reloadLogs];
    [self reloadDataMainQueue];
}

- (void)menuSubmit
{
    if (selected != nil)
        [self menuSubmit:selected];
}

- (void)menuSubmit:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypointsWithLogs objectAtIndex:indexPath.section];
    dbLog *l = [[dbLog dbAllByWaypointUnsubmitted:wp] objectAtIndex:indexPath.row];

    WaypointViewController *wpvc = [[WaypointViewController alloc] init];
    wpvc.hasCloseButton = YES;
    [wpvc showWaypoint:wp];
    wpvc.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:wpvc animated:YES];

    WaypointLogViewController *lvc = [[WaypointLogViewController alloc] init:wp];
    lvc.edgesForExtendedLayout = UIRectEdgeNone;
    lvc.delegateWaypoint = wpvc;
    [lvc importLog:l];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuDelete:
            [self menuDelete];
            return;
        case menuSubmit:
            [self menuSubmit];
            return;
        case menuDeleteAll:
            [self menuDeleteAll];
            return;
        case menuSubmitAll:
            [self menuSubmitAll];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
