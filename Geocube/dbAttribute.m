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

@interface dbAttribute ()

@end

@implementation dbAttribute

- (instancetype)init:(NSId)_id gc_id:(NSId)gc_id label:(NSString *)label icon:(NSInteger)icon
{
    self = [super init];

    self.icon = icon;
    self.label = label;
    self.gc_id = gc_id;
    self._id = _id;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, label, gc_id, icon from attributes");

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH (2, a.gc_id);
            INT_FETCH (3, a.icon);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update attributes set label = ?, icon = ? where id = ?");

        SET_VAR_TEXT(1, self.label);
        SET_VAR_INT (2, self.icon);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (NSId)dbCreate
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into attributes(label, gc_id, icon) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.label);
        SET_VAR_INT (2, self.gc_id);
        SET_VAR_INT (3, self.icon);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        self._id = _id;
        DB_FINISH;
    }
    return self._id;
}

+ (NSInteger)dbCount
{
    return [dbAttribute dbCount:@"attributes"];
}

//

+ (void)dbUnlinkAllFromWaypoint:(NSId)wp_id
{
    NSId __id = 0;

    @synchronized(db) {
        DB_PREPARE(@"delete from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
}

- (void)dbLinkToWaypoint:(NSId)wp_id YesNo:(BOOL)YesNo
{
    @synchronized(db) {
        DB_PREPARE(@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values(?, ?, ?)");

        SET_VAR_INT (1, self._id);
        SET_VAR_INT (2, wp_id);
        SET_VAR_BOOL(3, YesNo);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbAllLinkToWaypoint:(NSId)wp_id attributes:(NSArray *)attrs YesNo:(BOOL)YesNo
{
    if ([attrs count] == 0)
        return;

    __block NSMutableString *sql = [NSMutableString stringWithString:@"insert into attribute2waypoints(attribute_id, waypoint_id, yes) values "];
    [attrs enumerateObjectsUsingBlock:^(dbAttribute *attr, NSUInteger idx, BOOL *stop) {
        if (idx != 0)
            [sql appendString:@","];
        [sql appendFormat:@"(%ld, %ld, %d)", (long)attr._id, (long)wp_id, YesNo];
    }];
    @synchronized(db) {
        DB_PREPARE(sql);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from attribute2waypoints where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByWaypoint:(NSId)wp_id
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select a.id, a.label, a.icon, a.gc_id, b.yes from attributes a inner join attribute2waypoints b on a.id = b.attribute_id where b.waypoint_id = ?");

        SET_VAR_INT( 1, wp_id);

        DB_WHILE_STEP {
            dbAttribute *a = [[dbAttribute alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.label);
            INT_FETCH (2, a.icon);
            INT_FETCH (3, a.gc_id);
            INT_FETCH (4, a._YesNo);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

@end
