/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface dbLogStringWaypoint ()

@end

@implementation dbLogStringWaypoint

TABLENAME(@"log_string_waypoints")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(logString);
    @synchronized(db) {
        DB_PREPARE(@"insert into log_string_waypoints(wptype, log_string_id) values(?, ?)");

        SET_VAR_INT(1, self.wptype);
        SET_VAR_INT(2, self.logString._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update log_string_waypoints set wptype = ?, log_string_id = ? where id = ?");

        SET_VAR_INT (1, self.wptype);
        SET_VAR_INT (2, self.logString._id);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbLogStringWaypoint *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLogStringWaypoint *> *lswps = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, wptype, log_string_id from log_string_waypoints "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);
        DB_WHILE_STEP {
            dbLogStringWaypoint *lswp = [[dbLogStringWaypoint alloc] init];
            INT_FETCH(0, lswp._id);
            INT_FETCH(1, lswp.wptype);
            INT_FETCH(2, i);
            lswp.logString = [dbLogString dbGet:i];
            [lswp finish];
            [lswps addObject:lswp];
        }
        DB_FINISH;
    }
    return lswps;
}

+ (dbLogStringWaypoint *)dbGetByLogStringWPType:(dbLogString *)logstring wptype:(LogStringWPType)wptype
{
    return [[self dbAllXXX:@"where log_string_id = ? and wptype = ?" keys:@"ii" values:@[[NSNumber numberWithId:logstring._id], [NSNumber numberWithInteger:wptype]]] firstObject];
}

+ (void)dbDeleteAllByLogString:(dbLogString *)logstring
{
    NSString *sql = @"delete from log_string_waypoints where log_string_id = ?";

    @synchronized(db) {
        DB_PREPARE(sql);

        SET_VAR_INT(1, logstring._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
