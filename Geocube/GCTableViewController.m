//
//  GroupsViewControllerViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation GCTableViewController

@synthesize numberOfItemsInRow, tab_menu, global_menu;

- (id)init
{
    self = [super init];
    menuItems = [NSArray arrayWithObjects:@"Empty", nil];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOfItemsInRow = 3;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Local" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [menuGlobal addButtons:self numberOfItemsInRow:self.numberOfItemsInRow];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // NSLog(@"GCTableViewController:viewWillAppear: self:%p", self);
    
    [menuGlobal didDismissMenu:nil];
    [menuGlobal setTarget:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 0;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (DOPNavbarMenu *)tab_menu
{
    if (tab_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];
        
        NSEnumerator *e = [menuItems objectEnumerator];
        NSString *menuitem;
        while ((menuitem = [e nextObject]) != nil) {
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:menuitem icon:[UIImage imageNamed:@"Image"]];
            [menuoptions addObject:item];
        }

        tab_menu = [[DOPNavbarMenu alloc] initWithItems:menuoptions width:self.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        tab_menu.backgroundColor = [UIColor blackColor];
        tab_menu.separatarColor = [UIColor whiteColor];
        tab_menu.menuName = @"Local";
        tab_menu.delegate = self;
    }
    return tab_menu;
}


- (void)openMenu:(id)sender
{
    if (sender != self.navigationItem.rightBarButtonItem) {
        [menuGlobal openMenu:sender];
        return;
    }
    
    // NSLog(@"GCTableViewController/openMenu: self:%p", self);

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
        [menuGlobal didShowMenu:menu];
        return;
    }

    // NSLog(@"GCTableViewController/didShowMenu: self:%p", self);
    
    [self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    if (menu != self.tab_menu) {
        [menuGlobal didDismissMenu:menu];
        return;
    }
    
    // NSLog(@"GCTableViewController/didDismissMenu: self:%p", self);
    
    [self.navigationItem.rightBarButtonItem setTitle:menu.menuName];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }
    
    // NSLog(@"GCTableViewController/didSelectedMenu: self:%p", self);
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you selected" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
