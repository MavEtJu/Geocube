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
    [filters addObject:[FilterObject init:@"Group"]];
    [filters addObject:[FilterObject init:@"Cache Type"]];
    [filters addObject:[FilterObject init:@"Favourites"]];
    [filters addObject:[FilterObject init:@"Size X"]];
    [filters addObject:[FilterObject init:@"Difficulty"]];
    [filters addObject:[FilterObject init:@"Terrain"]];
    [filters addObject:[FilterObject init:@"Distance"]];
    [filters addObject:[FilterObject init:@"Direction"]];
    [filters addObject:[FilterObject init:@"Text"]];
    [filters addObject:[FilterObject init:@"Date"]];
    [filters addObject:[FilterObject init:@"Category XX"]];
    [filters addObject:[FilterObject init:@"Other Requirements XX"]];

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
        fo.tvc = cell;
        return cell;
    }

    // Types
    if (indexPath.row == 1) {
        FilterTypesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterTypesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Favourites
    if (indexPath.row == 2) {
        FilterFavouritesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterFavouritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Sizes
    if (indexPath.row == 3) {
        FilterSizesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterSizesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Difficulty
    if (indexPath.row == 4) {
        FilterDifficultyTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterDifficultyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Terrain
    if (indexPath.row == 5) {
        FilterTerrainTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterTerrainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Distance
    if (indexPath.row == 6) {
        FilterDistanceTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterDistanceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Direction
    if (indexPath.row == 7) {
        FilterDirectionTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterDirectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Text
    if (indexPath.row == 8) {
        FilterTextTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Date
    if (indexPath.row == 9) {
        FilterDateTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Category
    if (indexPath.row == 10) {
        FilterCategoryTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    // Other
    if (indexPath.row == 11) {
        FilterOthersTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
        if (cell == nil) {
            cell = [[FilterOthersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        fo.tvc = cell;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];
    fo.expanded = !fo.expanded;
    FilterTableViewCell *ftvc = (FilterTableViewCell *)fo.tvc;
    [ftvc configUpdate];
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
