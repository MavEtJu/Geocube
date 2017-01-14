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

// Global menu management
SideMenu *menuGlobal;

// Database handle and cache
database *db = nil;
DatabaseCache *dbc = nil;

// Image Library
ImageLibrary *imageLibrary = nil;

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

// Download manager
DownloadManager *downloadManager = nil;
ImportManager *importManager = nil;

//
AppDelegate *_AppDelegate;

int main(int argc, char * argv[])
{
    srand((unsigned int)time(NULL));

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
