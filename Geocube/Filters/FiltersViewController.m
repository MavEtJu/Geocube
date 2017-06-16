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
    [lmi addItem:menuSetDefaultValues label:@"Set default values"];
    [lmi addItem:menuSaveFilter label:@"Save filter"];
    [lmi addItem:menuLoadFilter label:@"Load filter"];

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
            MATCH(filterAccounts, @"Accounts");
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
        FILTER(filterAccounts, FilterAccountsTableViewCell)
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
    SAVE(FilterDateTableViewCell)
    SAVE(FilterFlagsTableViewCell)
    SAVE(FilterAccountsTableViewCell)
}

- (void)menuSaveFilter
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Save filter as..."
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *save = [UIAlertAction
                           actionWithTitle:@"Save" style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               UITextField *tf = alert.textFields.firstObject;
                               [self saveAsFilter:tf.text];
                               [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:save];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Filter name";
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
    LOAD(FilterDateTableViewCell)
    LOAD(FilterFlagsTableViewCell)
    LOAD(FilterAccountsTableViewCell)
    [self.tableView reloadData];
}

- (void)menuLoadFilter
{
    NSArray<NSString *> *fs = [dbFilter findFilterNames];

    [ActionSheetStringPicker
        showPickerWithTitle:@"Load filter"
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
            [filters enumerateObjectsUsingBlock:^(FilterObject *fo, NSUInteger idx, BOOL *stop) {
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
