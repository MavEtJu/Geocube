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

@interface HelpDatabaseViewController ()
{
    NSArray<NSString *> *fieldsSizes;
    NSArray<NSString *> *valuesSizes;
    NSArray<NSString *> *fieldsDBCount;
    NSArray<NSString *> *valuesDBCount;
    NSArray<dbConfig *> *config;
}

@end

@implementation HelpDatabaseViewController

#define THISCELL @"HelpDatabaseViewController"

enum {
    SECTION_SIZES = 0,
    SECTION_DBCOUNT,
    SECTION_CONFIGURATION,
    SECTION_MAX
};

enum {
    menuDumpDatabase = 0,
    menuMax,
};

- (instancetype)init
{
    self = [super init];
    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuDumpDatabase label:@"Dump database"];

    [self.tableView registerClass:[GCTableViewCellFieldValue class] forCellReuseIdentifier:THISCELL];
    [self reloadNumbers];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadNumbers];
    [self.tableView reloadData];
}

- (void)reloadNumbers
{
    NSMutableArray<NSString *> *vs = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray<NSString *> *fs = [NSMutableArray arrayWithCapacity:20];

    [fs addObject:@"Accounts"];
    [vs addObject:[[NSNumber numberWithInteger:[dbAccount dbCount]] stringValue]];
    [fs addObject:@"Attributes"];
    [vs addObject:[[NSNumber numberWithInteger:[dbAttribute dbCount]] stringValue]];
    [fs addObject:@"Bookmarks"];
    [vs addObject:[[NSNumber numberWithInteger:[dbBookmark dbCount]] stringValue]];
    [fs addObject:@"Config"];
    [vs addObject:[[NSNumber numberWithInteger:[dbConfig dbCount]] stringValue]];
    [fs addObject:@"Countries"];
    [vs addObject:[[NSNumber numberWithInteger:[dbCountry dbCount]] stringValue]];
    [fs addObject:@"Containers"];
    [vs addObject:[[NSNumber numberWithInteger:[dbContainer dbCount]] stringValue]];
    [fs addObject:@"ExternalMaps"];
    [vs addObject:[[NSNumber numberWithInteger:[dbExternalMap dbCount]] stringValue]];
    [fs addObject:@"ExternalMapURLs"];
    [vs addObject:[[NSNumber numberWithInteger:[dbExternalMapURL dbCount]] stringValue]];
    [fs addObject:@"FileImports"];
    [vs addObject:[[NSNumber numberWithInteger:[dbFileImport dbCount]] stringValue]];
    [fs addObject:@"Filters"];
    [vs addObject:[[NSNumber numberWithInteger:[dbFilter dbCount]] stringValue]];
    [fs addObject:@"Groups"];
    [vs addObject:[[NSNumber numberWithInteger:[dbGroup dbCount]] stringValue]];
    [fs addObject:@"Images"];
    [vs addObject:[[NSNumber numberWithInteger:[dbImage dbCount]] stringValue]];
    [fs addObject:@"Logs"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLog dbCount]] stringValue]];
    [fs addObject:@"LogStrings"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogString dbCount]] stringValue]];
    [fs addObject:@"Names"];
    [vs addObject:[[NSNumber numberWithInteger:[dbName dbCount]] stringValue]];
    [fs addObject:@"Notices"];
    [vs addObject:[[NSNumber numberWithInteger:[dbNotice dbCount]] stringValue]];
    [fs addObject:@"Personal Notes"];
    [vs addObject:[[NSNumber numberWithInteger:[dbPersonalNote dbCount]] stringValue]];
    [fs addObject:@"QueryImports"];
    [vs addObject:[[NSNumber numberWithInteger:[dbQueryImport dbCount]] stringValue]];
    [fs addObject:@"States"];
    [vs addObject:[[NSNumber numberWithInteger:[dbState dbCount]] stringValue]];
    [fs addObject:@"Symbols"];
    [vs addObject:[[NSNumber numberWithInteger:[dbSymbol dbCount]] stringValue]];
    [fs addObject:@"Trackables"];
    [vs addObject:[[NSNumber numberWithInteger:[dbTrackable dbCount]] stringValue]];
    [fs addObject:@"TrackElements"];
    [vs addObject:[[NSNumber numberWithInteger:[dbTrackElement dbCount]] stringValue]];
    [fs addObject:@"Tracks"];
    [vs addObject:[[NSNumber numberWithInteger:[dbTrack dbCount]] stringValue]];
    [fs addObject:@"Types"];
    [vs addObject:[[NSNumber numberWithInteger:[dbType dbCount]] stringValue]];
    [fs addObject:@"Waypoints"];
    [vs addObject:[[NSNumber numberWithInteger:[dbWaypoint dbCount]] stringValue]];
    fieldsDBCount = fs;
    valuesDBCount = vs;

    vs = [NSMutableArray arrayWithCapacity:20];
    fs = [NSMutableArray arrayWithCapacity:20];

    [fs addObject:@"Database size"];
    [vs addObject:[MyTools niceFileSize:[db getDatabaseSize]]];

    NSInteger size = [MyTools determineDirectorySize:[MyTools ImagesDir]];
    [fs addObject:@"Images directory size"];
    [vs addObject:[MyTools niceFileSize:size]];

    size = [MyTools determineDirectorySize:[MyTools FilesDir]];
    [fs addObject:@"Files directory size"];
    [vs addObject:[MyTools niceFileSize:size]];

    NSDictionary<NSString *, MapBrand *> *d = [MapTemplateViewController initMapBrands];
    [d enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MapBrand * _Nonnull mb, BOOL * _Nonnull stop) {
        if ([mb.mapObject respondsToSelector:@selector(cachePrefix)] == NO)
            return;
        NSString *prefix = [mb.mapObject cachePrefix];
        [fs addObject:[NSString stringWithFormat:@"MapCache %@", prefix]];

        NSInteger size = [MyTools determineDirectorySize:[NSString stringWithFormat:@"%@/%@", [MyTools MapCacheDir], prefix]];
        [vs addObject:[MyTools niceFileSize:size]];
    }];

    fieldsSizes = fs;
    valuesSizes = vs;

    config = [dbConfig dbAll];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return SECTION_MAX;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_SIZES:
            return @"File sizes";
        case SECTION_DBCOUNT:
            return @"Database count";
        case SECTION_CONFIGURATION:
            return @"Configuration";
    }
    return nil;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SECTION_SIZES:
            return [fieldsSizes count];
        case SECTION_DBCOUNT:
            return [fieldsDBCount count];
        case SECTION_CONFIGURATION:
            return [config count];
    }
    return 0;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellFieldValue *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    switch (indexPath.section) {
        case SECTION_SIZES: {
            cell.fieldLabel.text = [fieldsSizes objectAtIndex:indexPath.row];
            cell.valueLabel.text = [[valuesSizes objectAtIndex:indexPath.row] description];
            cell.userInteractionEnabled = NO;
            break;
        }
        case SECTION_DBCOUNT: {
            cell.fieldLabel.text = [fieldsDBCount objectAtIndex:indexPath.row];
            cell.valueLabel.text = [[valuesDBCount objectAtIndex:indexPath.row] description];
            cell.userInteractionEnabled = NO;
            break;
        }
        case SECTION_CONFIGURATION: {
            dbConfig *c = [config objectAtIndex:indexPath.row];
            cell.fieldLabel.text = c.key;
            cell.valueLabel.text = c.value;
            cell.userInteractionEnabled = NO;
            break;
        }
    }

    [cell viewWillTransitionToSize];

    return cell;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuDumpDatabase:
            [self dumpDatabase];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)dumpDatabase
{
    NSString *file = [db saveCopy];
    [MyTools messageBox:self header:@"Backup saved" text:[NSString stringWithFormat:@"You can find the dump in the Files section as %@", file]];
}

@end
