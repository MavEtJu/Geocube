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

- (instancetype)init:(NSId)_id name:(NSString *)name usergroup:(BOOL)usergroup deletable:(BOOL)deletable
{
    self = [super init];
    self._id = _id;
    self.name = name;
    self.usergroup = usergroup;
    self.deletable = deletable;
    [self finish];
    return self;
}

- (void)dbEmpty
{
    @synchronized(db) {
        DB_PREPARE(@"delete from group2waypoints where group_id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}


+ (dbGroup *)dbGetByName:(NSString *)name
{
    dbGroup *cg;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, usergroup, deletable from groups where name = ?");

        SET_VAR_TEXT(1, name);

        DB_IF_STEP {
            cg = [[dbGroup alloc] init];
            INT_FETCH (0, cg._id);
            TEXT_FETCH(1, cg.name);
            BOOL_FETCH(2, cg.usergroup);
            BOOL_FETCH(3, cg.deletable)
        }
        DB_FINISH;
    }
    return cg;
}

+ (dbGroup *)dbGet:(NSId)_id
{
    dbGroup *cg;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, usergroup, deletable from groups where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            cg = [[dbGroup alloc] init];
            INT_FETCH (0, cg._id);
            TEXT_FETCH(1, cg.name);
            BOOL_FETCH(2, cg.usergroup);
            BOOL_FETCH(3, cg.deletable)
        }
        DB_FINISH;
    }
    return cg;
}

+ (NSMutableArray<dbGroup *> *)dbAll
{
    NSMutableArray<dbGroup *> *cgs = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name, usergroup, deletable from groups");

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

+ (NSInteger)dbCount
{
    return [dbGroup dbCount:@"groups"];
}

+ (NSArray<dbGroup *> *)dbAllByWaypoint:(NSId)wp_id
{
    NSMutableArray<dbGroup *> *cgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbGroup *cg;

    @synchronized(db) {
        DB_PREPARE(@"select group_id from group2waypoints where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(0, cgid);
            cg = [dbc Group_get:cgid];
            // cg should never be nil but can happen when the import has been aborted halfway.
            if (cg != nil)
                [cgs addObject:cg];
        }
        DB_FINISH;
    }
    return cgs;
}

- (NSInteger)dbCountWaypoints
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

+ (NSId)dbCreate:(NSString *)_name isUser:(BOOL)_usergroup
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into groups(name, usergroup, deletable) values(?, ?, 1)");

        SET_VAR_TEXT(1, _name);
        SET_VAR_BOOL(2, _usergroup);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

- (void)dbDelete
{
    [dbGroup dbDelete:self._id];
}

+ (void)dbDelete:(NSId)_id
{
    @synchronized(db) {
        DB_PREPARE(@"delete from groups where id = ?");

        SET_VAR_INT(1, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
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

- (void)dbAddWaypoint:(NSId)__id
{
    @synchronized(db) {
        DB_PREPARE(@"insert into group2waypoints(group_id, waypoint_id) values(?, ?)");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, __id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbRemoveWaypoint:(NSId)__id
{
    @synchronized(db) {
        DB_PREPARE(@"delete from group2waypoints where group_id = ? and waypoint_id = ?");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, __id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbAddWaypoints:(NSArray<dbWaypoint *> *)waypoints
{
    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
        [self dbAddWaypoint:wp._id];
    }];
}


- (BOOL)dbContainsWaypoint:(NSId)c_id
{
    NSInteger count = 0;

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from group2waypoints where group_id = ? and waypoint_id = ?");

        SET_VAR_INT(1, self._id);
        SET_VAR_INT(2, c_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count == 0 ? NO : YES;
}

@end
