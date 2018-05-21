/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

    // Audio manager
    audioManager = [[AudioManager alloc] init];

    /* Create working directories */
    [fileManager createDirectoryAtPath:[MyTools FilesDir] withIntermediateDirectories:NO attributes:nil error:nil];
    [fileManager createDirectoryAtPath:[MyTools KMLDir] withIntermediateDirectories:NO attributes:nil error:nil];
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

    // Initialize the IOS File Transfer Manager - After fileManager
    IOSFTM = [[IOSFileTransfers alloc] init];

    // Initialize and cache the database - after fileManager
    db = [[database alloc] init];
    [db checkVersion];
    dbc = [[DatabaseCache alloc] init];
    [dbc loadCachableData]; // Explicit because it requires itself to be there.

    // Initialize the configuration manager - after db
    configManager = [[ConfigManager alloc] init];

    // Database backup - after configManager and db
    if (configManager.automaticDatabaseBackup == YES)
        [db checkForBackup];

    // Localization manager - after configManager
    localizationManager = [[LocalizationManager alloc] init];

    // Initialize the global menu - after localizationManager and configManager
    menuGlobal = [[SideMenu alloc] init];

    // After configManager
    opencageManager = [[OpenCageManager alloc] init];

    // Initialize the location mamager - after configurationManager
    LM = [[LocationManager alloc] init];
    [LM startDelegationLocation:nil isNavigating:NO];

    // Initialize Google Maps -- after keyManager
    [GMSServices provideAPIKey:keyManager.googlemaps];

    // Initialize Mapbox -- after configurationManager
    [MGLAccountManager setAccessToken:configManager.mapboxKey];

    // Clean the map cache - after configurationManager
    [MapAppleCache cleanupCache];

    // Auto rotate the kept tracks
    [KeepTrackTracks trackAutoRotate];
    [KeepTrackTracks trackAutoPurge];

    // Audio
    audioFeedback = [[AudioFeedback alloc] init];
    [audioFeedback togglePlay:configManager.soundDirection];

    // Initialize the image library
    imageManager = [[ImageManager alloc] init];

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

                VC(CompassViewController, _(@"menu-navigate-Compass"));
                VC(WaypointViewController, _(@"menu-navigate-Target"));
                VC(MapOneWPViewController, _(@"menu-navigate-Map"));

                TABBARCONTROLLER(RC_NAVIGATE, controllers)
                break;

            case RC_WAYPOINTS:
                controllers = [NSMutableArray array];

                VC(FiltersViewController, _(@"menu-waypoints-Filters"));
                VC(WaypointsListViewController, _(@"menu-waypoints-List"));
                VC(MapAllWPViewController, _(@"menu-waypoints-Map"));

                TABBARCONTROLLER(RC_WAYPOINTS, controllers)
                break;

            case RC_KEEPTRACK:
                controllers = [NSMutableArray array];

                VC(KeepTrackCar, _(@"menu-keeptrack-Car"));
                VC(KeepTrackTracks, _(@"menu-keeptrack-Tracks"));
                VC(MapTrackViewController, _(@"menu-keeptrack-Map"));
                VC(KeepTrackBeeper, _(@"menu-keeptrack-Beeper"));

                TABBARCONTROLLER(RC_KEEPTRACK, controllers)
                break;

            case RC_NOTESANDLOGS:
                controllers = [NSMutableArray array];

                VC(NotesSavedViewController, _(@"menu-noteslogs-Saved"));
                VC(NotesPersonalNotesViewController, _(@"menu-noteslogs-Personal"));
                VC(NotesFieldnotesViewController, _(@"menu-noteslogs-Field"));
                VC(NotesImagesViewController, _(@"menu-noteslogs-Images"));

                TABBARCONTROLLER(RC_NOTESANDLOGS, controllers)
                break;

            case RC_TRACKABLES:
                controllers = [NSMutableArray array];

                VC(TrackablesInventoryViewController, _(@"menu-trackables-Inventory"));
                VC(TrackablesMineViewController, _(@"menu-trackables-Mine"));
                VC(TrackablesListViewController, _(@"menu-trackables-List"));

                TABBARCONTROLLER(RC_TRACKABLES, controllers)
                break;

            case RC_GROUPS:
                controllers = [NSMutableArray array];

                VC(GroupsUserViewController, _(@"menu-groups-User Groups"));
                VC(GroupsSystemViewController, _(@"menu-groups-System Groups"));

                TABBARCONTROLLER(RC_GROUPS, controllers)
                break;

            case RC_BROWSER:
                controllers = [NSMutableArray array];

                VC(BrowserUserViewController, _(@"menu-browser-User"));
                VC(BrowserAccountsViewController, _(@"menu-browser-Queries"));
                VC(BrowserBrowserViewController, _(@"menu-browser-Browser"));

                TABBARCONTROLLER(RC_BROWSER, controllers)
                break;

            case RC_FILES:
                controllers = [NSMutableArray array];

                VC(FilesViewController, _(@"menu-files-Local Files"));
                VC(FileKMLViewController, _(@"menu-files-KML"));
                VC(FileBrowserViewController, _(@"menu-files-File Browser"));

                TABBARCONTROLLER(RC_FILES, controllers)
                break;

            case RC_STATISTICS:
                controllers = [NSMutableArray array];

                VC(StatisticsViewController, _(@"menu-statistics-Statistics"));

                TABBARCONTROLLER(RC_STATISTICS, controllers)
                break;

            case RC_SETTINGS:
                controllers = [NSMutableArray array];

                VC(SettingsAccountsViewController, _(@"menu-settings-Accounts"));
                VC(SettingsMainViewController, _(@"menu-settings-Settings"));
                VC(SettingsColoursViewController, _(@"menu-settings-Colours"));
                VC(SettingsLogTemplatesViewController, _(@"menu-settings-Log"));

                TABBARCONTROLLER(RC_SETTINGS, controllers)
                break;

            case RC_HELP:
                controllers = [NSMutableArray array];

                VC(HelpAboutViewController, _(@"menu-help-About"));
                VC(HelpHelpViewController, _(@"menu-help-Help"));
                VC(NoticesViewController, _(@"menu-help-Notices"));

                TABBARCONTROLLER(RC_HELP, controllers)
                break;

            case RC_LISTS:
                controllers = [NSMutableArray array];

                VC(ListFoundViewController, _(@"menu-lists-Found"));
                VC(ListDNFViewController, _(@"menu-lists-DNF"));
                VC(ListHighlightViewController, _(@"menu-lists-Highlight"));
                VC(ListInProgressViewController, _(@"menu-lists-In Progress"));
                VC(ListIgnoredViewController, _(@"menu-lists-Ignored"));

                TABBARCONTROLLER(RC_LISTS, controllers)
                break;

            case RC_QUERIES:
                controllers = [NSMutableArray array];

                VC(QueriesLiveAPIViewController, _(@"menu-queries-LiveAPI"));
                VC(QueriesGGCWViewController, _(@"menu-queries-Geocaching.com website"));
                VC(QueriesGCAViewController, _(@"menu-queries-GCA"));
                VC(QueriesGCAPublicViewController, _(@"menu-queries-GCA Public"));

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_TOOLS:
                controllers = [NSMutableArray array];

                VC(ToolsGNSSViewController, _(@"menu-tools-GNSS"));
                VC(ToolsRot13ViewController, _(@"menu-tools-ROT13"));

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_LOCATIONSLESS:
                controllers = [NSMutableArray array];

                VC(LocationlessListViewController, _(@"menu-locationless-All"));
                VC(LocationlessPlannedViewController, _(@"menu-locationless-Planned"));
                VC(MapLogsViewController, _(@"menu-locationless-Map"));

                TABBARCONTROLLER(RC_QUERIES, controllers)
                break;

            case RC_DEVELOPER:
                controllers = [NSMutableArray array];

                VC(DeveloperRemoteAPIViewController, _(@"menu-developer-RemoteAPI"));
                VC(DeveloperImagesViewController, _(@"menu-developer-Images"));
                VC(DeveloperDatabaseViewController, _(@"menu-developer-DB"));

                TABBARCONTROLLER(RC_DEVELOPER, controllers)
                break;

            case RC_MOVEABLES:
                controllers = [NSMutableArray array];

                VC(MoveablesInventoryViewController, _(@"menu-moveables-Inventory"));
                VC(MoveablesMineViewController, _(@"menu-moveables-Mine"));
                VC(MoveablesListViewController, _(@"menu-moveables-List"));
                VC(MapLogsViewController, _(@"menu-moveables-Map"));

                TABBARCONTROLLER(RC_DEVELOPER, controllers)
                break;

            default:
                NSAssert1(FALSE, @"Tabbar missing item %ld", (long)i);

        }
    }

    // Switch back to the last page the user was on.
    NSInteger currentIndex = configManager.currentPageTab;
    if (configManager.currentPage >= [self.tabBars count])
        [configManager currentPageUpdate:0];
    [self switchController:configManager.currentPage];
    MHTabBarController *currentTab = [self.tabBars objectAtIndex:configManager.currentPage];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = currentTab;

    [self.window makeKeyAndVisible];
    [currentTab setSelectedIndex:currentIndex animated:YES];

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

    // Moveables Map
    moveablesMapTabController = [_AppDelegate.tabBars objectAtIndex:RC_MOVEABLES];
    nvc = [moveablesMapTabController.viewControllers objectAtIndex:VC_MOVEABLES_MAP];
    moveablesMapViewController = [nvc.viewControllers objectAtIndex:0];

    // Download View Controller and Manager
    downloadManager = [[DownloadManager alloc] init];
    importManager = [[ImportManager alloc] init];
    imagesDownloadManager = [[ImagesDownloadManager alloc] init];

    // OwnTracks Manager - after configManager and downloadManager
    owntracksManager = [[OwnTracksManager alloc] init];

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
        BACKGROUND(checkForDownloadConfigurationFiles, nil);

    // Ask for notifications
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // Nothing
    }];

    return YES;
}

- (void)checkForDownloadConfigurationFiles
{
    [SettingsAccountsViewController needsToDownloadFiles];
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
    [self.tabBars enumerateObjectsUsingBlock:^(MHTabBarController * _Nonnull vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [vc resizeController:size coordinator:coordinator];
    }];
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    NSLog(@"import");
    [IOSFTM importAirdropAttachment:url];
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"%@ - %@ - memory warning", [application class], [self class]);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [owntracksManager alertForegroundToBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [owntracksManager alertBackgroundToForeground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [owntracksManager alertAppStopped];
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
