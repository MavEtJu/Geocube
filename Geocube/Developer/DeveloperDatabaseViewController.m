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

@interface DeveloperDatabaseViewController ()

@property (nonatomic, retain) NSArray<NSString *> *fieldsSizes;
@property (nonatomic, retain) NSArray<NSString *> *valuesSizes;
@property (nonatomic, retain) NSArray<NSString *> *fieldsDBCount;
@property (nonatomic, retain) NSArray<NSString *> *valuesDBCount;
@property (nonatomic, retain) NSArray<dbConfig *> *config;
@property (nonatomic, retain) NSOperationQueue *runqueue;

@end

@implementation DeveloperDatabaseViewController

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
    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuDumpDatabase label:_(@"helpdatabaseviewcontroller-Dump database")];

    self.runqueue = [[NSOperationQueue alloc] init];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLKEYVALUE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadNumbers];
    [self reloadDiskUtilization];
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
    [fs addObject:@"KMLFiles"];
    [vs addObject:[[NSNumber numberWithInteger:[dbKMLFile dbCount]] stringValue]];
    [fs addObject:@"ListData"];
    [vs addObject:[[NSNumber numberWithInteger:[dbListData dbCount]] stringValue]];
    [fs addObject:@"Localities"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLocality dbCount]] stringValue]];
    [fs addObject:@"Logs"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogData dbCount]] stringValue]];
    [fs addObject:@"LogData"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLog dbCount]] stringValue]];
    [fs addObject:@"LogMacros"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogMacro dbCount]] stringValue]];
    [fs addObject:@"LogStrings"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogString dbCount]] stringValue]];
    [fs addObject:@"LogStringWaypoints"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogStringWaypoint dbCount]] stringValue]];
    [fs addObject:@"LogTemplates"];
    [vs addObject:[[NSNumber numberWithInteger:[dbLogTemplate dbCount]] stringValue]];
    [fs addObject:@"MoveableInventory"];
    [vs addObject:[[NSNumber numberWithInteger:[dbMoveableInventory dbCount]] stringValue]];
    [fs addObject:@"Names"];
    [vs addObject:[[NSNumber numberWithInteger:[dbName dbCount]] stringValue]];
    [fs addObject:@"Notices"];
    [vs addObject:[[NSNumber numberWithInteger:[dbNotice dbCount]] stringValue]];
    [fs addObject:@"OwnTrack"];
    [vs addObject:[[NSNumber numberWithInteger:[dbOwnTrack dbCount]] stringValue]];
    [fs addObject:@"PersonalNotes"];
    [vs addObject:[[NSNumber numberWithInteger:[dbPersonalNote dbCount]] stringValue]];
    [fs addObject:@"Pins"];
    [vs addObject:[[NSNumber numberWithInteger:[dbPin dbCount]] stringValue]];
    [fs addObject:@"Protocol"];
    [vs addObject:[[NSNumber numberWithInteger:[dbProtocol dbCount]] stringValue]];
    [fs addObject:@"QueryImport"];
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
    self.fieldsDBCount = fs;
    self.valuesDBCount = vs;

    self.config = [dbConfig dbAll];
}

- (void)reloadDiskUtilization
{
    NSMutableArray<NSString *> *vs = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray<NSString *> *fs = [NSMutableArray arrayWithCapacity:20];

    self.fieldsSizes = fs;
    self.valuesSizes = vs;

    [self.runqueue addOperationWithBlock:^{
        NSInteger size = [db getDatabaseSize];
        @synchronized(vs) {
            [vs addObject:[MyTools niceFileSize:size]];
            [fs addObject:@"Database size"];
        };
        [self reloadDataMainQueue];
    }];

    [self.runqueue addOperationWithBlock:^{
        NSInteger size = [MyTools determineDirectorySize:[MyTools FilesDir]];
        @synchronized(vs) {
            [vs addObject:[MyTools niceFileSize:size]];
            [fs addObject:@"Files directory size"];
        }
        [self reloadDataMainQueue];
    }];

    NSArray<MapBrand *> *mbs = [MapTemplateViewController initMapBrands];
    [mbs enumerateObjectsUsingBlock:^(MapBrand * _Nonnull mb, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([mb.mapObject respondsToSelector:@selector(cachePrefixes)] == NO)
            return;

        [[mb.mapObject cachePrefixes] enumerateObjectsUsingBlock:^(NSString * _Nonnull prefix, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.runqueue addOperationWithBlock:^{
                NSInteger size = [MyTools determineDirectorySize:[NSString stringWithFormat:@"%@/%@", [MyTools MapCacheDir], prefix]];
                @synchronized(vs) {
                    [vs addObject:[MyTools niceFileSize:size]];
                    [fs addObject:[NSString stringWithFormat:@"MapCache %@", prefix]];
                }

                [self reloadDataMainQueue];
            }];
        }];

    }];

    [self.runqueue addOperationWithBlock:^{
        NSInteger size = [MyTools determineDirectorySize:[MyTools ImagesDir]];
        @synchronized(vs) {
            [vs addObject:[MyTools niceFileSize:size]];
            [fs addObject:@"Images directory size"];
        }
        [self reloadDataMainQueue];
    }];
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
            return [self.fieldsSizes count];
        case SECTION_DBCOUNT:
            return [self.fieldsDBCount count];
        case SECTION_CONFIGURATION:
            return [self.config count];
    }
    return 0;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellKeyValue *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLKEYVALUE forIndexPath:indexPath];

    switch (indexPath.section) {
        case SECTION_SIZES: {
            cell.keyLabel.text = [self.fieldsSizes objectAtIndex:indexPath.row];
            cell.valueLabel.text = [[self.valuesSizes objectAtIndex:indexPath.row] description];
            cell.userInteractionEnabled = NO;
            break;
        }
        case SECTION_DBCOUNT: {
            cell.keyLabel.text = [self.fieldsDBCount objectAtIndex:indexPath.row];
            cell.valueLabel.text = [[self.valuesDBCount objectAtIndex:indexPath.row] description];
            cell.userInteractionEnabled = NO;
            break;
        }
        case SECTION_CONFIGURATION: {
            dbConfig *c = [self.config objectAtIndex:indexPath.row];
            cell.keyLabel.text = c.key;
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
    [MyTools messageBox:[MyTools topMostController] header:@"Backup saved" text:[NSString stringWithFormat:@"You can find the dump in the Files section as %@", file]];
}

@end
