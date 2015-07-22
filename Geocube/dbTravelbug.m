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

+ (void)dbUnlinkAllFromWaypoint:(NSId)wp_id
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(req, 1, wp_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(NSId)wp_id
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into travelbug2waypoint(travelbug_id, waypoint_id) values(?, ?)");

        SET_VAR_INT(req, 1, _id);
        SET_VAR_INT(req, 2, wp_id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(req, 1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbTravelbug *tb;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, ref, gc_id from travelbugs where id in (select travelbug_id from travelbug2waypoint where waypoint_id = ?)");

        SET_VAR_INT(req, 1, wp_id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            TEXT_FETCH_AND_ASSIGN(req, 2, ref);
            INT_FETCH_AND_ASSIGN(req, 2, gc_id);
            tb = [[dbTravelbug alloc] init:_id name:name ref:ref gc_id:gc_id];
            [ss addObject:tb];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSId)dbGetIdByGC:(NSId)_gc_id
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from travelbugs where gc_id = ?");

        SET_VAR_INT(req, 1, _gc_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, ___id);
            __id = ___id;
        }
        DB_FINISH;
    }
    return __id;
}

- (NSId)dbCreate
{
    return [dbTravelbug dbCreate:self];
}

+ (NSId)dbCreate:(dbTravelbug *)tb
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into travelbugs(gc_id, ref, name) values(?, ?, ?)");

        SET_VAR_INT(req, 1, tb.gc_id);
        SET_VAR_TEXT(req, 2, tb.ref);
        SET_VAR_TEXT(req, 3, tb.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update travelbugs set gc_id = ?, ref = ?, name = ? where id = ?");

        SET_VAR_INT(req, 1, gc_id);
        SET_VAR_TEXT(req, 2, ref);
        SET_VAR_TEXT(req, 3, name);
        SET_VAR_INT(req, 4, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
