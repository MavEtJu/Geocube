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

@implementation GCViewController

@synthesize numberOfItemsInRow, tab_menu, global_menu;

- (id)init
{
    self = [super init];
    menuItems = [NSMutableArray arrayWithArray:@[@"XEmpty"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.numberOfItemsInRow = 3;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Local" style:UIBarButtonItemStylePlain target:self action:@selector(openMenu:)];

    if (menuItems == nil) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor lightGrayColor];
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    }

    [menuGlobal addButtons:self numberOfItemsInRow:self.numberOfItemsInRow];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@/viewWillAppear", [self class]);

    [menuGlobal setTarget:self];
    [menuGlobal didDismissMenu:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DOPNavbarMenu *)tab_menu
{
    if (tab_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];

        NSEnumerator *e = [menuItems objectEnumerator];
        NSString *menuitem;
        while ((menuitem = [e nextObject]) != nil) {
            BOOL enabled = YES;
            if ([[menuitem substringWithRange:NSMakeRange(0, 1)] compare:@"X"] == NSOrderedSame) {
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


- (void)openMenu:(id)sender
{
    if (sender != self.navigationItem.rightBarButtonItem) {
        [menuGlobal openMenu:sender];
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
        [menuGlobal didShowMenu:menu];
        return;
    }

    [self.navigationItem.rightBarButtonItem setTitle:@"dismiss"];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    if (menu != self.tab_menu) {
        [menuGlobal didDismissMenu:menu];
        return;
    }

    [self.navigationItem.rightBarButtonItem setTitle:menu.menuName];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you selected" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

@end
