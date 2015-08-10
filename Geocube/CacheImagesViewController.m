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

@implementation CacheImagesViewController

#define THISCELL @"CacheImagesViewController"

- (id)init:(dbWaypoint *)wp
{
    self = [super init];

    menuItems = nil;
    hasCloseButton = YES;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];

    waypoint = wp;
    userImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_USER];
    cacheImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_CACHE];
    logImages = [dbImage dbAllByWaypoint:wp._id type:IMAGETYPE_LOG];

    return self;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [userImages count];
        case 1: return [cacheImages count];
        case 2: return [logImages count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"User Images";
        case 1: return @"Waypoint Images";
        case 2: return @"Log Images";
    }
    return @"Images???";
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbImage *img;
    switch (indexPath.section) {
        case 0: img = [userImages objectAtIndex:indexPath.row]; break;
        case 1: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case 2: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return nil;

    cell.textLabel.text = img.url;
    cell.userInteractionEnabled = YES;
    cell.imageView.image = [img imageGet];
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbImage *img = nil;

    switch (indexPath.section) {
        case 0: img = [userImages objectAtIndex:indexPath.row]; break;
        case 1: img = [cacheImages objectAtIndex:indexPath.row]; break;
        case 2: img = [logImages objectAtIndex:indexPath.row]; break;
    }

    if (img == nil)
        return;

    UIViewController *newController = [[CacheImageViewController alloc] init:img];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

@end
