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

@interface dbGroup ()

@end

@implementation dbGroup

TABLENAME(@"groups")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into groups(name, usergroup, deletable) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_BOOL(2, self.usergroup);
        SET_VAR_BOOL(3, self.deletable);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdateName:(NSString *)newname
{
    @synchronized(db) {
        DB_PREPARE(@"update groups set name = ? where id = ?");

        SET_VAR_TEXT(1, newname);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbGroup *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbGroup *> *cgs = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, usergroup, deletable from groups "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbGroup *cg = [[dbGroup alloc] init];
            INT_FETCH (0, cg._id);
            TEXT_FETCH(1, cg.name);
            BOOL_FETCH(2, cg.usergroup);
            BOOL_FETCH(3, cg.deletable);
            [cgs addObject:cg];
        }
        DB_FINISH;
    }
    return cgs;
}

+ (NSArray<dbGroup *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbGroup *> *)dbAllByWaypoint:(NSId)wp_id
{
    return [self dbAllXXX:@"where id in (select group_id from group2waypoints where waypoint_id = ?)" keys:@"i" values:@[[NSNumber numberWithInteger:wp_id]]];
}

+ (NSArray<dbGroup *> *)dbAllByUserGroup:(BOOL)isUser
{
    return [self dbAllXXX:@"where usergroup = ?" keys:@"b" values:@[[NSNumber numberWithBool:isUser]]];
}

+ (dbGroup *)dbGetByName:(NSString *)name
{
    return [[self dbAllXXX:@"where name = ?" keys:@"s" values:@[name]] firstObject];
}

+ (dbGroup *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

/* Other methods */

- (void)emptyGroup
{
    @synchronized(db) {
        DB_PREPARE(@"delete from group2waypoints where group_id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (NSInteger)countWaypoints
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from group2waypoints where group_id = ?");

        SET_VAR_INT(1, self._id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

- (void)addWaypointToGroup:(dbWaypoint *)wp
{
    @synchronized(db) {
        DB_PREPARE(@"insert into group2waypoints(group_id, waypoint_id) values(?, ?)");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, wp._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)removeWaypointFromGroup:(dbWaypoint *)wp
{
    @synchronized(db) {
        DB_PREPARE(@"delete from group2waypoints where group_id = ? and waypoint_id = ?");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, wp._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)addWaypointsToGroup:(NSArray<dbWaypoint *> *)waypoints
{
    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        [self addWaypointToGroup:wp];
    }];
}

- (BOOL)containsWaypoint:(dbWaypoint *)wp
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from group2waypoints where group_id = ? and waypoint_id = ?");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, wp._id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count == 0 ? NO : YES;
}

@end
