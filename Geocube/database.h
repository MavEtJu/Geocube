//
//  database.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_database_h
#define Geocube_database_h

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"


@interface database : NSObject {   
    sqlite3 *db;
    id dbaccess;
};

- (id)init;
- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;

- (dbWaypointGroup *)WaypointGroups_get_byName:(NSString *)name;
- (NSInteger)WaypointGroups_count_waypoints:(NSInteger)wpgid;
- (void)WaypointGroups_new:(NSString *)name isUser:(BOOL)isUser;
- (void)WaypointGroups_delete:(NSInteger)_id;
- (void)WaypointGroups_empty:(NSInteger)_id;
- (void)WaypointGroups_rename:(NSInteger)_id newName:(NSString *)newname;
- (void)WaypointGroups_add_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid;
- (BOOL)WaypointGroups_contains_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid;
- (NSArray *)WaypointGroups_all;

- (NSInteger)Waypoint_get_byname:(NSString *)name;
- (NSInteger)Waypoint_add:(dbWaypoint *)wp;
- (void)Waypoint_update:(dbWaypoint *)wp;
- (NSArray *)Waypoints_all;

- (NSInteger)Log_by_gcid:(NSInteger)gc_id;
- (NSInteger)Logs_add:(dbLog *)log;
- (void)Logs_update:(NSInteger)_id log:(dbLog *)log;
- (void)Logs_update_waypoint_id:(dbLog *)log waypoint_id:(NSInteger)wp_id;
- (NSInteger)Logs_count_byWaypoint_id:(NSInteger)wp_id;
- (NSArray *)Logs_all_bywaypointid:(NSInteger)wp_id;

- (NSArray *)WaypointTypes_all;
- (NSArray *)ContainerTypes_all;
- (NSArray *)LogTypes_all;


#define TEXT_FETCH_AND_ASSIGN(req, col, string) \
    NSString *string = nil; \
    { \
        char *s = (char *)sqlite3_column_text(req, col); \
        if (s == NULL) \
            string = nil; \
        else \
            string = [[NSString alloc] initWithUTF8String:s]; \
    }
#define BOOL_FETCH_AND_ASSIGN(req, col, string) \
    BOOL string = sqlite3_column_int(req, col);
#define INT_FETCH_AND_ASSIGN(req, col, string) \
    NSInteger string = sqlite3_column_int(req, col);
#define DOUBLE_FETCH_AND_ASSIGN(req, col, string) \
    double string = sqlite3_column_double(req, col);

#define SET_VAR_BOOL(req, col, string) \
    if (sqlite3_bind_int(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_BOOL: %s", sqlite3_errmsg(db));
#define SET_VAR_INT(req, col, string) \
    if (sqlite3_bind_int64(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_INT: %s", sqlite3_errmsg(db));

#define SET_VAR_TEXT(req, col, string) \
    if (sqlite3_bind_text(req, col, [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_TEXT: %s", sqlite3_errmsg(db));
#define SET_VAR_DOUBLE(req, col, string) \
    if (sqlite3_bind_double(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_DOUBLE: %s", sqlite3_errmsg(db));

@end

#endif
