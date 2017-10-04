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

#import "FiltersViewController.h"

#import "FilterHeaderTableViewCell.h"

@interface FiltersViewController ()
{
    NSMutableArray<FilterObject *> *filters;
}

@end

@implementation FiltersViewController

enum {
    menuSetDefaultValues = 0,
    menuSaveFilter,
    menuLoadFilter,
    menuMax
};

enum {
    filterGroups = 0,
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
    filterAccounts,
    filterMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuSetDefaultValues label:_(@"filtersviewcontroller-Set default values")];
    [lmi addItem:menuSaveFilter label:_(@"filtersviewcontroller-Save filter")];
    [lmi addItem:menuLoadFilter label:_(@"filtersviewcontroller-Load filter")];

    filters = [NSMutableArray arrayWithCapacity:15];

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

    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERHEADERTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERHEADERTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERDIRECTIONTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERDIRECTIONTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERDIFFICULTYTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERDIFFICULTYTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERTERRAINTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERTERRAINTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERFAVOURITESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERFAVOURITESTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERDATESTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERDATESTABLEVIEWCELL];
    [self.tableView registerNib:[UINib nibWithNibName:XIB_FILTERFLAGSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_FILTERFLAGSTABLEVIEWCELL];

#define MATCH(__idx__, __name__, __xib__) \
    case __idx__: { \
        FilterObject *fo = [[FilterObject alloc] init:__name__]; \
        fo.tvcDisabled = [self.tableView dequeueReusableCellWithIdentifier:XIB_FILTERHEADERTABLEVIEWCELL]; \
        [fo.tvcDisabled header:__name__]; \
        fo.tvcEnabled = [self.tableView dequeueReusableCellWithIdentifier:__xib__]; \
        [fo.tvcEnabled initFO:fo]; \
        [filters addObject:fo]; \
        break; \
    }

    for (NSInteger i = 0; i < filterMax; i++) {
        switch (i) {
            MATCH(filterTypes, _(@"filtersviewcontroller-types"), XIB_FILTERTABLEVIEWCELL);
            MATCH(filterGroups, _(@"filtersviewcontroller-groups"), XIB_FILTERTABLEVIEWCELL);
            MATCH(filterFavourites, _(@"filtersviewcontroller-favourites"), XIB_FILTERFAVOURITESTABLEVIEWCELL);
            MATCH(filterSizes, _(@"filtersviewcontroller-sizes"), XIB_FILTERTABLEVIEWCELL);
            MATCH(filterDifficulty, _(@"filtersviewcontroller-difficulty"), XIB_FILTERDIFFICULTYTABLEVIEWCELL);
            MATCH(filterTerrain, _(@"filtersviewcontroller-terrain"), XIB_FILTERTERRAINTABLEVIEWCELL);
            MATCH(filterDistance, _(@"filtersviewcontroller-distance"), XIB_FILTERTABLEVIEWCELL);
            MATCH(filterDirection, _(@"filtersviewcontroller-direction"), XIB_FILTERDIRECTIONTABLEVIEWCELL);
            MATCH(filterText, _(@"filtersviewcontroller-text"), XIB_FILTERTABLEVIEWCELL);
            MATCH(filterDates, _(@"filtersviewcontroller-dates"), XIB_FILTERDATESTABLEVIEWCELL);
            MATCH(filterFlags, _(@"filtersviewcontroller-flags"), XIB_FILTERFLAGSTABLEVIEWCELL);
            MATCH(filterAccounts, _(@"filtersviewcontroller-accounts"), XIB_FILTERTABLEVIEWCELL);
            default:
                NSAssert1(FALSE, @"Unknown filter %ld", (long)i);
        }
    }
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
    GCTableViewCell *cell;

#define FILTER(__row__) \
        case __row__: { \
            if (fo.expanded == YES) { \
                FilterTableViewCell *c = fo.tvcEnabled; \
                [c viewRefresh]; \
                cell = c; \
            } else \
                cell = fo.tvcDisabled; \
            break; \
        }

    switch (indexPath.row) {
        FILTER(filterGroups)
        FILTER(filterTypes)
        FILTER(filterFavourites)
        FILTER(filterSizes)
        FILTER(filterDifficulty)
        FILTER(filterTerrain)
        FILTER(filterDistance)
        FILTER(filterDirection)
        FILTER(filterText)
        FILTER(filterDates)
        FILTER(filterFlags)
        FILTER(filterAccounts)
        default:
            NSAssert1(FALSE, @"Unknown filter: %ld", (long)indexPath.row);
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FilterObject *fo = [filters objectAtIndex:indexPath.row];
    fo.expanded = !fo.expanded;
    [fo.tvcEnabled configUpdate];
    [aTableView reloadData];
    [waypointManager needsRefreshAll];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    FilterObject *fo = [filters objectAtIndex:indexPath.row];
//
//    if (fo.expanded)
//        return fo.cellHeight;
//
//    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
//}

#pragma mark - Local menu related

- (void)saveAsFilter:(NSString *)filtername
{
#define SAVE(__class__) \
    { \
        NSString *prefix = [__class__ configPrefix]; \
        NSArray<NSString *> *fields = [__class__ configFields]; \
        NSDictionary *defaults = [__class__ configDefaults]; \
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull fn, NSUInteger idx, BOOL * _Nonnull stop) { \
            NSString *value = [defaults objectForKey:fn]; \
            dbFilter *f = [dbFilter dbGetByKey:[NSString stringWithFormat:@"%@_%@", prefix, fn]]; \
            if (f != nil) \
                value = f.value; \
            [dbFilter dbUpdateOrInsert:[NSString stringWithFormat:@"%@||%@_%@", filtername, prefix, fn] value:value]; \
        }]; \
    }

    SAVE(FilterGroupsTableViewCell)
    SAVE(FilterTypesTableViewCell)
    SAVE(FilterFavouritesTableViewCell)
    SAVE(FilterSizesTableViewCell)
    SAVE(FilterDifficultyTableViewCell)
    SAVE(FilterTerrainTableViewCell)
    SAVE(FilterDistanceTableViewCell)
    SAVE(FilterDirectionTableViewCell)
    SAVE(FilterTextTableViewCell)
    SAVE(FilterDatesTableViewCell)
    SAVE(FilterFlagsTableViewCell)
    SAVE(FilterAccountsTableViewCell)
}

