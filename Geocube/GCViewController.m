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

@interface GCViewController ()
{
    NSInteger numberOfItemsInRow;
    DOPNavbarMenu *tab_menu;
    GCCloseButton *closeButton;
}

@end

@implementation GCViewController

@synthesize numberOfItemsInRow, tab_menu;

- (instancetype)init
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"XEmpty"]];
    self.numberOfItemsInRow = 3;

    hasCloseButton = NO;
    closeButton = nil;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeTheme];
}

- (void)changeTheme
{
    self.view.backgroundColor = currentTheme.tableViewBackgroundColor;

    [themeManager changeThemeView:self.view];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showCloseButton];
}

- (void)showCloseButton
{
    if (hasCloseButton == YES)
        [self.view bringSubviewToFront:closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@/viewWillAppear: %0.0f px", [self class], self.view.frame.size.height);

    // Deal with the local menu
    if (menuItems == nil)
        menuGlobal.localMenuButton.hidden = YES;
    else
        menuGlobal.localMenuButton.hidden = NO;
    [menuGlobal setLocalMenuTarget:self];

    // Add a close button to the view
    if (hasCloseButton == YES && closeButton == nil) {
        GCCloseButton *b = [GCCloseButton buttonWithType:UIButtonTypeCustom];
        [self.view addSubview:b];
        [b addTarget:self action:@selector(closePage:) forControlEvents:UIControlEventTouchDown];
        closeButton = b;
    }

    self.view.backgroundColor = currentTheme.viewBackgroundColor;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)closePage:(UIButton *)b
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (closeButton == nil)
        return;

    CGRect frame = closeButton.frame;
    frame.origin.x = scrollView.contentOffset.x;
    frame.origin.y = scrollView.contentOffset.y;
    closeButton.frame = frame;

    [self.view bringSubviewToFront:closeButton];
}

#pragma -- Local menu related functions

- (DOPNavbarMenu *)tab_menu
{
    if (tab_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];

        [menuItems enumerateObjectsUsingBlock:^(NSString *menuitem, NSUInteger idx, BOOL *stop) {
            BOOL enabled = YES;
            if ([[menuitem substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"X"] == YES) {
                enabled = NO;
                menuitem = [menuitem substringFromIndex:1];
            }
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:menuitem icon:[UIImage imageNamed:@"Image"] enabled:enabled];
            [menuoptions addObject:item];
        }];

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
    if (self.tab_menu.isOpen) {
        [self.tab_menu dismissWithAnimation:YES];
    } else {
        [self.tab_menu showInNavigationController:self.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"You selected...."
                               message:[NSString stringWithFormat:@"number %@", @(index + 1)]
                               preferredStyle:UIAlertControllerStyleAlert
                               ];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:nil
                         ];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
