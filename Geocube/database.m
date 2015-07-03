//
//  database.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <sqlite3.h>
#import <Foundation/Foundation.h>
#import "Geocube.h"
#import "dbObjects.h"
#import "database.h"
#import "My Tools.h"

@implementation database

#define TEXT_FETCH_AND_ASSIGN(req, col, string) \
    NSString *string = nil; \
    { \
        char *s = (char *)sqlite3_column_text(req, col); \
        if (s == NULL) \
            string = nil; \
        else \
            string = [[NSString alloc] initWithUTF8String:s]; \
    }
#define INT_FETCH_AND_ASSIGN(req, col, string) \
    NSInteger string = sqlite3_column_int(req, col);

#define SET_VAR_INT(req, col, string) \
    if (sqlite3_bind_int(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_INT: %s", sqlite3_errmsg(db));
#define SET_VAR_NSINTEGER(req, col, string) \
    if (sqlite3_bind_int64(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_INT: %s", sqlite3_errmsg(db));
#define SET_VAR_TEXT(req, col, string) \
    if (sqlite3_bind_text(req, col, [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_TEXT: %s", sqlite3_errmsg(db));


- (id)init
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];
    
    [self checkAndCreateDatabase:dbname empty:dbempty];
    
    sqlite3_open([dbempty UTF8String], &db);
    dbObjectConfig *c_empty = [self config_get:@"version"];
    sqlite3_close(db);
    
    sqlite3_open([dbname UTF8String], &db);
    dbObjectConfig *c_real = [self config_get:@"version"];
    sqlite3_close(db);
    
    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value compare:c_empty.value] != NSOrderedSame) {
        NSLog(@"Empty is newer, overwriting old one");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase:dbname empty:dbempty];
    }

    sqlite3_open([dbname UTF8String], &db);
    return self;
}

// Load all waypoints and waypoint related data in memory
- (void)loadWaypointData
{
    WaypointGroups = [self WaypointGroups_all];
    WaypointTypes = [self WaypointTypes_all];
    Waypoints = [self Waypoints_all];

    WaypointGroup_AllWaypoints = nil;
    WaypointGroup_AllWaypoints_Found = nil;
    WaypointGroup_AllWaypoints_NotFound = nil;
    WaypointGroup_LastImport = nil;
    WaypointGroup_LastImportAdded = nil;
    WaypointType_Unknown = nil;

    NSEnumerator *e = [WaypointGroups objectEnumerator];
    dbObjectWaypointGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints - Found"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints_Found = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"All Waypoints - Not Found"] == NSOrderedSame) {
            WaypointGroup_AllWaypoints_NotFound = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import"] == NSOrderedSame) {
            WaypointGroup_LastImport = wpg;
            continue;
        }
        if (wpg.usergroup == 0 && [wpg.name compare:@"Last Import - New"] == NSOrderedSame) {
            WaypointGroup_LastImportAdded = wpg;
            continue;
        }
    }

    e = [WaypointTypes objectEnumerator];
    dbObjectWaypointType *wpt;
    while ((wpt = [e nextObject]) != nil) {
        if ([wpg.name compare:@"*"] == NSOrderedSame) {
            WaypointType_Unknown = wpt;
            continue;
        }
    }
}

- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty
{
    BOOL success;
    NSFileManager *fm = [[NSFileManager alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database on user request.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        [fm removeItemAtPath:dbname error:NULL];
    }
    
    success = [fm fileExistsAtPath:dbname];
    if (success == NO) {
        [fm copyItemAtPath:dbempty toPath:dbname error:nil];
        NSLog(@"Initializing database from %@ to %@.", dbempty, dbname);
    }
}


- (void)dealloc
{
    sqlite3_close(db);
}

// ------------------------

- (dbObjectConfig *)config_get:(NSString *)key
{
    NSString *sql = @"select id, key, value from config where key = ?";
    sqlite3_stmt *req;
    
    dbObjectConfig *c;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"config_get:prepare: %s", sqlite3_errmsg(db));
        SET_VAR_TEXT(req, 1, key);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, key);
            TEXT_FETCH_AND_ASSIGN(req, 2, value);
            c = [[dbObjectConfig alloc] init:_id key:key value:value];
        }
        sqlite3_finalize(req);
    }
    return c;
}

