/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

#import "dbTrackable.h"

#import "Geocube-defines.h"

#import "DatabaseLibrary/dbName.h"
#import "DatabaseLibrary/dbWaypoint.h"

@interface dbTrackable ()

@end

@implementation dbTrackable

TABLENAME(@"travelbugs")

- (void)set_carrier_str:(NSString *)name account:(dbAccount *)account
{
    ASSERT_FIELD_EXISTS(account);
    self.carrier = [dbName dbGetByName:name account:account];
}
- (void)set_owner_str:(NSString *)name account:(dbAccount *)account
{
    ASSERT_FIELD_EXISTS(account);
    self.owner = [dbName dbGetByName:name account:account];
}

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(carrier);
    ASSERT_SELF_FIELD_EXISTS(owner);
    @synchronized(db) {
        DB_PREPARE(@"insert into travelbugs(gc_id, ref, name, carrier_id, owner_id, waypoint_name, log_type, code) values(?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT (1, self.gc_id);
        SET_VAR_TEXT(2, self.ref);
        SET_VAR_TEXT(3, self.name);
        SET_VAR_INT (4, self.carrier._id);
        SET_VAR_INT (5, self.owner._id);
        SET_VAR_TEXT(6, self.waypoint_name);
        SET_VAR_INT (7, self.logtype);
        SET_VAR_TEXT(8, self.code);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update travelbugs set gc_id = ?, ref = ?, name = ?, carrier_id = ?, owner_id = ?, waypoint_name = ?, log_type = ?, code = ? where id = ?");

        SET_VAR_INT (1, self.gc_id);
        SET_VAR_TEXT(2, self.ref);
        SET_VAR_TEXT(3, self.name);
        SET_VAR_INT (4, self.carrier._id);
        SET_VAR_INT (5, self.owner._id);
        SET_VAR_TEXT(6, self.waypoint_name);
        SET_VAR_INT (7, self.logtype);
        SET_VAR_TEXT(8, self.code);
        SET_VAR_INT (9, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray<dbTrackable *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbTrackable *> *tbs = [NSMutableArray arrayWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, ref, gc_id, carrier_id, owner_id, waypoint_name, log_type, code from travelbugs "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbTrackable *tb = [[dbTrackable alloc] init];
            INT_FETCH (0, tb._id);
            TEXT_FETCH(1, tb.name);
            TEXT_FETCH(2, tb.ref);
            INT_FETCH (3, tb.gc_id);
            INT_FETCH (4, i);
            tb.carrier = [dbName dbGet:i];
            INT_FETCH (5, i);
            tb.owner = [dbName dbGet:i];
            TEXT_FETCH(6, tb.waypoint_name);
            INT_FETCH (7, tb.logtype);
            TEXT_FETCH(8, tb.code);
            [tb finish];
            [tbs addObject:tb];
        }
        DB_FINISH;
    }
    return tbs;
}

+ (NSArray<dbTrackable *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbTrackable *> *)dbAllMine
{
    return [self dbAllXXX:@"where owner_id in (select accountname_id from accounts where accountname_id != 0)" keys:nil values:nil];
}

+ (NSArray<dbTrackable *> *)dbAllInventory
{
    return [self dbAllXXX:@"where carrier_id in (select accountname_id from accounts where accountname_id != 0)" keys:nil values:nil];
}

+ (NSArray<dbTrackable *> *)dbAllByWaypoint:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where id in (select travelbug_id from travelbug2waypoint where waypoint_id = ?)" keys:@"i" values:@[[NSNumber numberWithLongLong:wp._id]]];
}

+ (dbTrackable *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:_id]]] firstObject];
}

+ (NSId)dbGetIdByGC:(NSInteger)gc_id
{
    return [[self dbAllXXX:@"where gc_id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:gc_id]]] firstObject]._id;
}

+ (dbTrackable *)dbGetByCode:(NSString *)code
{
    return [[self dbAllXXX:@"where code = ?" keys:@"s" values:@[code]] firstObject];
}

+ (dbTrackable *)dbGetByRef:(NSString *)ref
{
    return [[self dbAllXXX:@"where ref = ?" keys:@"s" values:@[ref]] firstObject];
}

/* Other methods */

+ (void)dbUnlinkAllFromWaypoint:(dbWaypoint *)wp
{
    @synchronized(db) {
        DB_PREPARE(@"delete from travelbug2waypoint where waypoint_id = ?");

        SET_VAR_INT(1, wp._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(dbWaypoint *)wp
{
    @synchronized(db) {
        DB_PREPARE(@"insert into travelbug2waypoint(travelbug_id, waypoint_id) values(?, ?)");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, wp._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
