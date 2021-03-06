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

// Global menu management
SideMenu *menuGlobal;

// Database handle and cache
database *db = nil;
DatabaseCache *dbc = nil;

// Image Library
ImageManager *imageManager = nil;

// Images Download Manager
ImagesDownloadManager *imagesDownloadManager = nil;

// Current dbCache to navigate to
WaypointManager *waypointManager = nil;

// Location Manager
LocationManager *LM = nil;

// File manager
NSFileManager *fileManager = nil;

// IOS File Transfer Manager
IOSFileTransfers *IOSFTM;

// Bezel manager
BezelManager *bezelManager;

// Configuration manager
ConfigManager *configManager = nil;

// Webbrowser
MHTabBarController *browserTabController = nil;
BrowserBrowserViewController *browserViewController = nil;

// Keep Track Map
MHTabBarController *keepTrackTabController = nil;
MapTrackViewController *keepTrackMapViewController = nil;

// Locationless Map
MHTabBarController *locationlessMapTabController;
MapLogsViewController *locationlessMapViewController;
MHTabBarController *moveablesMapTabController;
MapLogsViewController *moveablesMapViewController;

// Download manager
DownloadManager *downloadManager = nil;
ImportManager *importManager = nil;

// Keymanager
KeyManager *keyManager = nil;

// OpenCageManager
OpenCageManager *opencageManager = nil;

// LocalisationManager
LocalizationManager *localizationManager = nil;

// AudioManager
AudioManager *audioManager = nil;

// OwnTracksManager
OwnTracksManager *owntracksManager = nil;

//
AppDelegate *_AppDelegate;

void testcoordinates(void);
int main(int argc, char * argv[])
{
    srand((unsigned int)time(NULL));

    // This is only needed when checking coordinates
    // testcoordinates();

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

void testcoordinates(void)
{
    fileManager = [[NSFileManager alloc] init];
    db = [[database alloc] init];
    [db checkVersion];
    configManager = [[ConfigManager alloc] init];
    localizationManager = [[LocalizationManager alloc] init];

    for (NSInteger j = 0; j < 100000; j++) {
        CLLocationDegrees lat = 90 - ((arc4random() % 18000000) / 100000.0);
        CLLocationDegrees lon = 90 - ((arc4random() % 18000000) / 100000.0);
        Coordinates *c = [[Coordinates alloc] initWithDegrees:lat longitude:lon];

        for (NSInteger i = 0; i < COORDINATES_MAX; i++) {
            if ([Coordinates checkCoordinate:[c niceCoordinates:i] coordType:i] == NO)
                NSLog(@"%ld - %d - %@ (%f, %f)", (long)i, [Coordinates checkCoordinate:[c niceCoordinates:i] coordType:i], [c niceCoordinates:i], lat, lon);
        }
    }

    exit(0);
}
