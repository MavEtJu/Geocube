//
//  GroupsViewControllerViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "DOPNavbarMenu.h"
#import "GroupsViewController.h"
#import "Geocube.h"
#import "database.h"
#import "GlobalMenu.h"

@implementation GroupsViewController

- (id)init:(BOOL)showUsers
{
    self = [super init];

    NSMutableArray *ws = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [WaypointGroups objectEnumerator];
    dbObjectWaypointGroup *wpg;
    
    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == showUsers)
            [ws addObject:wpg];
    }
    wpgs = ws;
    wpgCount = [wpgs count];

    // Local menu
    if (showUsers == YES)
        menuItems = [NSArray arrayWithObjects:@"Empty Groups", @"Add Group", nil];
    else
        menuItems = [NSArray arrayWithObjects:@"Empty Groups", nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return wpgCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    dbObjectWaypointGroup *wpg = [wpgs objectAtIndex:indexPath.row];
    cell.textLabel.text = wpg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld waypoints", [db WaypointGroups_count_waypoints:wpg._id]];
    
    return cell;
}

@end
