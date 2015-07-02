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

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

    self.numberOfItemsInRow = 3;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Local" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    [menuItems_Global addButtons:self view:self.view numberOfItemsInRow:self.numberOfItemsInRow];
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

- (DOPNavbarMenu *)tab_menu
{
    if (_tab_menu == nil) {
        DOPNavbarMenuItem *item_empty = [DOPNavbarMenuItem ItemWithTitle:@"empty" icon:[UIImage imageNamed:@"Image"]];
        _tab_menu = [[DOPNavbarMenu alloc] initWithItems:@[item_empty] width:self.view.dop_width maximumNumberInRow:_numberOfItemsInRow];
        _tab_menu.backgroundColor = [UIColor blackColor];
        _tab_menu.separatarColor = [UIColor whiteColor];
        _tab_menu.menuName = @"Local";
        _tab_menu.delegate = self;
    }
    return _tab_menu;
}


- (void)openMenu:(id)sender
{
    if (sender != self.navigationItem.rightBarButtonItem) {
        [menuItems_Global openMenu:sender];
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    if (self.tab_menu.isOpen) {
        [self.tab_menu dismissWithAnimation:YES];
    } else {
        [self.tab_menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
    if (menu != self.tab_menu) {
        [menuItems_Global didShowMenu:menu];
        return;
    }

    [self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    if (menu != self.tab_menu) {
        [menuItems_Global didDismissMenu:menu];
        return;
    }

    [self.navigationItem.rightBarButtonItem setTitle:menu.menuName];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuItems_Global didSelectedMenu:menu atIndex:index];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you selected" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
