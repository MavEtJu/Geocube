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

@synthesize _id, name, ref, gc_id;

- (id)init:(NSInteger)__id name:(NSString *)_name ref:(NSString *)_ref gc_id:(NSInteger)_gc_id
{
    self = [super init];

    name = _name;
    _id = __id;
    ref = _ref;
    gc_id = _gc_id;

    [self finish];
    return self;
}

+ (NSArray *)XXdbAll
{
    NSString *sql = @"select id, label, gc_id, icon from attributes";
    sqlite3_stmt *req;
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbAttribute *s;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, label);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            INT_FETCH_AND_ASSIGN(req, 3, icon);
            s = [[dbAttribute alloc] init:_id gc_id:gc_id label:label icon:icon];
            [ss addObject:s];
        }
        sqlite3_finalize(req);
    }
    return ss;
}

+ (void)dbUnlinkAllFromCache:(NSInteger)cache_id
{
    NSString *sql = @"delete from travelbug2cache where cache_id = ?";
    sqlite3_stmt *req;
    NSInteger __id = 0;

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

- (void)dbLinkToCache:(NSInteger)cache_id
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

+ (NSInteger)dbCountByCache:(NSInteger)cache_id
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

+ (NSArray *)XXdbAllByCache:(NSInteger)cache_id
{
    NSString *sql = @"select id, label, icon, gc_id from attributes where id in (select attribute_id from attribute2cache where cache_id = ?)";
    sqlite3_stmt *req;
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbAttribute *s;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, cache_id);

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, label);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            s = [[dbAttribute alloc] init:_id gc_id:gc_id label:label icon:icon];
            [ss addObject:s];
        }
        sqlite3_finalize(req);
    }
    return ss;
}

+ (NSInteger)dbGetIdByGC:(NSInteger)_gc_id
{
    NSString *sql = @"select id from travelbugs where gc_id = ?";
    sqlite3_stmt *req;
    NSInteger __id = 0;

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

- (NSInteger)dbCreate
{
    return [dbTravelbug dbCreate:self];
}

+ (NSInteger)dbCreate:(dbTravelbug *)tb
{
    NSString *sql = @"insert into travelbugs(gc_id, ref, name) values(?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger __id = 0;

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

@end
