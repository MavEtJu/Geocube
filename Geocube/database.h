//
//  database.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_database_h
#define Geocube_database_h

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "dbObjects.h"

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"


@interface database : NSObject {   
    sqlite3 *db;
    id dbaccess;
};

- (id)init;
- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;
- (void)loadWaypointData;

- (dbObjectWaypointGroup *)WaypointGroups_get_byName:(NSString *)name;
- (NSInteger)WaypointGroups_count_waypoints:(NSInteger)wpgid;
- (void)WaypointGroups_new:(NSString *)name isUser:(BOOL)isUser;
- (void)WaypointGroups_delete:(NSInteger)_id;
- (void)WaypointGroups_empty:(NSInteger)_id;
- (void)WaypointGroups_rename:(NSInteger)_id newName:(NSString *)newname;
- (void)WaypointGroups_add_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid;
- (BOOL)WaypointGroups_contains_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid;

- (NSInteger)Waypoint_get_byname:(NSString *)name;
- (NSInteger)Waypoint_add:(dbObjectWaypoint *)wp;
- (void)Waypoint_update:(dbObjectWaypoint *)wp;

@end

#endif
