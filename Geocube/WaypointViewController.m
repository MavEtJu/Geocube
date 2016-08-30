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

@interface WaypointViewController ()
{
    dbWaypoint *waypoint;

    WaypointHeaderTableViewCell *headerCell;
    NSInteger headerCellHeight;
}

@end

enum {
    WAYPOINT_HEADER,
    WAYPOINT_DATA,
    WAYPOINT_ACTIONS,
    WAYPOINT_MAX,

    WAYPOINT_HEADER_WAYPOINT = 0,
    WAYPOINT_HEADER_MAX,

    WAYPOINT_DATA_DESCRIPTION = 0,
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

#define THISCELL_HEADER @"Waypointtablecell_header"
#define THISCELL_DATA @"Waypointtablecell_data"
#define THISCELL_ACTIONS @"Waypointtablecell_actions"

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

- (instancetype)initWithStyle:(UITableViewStyle)style canBeClosed:(BOOL)canBeClosed
{
    self = [super initWithStyle:style];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuMarkAs label:@"Mark as..."];
    [lmi addItem:menuRefreshWaypoint label:@"Refresh waypoint"];
    [lmi addItem:menuAddToGroup label:@"Add to group"];
    [lmi addItem:menuViewRaw label:@"Raw data"];
    [lmi addItem:menuSetAsTarget label:@"Set target"];
    [lmi addItem:menuLogThisWaypoint label:@"Log waypoint"];
    [lmi addItem:menuOpenInBrowser label:@"Open browser"];
    [lmi addItem:menuExportGPX label:@"Export GPX"];
    [lmi addItem:menuDeleteWaypoint label:@"Delete waypoint"];

    hasCloseButton = canBeClosed;

    headerCell = nil;

    return self;
}

- (void)showWaypoint:(dbWaypoint *)_wp
{
    waypoint = _wp;
    headerCell = nil;
    headerCellHeight = 55;

    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    // Restore
    if (hasCloseButton == NO)
        [self showWaypoint:waypointManager.currentWaypoint];

    [self.tableView registerClass:[WaypointHeaderTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_DATA];
    [self.tableView registerClass:[GCTableViewCellRightImage class] forCellReuseIdentifier:THISCELL_ACTIONS];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([waypoint.account canDoRemoteStuff] == NO)
        [lmi disableItem:menuRefreshWaypoint];
    else
        [lmi enableItem:menuRefreshWaypoint];

    if (waypoint == waypointManager.currentWaypoint)
        [lmi disableItem:menuSetAsTarget];
    else
        [lmi enableItem:menuSetAsTarget];
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
                                                headerCell = nil;
                                                [self.tableView reloadData];
                                                [self viewWillTransitionToSize];
                                            }
                                 completion:nil
     ];
}

#pragma mark - Delegates

-  (void)WaypointImages_refreshTable
{
    [self.tableView reloadData];
}

-  (void)WaypointPersonalNote_refreshTable
{
    [self.tableView reloadData];
}

-  (void)WaypointLog_refreshTable
{
    [self.tableView reloadData];
}

-  (void)WaypointWaypoints_refreshTable
{
    [self.tableView reloadData];
}

