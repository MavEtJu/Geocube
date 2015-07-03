//
//  GlobalMenu.m
//  Geocube
//
//  Created by Edwin Groothuis on 2/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Geocube.h"
#import "GlobalMenu.h"
#import "DOPNavbarMenu.h"


@implementation GlobalMenu

@synthesize items, parent_vc, parent_view;

- (id)init
{
    self = [super init];
    items = [NSArray arrayWithObjects:
        [NSArray arrayWithObjects:@"NO",  @"Navigate", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Caches Online", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Caches Offline", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Notes and Logs", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Trackables", @"_showNull", nil],
        [NSArray arrayWithObjects:@"YES", @"Groups", @"_showGroups", nil],
        [NSArray arrayWithObjects:@"NO",  @"Bookmarks", @"_showNull", nil],
        [NSArray arrayWithObjects:@"YES", @"Files", @"_showFiles", nil],
        [NSArray arrayWithObjects:@"NO",  @"User Profile", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Notices", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Settings", @"_showNull", nil],
        [NSArray arrayWithObjects:@"NO",  @"Help", @"_showNull", nil],
        nil];
    
    return self;
}

- (void)addButtons:(UIViewController<DOPNavbarMenuDelegate> *)_vc view:(UIView *)_view numberOfItemsInRow:(NSInteger)_numberOfItemsInRow
{
    numberOfItemsInRow = _numberOfItemsInRow;
    parent_vc = _vc;
    parent_view = _view;

    parent_vc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Global" style:UIBarButtonItemStylePlain target:parent_vc action:@selector(openMenu:)];
    parent_vc.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (DOPNavbarMenu *)global_menu
{
    if (_global_menu == nil) {
        NSMutableArray *menuoptions = [[NSMutableArray alloc] initWithCapacity:20];
        
        NSEnumerator *e = [items objectEnumerator];
        NSArray *as;
        while ((as = [e nextObject]) != nil) {
            DOPNavbarMenuItem *item = [DOPNavbarMenuItem ItemWithTitle:[as objectAtIndex:1] icon:[UIImage imageNamed:@"Image"]];
            [menuoptions addObject: item];
        }
        
        _global_menu = [[DOPNavbarMenu alloc] initWithItems:menuoptions width:parent_vc.view.dop_width maximumNumberInRow:numberOfItemsInRow];
        _global_menu.backgroundColor = [UIColor blackColor];
        _global_menu.separatarColor = [UIColor whiteColor];
        _global_menu.menuName = @"Global";
        _global_menu.delegate = parent_vc;
    }
    return _global_menu;
}

- (void)openMenu:(id)sender
{
    parent_vc.navigationItem.leftBarButtonItem.enabled = NO;
    if (self.global_menu.isOpen) {
        [self.global_menu dismissWithAnimation:YES];
    } else {
        [self.global_menu showInNavigationController:parent_vc.navigationController];
    }
}

- (void)openLocalMenu:(id)sender
{
    parent_vc.navigationItem.leftBarButtonItem.enabled = NO;
    if (self.global_menu.isOpen) {
        [self.global_menu dismissWithAnimation:YES];
    } else {
        [self.global_menu showInNavigationController:parent_vc.navigationController];
    }
}

- (void)didShowMenu:(DOPNavbarMenu *)menu
{
    [parent_vc.navigationItem.leftBarButtonItem setTitle:@"dismiss"];
    parent_vc.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)didDismissMenu:(DOPNavbarMenu *)menu
{
    [parent_vc.navigationItem.leftBarButtonItem setTitle:menu.menuName];
    parent_vc.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{

    NSLog(@"Switching to %ld", index);
    [_AppDelegate switchController:index];
}

/*
- (void)_showFiles:(id)sender
{
    NSMutableArray *controllers = [NSMutableArray array];
    UINavigationController *nav;
    UITabBarController *tabBarController;
    UIViewController *vc;
    
    vc = [[FilesViewController alloc] init];
    vc.title = @"Shared Files";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    vc = [[FilesViewController alloc] init];
    vc.title = @"Dropbox";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:tabBarController];
}
- (void)_showGroups:(id)sender
{
    NSMutableArray *controllers = [NSMutableArray array];
    UINavigationController *nav;
    UITabBarController *tabBarController;
    UIViewController *vc;
    
    vc = [[GroupsViewController alloc] init:YES];
    vc.title = @"User";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    vc = [[GroupsViewController alloc] init:NO];
    vc.title = @"System";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:tabBarController];
}

- (void)_showNull:(id)sender
{
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[NullViewController alloc] init]];
}
*/

@end
