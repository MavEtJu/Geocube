//
//  AppDelegate.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@class JASidePanelController;

@interface AppDelegate : UIResponder <UITabBarControllerDelegate> {
    NSMutableArray *tabBars;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JASidePanelController *viewController;
@property (nonatomic, retain) NSMutableArray *tabBars;

- (void)switchController:(NSInteger)idx;


@end

#define RC_NAVIGATE 0
#define    VC_NAVIGATE_COMPASS 0
#define    VC_NAVIGATE_DETAILS 1
#define    VC_NAVIGATE_MAP 2
#define RC_CACHESONLINE 1
#define RC_CACHESOFFLINE 2
#define    VC_CACHESONLINE_FILTERS 0
#define    VC_CACHESONLINE_LIST 1
#define    VC_CACHESONLINE_GMAP 2
#define    VC_CACHESONLINE_AMAP 3
#define    VC_CACHESONLINE_OSM 4
#define RC_NOTESANDLOGS 3
#define RC_TRACKABLES 4
#define RC_GROUPS 5
#define    VC_GROUPS_USERGROUPS 0
#define    VC_GROUPS_SYSTEMGROUPS 1
#define RC_BOOKMARKS 6
#define RC_FILES 7
#define    VC_FILES_LOCALFILES 0
#define    VC_FILES_DROPBOX 1
#define RC_USERPROFILE 8
#define RC_NOTICES 9
#define RC_SETTINGS 10
#define RC_HELP 11
#define    VC_HELP_HELP 0
#define    VC_HELP_IMAGES 1
