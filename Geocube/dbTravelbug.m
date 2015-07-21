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

@implementation dbTravelbug

@synthesize name, ref, gc_id;

- (id)init:(NSId)__id name:(NSString *)_name ref:(NSString *)_ref gc_id:(NSId)_gc_id
{
    self = [super init];

    name = _name;
    _id = __id;
    ref = _ref;
    gc_id = _gc_id;

    [self finish];
    return self;
}

+ (void)dbUnlinkAllFromCache:(NSId)cache_id
{
    NSString *sql = @"delete from travelbug2cache where cache_id = ?";
    sqlite3_stmt *req;
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, cache_id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        __id = sqlite3_last_insert_rowid(db.db);
        sqlite3_finalize(req);
    }
}

- (void)dbLinkToCache:(NSId)cache_id
{
    NSString *sql = @"insert into travelbug2cache(travelbug_id, cache_id) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);
        SET_VAR_INT(req, 2, cache_id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

+ (NSInteger)dbCountByCache:(NSId)cache_id
{
    NSString *sql = @"select count(id) from travelbug2cache where cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, cache_id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

+ (NSArray *)dbAllByCache:(NSId)cache_id
{
    NSString *sql = @"select id, name, ref, gc_id from travelbugs where id in (select travelbug_id from travelbug2cache where cache_id = ?)";
    sqlite3_stmt *req;
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbTravelbug *tb;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, cache_id);

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            TEXT_FETCH_AND_ASSIGN(req, 2, ref);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            tb = [[dbTravelbug alloc] init:_id name:name ref:ref gc_id:gc_id];
            [ss addObject:tb];
        }
        sqlite3_finalize(req);
    }
    return ss;
}

+ (NSId)dbGetIdByGC:(NSId)_gc_id
{
    NSString *sql = @"select id from travelbugs where gc_id = ?";
    sqlite3_stmt *req;
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _gc_id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, ___id);
            __id = ___id;
        }
        sqlite3_finalize(req);
    }
    return __id;
}

- (NSId)dbCreate
{
    return [dbTravelbug dbCreate:self];
}

+ (NSId)dbCreate:(dbTravelbug *)tb
{
    NSString *sql = @"insert into travelbugs(gc_id, ref, name) values(?, ?, ?)";
    sqlite3_stmt *req;
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, tb.gc_id);
        SET_VAR_TEXT(req, 2, tb.ref);
        SET_VAR_TEXT(req, 3, tb.name);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        __id = sqlite3_last_insert_rowid(db.db);
        sqlite3_finalize(req);
    }
    return __id;
}

- (void)dbUpdate
{
    NSString *sql = @"update travelbugs set gc_id = ?, ref = ?, name = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, gc_id);
        SET_VAR_TEXT(req, 2, ref);
        SET_VAR_TEXT(req, 3, name);
        SET_VAR_INT(req, 4, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

@end
