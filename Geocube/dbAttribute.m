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

@implementation dbAttribute

@synthesize _id, icon, label, gc_id, _YesNo;

- (id)init:(NSInteger)__id gc_id:(NSInteger)_gc_id label:(NSString *)_label icon:(NSInteger)_icon
{
    self = [super init];

    icon = _icon;
    label = _label;
    gc_id = _gc_id;
    _id = __id;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSString *sql = @"select id, label, gc_id, icon from attributes";
    sqlite3_stmt *req;
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbAttribute *s;

    @synchronized(dbO.dbaccess) {
        if (sqlite3_prepare_v2(dbO.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

//

+ (void)dbUnlinkAllFromCache:(NSInteger)cache_id
{
    NSString *sql = @"delete from attribute2cache where cache_id = ?";
    sqlite3_stmt *req;
    NSInteger __id = 0;

    @synchronized(dbO.dbaccess) {
        if (sqlite3_prepare_v2(dbO.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, cache_id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        __id = sqlite3_last_insert_rowid(dbO.db);
        sqlite3_finalize(req);
    }
}

- (void)dbLinkToCache:(NSInteger)cache_id YesNo:(BOOL)YesNO
{
    NSString *sql = @"insert into attribute2cache(attribute_id, cache_id, yes ) values(?, ?, ?)";
    sqlite3_stmt *req;

    @synchronized(dbO.dbaccess) {
        if (sqlite3_prepare_v2(dbO.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);
        SET_VAR_INT(req, 2, cache_id);
        SET_VAR_BOOL(req, 3, YesNO);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

+ (NSInteger)dbCountByCache:(NSInteger)cache_id
{
    NSString *sql = @"select count(id) from attribute2cache where cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbO.dbaccess) {
        if (sqlite3_prepare_v2(dbO.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

+ (NSArray *)dbAllByCache:(NSInteger)cache_id
{
    NSString *sql = @"select id, label, icon, gc_id from attributes where id in (select attribute_id from attribute2cache where cache_id = ?)";
    sqlite3_stmt *req;
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbAttribute *s;

    @synchronized(dbO.dbaccess) {
        if (sqlite3_prepare_v2(dbO.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

@end
