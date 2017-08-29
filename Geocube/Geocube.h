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

#ifndef Geocube_Geocube_h
#define Geocube_Geocube_h

// Global menu management
extern SideMenu *menuGlobal;

// Database handle and cache
extern database *db;
extern DatabaseCache *dbc;

// Images
extern ImageLibrary *imageLibrary;

// Images Download Manager
extern ImagesDownloadManager *imagesDownloadManager;

// Current dbWaypoint to navitate to
extern WaypointManager *waypointManager;

// Location Manager
extern LocationManager *LM;

// File manager
extern NSFileManager *fileManager;

// IOS FileTransfer Manager
extern IOSFileTransfers *IOSFTM;

// Bezel Manager
extern BezelManager *bezelManager;

// Configuration Manager
extern ConfigManager *configManager;

// Webbrowser
extern MHTabBarController *browserTabController;
extern BrowserBrowserViewController *browserViewController;

// Keep Track Map
extern MHTabBarController *keepTrackTabController;
extern MapTrackViewController *keepTrackMapViewController;

// Locationless Map
extern MHTabBarController *locationlessMapTabController;
extern MapLogsViewController *locationlessMapViewController;

// Download and Import manager
extern DownloadManager *downloadManager;
extern ImportManager *importManager;

// Keymanager
extern KeyManager *keyManager;

// OpenCageManager
extern OpenCageManager *opencageManager;

// LocalisationManager
extern LocalizationManager *localizationManager;

// AudioManager
extern AudioManager *audioManager;

//
extern AppDelegate *_AppDelegate;

#endif
