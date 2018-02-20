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

@interface NotesImagesViewController ()

@property (nonatomic, retain) NSArray<dbWaypoint *> *waypointsWithImages;

@end

@implementation NotesImagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
    self.lmi = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.waypointsWithImages = [dbWaypoint dbAllWaypointsWithImages];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return [self.waypointsWithImages count];
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    dbWaypoint *wp = [self.waypointsWithImages objectAtIndex:section];
    return [dbImage dbCountByWaypoint:wp type:IMAGECATEGORY_USER];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    dbWaypoint *wp = [self.waypointsWithImages objectAtIndex:section];
    return [NSString stringWithFormat:@"%@ - %@", wp.wpt_name, wp.wpt_urlname];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [self.waypointsWithImages objectAtIndex:indexPath.section];
    NSArray<dbImage *> *imgs = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_USER];
    dbImage *img = [imgs objectAtIndex:indexPath.row];

    cell.textLabel.text = img.name;
    cell.userInteractionEnabled = YES;
    cell.imageView.image = [img imageGet];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [self.waypointsWithImages objectAtIndex:indexPath.section];
    NSArray<dbImage *> *imgs = [dbImage dbAllByWaypoint:wp type:IMAGECATEGORY_USER];
    dbImage *img = [imgs objectAtIndex:indexPath.row];

    WaypointImageViewController *newController = [[WaypointImageViewController alloc] init];
    [newController setImage:img idx:0 totalImages:0 waypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

@end
