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

- (void)showWaypoint:(dbWaypoint *)_wp
{
    waypoint = _wp;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[CacheHeaderTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL_DATA];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL_ACTIONS];

    waypointItems = @[@"Description", @"Hint", @"Personal Note", @"Field Note", @"Logs", @"Attributes", @"Related Waypoints", @"Inventory", @"Images", @"Group Members"];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    l.text = waypoint.description;
    l.font = [UIFont boldSystemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:l];

    l = [[UILabel alloc] initWithFrame:CGRectMake (0, 15, width, 10)];
    NSMutableString *s = [NSMutableString stringWithString:@""];
    if ([waypoint.groundspeak.placed_by_str compare:@""] != NSOrderedSame)
        [s appendFormat:@"by %@", waypoint.groundspeak.placed_by_str];
    if ([waypoint.date_placed compare:@""] != NSOrderedSame)
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
        [cell setRatings:waypoint.groundspeak.favourites terrain:waypoint.groundspeak.rating_terrain difficulty:waypoint.groundspeak.rating_difficulty];

        cell.size.image = [imageLibrary get:waypoint.groundspeak.container.icon];
        cell.icon.image = [imageLibrary get:waypoint.type.icon];
        return cell;
    }

    // Cache data
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_DATA forIndexPath:indexPath];
        cell.textLabel.text = [waypointItems objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0: /* Description */
                if ([waypoint.groundspeak.short_desc compare:@""] == NSOrderedSame && [waypoint.groundspeak.long_desc compare:@""] == NSOrderedSame && [waypoint.description compare:@""] == NSOrderedSame) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 1: /* Hint */
                //                if (waypoint.groundspeak.hint ==b nil || [waypoint.groundspeak.hint compare:@""] == NSOrderedSame)
                if ([waypoint.groundspeak.hint compare:@""] == NSOrderedSame || [waypoint.groundspeak.hint compare:@" "] == NSOrderedSame) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 2: /* Personal note */
                if ([waypoint.groundspeak.personal_note compare:@""] == NSOrderedSame) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 3: /* Field Note */
                if ([waypoint hasFieldNotes] == FALSE) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                }
                break;
            case 4: { /* Logs */
                NSInteger c = [waypoint hasLogs];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
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
                NSInteger c = [waypoint hasWaypoints];
                if (c == 0) {
                    tc = [UIColor lightGrayColor];
                    cell.userInteractionEnabled = NO;
                } else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [waypointItems objectAtIndex:indexPath.row], (long)c];
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
        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageLibrary get:ImageIcon_Target];
                break;
            case 1:
                cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
                break;
        }
        cell.textLabel.text = [actionItems objectAtIndex:indexPath.row];
        cell.textLabel.textColor = tc;
        cell.accessoryType = UITableViewCellAccessoryNone;
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
        if (indexPath.row == 7) {    /* Groups */
            UITableViewController *newController = [[CacheTravelbugsViewController alloc] init:waypoint];
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
            currentWaypoint = waypoint;

            UITabBarController *tb = [_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE];
            UINavigationController *nvc = [[tb viewControllers] objectAtIndex:VC_NAVIGATE_TARGET];
            CacheViewController *cvc = [nvc.viewControllers objectAtIndex:0];
            [cvc showWaypoint:currentWaypoint];

            nvc = [[tb viewControllers] objectAtIndex:VC_NAVIGATE_MAP_GMAP];
            MapGoogleViewController *mgv = [nvc.viewControllers objectAtIndex:0];
            [mgv refreshWaypointsData];

            nvc = [[tb viewControllers] objectAtIndex:VC_NAVIGATE_MAP_AMAP];
            MapAppleViewController *mav = [nvc.viewControllers objectAtIndex:0];
            [mav refreshWaypointsData];

            nvc = [[tb viewControllers] objectAtIndex:VC_NAVIGATE_MAP_OSM];
            MapOSMViewController *mov = [nvc.viewControllers objectAtIndex:0];
            [mov refreshWaypointsData];

            [_AppDelegate switchController:RC_NAVIGATE];
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

@end
