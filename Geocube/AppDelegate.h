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

@interface AppDelegate : UIResponder <UITabBarControllerDelegate>

@property (nonatomic, retain) NSMutableArray *tabBars;
@property (nonatomic) NSInteger currentTabBar;

- (void)switchController:(NSInteger)idx;

@end

enum {
    RC_NAVIGATE = 0,
    RC_WAYPOINTS,
    RC_KEEPTRACK,
    RC_NOTESANDLOGS,
    RC_TRACKABLES,
    RC_GROUPS,
    RC_LISTS,
    RC_QUERIES,
    RC_FILES,
    RC_USERPROFILE,
    RC_BROWSER,
    RC_NOTICES,
    RC_SETTINGS,
    RC_HELP,
    RC_MAX,

    VC_NAVIGATE_COMPASS = 0,
    VC_NAVIGATE_TARGET,
    VC_NAVIGATE_MAP,
    VC_NAVIGATE_MAX,

    VC_WAYPOINTS_FILTERS = 0,
    VC_WAYPOINTS_LIST,
    VC_WAYPOINTS_MAP,
    VC_WAYPOINTS_MAj,

    VC_KEEPTRACK_CAR = 0,
    VC_KEEPTRACK_TRACKS,
    VC_KEEPTRACK_MAX,

    VC_NOTESANDLOGS_PERSONALNOTES = 0,
    VC_NOTESANDLOGS_FIELDNOTES,
    VC_NOTESANDLOGS_IMAGES,
    VC_NOTESANDLOGS_MAX,

    VC_GROUPS_USERGROUPS = 0,
    VC_GROUPS_SYSTEMGROUPS,
    VC_GROUPS_MAX,

    VC_BROWSER_USERS = 0,
    VC_BROWSER_QUERIES,
    VC_BROWSER_BROWSER,
    VC_BROWSER_MAX,

    VC_QUERIES_GS = 0,
    VC_QUERIES_GCA,
    VC_QUERIES_MAX,

    VC_FILES_LOCALFILES = 0,
    VC_FILES_MAX,

    VC_NOTICES_NOTICES = 0,
    VC_NOTICES_MAX,

    VC_SETTINGS_SETTINGS = 0,
    VC_SETTINGS_ACCOUNTS,
    VC_SETTINGS_COLOURS,
    VC_SETTINGS_MAX,

    VC_HELP_ABOUT = 0,
    VC_HELP_HELP,
    VC_HELP_IMAGES,
    VC_HELP_DATABASE,
    VC_HELP_MAX,

    VC_LISTS_HIGHLIGHT = 0,
    VC_LISTS_MARKEDFOUND,
    VC_LISTS_DNF,
    VC_LISTS_INPROGRESS,
    VC_LISTS_IGNORE,
};