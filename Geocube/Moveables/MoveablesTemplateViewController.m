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

@interface MoveablesTemplateViewController ()

@end

@implementation MoveablesTemplateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerNib:[UINib nibWithNibName:XIB_LOCATIONLESSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_LOCATIONLESSTABLEVIEWCELL];

    [self loadWaypoints];
}

- NEEDS_OVERLOADING_VOID(loadWaypoints)

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.waypoints count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%ld %@", (long)[self.waypoints count], _(@"moveablestemplateviewcontroller-moveables")];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationlessTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_LOCATIONLESSTABLEVIEWCELL forIndexPath:indexPath];

    dbWaypoint *wp = [self.waypoints objectAtIndex:indexPath.row];
    cell.icon.image = [imageManager getType:wp];
    cell.name.text = wp.wpt_urlname;
    cell.owner.text = wp.gs_owner.name;
    cell.code.text = wp.wpt_name;
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:wp.wpt_name];
    cell.note.text = pn.note;

    return cell;
}

@end
