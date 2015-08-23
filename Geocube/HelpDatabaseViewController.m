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

@implementation HelpDatabaseViewController

#define THISCELL @"HelpBaseViewController"

- (id)init
{
    self = [super init];
    menuItems = nil;

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
    [fs addObject:@"Filters"];
    [vs addObject:[NSNumber numberWithInteger:[dbFilter dbCount]]];
    [fs addObject:@"Groundspeak"];
    [vs addObject:[NSNumber numberWithInteger:[dbGroundspeak dbCount]]];
    [fs addObject:@"Groups"];
    [vs addObject:[NSNumber numberWithInteger:[dbGroup dbCount]]];
    [fs addObject:@"Images"];
    [vs addObject:[NSNumber numberWithInteger:[dbImage dbCount]]];
    [fs addObject:@"Logs"];
    [vs addObject:[NSNumber numberWithInteger:[dbLog dbCount]]];
    [fs addObject:@"LogTypes"];
    [vs addObject:[NSNumber numberWithInteger:[dbLogType dbCount]]];
    [fs addObject:@"Names"];
    [vs addObject:[NSNumber numberWithInteger:[dbName dbCount]]];
    [fs addObject:@"Personal Notes"];
    [vs addObject:[NSNumber numberWithInteger:[dbPersonalNote dbCount]]];
    [fs addObject:@"States"];
    [vs addObject:[NSNumber numberWithInteger:[dbState dbCount]]];
    [fs addObject:@"Symbols"];
    [vs addObject:[NSNumber numberWithInteger:[dbSymbol dbCount]]];
    [fs addObject:@"Travelbugs"];
    [vs addObject:[NSNumber numberWithInteger:[dbTravelbug dbCount]]];
    [fs addObject:@"Types"];
    [vs addObject:[NSNumber numberWithInteger:[dbType dbCount]]];
    [fs addObject:@"Waypoints"];
    [vs addObject:[NSNumber numberWithInteger:[dbWaypoint dbCount]]];

    fields = fs;
    values = vs;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCellTwoTextfields class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [fields count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellTwoTextfields *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCellTwoTextfields alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    cell.fieldLabel.text = [fields objectAtIndex:indexPath.row];
    cell.valueLabel.text = [MyTools niceNumber:[[values objectAtIndex:indexPath.row] integerValue]];
    cell.userInteractionEnabled = NO;

    return cell;
}

@end
