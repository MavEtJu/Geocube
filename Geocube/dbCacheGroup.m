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

@implementation dbCacheGroup

@synthesize _id, name, usergroup;

- (id)init:(NSInteger)__id name:(NSString *)_name usergroup:(BOOL)_usergroup
{
    self = [super init];
    _id = __id;
    name = _name;
    usergroup = _usergroup;
    [self finish];
    return self;
}

- (void)dbEmpty
{
    NSString *sql = @"delete from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}


+ (dbCacheGroup *)dbGetByName:(NSString *)name
{
    NSString *sql = @"select id, name, usergroup from cache_groups where name = ?";
    sqlite3_stmt *req;
    dbCacheGroup *wpg;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

+ (NSMutableArray *)dbAll
{
    NSString *sql = @"select id, name, usergroup from cache_groups";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _name);
            INT_FETCH_AND_ASSIGN(req, 2, _ug);
            wpg = [[dbCacheGroup alloc] init:__id name:_name usergroup:_ug];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

+ (NSArray *)dbAllByCache:(NSInteger)wp_id
{
    NSString *sql = @"select cache_group_id from cache_group2caches where cache_id = ?";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

- (NSInteger)dbCountCaches
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, self._id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

+ (NSInteger)dbCreate:(NSString *)_name isUser:(BOOL)_usergroup
{
    NSString *sql = @"insert into cache_groups(name, usergroup) values(?, ?)";
    sqlite3_stmt *req;
    NSInteger __id;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, _name);
        SET_VAR_BOOL(req, 2, _usergroup);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        __id = sqlite3_last_insert_rowid(db.db);
        sqlite3_finalize(req);
    }
    return __id;
}

- (void)dbDelete
{
    [dbCacheGroup dbDelete:self._id];
}

+ (void)dbDelete:(NSInteger)__id
{
    NSString *sql = @"delete from cache_groups where id = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, __id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)dbUpdateName:(NSString *)newname
{
    NSString *sql = @"update cache_groups set name = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, newname);
        SET_VAR_INT(req, 2, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)dbAddCache:(NSInteger)__id
{
    NSString *sql = @"insert into cache_group2caches(cache_group_id, cache_id) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, self._id);
        SET_VAR_INT(req, 2, __id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (BOOL)dbContainsCache:(NSInteger)c_id
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ? and cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, self._id);
        SET_VAR_INT(req, 2, c_id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count == 0 ? NO : YES;
}

@end
