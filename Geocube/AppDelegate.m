//
//  AppDelegate.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "AppDelegate.h"
#import "Geocube.h"
#import "FilesViewController.h"
#import "GroupsViewController.h"
#import "NullViewController.h"
#import "database.h"
#import "My Tools.h"

@implementation AppDelegate

@synthesize tabBars;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _AppDelegate = self;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    /* Create files directory */
    [fm createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];
    
    /* Move two zip files into files directory */
    NSArray *files = [NSArray arrayWithObjects:@"GCA - 7248.zip", @"GC - 15670269_ACT-1.zip", nil];
    NSEnumerator *e = [files objectEnumerator];
    NSString *f;
    while ((f = [e nextObject]) != nil) {
        NSString *fromfile = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], f];
        NSString *tofile = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools FilesDir], f];
        [fm copyItemAtPath:fromfile toPath:tofile error:nil];
    }
    
    // Initialize the global menu
    menuItems_Global = [[GlobalMenu alloc] init];
    
    // Initialize and cache the database
    db = [[database alloc] init];
    [db loadWaypointData];
    
    /*
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    GroupsViewController *tbvc = [[GroupsViewController alloc] init];
    tbvc.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    return YES;
*/

    /*
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
    self.viewController.leftPanel = [[LefthandMenu alloc] init];
    self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[GroupsViewController alloc] init]];
    self.viewController.rightPanel = [[LefthandMenu alloc] init];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
*/
    
    NSMutableArray *controllers;
    UINavigationController *nav;
    UITabBarController *tabBarController;
    UIViewController *vc;
    
    tabBars = [[NSMutableArray alloc] initWithCapacity:5];

    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Navigate";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Caches Online";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Caches Offline";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Notes and Logs";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Trackables";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Group Root Controllers
    controllers = [NSMutableArray array];
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
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Navigate";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Files RootController
    controllers = [NSMutableArray array];
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
    [tabBars addObject:tabBarController];

    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"User Profile";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Notices";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Settings";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    
    // Navigate RootController
    controllers = [NSMutableArray array];
    vc = [[NullViewController alloc] init];
    vc.title = @"Help";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    [tabBars addObject:tabBarController];
    


    // UIResponder.window = UIWIndow
    // UIWindow.rootViewController = UITabBarController
    // UITabBarController.viewControllers = [UIViewController ...]

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [tabBars objectAtIndex:5];
    [self.window makeKeyAndVisible];
    return YES;

    
/*
    NSMutableArray *controllers = [NSMutableArray array];
    UINavigationController *nav;
    UITabBarController *tabBarController;

    UIViewController *viewGroups = [[GroupsViewController alloc] init];
    viewGroups.title = @"Groups";
    nav = [[UINavigationController alloc] initWithRootViewController:viewGroups];
    [controllers addObject:nav];

    UIViewController *viewFiles = [[FilesViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:viewFiles];
    viewFiles.title = @"Files";
    [controllers addObject:nav];
    
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.barTintColor = [UIColor blackColor];
    tabBarController.tabBar.translucent = NO;
    tabBarController.viewControllers = controllers;
    tabBarController.customizableViewControllers = controllers;
    tabBarController.delegate = self;
    
    // UIResponder.window = UIWIndow
    // UIWIndow.rootViewController = UITabBarController
    // UITabBarController.viewControllers = [UIViewController ...]
    

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
*/
    
    
    /*
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
    self.viewController.leftPanel = [[LefthandMenu alloc] init];
    self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:tabBarController];
    self.viewController.rightPanel = nil;

    
    self.window.rootViewController = self.viewController;
     */
    //[self.window makeKeyAndVisible];
    //creturn YES;
}

- (void)switchController:(NSInteger)idx
{
    NSLog(@"AppDelegate: Switching to %ld", idx);
    self.window.rootViewController = [tabBars objectAtIndex:idx];
    [self.window makeKeyAndVisible];
}


- (void)doThings:(id)s {}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
