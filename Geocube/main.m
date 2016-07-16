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

#import "Geocube-Prefix.pch"

// Global menu management
GlobalMenu *menuGlobal;

// Database handle
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
NSFileManager *fm = nil;

// IOS File Transfer Manager
IOSFileTransfers *IOSFTM;

// Configuration manager
MyConfig *myConfig = nil;

// Webbrowser
MHTabBarController *tbc = nil;
BrowserBrowserViewController *bbvc = nil;

// Download manager and view controller
MHTabBarController *downloadTabController;
DownloadsViewController *downloadViewController;
DownloadManager *downloadManager;

//
AppDelegate *_AppDelegate;

// Hardware models
NSInteger hardwaremodel = hardwareModelUnknown;

int main(int argc, char * argv[])
{
    UIDevice *device = [UIDevice currentDevice];
    hardwaremodel = hardwareModelUnknown;
    if ([device.model containsString:@"iPad"] == YES)
        hardwaremodel = hardwareModelIPad;
    if ([device.model containsString:@"iPhone"] == YES)
        hardwaremodel = hardwareModelIPhone;
    if ([device.model containsString:@"iPod"] == YES)
        hardwaremodel = hardwareModelIPod;

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}