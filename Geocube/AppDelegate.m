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

@synthesize tabBars, currentTabBar;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _AppDelegate = self;

    // File manager
    fm = [[NSFileManager alloc] init];

    // Initialize the location mamager
    LM = [[GCLocationManager alloc] init];
    [LM startDelegation:nil isNavigating:NO];

    // Initialize Google Maps
    [GMSServices provideAPIKey:@"AIzaSyDBQPbKVG2MqNQaCKaLMuTaI_gcQrlWcGY"];

    /* Create files directory */
    [fm createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];

    // Initialize the global menu
    menuGlobal = [[GlobalMenu alloc] init];

    // Initialize imagesDownloader
    imagesDownloadManager = [[ImagesDownloadManager alloc] init];

    // Initialize and cache the database - after file manager
    db = [[database alloc] init];
    [db checkVersion];
    dbc = [[DatabaseCache alloc] init];

    // Initialize the configuration manager - after db
    myConfig = [[MyConfig alloc] init];

    // Audio
    audioFeedback = [[AudioFeedback alloc] init];
    [audioFeedback togglePlay:[myConfig soundDirection]];

    // Initialize the theme - after myconfig
    themeManager = [[ThemeManager alloc] init];
    [themeManager setTheme:myConfig.themeType];

    // Waypoint Manager - after myConfig, LM, db
    waypointManager = [[CacheFilterManager alloc] init];
   [dbc loadWaypointData];

    // Initialize the image library
    imageLibrary = [[ImageLibrary alloc] init];

    // Initialize the tabbar controllers

    NSMutableArray *controllers;
    UINavigationController *nav;
    UIViewController *vc;

    tabBars = [[NSMutableArray alloc] initWithCapacity:12];

#define TABBARCONTROLLER(__controllers__) \
    tabBarController = [[UITabBarController alloc] init]; \
    tabBarController.tabBar.translucent = NO; \
    tabBarController.viewControllers = __controllers__; \
    tabBarController.customizableViewControllers = __controllers__; \
    tabBarController.delegate = self; \
    [tabBars addObject:tabBarController];
#undef TABBARCONTROLLER
#define TABBARCONTROLLER(__controllers__) { \
        BHTabsViewController *tbc = \
            [[BHTabsViewController alloc] \
            initWithViewControllers:__controllers__ \
            style:[BHTabStyle defaultStyle]]; \
        [tabBars addObject:tbc]; \
    }

    // Navigate tabs #0
    controllers = [NSMutableArray array];

    vc = [[CompassViewController alloc] init];
    vc.title = @"Compass";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    CacheViewController *cvc = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:NO];
    cvc.title = @"Target";
    nav = [[UINavigationController alloc] initWithRootViewController:cvc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapGoogleViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"GMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapAppleViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"AMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapOSMViewController alloc] init:SHOW_ONECACHE];
    vc.title = @"OSM";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Caches Online tabs #1
    controllers = [NSMutableArray array];

    vc = [[NullViewController alloc] init];
    vc.title = @"Caches Online";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    controllers = [NSMutableArray array];

    vc = [[FiltersViewController alloc] init];
    vc.title = @"Filters";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[CachesOfflineListViewController alloc] init];
    vc.title = @"List";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapGoogleViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"GMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapAppleViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"AMap";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[MapOSMViewController alloc] init:SHOW_ALLCACHES];
    vc.title = @"OSM";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Notes and logs tabs #3
    controllers = [NSMutableArray array];

    vc = [[NotesPersonalNotesViewController alloc] init];
    vc.title = @"Personal";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[NotesFieldnotesViewController alloc] init];
    vc.title = @"Field";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[NotesImagesViewController alloc] init];
    vc.title = @"Images";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Trackables logs #4
    controllers = [NSMutableArray array];

    vc = [[TrackablesViewController alloc] init];
    vc.title = @"Trackables";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Groups Root Controllers #5
    controllers = [NSMutableArray array];

    vc = [[GroupsViewController alloc] init:YES];
    vc.title = @"User Groups";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[GroupsViewController alloc] init:NO];
    vc.title = @"System Groups";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Browser tabs #6
    controllers = [NSMutableArray array];

    vc = [[BrowserUserViewController alloc] init];
    vc.title = @"User";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[BrowserAccountsViewController alloc] init];
    vc.title = @"Queries";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[BrowserBrowserViewController alloc] init];
    vc.title = @"Browser";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Files RootController #7
    controllers = [NSMutableArray array];

    vc = [[FilesViewController alloc] init];
    vc.title = @"Local Files";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[NullViewController alloc] init];
    vc.title = @"XDropbox";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // User profile tabs #8
    controllers = [NSMutableArray array];

    vc = [[UserProfileViewController alloc] init];
    vc.title = @"User Profile";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Notices tabs #9
    controllers = [NSMutableArray array];

    vc = [[NoticesViewController alloc] init];
    vc.title = @"Notices";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Settings tabs #10
    controllers = [NSMutableArray array];

    vc = [[SettingsMainViewController alloc] init];
    vc.title = @"Settings";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[SettingsAccountsViewController alloc] init];
    vc.title = @"Accounts";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[SettingsColoursViewController alloc] init];
    vc.title = @"Colours";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // Help tabs #11
    controllers = [NSMutableArray array];

    vc = [[HelpAboutViewController alloc] init];
    vc.title = @"About";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[NullViewController alloc] init];
    vc.title = @"Help";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[HelpImagesViewController alloc] init];
    vc.title = @"Images";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    vc = [[HelpDatabaseViewController alloc] init];
    vc.title = @"DB";
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    [controllers addObject:nav];

    TABBARCONTROLLER(controllers)

    // UIResponder.window = UIWIndow
    // UIWindow.rootViewController = UITabBarController
    // UITabBarController.viewControllers = [UIViewController ...]

    [self switchController:[myConfig currentPage]];
    BHTabsViewController *currentTab = [tabBars objectAtIndex:[myConfig currentPage]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = currentTab;
    NSInteger cpt = [myConfig currentPageTab];

    [self.window makeKeyAndVisible];
    [currentTab makeTabViewCurrent:cpt];

    /* No site information yet? */
    dbConfig *db = [dbConfig dbGetByKey:@"sites_revision"];
    if (db == nil) {
        [self switchController:RC_NOTICES];
        currentTab = [tabBars objectAtIndex:RC_NOTICES];
        cpt = VC_NOTICES;
        [currentTab makeTabViewCurrent:cpt];
        [NoticesViewController AccountsNeedToBeInitialized];
    }
    return YES;
}

- (void)switchController:(NSInteger)idx
{
    NSLog(@"AppDelegate: Switching to TB %ld", (long)idx);
    currentTabBar = idx;
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
