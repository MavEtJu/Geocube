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

@interface dbTrackable ()

@end

@implementation dbTrackable

@synthesize _id, name, ref, gc_id, carrier, carrier_str, carrier_id, owner, owner_str, owner_id, waypoint_name, logtype, code;

- (void)finish
{
    NSAssert(NO, @"Use finish:account");
}

- (void)finish:(dbAccount *)account;
{
    if (carrier_id != 0)
        carrier = [dbName dbGet:carrier_id];
    if (carrier_str != nil)
        carrier = [dbName dbGetByName:carrier_str account:account];
    carrier_id = carrier._id;
    carrier_str = carrier.name;

    if (owner_id != 0)
        owner = [dbName dbGet:owner_id];
    if (owner_str != nil)
        owner = [dbName dbGetByName:owner_str account:account];
    owner_id = owner._id;
    owner_str = owner.name;
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


+ (NSArray *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray *)values
{
    NSMutableArray *tbs = [NSMutableArray arrayWithCapacity:20];

    NSString *sql = [NSString stringWithFormat:@"select id, name, ref, gc_id, carrier_id, owner_id, waypoint_name, log_type, code from travelbugs %@", where];

    @synchronized(db.dbaccess) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbTrackable *tb = [[dbTrackable alloc] init];
            INT_FETCH (0, tb._id);
            TEXT_FETCH(1, tb.name);
            TEXT_FETCH(2, tb.ref);
            INT_FETCH (3, tb.gc_id);
            INT_FETCH (4, tb.carrier_id);
            INT_FETCH (5, tb.owner_id);
            TEXT_FETCH(6, tb.waypoint_name);
            INT_FETCH (7, tb.logtype);
            TEXT_FETCH(8, tb.code);
            [tb finish:nil];    // can be nil because we have the _id's
            [tbs addObject:tb];
        }
        DB_FINISH;
    }
    return tbs;
}

+ (NSArray *)dbAllXXX:(NSString *)where
{
    return [dbTrackable dbAllXXX:where keys:nil values:nil];
}

+ (NSArray *)dbAll
{
    return [self dbAllXXX:@""];
}

+ (NSArray *)dbAllMine
{
    return [self dbAllXXX:@"where owner_id in (select id from names where name in (select accountname from accounts where accountname != ''))"];
}

+ (NSArray *)dbAllInventory
{
    return [self dbAllXXX:@"where carrier_id in (select id from names where name in (select accountname from accounts where accountname != ''))"];
}

+ (dbTrackable *)dbGet:(NSId)_id
{
    NSArray *as = [self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:_id]]];
    return [as objectAtIndex:0];
}

+ (NSInteger)dbCount
{
    return [dbTrackable dbCount:@"travelbugs"];
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id
{
    NSString *sql = [NSString stringWithFormat:@"where id in (select travelbug_id from travelbug2waypoint where waypoint_id = ?)"];
    return [self dbAllXXX:sql keys:@"i" values:@[[NSNumber numberWithLongLong:wp_id]]];
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

+ (dbTrackable *)dbGetByCode:(NSString *)code
{
    NSArray *tbs = [self dbAllXXX:@"where code = ?" keys:@"s" values:@[code]];
    if (tbs == nil)
        return nil;
    if ([tbs count] == 0)
        return nil;
    return [tbs objectAtIndex:0];
}

+ (dbTrackable *)dbGetByRef:(NSString *)ref
{
    NSArray *tbs = [self dbAllXXX:@"where ref = ?" keys:@"s" values:@[ref]];
    if (tbs == nil)
        return nil;
    if ([tbs count] == 0)
        return nil;
    return [tbs objectAtIndex:0];
}

- (NSId)dbCreate
{
    return [dbTrackable dbCreate:self];
}

+ (NSId)dbCreate:(dbTrackable *)tb
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into travelbugs(gc_id, ref, name, carrier_id, owner_id, waypoint_name, log_type, code) values(?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT (1, tb.gc_id);
        SET_VAR_TEXT(2, tb.ref);
        SET_VAR_TEXT(3, tb.name);
        SET_VAR_INT (4, tb.carrier_id);
        SET_VAR_INT (5, tb.owner_id);
        SET_VAR_TEXT(6, tb.waypoint_name);
        SET_VAR_INT (7, tb.logtype);
        SET_VAR_TEXT(8, tb.code);

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
        DB_PREPARE(@"update travelbugs set gc_id = ?, ref = ?, name = ?, carrier_id = ?, owner_id = ?, waypoint_name = ?, log_type = ?, code = ? where id = ?");

        SET_VAR_INT (1, gc_id);
        SET_VAR_TEXT(2, ref);
        SET_VAR_TEXT(3, name);
        SET_VAR_INT (4, carrier_id);
        SET_VAR_INT (5, owner_id);
        SET_VAR_TEXT(6, waypoint_name);
        SET_VAR_INT (7, logtype);
        SET_VAR_TEXT(8, code);
        SET_VAR_INT (9, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