- (void)config_update:(NSString *)key value:(NSString *)value
{
    NSString *sql = @"update config set value = ? where key = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"config_update:prepare: %s", sqlite3_errmsg(db));

        SET_VAR_TEXT(req, 1, value);
        SET_VAR_TEXT(req, 2, key);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"onfig_update:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

// ------------------------

- (dbObjectWaypointGroup *)WaypointGroups_get_byName:(NSString *)name
{
    NSString *sql = @"select id, name, usergroup from waypoint_groups where name = ?";
    sqlite3_stmt *req;
    dbObjectWaypointGroup *wpg;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_get_byNamee:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, name);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbObjectWaypointGroup alloc] init:_id name:name usergroup:ug];
        }
        sqlite3_finalize(req);
    }
    return wpg;
}

- (NSMutableArray *)WaypointGroups_all
{
    NSString *sql = @"select id, name, usergroup from waypoint_groups";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbObjectWaypointGroup *wpg;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbObjectWaypointGroup alloc] init:_id name:name usergroup:ug];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSInteger)WaypointGroups_count_waypoints:(NSInteger)wpgid
{
    NSString *sql = @"select count(id) from waypoint_groups2waypoints where waypoint_group_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_count_waypoints:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_NSINTEGER(req, 1, wpgid);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

- (void)WaypointGroups_new:(NSString *)name isUser:(BOOL)isUser
{
    NSString *sql = @"insert into waypoint_groups(name, usergroup) values(?, ?)";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_new:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, name);
        SET_VAR_INT(req, 2, isUser);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_new:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_delete:(NSInteger)_id
{
    NSString *sql = @"delete from waypoint_groups where id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_delete:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_NSINTEGER(req, 1, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_delete:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_empty:(NSInteger)_id
{
    NSString *sql = @"delete from waypoint_groups2waypoints where waypoint_group_id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_empty:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_NSINTEGER(req, 1, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_empty:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_rename:(NSInteger)_id newName:(NSString *)newname
{
    NSString *sql = @"update waypoint_groups set name = ? where id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_rename:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, newname);
        SET_VAR_NSINTEGER(req, 2, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_rename:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }

}


// ------------------------

- (dbObjectWaypointType *)WaypointTypes_get_byType:(NSString *)type
{
    NSString *sql = @"select id, type, icon from waypoint_types where type = ?";
    sqlite3_stmt *req;
    dbObjectWaypointType *wpt;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointTypes_get_byType:prepare %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, type);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, type);
            TEXT_FETCH_AND_ASSIGN(req, 2, icon);
            wpt = [[dbObjectWaypointType alloc] init:_id type:type icon:icon];
        }
        sqlite3_finalize(req);
    }
    return wpt;
}

- (NSMutableArray *)WaypointTypes_all
{
    NSString *sql = @"select id, type, icon from waypoint_types";
    sqlite3_stmt *req;
    NSMutableArray *wpts = [[NSMutableArray alloc] initWithCapacity:20];
    dbObjectWaypointType *wpt;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointTypes_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, type);
            TEXT_FETCH_AND_ASSIGN(req, 2, icon);
            wpt = [[dbObjectWaypointType alloc] init:_id type:type icon:icon];
            [wpts addObject:wpt];
        }
        sqlite3_finalize(req);
    }
    return wpts;
}

// ------------------------

- (NSMutableArray *)Waypoints_all
{
    NSString *sql = @"select id, name, description from waypoints";
    sqlite3_stmt *req;
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbObjectWaypoint *wp;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Waypoints_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            TEXT_FETCH_AND_ASSIGN(req, 2, desc);
            wp = [[dbObjectWaypoint alloc] init:_id];
            [wp setName:name];
            [wp setDescription:desc];
            [wps addObject:wp];
        }
        sqlite3_finalize(req);
    }
    return wps;
}



@end
