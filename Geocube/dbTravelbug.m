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
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(NSId)wp_id
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into travelbug2waypoint(travelbug_id, waypoint_id) values(?, ?)");

        SET_VAR_INT(1, _id);
        SET_VAR_INT(2, wp_id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}


+ (NSArray *)dbAll
{
    NSMutableArray *tbs = [NSMutableArray arrayWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, ref, gc_id from travelbugs");

        DB_WHILE_STEP {
            dbTravelbug *tb = [[dbTravelbug alloc] init];
            INT_FETCH(0, tb._id);
            TEXT_FETCH(1, tb.name);
            TEXT_FETCH(2, tb.ref);
            INT_FETCH(2, tb.gc_id);
            [tbs addObject:tb];
        }
        DB_FINISH;
    }
    return tbs;
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, ref, gc_id from travelbugs where id in (select travelbug_id from travelbug2waypoint where waypoint_id = ?)");

        SET_VAR_INT(1, wp_id);

        DB_WHILE_STEP {
            dbTravelbug *tb = [[dbTravelbug alloc] init];;
            INT_FETCH(0, tb._id);
            TEXT_FETCH(1, tb.name);
            TEXT_FETCH(2, tb.ref);
            INT_FETCH(2, tb.gc_id);
            [ss addObject:tb];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSId)dbGetIdByGC:(NSId)_gc_id
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from travelbugs where gc_id = ?");

        SET_VAR_INT(1, _gc_id);

        DB_IF_STEP {
            INT_FETCH(0, _id);
        }
        DB_FINISH;
    }
    return _id;
}

- (NSId)dbCreate
{
    return [dbTravelbug dbCreate:self];
}

+ (NSId)dbCreate:(dbTravelbug *)tb
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into travelbugs(gc_id, ref, name) values(?, ?, ?)");

        SET_VAR_INT( 1, tb.gc_id);
        SET_VAR_TEXT(2, tb.ref);
        SET_VAR_TEXT(3, tb.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    tb._id = _id;
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update travelbugs set gc_id = ?, ref = ?, name = ? where id = ?");

        SET_VAR_INT( 1, gc_id);
        SET_VAR_TEXT(2, ref);
        SET_VAR_TEXT(3, name);
        SET_VAR_INT( 4, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
