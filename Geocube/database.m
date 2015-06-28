//
//  database.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <sqlite3.h>
#import <Foundation/Foundation.h>
#import "dbObjectConfig.h"
#import "dbObjectWaypoint.h"
#import "dbObjectWaypointType.h"
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
#define SET_VAR_TEXT(req, col, string) \
    if (sqlite3_bind_text(req, col, [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_TEXT: %s", sqlite3_errmsg(db));


- (id)init
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", DocumentRoot(), DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", DataDistributionDirectory(), DB_EMPTY];
    
    [self checkAndCreateDatabase:dbname empty:dbempty];
    sqlite3_open([dbname UTF8String], &db);

    dbObjectConfig *c = [self config_get:@"version"];
    NSLog(@"Database version %@.", c.value);
    
    return self;
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

- (NSArray *)waypointtypes_all
{
    NSString *sql = @"select id, type, icon from waypoint_types";
    sqlite3_stmt *req;
    
    dbObjectWaypointType *wpt;
    NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:20];
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"config_get:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, type);
            TEXT_FETCH_AND_ASSIGN(req, 2, icon);
            wpt = [[dbObjectWaypointType alloc] init:_id type:type icon:icon];
            [a addObject:wpt];
        }
    }
    sqlite3_finalize(req);
    return a;
}

@end
