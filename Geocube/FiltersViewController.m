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

#define THISCELL @"FilterViewControllerTableCells"
#define THISCELL_GROUPS @"FilterViewControllerTableCellsGroups"
#define THISCELL_CONTAINERS @"FilterViewControllerTableCellsHeader"

@implementation FiltersViewController

- (id)init
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"XSet default values"]];

    filters = [NSMutableArray arrayWithCapacity:10];
    [filters addObject:[FilterObject init:@"Any Group"]];
    [filters addObject:[FilterObject init:@"Any Cache Type"]];
    [filters addObject:[FilterObject init:@"Any Favourites"]];
    [filters addObject:[FilterObject init:@"Any Size"]];
    [filters addObject:[FilterObject init:@"Any Difficulty"]];
    [filters addObject:[FilterObject init:@"Any Terrain"]];
    [filters addObject:[FilterObject init:@"Any Distance"]];
    [filters addObject:[FilterObject init:@"Any Direction"]];
    [filters addObject:[FilterObject init:@"Any Text"]];
    [filters addObject:[FilterObject init:@"Any date"]];
    [filters addObject:[FilterObject init:@"Any Category"]];
    [filters addObject:[FilterObject init:@"Other Requirements"]];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [filters count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   FilterObject *fo = [filters objectAtIndex:indexPath.row];

    // Groups
    if (indexPath.row == 0) {
        FilterGroupsTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterGroupsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        /* Save the height for later */
        fo.cellHeight = [cell cellHeight];
        return cell;
    }

    // Types
    if (indexPath.row == 1) {
        FilterTypesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterTypesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        /* Save the height for later */
        fo.cellHeight = [cell cellHeight];
        return cell;
    }

    // Only show the header
    if (fo.expanded == NO) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
        cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:THISCELL];

        cell.textLabel.text = fo.name;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];
    fo.expanded = !fo.expanded;
    [aTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];

    if (fo.expanded)
        return fo.cellHeight;

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
