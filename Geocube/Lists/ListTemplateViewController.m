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

@interface ListTemplateViewController ()

@property (nonatomic        ) SortOrderList currentSortOrder;
@property (nonatomic, retain) RemoteAPIProcessingGroup *processing;

@end

@implementation ListTemplateViewController

enum {
    menuClearFlags,
    menuReloadWaypoints,
    menuSortBy,
    menuExportGPX,
    menuMax
};

- NEEDS_OVERLOADING_VOID(clearFlags)
- NEEDS_OVERLOADING_VOID(removeMark:(NSInteger)idx)

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuClearFlags label:_(@"listtemplateviewcontroller-Clear list")];
    [self.lmi addItem:menuReloadWaypoints label:_(@"listtemplateviewcontroller-Reload waypoints")];
    [self.lmi addItem:menuExportGPX label:_(@"listtemplateviewcontroller-Export GPX")];
    [self.lmi addItem:menuSortBy label:_(@"listtemplateviewcontroller-Sort by")];

    self.currentSortOrder = configManager.listSortBy;
    self.processing = [[RemoteAPIProcessingGroup alloc] init];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_WAYPOINTTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_WAYPOINTTABLEVIEWCELL];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20;

    [self makeInfoView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.waypoints = [NSMutableArray arrayWithArray:[WaypointSorter resortWaypoints:[dbWaypoint dbAllByFlag:self.flag] listSortOrder:self.currentSortOrder flag:self.flag]];
    [self.tableView reloadData];

    if ([self.waypoints count] == 0)
        [self.lmi disableItem:menuExportGPX];
    else
        [self.lmi enableItem:menuExportGPX];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.waypoints == nil)
        return @"";
    NSInteger c = [self.waypoints count];
    return [NSString stringWithFormat:@"%ld %@", (unsigned long)c, c == 1 ? _(@"waypoint") : _(@"waypoints")];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.waypoints count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTTABLEVIEWCELL];

    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    [cell setWaypoint:wp];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    WaypointViewController *newController = [[WaypointViewController alloc] init];
    newController.hasCloseButton = YES;
    [newController showWaypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = newTitle;
    [self.navigationController pushViewController:newController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];

        [self removeMark:indexPath.row];
        [self.waypoints removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [waypointManager needsRefreshUpdate:wp];
        [self.tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _(@"listtemplateviewcontroller-Remove mark");
}

#pragma mark - Local menu related functions

- (void)menuClearFlags
{
    [self clearFlags];
    [self.waypoints removeAllObjects];
    [self.tableView reloadData];
    [waypointManager needsRefreshAll];
}

- (void)menuReloadWaypoints
{
    [self showInfoView];

    [self.processing clearAll];
    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPOST infoItem:nil];

    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull account, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray<NSString *> *wps = [NSMutableArray arrayWithCapacity:[self.waypoints count]];
        [self.waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
            if (wp.account._id == account._id)
                [wps addObject:wp.wpt_name];
        }];
        if ([wps count] == 0)
            return;

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
        [dict setObject:wps forKey:@"waypoints"];
        [dict setObject:account forKey:@"account"];

        [self.processing addIdentifier:(long)account._id];
        NSLog(@"PROCESSING: Adding %ld (%@)", (long)account._id, account.site);
        BACKGROUND(runReloadWaypoints:, dict);
    }];

    BACKGROUND(waitForDownloadsToFinish, nil);
}

- (void)waitForDownloadsToFinish
{
    [NSThread sleepForTimeInterval:0.5];
    do {
        [NSThread sleepForTimeInterval:0.1];
    } while ([self.processing hasIdentifiers] == YES);
    NSLog(@"PROCESSING: Nothing pending");

    [importManager process:nil group:nil account:nil options:IMPORTOPTION_NOPARSE|IMPORTOPTION_NOPRE infoItem:nil];

    self.waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllByFlag:self.flag]];
    [waypointManager needsRefreshAll];
    [self reloadDataMainQueue];
    [audioManager playSound:PLAYSOUND_IMPORTCOMPLETE];

    [self hideInfoView];
}

- (void)runReloadWaypoints:(NSDictionary *)dict
{
    NSArray<NSString *> *wps = [dict objectForKey:@"waypoints"];
    dbAccount *account = [dict objectForKey:@"account"];

    InfoItem *iid = [self.infoView addDownload];
    [iid changeChunksTotal:[wps count]];
    [iid changeDescription:[NSString stringWithFormat:_(@"listtemplateviewcontroller-Downloading for %@"), account.site]];

    NSInteger rv = [account.remoteAPI loadWaypointsByCodes:wps infoItem:iid identifier:(long)account._id group:dbc.groupLastImport callback:self];
    if (rv != REMOTEAPI_OK)
        [MyTools messageBox:self header:_(@"listtemplateviewcontroller-Reload waypoints") text:_(@"listtemplateviewcontroller-Update failed") error:account.remoteAPI.lastError];
    [iid removeFromInfoViewer];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    NSLog(@"PROCESSING: Downloaded %ld", (long)identifier);
    [self.processing increaseDownloadedChunks:identifier];

    [importManager process:o group:group account:account options:IMPORTOPTION_NOPRE|IMPORTOPTION_NOPOST infoItem:iii];
    [iii removeFromInfoViewer];

    NSLog(@"PROCESSING: Processed %ld", (long)identifier);
    [self.processing increaseProcessedChunks:identifier];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    NSLog(@"PROCESSING: Expecting %ld for %ld", (long)numberOfChunks, (long)identifier);
    [self.processing expectedChunks:identifier chunks:numberOfChunks];
    if ([self.processing hasAllProcessed:identifier] == YES) {
        NSLog(@"PROCESSING: All seen for %ld", (long)identifier);
        [self.processing removeIdentifier:identifier];
    }
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    NSLog(@"PROCESSING: Failed %ld", (long)identifier);
    [self.processing removeIdentifier:identifier];
}

- (void)menuSortBy
{
    NSArray<NSString *> *orders = [WaypointSorter listSortOrders];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"listtemplateviewcontroller-Sort by")
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    for (NSInteger i = 0; i < SORTORDERLIST_MAX; i++) {
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:[orders objectAtIndex:i]
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     self.currentSortOrder = i;
                                     self.waypoints = [NSMutableArray arrayWithArray:[WaypointSorter resortWaypoints:self.waypoints listSortOrder:self.currentSortOrder flag:self.flag]];
                                     [self.tableView reloadData];
                                 }];
        [alert addAction:action];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuClearFlags:
            [self menuClearFlags];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
        case menuExportGPX:
            [ExportGPX exports:self.waypoints];
            [MyTools messageBox:self header:_(@"listtemplateviewcontroller-Export successful") text:_(@"listtemplateviewcontroller-The exported file can be found in the Files section")];
            return;
        case menuSortBy:
            [self menuSortBy];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
