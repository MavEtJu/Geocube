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

#define TESTLOGJE
#undef TESTLOGJE

@interface WaypointViewController ()

@property (nonatomic, retain) dbWaypoint *waypoint;

@property (nonatomic, retain) WaypointHeaderTableViewCell *headerCell;
@property (nonatomic        ) NSInteger headerCellHeight;
@property (nonatomic        ) NSInteger chunksDownloaded;
@property (nonatomic        ) NSInteger chunksProcessed;

@end

enum {
    WAYPOINT_HEADER,
    WAYPOINT_DATA,
    WAYPOINT_ACTIONS,
    WAYPOINT_MAX,

    WAYPOINT_HEADER_WAYPOINT = 0,
    WAYPOINT_HEADER_MAX,

    WAYPOINT_DATA_DESCRIPTION = 0,
#ifdef TESTLOGJE
    WAYPOINT_DATA_LOGJE,
#endif
    WAYPOINT_DATA_HINT,
    WAYPOINT_DATA_PERSONALNOTE,
    WAYPOINT_DATA_FIELDNOTES,
    WAYPOINT_DATA_LOGS,
    WAYPOINT_DATA_ATTRIBUTES,
    WAYPOINT_DATA_ADDITIONALWAYPOINTS,
    WAYPOINT_DATA_INVENTORY,
    WAYPOINT_DATA_IMAGES,
    WAYPOINT_DATA_GROUPMEMBERS,
    WAYPOINT_DATA_MAX,

    WAYPOINT_ACTIONS_SETASTARGET = 0,
    WAYPOINT_ACTIONS_LOGTHISWAYPOINT,
    WAYPOINT_ACTIONS_OPENINBROWSER,
    WAYPOINT_ACTIONS_MAX,
};

@implementation WaypointViewController

enum {
    menuRefreshWaypoint = 0,
    menuMarkAs,
    menuSetAsTarget,
    menuLogThisWaypoint,
    menuOpenInBrowser,
    menuAddToGroup,
    menuViewRaw,
    menuExportGPX,
    menuDeleteWaypoint,
    menuMax
};

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuMarkAs label:_(@"waypointviewcontroller-Mark as")];
    [self.lmi addItem:menuRefreshWaypoint label:_(@"waypointviewcontroller-Refresh waypoint")];
    [self.lmi addItem:menuAddToGroup label:_(@"waypointviewcontroller-Add to group")];
    [self.lmi addItem:menuViewRaw label:_(@"waypointviewcontroller-Raw data")];
    [self.lmi addItem:menuSetAsTarget label:_(@"waypointviewcontroller-Set target")];
    [self.lmi addItem:menuLogThisWaypoint label:_(@"waypointviewcontroller-Log waypoint")];
    [self.lmi addItem:menuOpenInBrowser label:_(@"waypointviewcontroller-Open in browser")];
    [self.lmi addItem:menuExportGPX label:_(@"waypointviewcontroller-Export GPX")];
    [self.lmi addItem:menuDeleteWaypoint label:_(@"waypointviewcontroller-Delete waypoint")];

    self.hasCloseButton = NO;
    self.isLocationless = NO;

    self.headerCell = nil;

    return self;
}

- (void)showWaypoint:(dbWaypoint *)wp
{
    self.waypoint = wp;
    self.headerCell = nil;

    self.headerCellHeight = currentTheme.GCLabelNormalSizeFont.lineHeight + 3 * currentTheme.GCLabelSmallSizeFont.lineHeight;

    [self reloadDataMainQueue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    // Restore
    if (self.hasCloseButton == NO)
        [self showWaypoint:waypointManager.currentWaypoint];
    [self makeInfoView];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_WAYPOINTHEADERTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_WAYPOINTHEADERTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_WAYPOINTLOGSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_WAYPOINTLOGSTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLRIGHTIMAGEDISCLOSURE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGEDISCLOSURE];

    UINib *sectionHeaderNib = [UINib nibWithNibName:XIB_WAYPOINTHEADERHEADERVIEW bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:XIB_WAYPOINTHEADERHEADERVIEW];

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self.waypoint.account canDoRemoteStuff] == NO)
        [self.lmi disableItem:menuRefreshWaypoint];
    else
        [self.lmi enableItem:menuRefreshWaypoint];

    if (self.waypoint == waypointManager.currentWaypoint)
        [self.lmi disableItem:menuSetAsTarget];
    else
        [self.lmi enableItem:menuSetAsTarget];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                                self.headerCell = nil;
                                                [self reloadDataMainQueue];
                                                [self viewWillTransitionToSize];
                                            }
                                 completion:nil
     ];
}

