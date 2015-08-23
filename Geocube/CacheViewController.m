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

#define THISCELL_HEADER @"cachetablecell_header"
#define THISCELL_DATA @"cachetablecell_data"
#define THISCELL_ACTIONS @"cachetablecell_actions"

@implementation CacheViewController

- initWithStyle:(UITableViewStyle)style canBeClosed:(BOOL)canBeClosed
{
    self = [super initWithStyle:style];

    menuItems = [NSMutableArray arrayWithArray:@[@"Add waypoint", @"Highlight"]];
    hasCloseButton = YES;

    return self;
}

- (void)showWaypoint:(dbWaypoint *)_wp
{
    if (_wp == nil) {
        waypoint = nil;
        groundspeak = nil;
    } else {
        waypoint = _wp;
        groundspeak = [dbGroundspeak dbGet:_wp.groundspeak_id];
        [groundspeak finish];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[CacheHeaderTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL_DATA];
    [self.tableView registerClass:[GCTableViewCellRightImage class] forCellReuseIdentifier:THISCELL_ACTIONS];

    waypointItems = @[@"Description", @"Hint", @"Personal Note", @"Field Notes", @"Logs", @"Attributes", @"Additional Waypoints", @"Inventory", @"Images", @"Group Members"];
    actionItems = @[@"Set as Target", @"Mark as Found"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (waypoint == nil)
        return 0;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (waypoint == nil)
        return 0;
    if (section == 0)
        return 1;
    if (section == 1)
        return [waypointItems count];
    if (section == 2)
        return [actionItems count];
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"Waypoint data";
    if (section == 2)
        return @"Waypoint actions";
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0)
        return nil;

    NSInteger width = tableView.bounds.size.width;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 35)];
    UILabel *l;

    l = [[UILabel alloc] initWithFrame:CGRectMake (0, 0, width, 14)];
    l.text = waypoint.urlname;
    l.font = [UIFont boldSystemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:l];

    l = [[UILabel alloc] initWithFrame:CGRectMake (0, 15, width, 10)];
    NSMutableString *s = [NSMutableString stringWithString:@""];
    if (groundspeak != nil && groundspeak.placed_by != nil && [groundspeak.placed_by isEqualToString:@""] == NO)
        [s appendFormat:@"by %@", groundspeak.placed_by];
    if ([waypoint.date_placed isEqualToString:@""] == NO)
        [s appendFormat:@" on %@", [MyTools datetimePartDate:waypoint.date_placed]];
    l.text = s;
    l.font = [UIFont systemFontOfSize:10];
    l.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:l];

    l = [[UILabel alloc] initWithFrame:CGRectMake (0, 25, width, 12)];
    l.text = waypoint.name;
    l.font = [UIFont systemFontOfSize:12];
    l.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:l];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 37;
    return [super tableView:tableView heightForHeaderInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Cache header
    if (indexPath.section == 0) {
        CacheHeaderTableViewCell *cell = [[CacheHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_HEADER];
        cell.accessoryType = UITableViewCellAccessoryNone;
        Coordinates *c = [[Coordinates alloc] init:waypoint.lat_float lon:waypoint.lon_float];
        cell.lat.text = [c lat_degreesDecimalMinutes];
        cell.lon.text = [c lon_degreesDecimalMinutes];
        [cell setRatings:groundspeak.favourites terrain:groundspeak.rating_terrain difficulty:groundspeak.rating_difficulty];

        cell.userInteractionEnabled = NO;
        cell.size.image = [imageLibrary get:groundspeak.container.icon];
        cell.icon.image = [imageLibrary get:waypoint.type.icon];

        [cell showGroundspeak:(groundspeak != nil)];
        return cell;
    }

    // Cache data
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_DATA forIndexPath:indexPath];
        if (cell == nil)
            cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_DATA];
        cell.textLabel.text = [waypointItems objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;

        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0: /* Description */
                if ([groundspeak.short_desc isEqualToString:@""] == YES && [groundspeak.long_desc isEqualToString:@""] == YES && [waypoint.description isEqualToString:@""] == YES) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 1: /* Hint */
                //                if (waypoint.groundspeak.hint ==b nil || [waypoint.groundspeak.hint isEqualToString:@""] == YES)
                if (groundspeak.hint == nil || [groundspeak.hint isEqualToString:@""] == YES || [groundspeak.hint isEqualToString:@" "] == YES) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 2: /* Personal note */
                if ([dbPersonalNote dbGetByWaypointID:waypoint._id] == nil) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = YES;     // Be able to create one
                }
                break;
            case 3: { /* Field Note */
                NSInteger c = [waypoint hasFieldNotes];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
                break;
            }
            case 4: { /* Logs */
                NSInteger c = [waypoint hasLogs];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
                }
                break;
            }
            case 5: { /* Attributes */
                NSInteger c = [waypoint hasAttributes];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
                break;
            }
            case 6: { /* Related Waypoints */
                NSArray *wps = [waypoint hasWaypoints];
                if ([wps count] <= 1) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)([wps count] - 1)];
                break;
            }
            case 7: { /* Inventory */
                NSInteger c = [waypoint hasInventory];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
                break;
            }
            case 8: { /* Images */
                NSInteger c = [waypoint hasImages];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
                break;
            }
        }
        cell.textLabel.textColor = tc;
        cell.imageView.image = nil;
        return cell;
    }

    // Cache commands
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_ACTIONS forIndexPath:indexPath];
        if (cell == nil)
            cell = [[GCTableViewCellRightImage alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_ACTIONS];
        cell.accessoryType = UITableViewCellAccessoryNone;

        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageLibrary get:ImageIcon_Target];
                if ([waypointManager currentWaypoint] != nil && [[waypointManager currentWaypoint].name isEqualToString:waypoint.name] == YES)
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                break;
            case 1:
                cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
                break;
        }
        cell.textLabel.text = [actionItems objectAtIndex:indexPath.row];
        cell.textLabel.textColor = tc;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {   /* Description */
            UIViewController *newController = [[CacheDescriptionViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 1) {   /* Hint */
            UIViewController *newController = [[CacheHintViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 2) {   /* Personal note */
            UIViewController *newController = [[CachePersonalNoteViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 3) {   /* Field Notes */
            UITableViewController *newController = [[CacheLogsViewController alloc] initMine:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 4) {   /* Logs */
            UITableViewController *newController = [[CacheLogsViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 5) {   /* Attributes */
            UITableViewController *newController = [[CacheAttributesViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 6) {    /* Waypoints */
            UITableViewController *newController = [[CacheWaypointsViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 7) {    /* Travelbugs */
            UITableViewController *newController = [[CacheTravelbugsViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 8) {    /* Images */
            UITableViewController *newController = [[CacheImagesViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 9) {    /* Groups */
            UITableViewController *newController = [[CacheGroupsViewController alloc] init:waypoint];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        return;
    }

    if (indexPath.section == 2) {
        if (indexPath.row == 0) {   /* Set a target */
            if ([waypointManager currentWaypoint] != nil &&
                [[waypointManager currentWaypoint].name isEqualToString:waypoint.name] == YES) {
                [waypointManager setCurrentWaypoint:nil];
                [self showWaypoint:nil];
                [self.tableView reloadData];
                return;
            }

            [waypointManager setCurrentWaypoint:waypoint];
            [self.tableView reloadData];

            BHTabsViewController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
            UINavigationController *nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_TARGET];
            CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];
            [cvc showWaypoint:waypointManager.currentWaypoint];

            nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP_GMAP];
            MapGoogleViewController *mgv = [nvc.viewControllers objectAtIndex:0];
            [mgv refreshWaypointsData];

            nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP_AMAP];
            MapAppleViewController *mav = [nvc.viewControllers objectAtIndex:0];
            [mav refreshWaypointsData];

            nvc = [tb.viewControllers objectAtIndex:VC_NAVIGATE_MAP_OSM];
            MapOSMViewController *mov = [nvc.viewControllers objectAtIndex:0];
            [mov refreshWaypointsData];

            [_AppDelegate switchController:RC_NAVIGATE];
            [tb makeTabViewCurrent:VC_NAVIGATE_COMPASS];
            return;
        }
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [CacheTableViewCell cellHeight];
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Add a waypoint
    switch (index) {
        case 0:
            [self newWaypoint];
            return;
        case 1:
            break;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)newWaypoint
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Add a related waypoint"
                               message:@"Add a related waypoint2"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *lat = tf.text;
                             NSLog(@"Lattitude '%@'", lat);

                             tf = [alert.textFields objectAtIndex:1];
                             NSString *lon = tf.text;
                             NSLog(@"Longitude '%@'", lon);

                             Coordinates *c;
                             c = [[Coordinates alloc] initString:lat lon:lon];

                             dbWaypoint *wp = [[dbWaypoint alloc] init:0];
                             wp.lat = [c lat_decimalDegreesSigned];
                             wp.lon = [c lon_decimalDegreesSigned];
                             wp.lat_int = [c lat] * 1000000;
                             wp.lon_int = [c lon] * 1000000;
                             wp.name = [dbWaypoint makeName:[waypoint.name substringFromIndex:2]];
                             wp.description = wp.name;
                             wp.date_placed_epoch = time(NULL);
                             wp.date_placed = [MyTools dateString:wp.date_placed_epoch];
                             wp.url = nil;
                             wp.urlname = wp.name;
                             wp.symbol_id = 1;
                             wp.type_id = [dbc Type_Unknown]._id;
                             [dbWaypoint dbCreate:wp];

                             [dbc.Group_AllWaypoints_ManuallyAdded dbAddWaypoint:wp._id];
                             [dbc.Group_AllWaypoints dbAddWaypoint:wp._id];

                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Lattitude (like S 12 34.567)";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Longitude (like E 23.45.678)";
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