- (void)menuSaveFilter
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"filtersviewcontroller-Save filter as...")
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *save = [UIAlertAction
                           actionWithTitle:_(@"Save") style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               UITextField *tf = alert.textFields.firstObject;
                               [self saveAsFilter:tf.text];
                               [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:save];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"filtersviewcontroller-Filter name");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)loadFilter:(NSString *)filtername
{
    [dbFilter dbAllClear:nil];

#define LOAD(__class__) { \
        NSString *prefix = [__class__ configPrefix]; \
        NSArray<NSString *> *fields = [__class__ configFields]; \
        [fields enumerateObjectsUsingBlock:^(NSString * _Nonnull fn, NSUInteger idx, BOOL * _Nonnull stop) { \
            NSString *ffn = [NSString stringWithFormat:@"%@||%@_%@", filtername, prefix, fn]; \
            dbFilter *f = [dbFilter dbGetByKey:ffn]; \
            if (f != nil) \
                [dbFilter dbUpdateOrInsert:[NSString stringWithFormat:@"%@_%@", prefix, fn] value:f.value]; \
        }]; \
    }

    LOAD(FilterGroupsTableViewCell)
    LOAD(FilterTypesTableViewCell)
    LOAD(FilterFavouritesTableViewCell)
    LOAD(FilterSizesTableViewCell)
    LOAD(FilterDifficultyTableViewCell)
    LOAD(FilterTerrainTableViewCell)
    LOAD(FilterDistanceTableViewCell)
    LOAD(FilterDirectionTableViewCell)
    LOAD(FilterTextTableViewCell)
    LOAD(FilterDatesTableViewCell)
    LOAD(FilterFlagsTableViewCell)
    LOAD(FilterAccountsTableViewCell)
    [self.tableView reloadData];
}

- (void)menuLoadFilter
{
    NSArray<NSString *> *fs = [dbFilter findFilterNames];

    [ActionSheetStringPicker
        showPickerWithTitle:_(@"filtersviewcontroller-Load filter")
        rows:fs
        initialSelection:0
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            NSString *filter = [fs objectAtIndex:selectedIndex];
            [self loadFilter:filter];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
        }
        origin:self.view
     ];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Add a group
    switch (index) {
        case menuSetDefaultValues:
            [dbFilter dbAllClear:nil];
            [filters enumerateObjectsUsingBlock:^(FilterObject * _Nonnull fo, NSUInteger idx, BOOL * _Nonnull stop) {
                fo.expanded = NO;
            }];
            [self.tableView reloadData];
            return;
        case menuSaveFilter:
            [self menuSaveFilter];
            return;
        case menuLoadFilter:
            [self menuLoadFilter];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
