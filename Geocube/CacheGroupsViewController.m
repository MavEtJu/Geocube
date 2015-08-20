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

#define THISCELL @"CacheGroupsViewControllerCell"

@implementation CacheGroupsViewController

- (id)init:(dbWaypoint *)_wp
{
    self = [super init];
    waypoint = _wp;

    ugs = [NSMutableArray arrayWithCapacity:5];
    sgs = [NSMutableArray arrayWithCapacity:5];

    NSArray *gs = [dbGroup dbAllByWaypoint:waypoint._id];
    NSEnumerator *e = [gs objectEnumerator];
    dbGroup *cg;
    while ((cg = [e nextObject]) != nil) {
        if (cg.usergroup == TRUE)
            [ugs addObject:cg];
        else
            [sgs addObject:cg];
    }

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    hasCloseButton = YES;
    
    return self;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [ugs count];
    return [sgs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"User groups";
    return @"System groups";
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    if (cell == nil) {
        cell = [[UITableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSEnumerator *e;
    if (indexPath.section == 0)
        e = [ugs objectEnumerator];
    else
        e = [sgs objectEnumerator];

    dbGroup *cg;
    NSInteger c = 0;
    while ((cg = [e nextObject]) != nil) {
        if (c == indexPath.row)
            break;
        c++;
    }
    cell.textLabel.text = cg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld caches", (long)[cg dbCountWaypoints]];
    cell.imageView.image = nil;
    cell.userInteractionEnabled = NO;

    return cell;
}


@end