#pragma mark - Delegates

-  (void)WaypointImages_refreshTable
{
    [self reloadDataMainQueue];
}

-  (void)waypointPersonalNoteRefreshTable
{
    [self reloadDataMainQueue];
}

-  (void)WaypointLog_refreshTable
{
    [self reloadDataMainQueue];
}

-  (void)WaypointWaypoints_refreshTable
{
    [self reloadDataMainQueue];
}

-  (void)WaypointLogs_refreshTable
{
    [self reloadDataMainQueue];
}

-  (void)WaypointDescription_refreshTable
{
    [self reloadDataMainQueue];
}

-  (void)WaypointLog_refreshWaypointData
{
    BACKGROUND(runRefreshWaypoint, nil);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.waypoint == nil)
        return 0;
    return WAYPOINT_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.waypoint == nil)
        return 0;
    switch (section) {
        case WAYPOINT_HEADER:
            return WAYPOINT_HEADER_MAX;
        case WAYPOINT_DATA:
            return WAYPOINT_DATA_MAX;
        case WAYPOINT_ACTIONS:
            return WAYPOINT_ACTIONS_MAX;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case WAYPOINT_DATA:
            return _(@"waypointviewcontroller-Waypoint data");
        case WAYPOINT_ACTIONS:
            return _(@"waypointviewcontroller-Waypoint actions");
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != WAYPOINT_HEADER)
        return [super tableView:tableView viewForHeaderInSection:section];

    WaypointHeaderHeaderView *hv = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:XIB_WAYPOINTHEADERHEADERVIEW];
    [hv setWaypoint:self.waypoint];
    return hv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == WAYPOINT_HEADER)
        return self.headerCellHeight;
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case WAYPOINT_HEADER: {
            self.headerCell = [self.tableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTHEADERTABLEVIEWCELL];

            self.headerCell.accessoryType = UITableViewCellAccessoryNone;
            [self.headerCell setWaypoint:self.waypoint];
            self.headerCell.userInteractionEnabled = NO;

            return self.headerCell;
        }

        case WAYPOINT_DATA: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;

            UIColor *tc = currentTheme.labelTextColor;
            switch (indexPath.row) {
#ifdef TESTLOGJE
                case WAYPOINT_DATA_LOGJE:
                    cell.textLabel.text = @"Logje";
                    break;
#endif

               case WAYPOINT_DATA_DESCRIPTION:
                    cell.textLabel.text = _(@"waypointviewcontroller-Description");
                    if ([self.waypoint.gs_short_desc isEqualToString:@""] == YES && [self.waypoint.gs_long_desc isEqualToString:@""] == YES && [self.waypoint.description isEqualToString:@""] == YES) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    }
                    break;

                case WAYPOINT_DATA_HINT:
                    cell.textLabel.text = _(@"waypointviewcontroller-Hint");
                    if (IS_EMPTY(self.waypoint.gs_hint) == YES || [self.waypoint.gs_hint isEqualToString:@" "] == YES) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    }
                    break;

                case WAYPOINT_DATA_PERSONALNOTE: {
                    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:self.waypoint.wpt_name];
                    if (pn == 0)
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", _(@"waypointviewcontroller-Personal note"), _(@"waypointviewcontroller-None yet")];
                    else {
                        NSArray<NSString *> *words = [pn.note componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld %@)", _(@"waypointviewcontroller-Personal note"), (long)[words count], [words count] == 1 ? _(@"waypointviewcontroller-Word") : _(@"waypointviewcontroller-Words")];
                    }
                    break;
                }

