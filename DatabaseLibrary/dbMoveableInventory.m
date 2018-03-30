/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2018 Edwin Groothuis
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

@interface dbMoveableInventory ()

@end

@implementation dbMoveableInventory

TABLENAME(@"moveable_inventory")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(waypoint);
    @synchronized(db) {
        DB_PREPARE(@"insert into moveable_inventory(waypoint_id) values(?)");

        SET_VAR_INT(1, self.waypoint._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

+ (NSArray<dbMoveableInventory *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbMoveableInventory *> *mis = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, waypoint_id from moveable_inventory "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbMoveableInventory *mi = [[dbMoveableInventory alloc] init];
            INT_FETCH (0, mi._id);
            INT_FETCH (1, i);
            mi.waypoint = [dbWaypoint dbGet:i];
            [mi finish];
            [mis addObject:mi];
        }
        DB_FINISH;
    }
    return mis;
}

+ (NSArray<dbMoveableInventory *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbMoveableInventory *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

+ (dbMoveableInventory *)dbGetByWaypoint:(dbWaypoint *)wp
{
    return [[self dbAllXXX:@"where waypoint_id = ?" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]] firstObject];
}

@end
