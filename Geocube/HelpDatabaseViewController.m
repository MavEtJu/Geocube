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

@interface HelpDatabaseViewController ()
{
    NSArray *fields1;
    NSArray *values1;
    NSArray *config;
}

@end

@implementation HelpDatabaseViewController

#define THISCELL @"HelpDatabaseViewController"

enum {
    SECTION_DBCOUNT = 0,
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
    NSMutableArray *vs = [NSMutableArray arrayWithCapacity:20];
    NSMutableArray *fs = [NSMutableArray arrayWithCapacity:20];

    [fs addObject:@"Database size"];
    [vs addObject:[MyTools niceFileSize:[db getDatabaseSize]]];

    [fs addObject:@"Accounts"];
    [vs addObject:[NSNumber numberWithInteger:[dbAccount dbCount]]];
    [fs addObject:@"Attributes"];
    [vs addObject:[NSNumber numberWithInteger:[dbAttribute dbCount]]];
    [fs addObject:@"Bookmarks"];
    [vs addObject:[NSNumber numberWithInteger:[dbBookmark dbCount]]];
    [fs addObject:@"Config"];
    [vs addObject:[NSNumber numberWithInteger:[dbConfig dbCount]]];
    [fs addObject:@"Countries"];
    [vs addObject:[NSNumber numberWithInteger:[dbCountry dbCount]]];
    [fs addObject:@"Containers"];
    [vs addObject:[NSNumber numberWithInteger:[dbContainer dbCount]]];
    [fs addObject:@"ExternalMaps"];
    [vs addObject:[NSNumber numberWithInteger:[dbExternalMap dbCount]]];
    [fs addObject:@"ExternalMapURLs"];
    [vs addObject:[NSNumber numberWithInteger:[dbExternalMapURL dbCount]]];
    [fs addObject:@"FileImports"];
    [vs addObject:[NSNumber numberWithInteger:[dbFileImport dbCount]]];
    [fs addObject:@"Filters"];
    [vs addObject:[NSNumber numberWithInteger:[dbFilter dbCount]]];
    [fs addObject:@"Groups"];
    [vs addObject:[NSNumber numberWithInteger:[dbGroup dbCount]]];
    [fs addObject:@"Images"];
    [vs addObject:[NSNumber numberWithInteger:[dbImage dbCount]]];
    [fs addObject:@"Logs"];
    [vs addObject:[NSNumber numberWithInteger:[dbLog dbCount]]];
    [fs addObject:@"LogStrings"];
    [vs addObject:[NSNumber numberWithInteger:[dbLogString dbCount]]];
    [fs addObject:@"Names"];
    [vs addObject:[NSNumber numberWithInteger:[dbName dbCount]]];
    [fs addObject:@"Notices"];
    [vs addObject:[NSNumber numberWithInteger:[dbNotice dbCount]]];
    [fs addObject:@"Personal Notes"];
    [vs addObject:[NSNumber numberWithInteger:[dbPersonalNote dbCount]]];
    [fs addObject:@"QueryImports"];
    [vs addObject:[NSNumber numberWithInteger:[dbQueryImport dbCount]]];
    [fs addObject:@"States"];
    [vs addObject:[NSNumber numberWithInteger:[dbState dbCount]]];
    [fs addObject:@"Symbols"];
    [vs addObject:[NSNumber numberWithInteger:[dbSymbol dbCount]]];
    [fs addObject:@"Trackables"];
    [vs addObject:[NSNumber numberWithInteger:[dbTrackable dbCount]]];
    [fs addObject:@"TrackElements"];
    [vs addObject:[NSNumber numberWithInteger:[dbTrackElement dbCount]]];
    [fs addObject:@"Tracks"];
    [vs addObject:[NSNumber numberWithInteger:[dbTrack dbCount]]];
    [fs addObject:@"Types"];
    [vs addObject:[NSNumber numberWithInteger:[dbType dbCount]]];
    [fs addObject:@"Waypoints"];
    [vs addObject:[NSNumber numberWithInteger:[dbWaypoint dbCount]]];
    fields1 = fs;
    values1 = vs;

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
        case SECTION_DBCOUNT:
            return [fields1 count];
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
        case SECTION_DBCOUNT: {
            cell.fieldLabel.text = [fields1 objectAtIndex:indexPath.row];
            NSObject *o = [values1 objectAtIndex:indexPath.row];
            if ([o isKindOfClass:[NSNumber class]] == YES)
                cell.valueLabel.text = [MyTools niceNumber:[[values1 objectAtIndex:indexPath.row] integerValue]];
            else
                cell.valueLabel.text = [values1 objectAtIndex:indexPath.row];
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
