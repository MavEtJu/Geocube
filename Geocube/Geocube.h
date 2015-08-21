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

#ifndef Geocube_Geocube_h
#define Geocube_Geocube_h

// Global menu
extern GlobalMenu *menuGlobal;

// Database handle
extern database *dbe;
extern DatabaseCache *dbc;

// Images
extern ImageLibrary *imageLibrary;

// Images Download Manager
extern ImagesDownloadManager *imagesDownloadManager;

// Current dbWaypoint to navitate to
extern CacheFilterManager *waypointManager;

// Location Manager
extern GCLocationManager *LM;

// File manager
extern NSFileManager *fm;

// Configuration Manager
extern MyConfig *myConfig;

//
extern AppDelegate *_AppDelegate;

// Theme
extern ThemeTemplate *currentTheme;

#endif
