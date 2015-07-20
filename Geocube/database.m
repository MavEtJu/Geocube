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

@implementation database

- (id)init
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];

    [self checkAndCreateDatabase:dbname empty:dbempty];
    dbO.dbaccess = self;

    sqlite3_open([dbempty UTF8String], &db);
    dbO.db = db;
    dbConfig *c_empty = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    sqlite3_open([dbname UTF8String], &db);
    dbO.db = db;
    dbConfig *c_real = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value compare:c_empty.value] != NSOrderedSame) {
        NSLog(@"Empty is newer, overwriting old one");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase:dbname empty:dbempty];
    }

    sqlite3_open([dbname UTF8String], &db);
    dbO.db = db;

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

- (dbCacheGroup *)CacheGroups_get_byName:(NSString *)name
{
    NSString *sql = @"select id, name, usergroup from cache_groups where name = ?";
    sqlite3_stmt *req;
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbCacheGroup alloc] init:_id name:name usergroup:ug];
        }
        sqlite3_finalize(req);
    }
    return wpg;
}

- (NSMutableArray *)CacheGroups_all
{
    NSString *sql = @"select id, name, usergroup from cache_groups";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbCacheGroup alloc] init:_id name:name usergroup:ug];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSArray *)CacheGroups_all_byCacheId:(NSInteger)wp_id
{
    NSString *sql = @"select cache_group_id from cache_group2caches where cache_id = ?";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wp_id);

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, wpgid);
            wpg = [dbc CacheGroup_get:wpgid];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSInteger)CacheGroups_count_caches:(NSInteger)wpgid
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

- (void)CacheGroups_new:(NSString *)name isUser:(BOOL)isUser
{
    NSString *sql = @"insert into cache_groups(name, usergroup) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);
        SET_VAR_BOOL(req, 2, isUser);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_delete:(NSInteger)_id
{
    NSString *sql = @"delete from cache_groups where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_empty:(NSInteger)_id
{
    NSString *sql = @"delete from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_rename:(NSInteger)_id newName:(NSString *)newname
{
    NSString *sql = @"update cache_groups set name = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, newname);
        SET_VAR_INT(req, 2, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_add_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid
{
    NSString *sql = @"insert into cache_group2caches(cache_group_id, cache_id) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);
        SET_VAR_INT(req, 2, wpid);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (BOOL)CacheGroups_contains_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ? and cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);
        SET_VAR_INT(req, 2, wpid);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count == 0 ? NO : YES;
}

// ------------------------



@end
