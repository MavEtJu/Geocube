//
//  GroupsVIewControllerViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "GroupsViewController.h"
#import "Geocube.h"
#import "database.h"

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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(doThings:)];
    
    
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
    
    NSInteger c = [db WaypointGroups_count_waypoints:wpg._id];
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%ld waypoints", c];
    
    return cell;
}

// On selection, update the title and enable find/deselect
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.title = cell.textLabel.text;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    dbObjectWaypointGroup *wpg = [wpgs objectAtIndex:indexPath.row];
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle: wpg.name
                                 message:@"Select you Choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* empty = [UIAlertAction
                            actionWithTitle:@"Empty"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                             //Do some thing here
                             [view dismissViewControllerAnimated:YES completion:nil];
                            }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:empty];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}


// Deselect any current selection
- (void)deselect
{
}

- (void)doThings:(id)sender
{
}


@end
