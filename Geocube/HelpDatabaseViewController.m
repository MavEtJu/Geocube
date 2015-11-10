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

- (instancetype)init
{
    self = [super init];
    menuItems = nil;

    [self.tableView registerClass:[GCTableViewCellTwoTextfields class] forCellReuseIdentifier:THISCELL];
    [self reloadNumbers];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadNumbers];
    [self.tableView reloadData];
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
    [fs addObject:@"LogTypes"];
    [vs addObject:[NSNumber numberWithInteger:[dbLogType dbCount]]];
    [fs addObject:@"Names"];
    [vs addObject:[NSNumber numberWithInteger:[dbName dbCount]]];
    [fs addObject:@"Notices"];
    [vs addObject:[NSNumber numberWithInteger:[dbNotice dbCount]]];
    [fs addObject:@"Personal Notes"];
    [vs addObject:[NSNumber numberWithInteger:[dbPersonalNote dbCount]]];
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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Database count";
    if (section == 1)
        return @"Configuration";
    return nil;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [fields1 count];
    if (section == 1)
        return [config count];
    return 0;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellTwoTextfields *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCellTwoTextfields alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    if (indexPath.section == 0) {
        cell.fieldLabel.text = [fields1 objectAtIndex:indexPath.row];
        NSObject *o = [values1 objectAtIndex:indexPath.row];
        if ([o isKindOfClass:[NSNumber class]] == YES)
            cell.valueLabel.text = [MyTools niceNumber:[[values1 objectAtIndex:indexPath.row] integerValue]];
        else
            cell.valueLabel.text = [values1 objectAtIndex:indexPath.row];
        cell.userInteractionEnabled = NO;
    }
    if (indexPath.section == 1) {
        dbConfig *c = [config objectAtIndex:indexPath.row];
        cell.fieldLabel.text = c.key;
        cell.valueLabel.text = c.value;
        cell.userInteractionEnabled = NO;
    }

    [cell viewWillTransitionToSize];

    return cell;
}

@end
