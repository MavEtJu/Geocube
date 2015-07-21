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

@import GoogleMaps;

#import "Geocube-Prefix.pch"

@implementation AppDelegate

@synthesize tabBars;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _AppDelegate = self;

    // File manager
    fm = [[NSFileManager alloc] init];

    // Initialize Google Maps
    [GMSServices provideAPIKey:@"AIzaSyDBQPbKVG2MqNQaCKaLMuTaI_gcQrlWcGY"];

    /* Create files directory */
    [fm createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];

    /* Move two zip files into files directory */
    NSArray *files = @[@"GCA - 7248.zip", @"GC - 15670269_ACT-1.zip", @"16171009_iossimulator-freewaydrive.zip", @"waymarking.gpx"];
    NSEnumerator *e = [files objectEnumerator];
    NSString *f;
    while ((f = [e nextObject]) != nil) {
        NSString *fromfile = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], f];
        NSString *tofile = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools FilesDir], f];
        [fm copyItemAtPath:fromfile toPath:tofile error:nil];
    }

    // Initialize the global menu
    menuGlobal = [[GlobalMenu alloc] init];

    // Initialize and cache the database
    db = [[database alloc] init];
    [db checkVersion];
    dbc = [[DatabaseCache alloc] init];
    [dbc loadCacheData];

    // Initialize the image library
    imageLibrary = [[ImageLibrary alloc] init];

    // Initialize the location mamager
    LM = [[GCLocationManager alloc] init];

    // Initialize the tabbar controllers

    NSMutableArray *controllers;
    UINavigationController *nav;
    UITabBarController *tabBarController;
    UIViewController *vc;

    tabBars = [[NSMutableArray alloc] initWithCapacity:5];

#define TABBARCONTROLLER(__controllers__) \
    tabBarController = [[UITabBarController alloc] init]; \
    tabBarController.tabBar.translucent = NO; \
    tabBarController.viewControllers = __controllers__; \
    tabBarController.customizableViewControllers = __controllers__; \
    tabBarController.delegate = self; \
    [tabBars addObject:tabBarController];

    // Navigate tabs #0
    controllers = [NSMutableArray array];

    vc = [[CompassViewController alloc] init];
    vc.title = @"Compass";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    CacheViewController *cvc = [[CacheViewController alloc] init];
    cvc.title = @"Details";
    nav = [[UINavigationController alloc] initWithRootViewController:cvc];
    [controllers addObject:nav];

    vc = [[MapGoogleViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"GMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[MapAppleViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"AMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[MapOSMViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"OSM";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Caches Online tabs #1
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Caches Online";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"XFilters";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[CachesOfflineListViewController alloc] init];
    vc.title = @"List";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[MapGoogleViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"GMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[MapAppleViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"AMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[MapOSMViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"OSM";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Notes and logs tabs #3
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Notes and Logs";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Trackables logs #4
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Trackables";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Groups Root Controllers #5
    controllers = [NSMutableArray array];

    vc = [[GroupsViewController alloc] init:YES];
    vc.title = @"User Groups";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[GroupsViewController alloc] init:NO];
    vc.title = @"System Groups";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Bookmarks tabs #6
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Bookmarks";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Files RootController #7
    controllers = [NSMutableArray array];

    vc = [[FilesViewController alloc] init];
    vc.title = @"Local Files";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[NullViewController alloc] init];
    vc.title = @"XDropbox";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // User profile tabs #8
    controllers = [NSMutableArray array];

    vc = [[UserProfileViewController alloc] init];
    vc.title = @"User Profile";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Notices tabs #9
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Notices";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Settings tabs #10
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Settings";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Help tabs #11
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Help";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    vc = [[HelpImagesViewController alloc] init];
    vc.title = @"Images";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // UIResponder.window = UIWIndow
    // UIWindow.rootViewController = UITabBarController
    // UITabBarController.viewControllers = [UIViewController ...]

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [tabBars objectAtIndex:RC_CACHESOFFLINE];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)switchController:(NSInteger)idx
{
    NSLog(@"AppDelegate: Switching to TB %ld", (long)idx);
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
