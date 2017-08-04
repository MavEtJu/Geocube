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

    // PKI manager
    keyManager = [[KeyManager alloc] init];

    /* Create working directories */
    [fileManager createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];
    [fileManager createDirectoryAtPath:[MyTools ApplicationSupportRoot] withIntermediateDirectories:NO attributes:nil error:nil];

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

    // After configManager
    opencageManager = [[OpenCageManager alloc] init];

    // Initialize the location mamager - after configurationManager
    LM = [[LocationManager alloc] init];
    [LM startDelegation:nil isNavigating:NO];

    // Initialize Google Maps -- after keyManager
    [GMSServices provideAPIKey:keyManager.googlemaps];

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

                VC(CompassViewController, NSLocalizedString(@"menu-navigate-compass", nil));
                VC(WaypointViewController, NSLocalizedString(@"menu-navigate-target", nil));
                VC(MapOneWPViewController, NSLocalizedString(@"menu-navigate-map", nil));

                TABBARCONTROLLER(RC_NAVIGATE, controllers)
                break;

            case RC_WAYPOINTS:
                controllers = [NSMutableArray array];

                VC(FiltersViewController, NSLocalizedString(@"menu-waypoints-filters", nil));
                VC(WaypointsListViewController, NSLocalizedString(@"menu-waypoints-list", nil));
                VC(MapAllWPViewController, NSLocalizedString(@"menu-waypoints-map", nil));

                TABBARCONTROLLER(RC_WAYPOINTS, controllers)
                break;

            case RC_KEEPTRACK:
                controllers = [NSMutableArray array];

                VC(KeepTrackCar, NSLocalizedString(@"menu-keeptack-car", nil));
                VC(KeepTrackTracks, NSLocalizedString(@"menu-keeptack-tracks", nil));
                VC(MapTrackViewController, NSLocalizedString(@"menu-keeptack-map", nil));

                TABBARCONTROLLER(RC_KEEPTRACK, controllers)
                break;

            case RC_NOTESANDLOGS:
                controllers = [NSMutableArray array];

                VC(NotesSavedViewController, NSLocalizedString(@"menu-noteslogs-saved", nil));
                VC(NotesPersonalNotesViewController, NSLocalizedString(@"menu-noteslogs-personal", nil));
                VC(NotesFieldnotesViewController, NSLocalizedString(@"menu-noteslogs-field", nil));
                VC(NotesImagesViewController, NSLocalizedString(@"menu-noteslogs-images", nil));

                TABBARCONTROLLER(RC_NOTESANDLOGS, controllers)
                break;

            case RC_TRACKABLES:
                controllers = [NSMutableArray array];

                VC(TrackablesInventoryViewController, NSLocalizedString(@"menu-trackables-inventory", nil));
                VC(TrackablesMineViewController, NSLocalizedString(@"menu-trackables-mine", nil));
                VC(TrackablesListViewController, NSLocalizedString(@"menu-trackables-list", nil));

                TABBARCONTROLLER(RC_TRACKABLES, controllers)
                break;

            case RC_GROUPS:
                controllers = [NSMutableArray array];

                VC(GroupsUserViewController, NSLocalizedString(@"menu-groups-usergroups", nil));
                VC(GroupsSystemViewController, NSLocalizedString(@"menu-groups-systemgroups", nil));

                TABBARCONTROLLER(RC_GROUPS, controllers)
                break;

            case RC_BROWSER:
                controllers = [NSMutableArray array];

                VC(BrowserUserViewController, NSLocalizedString(@"menu-browser-user", nil));
                VC(BrowserAccountsViewController, NSLocalizedString(@"menu-browser-queries", nil));
                VC(BrowserBrowserViewController, NSLocalizedString(@"menu-browser-browser", nil));

                TABBARCONTROLLER(RC_BROWSER, controllers)
                break;

            case RC_FILES:
                controllers = [NSMutableArray array];

                VC(FilesViewController, NSLocalizedString(@"menu-files-localfiles", nil));
                VC(FileBrowserViewController, NSLocalizedString(@"menu-files-filebrowser", nil));

                TABBARCONTROLLER(RC_FILES, controllers)
                break;

            case RC_STATISTICS:
                controllers = [NSMutableArray array];

                VC(StatisticsViewController, NSLocalizedString(@"menu-statistics-statistics", nil));

                TABBARCONTROLLER(RC_STATISTICS, controllers)
                break;

            case RC_SETTINGS:
                controllers = [NSMutableArray array];

                VC(SettingsAccountsViewController, NSLocalizedString(@"menu-settings-accounts", nil));
                VC(SettingsMainViewController, NSLocalizedString(@"menu-settings-settings", nil));
                VC(SettingsColoursViewController, NSLocalizedString(@"menu-settings-colours", nil));
                VC(SettingsLogTemplatesViewController, NSLocalizedString(@"menu-settings-log", nil));

                TABBARCONTROLLER(RC_SETTINGS, controllers)
                break;

            case RC_HELP:
                controllers = [NSMutableArray array];

                VC(HelpAboutViewController, NSLocalizedString(@"menu-help-about", nil));
                VC(HelpHelpViewController, NSLocalizedString(@"menu-help-help", nil));
                VC(NoticesViewController, NSLocalizedString(@"menu-help-notices", nil));
                VC(HelpImagesViewController, NSLocalizedString(@"menu-help-images", nil));
                VC(HelpDatabaseViewController, NSLocalizedString(@"menu-help-db", nil));

                TABBARCONTROLLER(RC_HELP, controllers)
                break;

            case RC_LISTS:
                controllers = [NSMutableArray array];

                VC(ListHighlightViewController, NSLocalizedString(@"menu-lists-highlight", nil));
                VC(ListFoundViewController, NSLocalizedString(@"menu-lists-found", nil));
                VC(ListDNFViewController, NSLocalizedString(@"menu-lists-dnf", nil));
                VC(ListInProgressViewController, NSLocalizedString(@"menu-lists-inprogress", nil));
                VC(ListIgnoredViewController, NSLocalizedString(@"menu-lists-ingnored", nil));

                TABBARCONTROLLER(RC_LISTS, controllers)
                break;

            case RC_QUERIES:
                controllers = [NSMutableArray array];

                VC(QueriesGroundspeakViewController, NSLocalizedString(@"menu-queries-groundspeak", nil));
                VC(QueriesGGCWViewController, NSLocalizedString(@"menu-queries-geocaching.comwebsite", nil));
                VC(QueriesGCAViewController, NSLocalizedString(@"menu-queries-gca", nil));

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_TOOLS:
                controllers = [NSMutableArray array];

                VC(ToolsGPSViewController, NSLocalizedString(@"menu-tools-gps", nil));
                VC(ToolsRot13ViewController, NSLocalizedString(@"menu-tools-rot13", nil));

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_LOCATIONSLESS:
                controllers = [NSMutableArray array];

                VC(LocationlessListViewController, NSLocalizedString(@"menu-locationless-all", nil));
                VC(LocationlessPlannedViewController, NSLocalizedString(@"menu-locationless-planned", nil));
                VC(MapLogsViewController, NSLocalizedString(@"menu-locationless-map", nil));

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

    // Locationless Map
    locationlessMapTabController = [_AppDelegate.tabBars objectAtIndex:RC_LOCATIONSLESS];
    nvc = [locationlessMapTabController.viewControllers objectAtIndex:VC_LOCATIONLESS_MAP];
    locationlessMapViewController = [nvc.viewControllers objectAtIndex:0];

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
    else
        [SettingsAccountsViewController needsToDownloadFiles];

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
