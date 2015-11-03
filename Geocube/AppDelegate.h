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

@interface AppDelegate : UIResponder <UITabBarControllerDelegate> {
    NSMutableArray *tabBars;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *tabBars;
@property (nonatomic) NSInteger currentTabBar;

- (void)switchController:(NSInteger)idx;


@end

#define RC_NAVIGATE 0
#define    VC_NAVIGATE_COMPASS 0
#define    VC_NAVIGATE_TARGET 1
#define    VC_NAVIGATE_MAP_GMAP 2
#define    VC_NAVIGATE_MAP_AMAP 3
#define    VC_NAVIGATE_MAP_OSM 4
#define RC_CACHESONLINE 1
#define RC_CACHESOFFLINE 2
#define    VC_CACHESOFFLINE_FILTERS 0
#define    VC_CACHESOFFLINE_LIST 1
#define    VC_CACHESOFFLINE_GMAP 2
#define    VC_CACHESOFFLINE_AMAP 3
#define    VC_CACHESOFFLINE_OSM 4
#define RC_NOTESANDLOGS 3
#define    VC_NOTESANDLOGS_PERSONALNOTES 0
#define    VC_NOTESANDLOGS_FIELDNOTES 1
#define    VC_NOTESANDLOGS_IMAGES 2
#define RC_TRACKABLES 4
#define RC_GROUPS 5
#define    VC_GROUPS_USERGROUPS 0
#define    VC_GROUPS_SYSTEMGROUPS 1
#define RC_BROWSER 6
#define    VC_BROWSER_USERS 0
#define    VC_BROWSER_QUERIES 1
#define    VC_BROWSER_BROWSER 2
#define RC_FILES 7
#define    VC_FILES_LOCALFILES 0
#define    VC_FILES_DROPBOX 1
#define    VC_FILES_ICLOUD 2
#define RC_USERPROFILE 8
#define RC_NOTICES 9
#define    VC_NOTICES 0
#define RC_SETTINGS 10
#define    VC_SETTINGS_SETTINGS 0
#define    VC_SETTINGS_ACCOUNTS 1
#define    VC_SETTINGS_COLOURS 2
#define RC_HELP 11
#define    VC_HELP_ABOUT 0
#define    VC_HELP_HELP 1
#define    VC_HELP_IMAGES 2
#define    VC_HELP_DATABASE 3
#define RC_KEEPTRACK 12
#define    VC_KEEPTRACK_CAR 0
#define    VC_KEEPTRACK_TRACKS 1
