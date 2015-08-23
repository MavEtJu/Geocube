//
//  HelpDatabaseViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 23/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
    cell.valueLabel.text = [NSString stringWithFormat:@"%@", [values objectAtIndex:indexPath.row]];
    cell.userInteractionEnabled = NO;

    return cell;
}

@end