-  (void)WaypointLog_refreshWaypointData
{
    [self performSelectorInBackground:@selector(runRefreshWaypoint) withObject:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (waypoint == nil)
        return 0;
    return WAYPOINT_MAX;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (waypoint == nil)
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
            return @"Waypoint data";
        case WAYPOINT_ACTIONS:
            return @"Waypoint actions";
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != WAYPOINT_HEADER)
        return [super tableView:tableView viewForHeaderInSection:section];

    NSInteger width = tableView.bounds.size.width;
    NSInteger y = 2;

    GCView *headerView = [[GCView alloc] initWithFrame:CGRectMake(0, 0, width, 35)];
    GCLabel *l;

    UIColor *backgroundColor = [UIColor clearColor];
    if (waypoint.flag_highlight == YES)
       backgroundColor = [UIColor yellowColor];

    l = [[GCLabel alloc] initWithFrame:CGRectZero];
    l.text = waypoint.wpt_urlname;
    l.font = [UIFont boldSystemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = backgroundColor;
    l.frame = CGRectMake(0, y, width, l.font.lineHeight);
    [headerView addSubview:l];
    y += l.font.lineHeight;

    l = [[GCLabel alloc] initWithFrame:CGRectZero];
    NSMutableString *s = [NSMutableString stringWithString:@""];
    if (waypoint.gs_owner_str != nil && [waypoint.gs_owner_str isEqualToString:@""] == NO)
        [s appendFormat:@"by %@", waypoint.gs_owner_str];
    if ([waypoint.wpt_date_placed isEqualToString:@""] == NO)
        [s appendFormat:@" on %@", [MyTools dateTimeString_YYYY_MM_DD:waypoint.wpt_date_placed_epoch]];
    l.text = s;
    l.font = [UIFont systemFontOfSize:10];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = backgroundColor;
    l.frame = CGRectMake(0, y, width, l.font.lineHeight);
    [headerView addSubview:l];
    y += l.font.lineHeight;

    l = [[GCLabel alloc] initWithFrame:CGRectZero];
    l.text = [NSString stringWithFormat:@"%@ (%@)", waypoint.wpt_name, waypoint.account.site];
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = backgroundColor;
    l.frame = CGRectMake(0, y, width, l.font.lineHeight);
    [headerView addSubview:l];
    y += l.font.lineHeight;

    l = [[GCLabel alloc] initWithFrame:CGRectZero];
    l.text = [NSString stringWithFormat:@"Last imported on %@", [MyTools dateTimeString_YYYY_MM_DD:waypoint.date_lastimport_epoch]];
    l.font = [UIFont systemFontOfSize:10];
    l.textAlignment = NSTextAlignmentCenter;
    l.backgroundColor = backgroundColor;
    l.frame = CGRectMake(0, y, width, l.font.lineHeight);
    [headerView addSubview:l];
    y += l.font.lineHeight;

    y += 2;
    headerCellHeight = y;

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == WAYPOINT_HEADER)
        return headerCellHeight;
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case WAYPOINT_HEADER: {
            if (headerCell == nil)
                headerCell = [[WaypointHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_HEADER];

            headerCell.accessoryType = UITableViewCellAccessoryNone;
            Coordinates *c = [[Coordinates alloc] init:waypoint.wpt_lat_float lon:waypoint.wpt_lon_float];
            headerCell.lat.text = [c lat_degreesDecimalMinutes];
            headerCell.lon.text = [c lon_degreesDecimalMinutes];
            [headerCell setRatings:waypoint.gs_favourites terrain:waypoint.gs_rating_terrain difficulty:waypoint.gs_rating_difficulty];

            NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:waypoint.coordinates];
            headerCell.beardis.text = [NSString stringWithFormat:@"%ldº (%@) at %@",
                                       (long)[Coordinates coordinates2bearing:LM.coords to:waypoint.coordinates],
                                       [Coordinates bearing2compass:bearing],
                                       [MyTools niceDistance:[Coordinates coordinates2distance:waypoint.coordinates to:LM.coords]]];
            headerCell.location.text = [waypoint makeLocaleStateCountry];

            headerCell.userInteractionEnabled = NO;
            if (waypoint.gs_container != nil)
                headerCell.size.image = [imageLibrary get:waypoint.gs_container.icon];
            else
                headerCell.size.image = nil;
            headerCell.icon.image = [imageLibrary getType:waypoint];

            return headerCell;
        }

        case WAYPOINT_DATA: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_DATA forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;

            UIColor *tc = currentTheme.textColor;
            switch (indexPath.row) {

               case WAYPOINT_DATA_DESCRIPTION:
                    cell.textLabel.text = @"Description";
                    if ([waypoint.gs_short_desc isEqualToString:@""] == YES && [waypoint.gs_long_desc isEqualToString:@""] == YES && [waypoint.description isEqualToString:@""] == YES) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    }
                    break;

                case WAYPOINT_DATA_HINT:
                    cell.textLabel.text = @"Hint";
                    if (waypoint.gs_hint == nil || [waypoint.gs_hint isEqualToString:@""] == YES || [waypoint.gs_hint isEqualToString:@" "] == YES) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    }
                    break;

                case WAYPOINT_DATA_PERSONALNOTE:
                    cell.textLabel.text = @"Personal Note";
                    if ([dbPersonalNote dbGetByWaypointName:waypoint.wpt_name] == nil)
                        tc = currentTheme.labelTextColorDisabled;
                    // Do not disable this one as you want to be able to create one.
                    break;

                case WAYPOINT_DATA_FIELDNOTES: {
                    cell.textLabel.text = @"Field Notes";
                    NSInteger c = [waypoint hasFieldNotes];
                    if (c == 0) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", cell.textLabel.text, (long)c];
                    break;
                }

                case WAYPOINT_DATA_LOGS: {
                    cell.textLabel.text = @"Logs";
                    NSInteger c = [waypoint hasLogs];
                    if (c == 0) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else {
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", cell.textLabel.text, (long)c];
                    }
                    break;
                }

                case WAYPOINT_DATA_ATTRIBUTES: {
                    cell.textLabel.text = @"Attributes";
                    NSInteger c = [waypoint hasAttributes];
                    if (c == 0) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", cell.textLabel.text, (long)c];
                    break;
                }

                case WAYPOINT_DATA_ADDITIONALWAYPOINTS: {
                    cell.textLabel.text = @"Additional Waypoints";
                    NSArray *wps = [waypoint hasWaypoints];
                    if ([wps count] <= 1) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = YES;     // Be able to create one
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", cell.textLabel.text, (long)([wps count] - 1)];
                    break;
                }

                case WAYPOINT_DATA_INVENTORY: {
                    cell.textLabel.text = @"Inventory";
                    NSInteger c = [waypoint hasInventory];
                    if (c == 0) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = NO;
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", cell.textLabel.text, (long)c];
                    break;
                }

                case WAYPOINT_DATA_IMAGES: {
                    cell.textLabel.text = @"Images";
                    NSInteger c = [waypoint hasImages];
                    if (c == 0) {
                        tc = currentTheme.labelTextColorDisabled;
                        cell.userInteractionEnabled = YES;  // Be able to create one
                    } else
                        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)",cell.textLabel.text, (long)c];
                    break;
                }

                case WAYPOINT_DATA_GROUPMEMBERS:
                    cell.textLabel.text = @"Group Members";
                    break;
            }
            cell.textLabel.textColor = tc;
            cell.imageView.image = nil;
            return cell;

        }

        case WAYPOINT_ACTIONS:
            switch (indexPath.row) {
                case WAYPOINT_ACTIONS_SETASTARGET: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_ACTIONS forIndexPath:indexPath];
                    cell.userInteractionEnabled = YES;
                    cell.imageView.image = [imageLibrary get:ImageIcon_Target];
                    if (waypoint == waypointManager.currentWaypoint) {
                        cell.textLabel.text = @"Remove as target";
                    } else {
                        cell.textLabel.text = @"Set as target";
                    }
                    return cell;
                }

                case WAYPOINT_ACTIONS_LOGTHISWAYPOINT: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_ACTIONS forIndexPath:indexPath];
                    cell.userInteractionEnabled = YES;
                    cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
                    cell.textLabel.text = @"Log this waypoint";
                    return cell;
                }

                case WAYPOINT_ACTIONS_OPENINBROWSER: {
                    GCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_DATA forIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.userInteractionEnabled = YES;

                    if (waypoint.wpt_url == nil)
                        cell.userInteractionEnabled = NO;

                    cell.textLabel.text = @"Open in browser";
                    return cell;
                }

            }
    }

    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case WAYPOINT_HEADER:
            return;

        case WAYPOINT_DATA:
            switch (indexPath.row) {
                case WAYPOINT_DATA_DESCRIPTION: {
                    UIViewController *newController = [[WaypointDescriptionViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_HINT: {
                    UIViewController *newController = [[WaypointHintViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_PERSONALNOTE: {
                    WaypointPersonalNoteViewController *newController = [[WaypointPersonalNoteViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_FIELDNOTES: {
                    UITableViewController *newController = [[WaypointLogsViewController alloc] initMine:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_LOGS: {
                    UITableViewController *newController = [[WaypointLogsViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_ATTRIBUTES: {
                    UITableViewController *newController = [[WaypointAttributesViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_ADDITIONALWAYPOINTS: {
                    WaypointWaypointsViewController *newController = [[WaypointWaypointsViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_INVENTORY: {
                    UITableViewController *newController = [[WaypointTrackablesViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_IMAGES: {
                    WaypointImagesViewController *newController = [[WaypointImagesViewController alloc] init:waypoint];
                    newController.edgesForExtendedLayout = UIRectEdgeNone;
                    newController.delegateWaypoint = self;
                    [self.navigationController pushViewController:newController animated:YES];
                    return;
                }

                case WAYPOINT_DATA_GROUPMEMBERS: {
                    UITableViewController *newController = [[WaypointGroupsViewController alloc] init:waypoint];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == WAYPOINT_HEADER)
        return [headerCell cellHeight];
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuRefreshWaypoint: // Refresh waypoint from server
            [self performSelectorInBackground:@selector(runRefreshWaypoint) withObject:nil];
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
            [ExportGPX export:waypoint];
            [MyTools messageBox:self header:@"Export successful" text:@"The exported file can be found in the Files section"];
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
    [browserViewController loadURL:waypoint.wpt_url];
}

- (void)menuLogThisWaypoint
{
    WaypointLogViewController *newController = [[WaypointLogViewController alloc] init:waypoint];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.delegateWaypoint = self;
    [self.navigationController pushViewController:newController animated:YES];
}

- (void)menuSetAsTarget
{
    if ([waypointManager currentWaypoint] != nil &&
        [[waypointManager currentWaypoint].wpt_name isEqualToString:waypoint.wpt_name] == YES) {
        [waypointManager setCurrentWaypoint:nil];
        [self showWaypoint:nil];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [waypointManager setCurrentWaypoint:waypoint];
    [self.tableView reloadData];

    MHTabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
    UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
    WaypointViewController *cvc = [nvc.viewControllers objectAtIndex:0];
    [cvc showWaypoint:waypointManager.currentWaypoint];

    nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP];
    MapViewController *mvc = [nvc.viewControllers objectAtIndex:0];
    [mvc refreshWaypointsData];

    [_AppDelegate switchController:RC_NAVIGATE];
    [tb setSelectedIndex:VC_NAVIGATE_COMPASS animated:YES];
}

- (void)menuDeleteWaypoint
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Delete waypoint"
                               message:@"Are you sure?"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *yes = [UIAlertAction
                          actionWithTitle:@"Yes"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction *action) {
                              [waypoint dbDelete];
                              [db cleanupAfterDelete];
                              [waypointManager needsRefresh];
                              [self.navigationController popViewControllerAnimated:YES];
                          }];

    UIAlertAction *no = [UIAlertAction
                         actionWithTitle:@"NO!" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:yes];
    [alert addAction:no];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuMarkAs
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Waypoint flags"
                               message:@"Mark as..."
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *dnf = [UIAlertAction
                          actionWithTitle:(waypoint.flag_dnf == YES) ? @"Remove mark as DNF" : @"Mark as DNF"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction *action) {
                              if (waypoint.flag_dnf)
                                  [self addLog:@"Unmarked as DNF"];
                              else
                                  [self addLog:@"Marked as DNF"];
                              waypoint.flag_dnf = !waypoint.flag_dnf;
                              [waypoint dbUpdateMarkedDNF];
                              [waypointManager needsRefresh];
                              if (waypoint.flag_dnf == YES && waypoint == waypointManager.currentWaypoint)
                                  [waypointManager setCurrentWaypoint:nil];
                              [self.tableView reloadData];
                          }];
    UIAlertAction *found = [UIAlertAction
                            actionWithTitle:(waypoint.flag_markedfound == YES) ? @"Remove mark as Found" : @"Mark as Found"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction *action) {
                                if (waypoint.flag_markedfound)
                                    [self addLog:@"Unmarked as Found"];
                                else
                                    [self addLog:@"Marked as Found"];
                                waypoint.flag_markedfound = !waypoint.flag_markedfound;
                                [waypoint dbUpdateMarkedFound];
                                if (waypoint.flag_markedfound == YES && waypoint == waypointManager.currentWaypoint)
                                    [waypointManager setCurrentWaypoint:nil];

                                if (waypoint.flag_markedfound == YES) {
                                    NSArray *wps = [waypoint hasWaypoints];
                                    [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                                        if (wp._id == waypoint._id)
                                            return;
                                        wp.flag_markedfound = YES;
                                        [wp dbUpdateMarkedFound];
                                        if (waypoint == waypointManager.currentWaypoint)
                                            [waypointManager setCurrentWaypoint:nil];
                                    }];
                                }

                                [waypointManager needsRefresh];
                                [self.tableView reloadData];
                            }];
    UIAlertAction *ignore = [UIAlertAction
                             actionWithTitle:(waypoint.flag_ignore == YES) ? @"Remove mark as Ignored" : @"Mark as Ignored"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 if (waypoint.flag_ignore)
                                     [self addLog:@"Unmarked as Ignored"];
                                 else
                                     [self addLog:@"Marked as Ignored"];
                                 waypoint.flag_ignore = !waypoint.flag_ignore;
                                 [waypoint dbUpdateIgnore];
                                 [waypointManager needsRefresh];
                                 [self.tableView reloadData];

                                 if (waypoint.flag_ignore == YES) {
                                     [[dbc Group_AllWaypoints_Ignored] dbAddWaypoint:waypoint._id];
                                 } else {
                                     [[dbc Group_AllWaypoints_Ignored] dbRemoveWaypoint:waypoint._id];
                                 }
                             }];
    UIAlertAction *inprogress = [UIAlertAction
                                 actionWithTitle:(waypoint.flag_inprogress == YES) ? @"Remove mark as In Progress" : @"Mark as In Progress"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     if (waypoint.flag_inprogress)
                                         [self addLog:@"Unmarked as In Progress"];
                                     else
                                         [self addLog:@"Marked as In Progress"];
                                     waypoint.flag_inprogress = !waypoint.flag_inprogress;
                                     [waypoint dbUpdateInProgress];
                                     [waypointManager needsRefresh];
                                     [self.tableView reloadData];
                                 }];
    UIAlertAction *highlight = [UIAlertAction
                                actionWithTitle:(waypoint.flag_highlight == YES) ? @"Remove mark as highlighted" : @"Mark as Highlighted"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    if (waypoint.flag_highlight)
                                        [self addLog:@"Unmarked as Highlighted"];
                                    else
                                        [self addLog:@"Marked as Highlighted"];
                                    waypoint.flag_highlight = !waypoint.flag_highlight;
                                    [waypoint dbUpdateHighlight];
                                    [waypointManager needsRefresh];
                                    [self.tableView reloadData];
                                }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:found];
    [alert addAction:dnf];
    [alert addAction:ignore];
    [alert addAction:inprogress];
    [alert addAction:highlight];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)addLog:(NSString *)text
{
    NSString *date = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss];
    NSInteger logtype = [dbLogString wptTypeToLogType:waypoint.wpt_type.type_full];
    dbLogString *logstring = [dbLogString dbGetByAccountLogtypeDefault:waypoint.account logtype:logtype default:LOGSTRING_DEFAULT_NOTE];

    [dbLog CreateLogNote:logstring waypoint:waypoint dateLogged:date note:text needstobelogged:NO];
}

- (void)addToGroup
{
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *groupNames = [NSMutableArray arrayWithCapacity:10];
    [[dbc Groups] enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == 0)
            return;
        [groupNames addObject:cg.name];
        [groups addObject:cg];
    }];

    [ActionSheetStringPicker showPickerWithTitle:@"Select a Group"
        rows:groupNames
        initialSelection:myConfig.lastAddedGroup
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            [myConfig lastAddedGroupUpdate:selectedIndex];
            dbGroup *group = [groups objectAtIndex:selectedIndex];
            [group dbRemoveWaypoint:waypoint._id];
            [group dbAddWaypoint:waypoint._id];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        }
        origin:self.tableView
    ];
}

- (void)runRefreshWaypoint
{
    [menuGlobal enableMenus:NO];
    [MHTabBarController enableMenus:NO controllerFrom:self];

    [downloadManager setBezelViewController:self];
    [downloadManager setBezelViewText:[NSString stringWithFormat:@"Updating %@", waypoint.wpt_name]];
    NSInteger retValue = [waypoint.account.remoteAPI loadWaypoint:waypoint];
    [downloadManager setBezelViewController:nil];

    [menuGlobal enableMenus:YES];
    [MHTabBarController enableMenus:YES controllerFrom:self];

    if (retValue == REMOTEAPI_OK) {
        waypoint = [dbWaypoint dbGet:waypoint._id];
        [self reloadDataMainQueue];
        [MyTools playSound:PLAYSOUND_IMPORTCOMPLETE];
        return;
    }
    [MyTools messageBox:self header:@"Update failed" text:@"Unable to update the waypoint." error:waypoint.account.lastError];
}

- (void)menuViewRaw
{
    UIViewController *newController = [[WaypointRawViewController alloc] init:waypoint];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
}

@end
