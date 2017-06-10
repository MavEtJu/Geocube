/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _AppDelegate = self;

    // Bezel manager
    bezelManager = [[BezelManager alloc] init];

    // File manager
    fileManager = [[NSFileManager alloc] init];

    /* Create files directory */
    [fileManager createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];

    // Do some directory juggling
    NSDictionary *d = @{
                        [MyTools OldImagesDir]: [MyTools ImagesDir],
                        [MyTools OldMapCacheDir]: [MyTools MapCacheDir]
                        };
    if ([fileManager fileExistsAtPath:[MyTools ApplicationSupportRoot]] == NO)
        [fileManager createDirectoryAtPath:[MyTools ApplicationSupportRoot] withIntermediateDirectories:YES attributes:nil error:nil];
    [d enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull old, NSString * _Nonnull new, BOOL * _Nonnull stop) {
        if ([fileManager fileExistsAtPath:old] == YES) {
            NSLog(@"Rename %@ to %@", old, new);
            NSError *e = nil;
            [fileManager moveItemAtPath:old toPath:new error:&e];
            if (e != nil)
                NSLog(@"Rename error %@", e);
        }
    }];

    // Initialize the global menu
    menuGlobal = [[SideMenu alloc] init];

    // Initialize the IOS File Transfer Manager - After fileManager
    IOSFTM = [[IOSFileTransfers alloc] init];

    // Initialize and cache the database - after fileManager
    db = [[database alloc] init];
    [db checkVersion];
    dbc = [[DatabaseCache alloc] init];
    [dbc loadCachableData]; // Explicit because it requires itself to be there.

    // Initialize the configuration manager - after db
    configManager = [[ConfigManager alloc] init];

    // Initialize the location mamager - after configurationManager
    LM = [[LocationManager alloc] init];
    [LM startDelegation:nil isNavigating:NO];

    // Initialize Google Maps -- after db, configurationManager
    [GMSServices provideAPIKey:configManager.keyGMS];

    // Clean the map cache - after configurationManager
    [MapAppleCache cleanupCache];

    // Auto rotate the kept tracks
    [KeepTrackTracks trackAutoRotate];
    [KeepTrackTracks trackAutoPurge];

    // Audio
    audioFeedback = [[AudioFeedback alloc] init];
    [audioFeedback togglePlay:configManager.soundDirection];

    // Initialize the image library
    imageLibrary = [[ImageLibrary alloc] init];

    // Initialize the theme - after configurationManager, imageLibrary
    themeManager = [[ThemeManager alloc] init];
    [themeManager setTheme:configManager.themeType];

    // Waypoint Manager - after configurationManager, LM, db, imageLibrary
    waypointManager = [[WaypointManager alloc] init];

    // Initialize the tabbar controllers

    NSMutableArray<UINavigationController *> *controllers;
    UINavigationController *nav;
    UIViewController *vc;

    self.tabBars = [[NSMutableArray alloc] initWithCapacity:RC_MAX];

#define TABBARCONTROLLER(index, __controllers__) { \
    MHTabBarController *tbc = [[MHTabBarController alloc] init]; \
    tbc.delegate = self; \
    tbc.viewControllers = __controllers__; \
    [self.tabBars addObject:tbc]; \
    }

