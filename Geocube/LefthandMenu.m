//
//  LefthandMenu.m
//  Geocube
//
//  Created by Edwin Groothuis on 30/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "LefthandMenu.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "FilesViewController.h"
#import "GroupsViewController.h"
#import "NullViewController.h"

@implementation LefthandMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor blueColor];
    
    UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"Menu";
    [label sizeToFit];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:label];
    //self.label = label;
    
    UIButton *button;
    NSInteger y = 30;
    
#define BUTTON(__enabled__, __title__, __selector__) \
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect]; \
    button.frame = CGRectMake(20.0f, y, 200.0f, 40.0f); \
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; \
    if (__enabled__ == NO) button.alpha = 0.66; \
    [button setTitle:__title__ forState:UIControlStateNormal]; \
    [button addTarget:self action:@selector(__selector__:) forControlEvents:UIControlEventTouchUpInside]; \
    [self.view addSubview:button]; \
    y += 40;
    
    BUTTON(NO,  @"Navigate", _showNull)
    BUTTON(NO,  @"Caches Online", _showNull)
    BUTTON(NO,  @"Caches Offline", _showNull)
    BUTTON(NO,  @"Notes and Logs", _showNull)
    BUTTON(NO,  @"Trackables", _showNull)
    BUTTON(YES, @"Groups", _showGroups)
    BUTTON(NO,  @"Bookmarks", _showNull)
    BUTTON(YES, @"Files", _showFiles)
    BUTTON(NO,  @"Profile", _showNull)
    BUTTON(NO,  @"Notices", _showNull)
    BUTTON(NO,  @"Settings", _showNull)
    BUTTON(NO,  @"Help", _showNull)
    BUTTON(NO,  @"Camera", _showNull)
    BUTTON(NO,  @"Torch", _showNull)
    BUTTON(NO,  @"GPS", _showNull)
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.label.center = CGPointMake(floorf(self.sidePanelController.leftVisibleWidth/2.0f), 25.0f);
}

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
    
    vc = [[GroupsViewController alloc] init];
    vc.title = @"User";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    vc = [[GroupsViewController alloc] init];
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

#pragma mark - Button Actions

- (void)_hideTapped:(id)sender {
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
    self.hide.hidden = YES;
    self.show.hidden = NO;
}

- (void)_showTapped:(id)sender {
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
    self.hide.hidden = NO;
    self.show.hidden = YES;
}

@end
