/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface FiltersViewController ()
{
    NSMutableArray<FilterObject *> *filters;
}

@end

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
            default:
                NSAssert1(FALSE, @"Unknown filter %ld", (long)i);
        }
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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

#define FILTER(__row__, __type__) \
        case __row__: { \
            __type__ *cell = [[__type__ alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil filterObject:fo]; \
            fo.tvc = cell; \
            break; \
        }

    switch (indexPath.row) {
        FILTER(filterGroups, FilterGroupsTableViewCell)
        FILTER(filterTypes, FilterTypesTableViewCell)
        FILTER(filterFavourites, FilterFavouritesTableViewCell)
        FILTER(filterSizes, FilterSizesTableViewCell)
        FILTER(filterDifficulty, FilterDifficultyTableViewCell)
        FILTER(filterTerrain, FilterTerrainTableViewCell)
        FILTER(filterDistance, FilterDistanceTableViewCell)
        FILTER(filterDirection, FilterDirectionTableViewCell)
        FILTER(filterText, FilterTextTableViewCell)
        FILTER(filterDates, FilterDateTableViewCell)
        FILTER(filterFlags, FilterFlagsTableViewCell)
        default:
            NSAssert1(FALSE, @"Unknown filter: %ld", (long)indexPath.row);

    }
    fo.tvc.accessoryType = UITableViewCellAccessoryNone;
    return fo.tvc;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];
    fo.expanded = !fo.expanded;
    FilterTableViewCell *ftvc = (FilterTableViewCell *)fo.tvc;
    [ftvc configUpdate];
    [aTableView reloadData];
    [waypointManager needsRefreshAll];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];

    if (fo.expanded)
        return fo.cellHeight;

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - Local menu related

- (void)performLocalMenuAction:(NSInteger)index
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

    [super performLocalMenuAction:index];
}


@end
