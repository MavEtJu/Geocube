/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface MoveablesListViewController ()

@end

@implementation MoveablesListViewController

- (void)loadWaypoints
{
    if (configManager.moveablesShowFound == YES)
        self.waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllMoveables]];
    else
        self.waypoints = [NSMutableArray arrayWithArray:[dbWaypoint dbAllMoveablesNotFound]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];

        dbMoveableInventory *mi = [[dbMoveableInventory alloc] init];
        mi.waypoint = wp;
        [mi dbCreate];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _(@"moveableslistviewcontroller-Grab");
}

@end