#define VC(__class__, __title__) \
    vc = [[__class__ alloc] init]; \
    vc.title = __title__; \
    nav = [[UINavigationController alloc] initWithRootViewController:vc]; \
    nav.navigationBarHidden = YES; \
    [controllers addObject:nav];

    for (NSInteger i = 0; i < RC_MAX; i++) {
        switch (i) {
            case RC_NAVIGATE:
                controllers = [NSMutableArray array];

                VC(CompassViewController, @"Compass");
                VC(WaypointViewController, @"Target");
                VC(MapOneWPViewController, @"Map");

                TABBARCONTROLLER(RC_NAVIGATE, controllers)
                break;

            case RC_WAYPOINTS:
                controllers = [NSMutableArray array];

                VC(FiltersViewController, @"Filters");
                VC(WaypointsListViewController, @"List");
                VC(MapAllWPViewController, @"Map");

                TABBARCONTROLLER(RC_WAYPOINTS, controllers)
                break;

            case RC_KEEPTRACK:
                controllers = [NSMutableArray array];

                VC(KeepTrackCar, @"Car");
                VC(KeepTrackTracks, @"Tracks");
                VC(MapTrackViewController, @"Map");

                TABBARCONTROLLER(RC_KEEPTRACK, controllers)
                break;

            case RC_NOTESANDLOGS:
                controllers = [NSMutableArray array];

                VC(NotesSavedViewController, @"Saved");
                VC(NotesPersonalNotesViewController, @"Personal");
                VC(NotesFieldnotesViewController, @"Field");
                VC(NotesImagesViewController, @"Images");

                TABBARCONTROLLER(RC_NOTESANDLOGS, controllers)
                break;

            case RC_TRACKABLES:
                controllers = [NSMutableArray array];

                VC(TrackablesInventoryViewController, @"Inventory");
                VC(TrackablesMineViewController, @"Mine");
                VC(TrackablesListViewController, @"List");

                TABBARCONTROLLER(RC_TRACKABLES, controllers)
                break;

            case RC_GROUPS:
                controllers = [NSMutableArray array];

                VC(GroupsUserViewController, @"User Groups");
                VC(GroupsSystemViewController, @"System Groups");

                TABBARCONTROLLER(RC_GROUPS, controllers)
                break;

            case RC_BROWSER:
                controllers = [NSMutableArray array];

                VC(BrowserUserViewController, @"User");
                VC(BrowserAccountsViewController, @"Queries");
                VC(BrowserBrowserViewController, @"Browser");

                TABBARCONTROLLER(RC_BROWSER, controllers)
                break;

            case RC_FILES:
                controllers = [NSMutableArray array];

                VC(FilesViewController, @"Local Files");
                VC(FileBrowserViewController, @"File Browser");

                TABBARCONTROLLER(RC_FILES, controllers)
                break;

            case RC_STATISTICS:
                controllers = [NSMutableArray array];

                VC(StatisticsViewController, @"Statistics");

                TABBARCONTROLLER(RC_STATISTICS, controllers)
                break;

            case RC_SETTINGS:
                controllers = [NSMutableArray array];

                VC(SettingsAccountsViewController, @"Accounts");
                VC(SettingsMainViewController, @"Settings");
                VC(SettingsColourViewController, @"Colours");
                VC(SettingsLogTemplatesViewController, @"Log");

                TABBARCONTROLLER(RC_SETTINGS, controllers)
                break;

            case RC_HELP:
                controllers = [NSMutableArray array];

                VC(HelpAboutViewController, @"About");
                VC(HelpHelpViewController, @"Help");
                VC(NoticesViewController, @"Notices");
                VC(HelpImagesViewController, @"Images");
                VC(HelpDatabaseViewController, @"DB");

                TABBARCONTROLLER(RC_HELP, controllers)
                break;

            case RC_LISTS:
                controllers = [NSMutableArray array];

                VC(ListHighlightViewController, @"Highlight");
                VC(ListFoundViewController, @"Found");
                VC(ListDNFViewController, @"DNF");
                VC(ListInProgressViewController, @"In Progress");
                VC(ListIgnoredViewController, @"Ingnored");

                TABBARCONTROLLER(RC_LISTS, controllers)
                break;

            case RC_QUERIES:
                controllers = [NSMutableArray array];

                VC(QueriesGroundspeakViewController, @"Groundspeak");
                VC(QueriesGGCWViewController, @"Geocaching.com website");
                VC(QueriesGCAViewController, @"GCA");

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_TOOLS:
                controllers = [NSMutableArray array];

                VC(ToolsGPSViewController, @"GPS");
                VC(ToolsRot13ViewController, @"Rot13");

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            default:
                NSAssert1(FALSE, @"Tabbar missing item %ld", (long)i);

        }
    }

    // Switch back to the last page the user was on.
    if (configManager.currentPage >= [self.tabBars count])
        [configManager currentPageUpdate:0];
    [self switchController:configManager.currentPage];
    MHTabBarController *currentTab = [self.tabBars objectAtIndex:configManager.currentPage];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = currentTab;

    [self.window makeKeyAndVisible];
    [currentTab setSelectedIndex:configManager.currentPageTab animated:YES];

    // Browser View Controller
    browserTabController = [_AppDelegate.tabBars objectAtIndex:RC_BROWSER];
    UINavigationController *nvc = [browserTabController.viewControllers objectAtIndex:VC_BROWSER_BROWSER];
    browserViewController = [nvc.viewControllers objectAtIndex:0];

    // Keep Track Map
    keepTrackTabController = [_AppDelegate.tabBars objectAtIndex:RC_KEEPTRACK];
    nvc = [keepTrackTabController.viewControllers objectAtIndex:VC_KEEPTRACK_MAP];
    keepTrackMapViewController = [nvc.viewControllers objectAtIndex:0];

    // Download View Controller and Manager
    downloadManager = [[DownloadManager alloc] init];
    importManager = [[ImportManager alloc] init];
    imagesDownloadManager = [[ImagesDownloadManager alloc] init];

    /* No site information yet? */
    dbConfig *db = [dbConfig dbGetByKey:@"sites_revision"];
    if (db == nil) {
        [self switchController:RC_SETTINGS];
        currentTab = [self.tabBars objectAtIndex:RC_SETTINGS];
        [currentTab setSelectedIndex:VC_SETTINGS_ACCOUNTS animated:YES];
    }

    // Cleanup imported information from iTunes -- after the viewcontroller has been generated
    [IOSFTM cleanupITunes];

    // Show the introduction
    if (configManager.introSeen == NO)
        [HelpIntroduction showIntro:self];

    return YES;
}

- (void)switchController:(NSInteger)idx
{
    NSLog(@"AppDelegate: Switching to TB %ld", (long)idx);
    self.currentTabBar = idx;
    self.window.rootViewController = [self.tabBars objectAtIndex:idx];
    [self.window makeKeyAndVisible];
}

- (void)resizeControllers:(CGSize)size coordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.tabBars enumerateObjectsUsingBlock:^(MHTabBarController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [vc resizeController:size coordinator:coordinator];
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"import");
    [IOSFTM importAirdropAttachment:url];
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"%@ - %@ - memory warning", [application class], [self class]);
}

- (BOOL)mh_tabBarController:(MHTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    NSLog(@"mh_tabBarController %@ shouldSelectViewController %@ at index %lu", tabBarController, viewController, (unsigned long)index);

    // Uncomment this to prevent "Tab 3" from being selected.
    //return (index != 2);

    return YES;
}

- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    NSLog(@"mh_tabBarController %@ didSelectViewController %@ at index %lu", tabBarController, viewController, (unsigned long)index);
}
@end
