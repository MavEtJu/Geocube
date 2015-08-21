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

@implementation GCTableViewController

@synthesize numberOfItemsInRow, tab_menu;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];

    menuItems = [NSMutableArray arrayWithObjects:@"XEmpty", nil];
    self.numberOfItemsInRow = 3;

    closeButton = nil;
    hasCloseButton = NO;

    self.tableView.backgroundColor = currentTheme.tableView_backgroundColor;

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (hasCloseButton == YES)
        [self.view bringSubviewToFront:closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@/viewWillAppear: %0.0f px", [self class], self.view.frame.size.height);

    [super viewWillAppear:animated];

    // Deal with the local menu button
    if (menuItems == nil)
        menuGlobal.localMenuButton.hidden = YES;
    else
        menuGlobal.localMenuButton.hidden = NO;
    [menuGlobal setLocalMenuTarget:self];

    // Add a close button to the view
    if (hasCloseButton == YES && closeButton == nil) {
        UIImage *imgMenu = [imageLibrary get:ImageIcon_CloseButton];
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(0, 0, imgMenu.size.width, imgMenu.size.height);
        [b setImage:imgMenu forState:UIControlStateNormal];
        [self.view addSubview:b];
        [b addTarget:self action:@selector(closePage:) forControlEvents:UIControlEventTouchDown];
        closeButton = b;
    }
}

- (void)closePage:(UIButton *)b
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -- UITableView related functions

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (closeButton == nil)
        return;

    CGRect frame = closeButton.frame;
    frame.origin.y = scrollView.contentOffset.y;
    closeButton.frame = frame;

    [self.view bringSubviewToFront:closeButton];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTheme.tableViewCell_gradient == YES) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = cell.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[currentTheme.tableViewCell_gradient1 CGColor],
                           (id)[currentTheme.tableViewCell_gradient2 CGColor],
                           nil];
        [cell.layer insertSublayer:gradient atIndex:0];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    return;
//        view.tintColor = [UIColor blackColor];
        // Text Color
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        [header.textLabel setBackgroundColor:[UIColor clearColor]];

    //if (currentTheme.tableViewCell_gradient == YES) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = header.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[currentTheme.tableViewCell_gradient1 CGColor],
                           (id)[currentTheme.tableViewCell_gradient2 CGColor],
                           nil];
        [header.layer insertSublayer:gradient atIndex:0];
//    }
}


#pragma -- Local menu related functions

- (DOPNavbarMenu *)tab_menu
{
    if (tab_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];

        NSEnumerator *e = [menuItems objectEnumerator];
        NSString *menuitem;
        while ((menuitem = [e nextObject]) != nil) {
            BOOL enabled = YES;
            if ([[menuitem substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"X"] == YES) {
                enabled = NO;
                menuitem = [menuitem substringFromIndex:1];
            }
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:menuitem icon:[UIImage imageNamed:@"Image"] enabled:enabled];
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


- (void)openLocalMenu:(id)sender
{
    // NSLog(@"GCTableViewController/openMenu: self:%p", self);

    if (menuItems == nil)
        return;

    if (self.tab_menu.isOpen) {
        [self.tab_menu dismissWithAnimation:YES];
    } else {
        [self.tab_menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
    // NSLog(@"GCTableViewController/didShowMenu: self:%p", self);
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    // NSLog(@"GCTableViewController/didDismissMenu: self:%p", self);
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    // NSLog(@"GCTableViewController/didSelectedMenu: self:%p", self);

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you selected" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
