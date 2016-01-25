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

@interface FiltersViewController ()
{
    NSMutableArray *filters;
}

@end

#define THISCELL @"FilterViewControllerTableCells"
#define THISCELL_GROUPS @"FilterViewControllerTableCellsGroups"
#define THISCELL_CONTAINERS @"FilterViewControllerTableCellsHeader"

@implementation FiltersViewController

enum {
    menuSetDefaultValues,
    menuMax
};

enum {
    filterGroups,
    filterTypes,
    filterFavourites,
    filterSizes,
    filterDifficulty,
    filterTerrain,
    filterDistance,
    filterDirection,
    filterText,
    filterDates,
    filterFlags,
    filterCategories,
    filterOtherRequirements,
    filterMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuSetDefaultValues label:@"Set default values"];

    filters = [NSMutableArray arrayWithCapacity:15];

#define MATCH(__i__, __s__) \
    case __i__: \
        [filters addObject:[FilterObject init:__s__]]; \
        break

    for (NSInteger i = 0; i < filterMax; i++) {
        switch (i) {
            MATCH(filterTypes, @"Types");
            MATCH(filterGroups, @"Groups");
            MATCH(filterFavourites, @"Favourites");
            MATCH(filterSizes, @"Sizes");
            MATCH(filterDifficulty, @"Difficulty");
            MATCH(filterTerrain, @"Terrain");
            MATCH(filterDistance, @"Distance");
            MATCH(filterDirection, @"Direction");
            MATCH(filterText, @"Text");
            MATCH(filterDates, @"Date");
            MATCH(filterFlags, @"Flags");
            MATCH(filterCategories, @"Category");
            MATCH(filterOtherRequirements, @"Other Requirements");
            default:
                NSAssert1(FALSE, @"Unknown filter %ld", (long)i);
        }
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     [self.tableView reloadData];
                                 }
     ];
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

    switch (indexPath.row) {
        case filterGroups: {
            FilterGroupsTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterGroupsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterTypes: {
            FilterTypesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterTypesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterFavourites: {
            FilterFavouritesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterFavouritesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterSizes: {
            FilterSizesTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterSizesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterDifficulty: {
            FilterDifficultyTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterDifficultyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterTerrain: {
            FilterTerrainTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterTerrainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterDistance: {
            FilterDistanceTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterDistanceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterDirection: {
            FilterDirectionTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterDirectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterText: {
            FilterTextTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterDates: {
            FilterDateTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterDateTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterCategories: {
            FilterCategoryTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterCategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterOtherRequirements: {
            FilterOthersTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterOthersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

        case filterFlags: {
            FilterFlagsTableViewCell *cell; //= [aTableView dequeueReusableCellWithIdentifier:THISCELL_GROUPS];
            if (cell == nil) {
                cell = [[FilterFlagsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_GROUPS filterObject:fo];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            fo.tvc = cell;
            return cell;
        }

    }

    NSAssert1(FALSE, @"Unknown filter: %ld", (long)indexPath.row);

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

#pragma mark - Local menu related

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Add a group
    switch (index) {
        case menuSetDefaultValues:
            [dbFilter dbAllClear];
            [filters enumerateObjectsUsingBlock:^(FilterObject *fo, NSUInteger idx, BOOL *stop) {
                fo.expanded = NO;
            }];
            [self.tableView reloadData];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}


@end