#define IMAGE(__idx__) \
    if ([logs count] > __idx__) { \
        dbLog *log = [logs objectAtIndex:__idx__]; \
        cell.image ## __idx__.image = [imageManager get:log.logstring.icon]; \
    }
                case WAYPOINT_DATA_FIELDNOTES: {
                    WaypointLogsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTLOGSTABLEVIEWCELL forIndexPath:indexPath];
                    cell.logs.text = _(@"waypointviewcontroller-Field notes");
                    cell.userInteractionEnabled = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    cell.image0.image = [imageManager get:ImageLog_Empty];
                    cell.image1.image = [imageManager get:ImageLog_Empty];
                    cell.image2.image = [imageManager get:ImageLog_Empty];
                    cell.image3.image = [imageManager get:ImageLog_Empty];
                    cell.image4.image = [imageManager get:ImageLog_Empty];
                    cell.image5.image = [imageManager get:ImageLog_Empty];

                    NSInteger c = [self.waypoint hasFieldNotes];
                    if (c == 0) {
                        cell.logs.textColor = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;

                    } else {
                        NSArray<dbLog *> *logs = [dbLog dbLast7ByWaypointLogged:self.waypoint];
                        IMAGE(0);
                        IMAGE(1);
                        IMAGE(2);
                        IMAGE(3);
                        IMAGE(4);
                        IMAGE(5);

                        cell.logs.text = [NSString stringWithFormat:@"%@ (%ld)", cell.logs.text, (long)c];
                    }

                    return cell;
                }

                case WAYPOINT_DATA_LOGS: {
                    WaypointLogsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_WAYPOINTLOGSTABLEVIEWCELL forIndexPath:indexPath];
                    cell.userInteractionEnabled = YES;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    cell.image0.image = [imageManager get:ImageLog_Empty];
                    cell.image1.image = [imageManager get:ImageLog_Empty];
                    cell.image2.image = [imageManager get:ImageLog_Empty];
                    cell.image3.image = [imageManager get:ImageLog_Empty];
                    cell.image4.image = [imageManager get:ImageLog_Empty];
                    cell.image5.image = [imageManager get:ImageLog_Empty];

                    NSInteger c = [self.waypoint hasLogs];
                    if (c == 0) {
                        cell.logs.text = _(@"waypointviewcontroller-Logs");
                        cell.logs.textColor = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else {
                        cell.logs.text = [NSString stringWithFormat:@"%@ (%ld)", _(@"waypointviewcontroller-Logs"), (long)c];

                        NSArray<dbLog *> *logs = [dbLog dbLast7ByWaypoint:self.waypoint];
#define IMAGE(__idx__) \
    if ([logs count] > __idx__) { \
        dbLog *log = [logs objectAtIndex:__idx__]; \
        cell.image ## __idx__.image = [imageManager get:log.logstring.icon]; \
    }
                        IMAGE(0);
                        IMAGE(1);
                        IMAGE(2);
                        IMAGE(3);
                        IMAGE(4);
                        IMAGE(5);
                    }

                    return cell;
                }

                case WAYPOINT_DATA_ATTRIBUTES: {
                    NSInteger c = [self.waypoint hasAttributes];
                    if (c == 0) {
                        cell.textLabel.text = _(@"waypointviewcontroller-Attributes");
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", _(@"waypointviewcontroller-Attributes"), (long)c];
                    break;
                }

                case WAYPOINT_DATA_ADDITIONALWAYPOINTS: {

                    NSArray<dbWaypoint *> *wps = [self.waypoint hasWaypoints];
                    if ([wps count] > 1)
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", _(@"waypointviewcontroller-Waypoints"), (long)([wps count] - 1)];
                    else
                        cell.textLabel.text = _(@"waypointviewcontroller-Waypoints");
                    break;
                }

                case WAYPOINT_DATA_INVENTORY: {
                    NSInteger c = [self.waypoint hasInventory];
                    if (c == 0) {
                        cell.textLabel.text = _(@"waypointviewcontroller-Inventory");
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", _(@"waypointviewcontroller-Inventory"), (long)c];
                    break;
                }

                case WAYPOINT_DATA_IMAGES: {
                    NSInteger c = [self.waypoint hasImages];
                    if (c == 0)
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", _(@"waypointviewcontroller-Images"), _(@"waypointviewcontroller-None yet")];
                    else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", _(@"waypointviewcontroller-Images"), (long)c];
                    break;
                }

                case WAYPOINT_DATA_GROUPMEMBERS:
                    cell.textLabel.text = _(@"waypointviewcontroller-Group members");
                    break;
            }
            cell.textLabel.textColor = tc;
            cell.imageView.image = nil;
            return cell;

        }

        case WAYPOINT_ACTIONS:
            switch (indexPath.row) {
                case WAYPOINT_ACTIONS_SETASTARGET: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGEDISCLOSURE forIndexPath:indexPath];
                    cell.userInteractionEnabled = YES;
                    cell.imageView.image = [imageManager get:ImageIcon_Target];
                    if (self.waypoint == waypointManager.currentWaypoint) {
                        cell.textLabel.text = _(@"waypointviewcontroller-Remove as target");
                    } else {
                        cell.textLabel.text = _(@"waypointviewcontroller-Set as target");
                    }
                    return cell;
                }

                case WAYPOINT_ACTIONS_LOGTHISWAYPOINT: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLRIGHTIMAGEDISCLOSURE forIndexPath:indexPath];
                    cell.userInteractionEnabled = YES;
                    cell.imageView.image = [imageManager get:ImageIcon_Smiley];
                    cell.textLabel.text = _(@"waypointviewcontroller-Log this waypoint");
                    return cell;
                }

                case WAYPOINT_ACTIONS_OPENINBROWSER: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.userInteractionEnabled = YES;

                    if (self.waypoint.wpt_url == nil)
                        cell.userInteractionEnabled = NO;

                    cell.textLabel.text = _(@"waypointviewcontroller-Open in browser");
                    return cell;
                }

            }
    }

    // Not reached
    abort();
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case WAYPOINT_HEADER:
            return;

        case WAYPOINT_DATA:
            switch (indexPath.row) {
#ifdef TESTLOGJE
                case WAYPOINT_DATA_LOGJE:
                    [self menuLogjeThisWaypoint];
                    return;
#endif

                case WAYPOINT_DATA_DESCRIPTION: {
                    WaypointDescriptionViewController *newController = [[WaypointDescriptionViewController alloc] init:self.waypoint webview:YES];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_HINT: {
                    UIViewController *newController = [[WaypointHintViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_PERSONALNOTE: {
                    WaypointPersonalNoteViewController *newController = [[WaypointPersonalNoteViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_FIELDNOTES: {
                    UITableViewController *newController = [[WaypointLogsViewController alloc] initMine:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_LOGS: {
                    WaypointLogsViewController *newController = [[WaypointLogsViewController alloc] init:self.waypoint];
                    newController.delegateWaypoint = self;
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_ATTRIBUTES: {
                    UITableViewController *newController = [[WaypointAttributesViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_ADDITIONALWAYPOINTS: {
                    WaypointWaypointsViewController *newController = [[WaypointWaypointsViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_INVENTORY: {
                    UITableViewController *newController = [[WaypointTrackablesViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_IMAGES: {
                    WaypointImagesViewController *newController = [[WaypointImagesViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_GROUPMEMBERS: {
                    UITableViewController *newController = [[WaypointGroupsViewController alloc] init:self.waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }
            }
            return;

        case WAYPOINT_ACTIONS:
            switch (indexPath.row) {
                case WAYPOINT_ACTIONS_SETASTARGET:
                    [self menuSetAsTarget];
                    return;

                case WAYPOINT_ACTIONS_LOGTHISWAYPOINT:
                    [self menuLogThisWaypoint];
                    return;

                case WAYPOINT_ACTIONS_OPENINBROWSER:
                    [self menuOpenInBrowser];
                    return;
            }

            return;
    }
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuRefreshWaypoint: // Refresh waypoint from server
            BACKGROUND(runRefreshWaypoint, nil);
            return;
        case menuAddToGroup: // Add waypoint to a group
            [self addToGroup];
            return;
        case menuViewRaw:
            [self menuViewRaw];
            return;
        case menuMarkAs:
            [self menuMarkAs];
            return;
        case menuOpenInBrowser:
            [self menuOpenInBrowser];
            return;
        case menuLogThisWaypoint:
            [self menuLogThisWaypoint];
            return;
        case menuSetAsTarget:
            [self menuSetAsTarget];
            return;
        case menuExportGPX:
            [ExportGPX export:self.waypoint];
            [MyTools messageBox:self header:_(@"waypointviewcontroller-Export successful") text:_(@"waypointviewcontroller-The exported file can be found in the Files section.")];
            return;
        case menuDeleteWaypoint:
            [self menuDeleteWaypoint];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)menuOpenInBrowser
{
    [browserViewController showBrowser];
    [browserViewController loadURL:self.waypoint.wpt_url];
}

- (void)menuLogThisWaypoint
{
    WaypointLogViewController *newController = [[WaypointLogViewController alloc] init:self.waypoint];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegateWaypoint = self;
    [self.navigationController pushViewController:newController animated:YES];
}

#ifdef TESTLOGJE
- (void)menuLogjeThisWaypoint
{
    WaypointLogViewController *newController = [[WaypointLogViewController alloc] init:waypoint];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegateWaypoint = self;
    [newController fakeLog];
    [self.navigationController pushViewController:newController animated:YES];
}
#endif

- (void)menuSetAsTarget
{
    if ([waypointManager currentWaypoint] != nil &&
        [[waypointManager currentWaypoint].wpt_name isEqualToString:self.waypoint.wpt_name] == YES) {
        [waypointManager setTheCurrentWaypoint:nil];
        [self showWaypoint:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [waypointManager setTheCurrentWaypoint:self.waypoint];
    [self reloadDataMainQueue];

    MHTabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapTemplateViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb setSelectedIndex:VC_NAVIGATE_COMPASS animated:YES];
}

- (void)menuDeleteWaypoint
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointviewcontroller-Delete waypoint")
                                message:_(@"waypointviewcontroller-Are you sure?")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:_(@"Yes")
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction *action) {
                              [self.waypoint dbDelete];
                              [db cleanupAfterDelete];
                              [waypointManager needsRefreshRemove:self.waypoint];
                              [self.navigationController popViewControllerAnimated:YES];
                          }];

    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:_(@"NO!") style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:yes];
    [alert addAction:no];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuMarkAs
{
    NSString *title;
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointviewcontroller-Waypoint flags")
                                message:_(@"waypointviewcontroller-Mark as")
                                preferredStyle:UIAlertControllerStyleAlert];

#define TITLE(__flag__, __string__) \
    if (__flag__ == YES) \
        title = [NSString stringWithFormat:_(@"waypointviewcontroller-Remove mark as %@"), __string__]; \
    else \
        title = [NSString stringWithFormat:_(@"waypointviewcontroller-Mark as %@"), __string__];

    TITLE(self.waypoint.flag_dnf, _(@"waypointviewcontroller-DNF"))
    UIAlertAction *dnf = [UIAlertAction
                          actionWithTitle:title
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction *action) {
                              if (self.waypoint.flag_dnf)
                                  [self addLocalLog:_(@"waypointviewcontroller-Unmarked as DNF")];
                              else
                                  [self addLocalLog:_(@"waypointviewcontroller-Marked as DNF")];
                              self.waypoint.flag_dnf = !self.waypoint.flag_dnf;
                              [self.waypoint dbUpdateMarkedDNF];
                              [waypointManager needsRefreshUpdate:self.waypoint];
                              if (self.waypoint.flag_dnf == YES) {
                                  // Remove from the navigation sreen
                                  if (self.waypoint == waypointManager.currentWaypoint)
                                      [waypointManager setTheCurrentWaypoint:nil];

                                  // Add to log data
                                  [dbLogData addEntry:self.waypoint type:LOGDATATYPE_DNF datetime:time(NULL)];
                              }
                              [self.tableView reloadData];
                          }];
    TITLE(self.waypoint.flag_markedfound, _(@"waypointviewcontroller-Found"))
    UIAlertAction *found = [UIAlertAction
                            actionWithTitle:title
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                if (self.waypoint.flag_markedfound)
                                    [self addLocalLog:_(@"waypointviewcontroller-Unmarked as Found")];
                                else
                                    [self addLocalLog:_(@"waypointviewcontroller-Marked as Found")];
                                self.waypoint.flag_markedfound = !self.waypoint.flag_markedfound;
                                [self.waypoint dbUpdateMarkedFound];
                                if (self.waypoint.flag_markedfound == YES && self.waypoint == waypointManager.currentWaypoint)
                                    [waypointManager setTheCurrentWaypoint:nil];

                                if (self.waypoint.flag_markedfound == YES) {
                                    // Add to log data
                                    [dbLogData addEntry:self.waypoint type:LOGDATATYPE_FOUND datetime:time(NULL)];

                                    // Mark all related waypoints as found.
                                    NSArray<dbWaypoint *> *wps = [self.waypoint hasWaypoints];
                                    [wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
                                        if (wp._id == self.waypoint._id)
                                            return;
                                        wp.flag_markedfound = YES;
                                        [wp dbUpdateMarkedFound];
                                        if (self.waypoint == waypointManager.currentWaypoint)
                                            [waypointManager setTheCurrentWaypoint:nil];
                                    }];
                                }

                                [waypointManager needsRefreshUpdate:self.waypoint];
                                [self.tableView reloadData];
                            }];
    TITLE(self.waypoint.flag_ignore, _(@"waypointviewcontroller-Ignored"))
    UIAlertAction *ignore = [UIAlertAction
                             actionWithTitle:title
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 if (self.waypoint.flag_ignore)
                                     [self addLocalLog:_(@"waypointviewcontroller-Unmarked as Ignored")];
                                 else
                                     [self addLocalLog:_(@"waypointviewcontroller-Marked as Ignored")];
                                 self.waypoint.flag_ignore = !self.waypoint.flag_ignore;
                                 [self.waypoint dbUpdateIgnore];
                                 [waypointManager needsRefreshUpdate:self.waypoint];
                                 [self.tableView reloadData];

                                 if (self.waypoint.flag_ignore == YES) {
                                     [dbc.groupAllWaypointsIgnored addWaypointToGroup:self.waypoint];
                                 } else {
                                     [dbc.groupAllWaypointsIgnored removeWaypointFromGroup:self.waypoint];
                                 }
                             }];
    TITLE(self.waypoint.flag_inprogress, _(@"waypointviewcontroller-In progress"))
    UIAlertAction *inprogress = [UIAlertAction
                                 actionWithTitle:title
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     if (self.waypoint.flag_inprogress)
                                         [self addLocalLog:_(@"waypointviewcontroller-Unmarked as In Progress")];
                                     else
                                         [self addLocalLog:_(@"waypointviewcontroller-Marked as In Progress")];
                                     self.waypoint.flag_inprogress = !self.waypoint.flag_inprogress;
                                     [self.waypoint dbUpdateInProgress];
                                     [waypointManager needsRefreshUpdate:self.waypoint];
                                     [self.tableView reloadData];
                                 }];
    TITLE(self.waypoint.flag_highlight, _(@"waypointviewcontroller-Highlight"))
    UIAlertAction *highlight = [UIAlertAction
                                actionWithTitle:title
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    if (self.waypoint.flag_highlight)
                                        [self addLocalLog:_(@"waypointviewcontroller-Unmarked as Highlighted")];
                                    else
                                        [self addLocalLog:_(@"waypointviewcontroller-Marked as Highlighted")];
                                    self.waypoint.flag_highlight = !self.waypoint.flag_highlight;
                                    [self.waypoint dbUpdateHighlight];
                                    [waypointManager needsRefreshUpdate:self.waypoint];
                                    [self.tableView reloadData];
                                }];
    UIAlertAction *planned = nil;

    if (self.isLocationless == YES) {
        TITLE(self.waypoint.flag_planned, _(@"waypointviewcontroller-Planned"))
        planned = [UIAlertAction
                   actionWithTitle:title
                   style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction *action) {
                       if (self.waypoint.flag_planned == YES)
                           [self addLocalLog:_(@"waypointviewcontroller-Unmarked as Planned")];
                       else
                           [self addLocalLog:_(@"waypointviewcontroller-Marked as Planned")];
                       self.waypoint.flag_planned = !self.waypoint.flag_planned;
                       [self.waypoint dbUpdatePlanned];
                   }];
    }

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    if (self.isLocationless == YES)
        [alert addAction:planned];
    [alert addAction:found];
    [alert addAction:dnf];
    [alert addAction:ignore];
    [alert addAction:inprogress];
    [alert addAction:highlight];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)addLocalLog:(NSString *)text
{
    dbLogString *logstring = [dbLogString dbGetByProtocolWPTypeDefault:self.waypoint.account.protocol wptype:LOGSTRING_WPTYPE_LOCALLOG default:LOGSTRING_DEFAULT_NOTE];

    if (logstring == nil)
        return;
    [dbLog CreateLogNote:logstring waypoint:self.waypoint dateLogged:time(NULL) note:text needstobelogged:NO locallog:YES coordinates:LM.coords];
}

- (void)addToGroup
{
    NSMutableArray<dbGroup *> *groups = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray<NSString *> *groupNames = [NSMutableArray arrayWithCapacity:10];
    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull cg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cg.usergroup == 0)
            return;
        [groupNames addObject:cg.name];
        [groups addObject:cg];
    }];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:WAYPOINT_DATA_GROUPMEMBERS inSection:WAYPOINT_DATA]];

    [ActionSheetStringPicker showPickerWithTitle:_(@"waypointviewcontroller-Select a group")
        rows:groupNames
        initialSelection:configManager.lastAddedGroup
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [configManager lastAddedGroupUpdate:selectedIndex];
            dbGroup *group = [groups objectAtIndex:selectedIndex];
            [group removeWaypointFromGroup:self.waypoint];
            [group addWaypointToGroup:self.waypoint];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        }
        origin:cell.contentView
    ];
}

- (void)runRefreshWaypoint
{
    [self showInfoView];
    InfoItem *iid = [self.infoView addDownload];
    [iid changeDescription:[NSString stringWithFormat:_(@"waypointviewcontroller-Updating %@"), self.waypoint.wpt_name]];

    self.chunksDownloaded = 0;
    self.chunksProcessed = 0;
    NSInteger retValue = [self.waypoint.account.remoteAPI loadWaypoint:self.waypoint infoItem:iid identifier:0 callback:self];

    if (retValue != REMOTEAPI_OK)
        [MyTools messageBox:self header:_(@"waypointviewcontroller-Update failed") text:_(@"waypointviewcontroller-Unable to update the waypoint.") error:self.waypoint.account.remoteAPI.lastError];
}

- (void)remoteAPI_objectReadyToImport:(NSInteger)identifier infoItem:(InfoItem *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)account
{
    @synchronized(self) {
        self.chunksDownloaded++;
    }

    [importManager process:o group:group account:account options:IMPORTOPTION_NONE infoItem:iii];
    [iii removeFromInfoViewer];

    @synchronized(self) {
        self.chunksProcessed++;
    }
}

- (void)remoteAPI_finishedDownloads:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
    [NSThread sleepForTimeInterval:0.5];
    while (self.chunksProcessed != -1 && self.chunksProcessed != numberOfChunks) {
        [NSThread sleepForTimeInterval:0.1];
    }
    if (self.chunksProcessed == -1)
        return;

    [waypointManager needsRefreshUpdate:self.waypoint];
    self.waypoint = [dbWaypoint dbGet:self.waypoint._id];
    [self reloadDataMainQueue];
    [waypointManager needsRefreshUpdate:self.waypoint];
    [audioManager playSound:PLAYSOUND_IMPORTCOMPLETE];

    [self hideInfoView];
}

- (void)remoteAPI_failed:(NSInteger)identifier
{
    self.chunksProcessed = -1;
    // Nothing
}

- (void)menuViewRaw
{
    UIViewController *newController = [[WaypointRawViewController alloc] init:self.waypoint];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
}

@end
