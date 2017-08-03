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

@interface dbListData ()

@end

@implementation dbListData

TABLENAME(@"listdata")

+ (NSArray<dbListData *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbListData *> *lds = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithFormat:@"select id, waypoint_id, type, datetime from listdata "];
    if (where != nil)
        [sql appendString:where];

    @synchronized (db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbListData *ld = [[dbListData alloc] init];
            INT_FETCH(0, ld._id);
            INT_FETCH(1, i);
            ld.waypoint = [dbWaypoint dbGet:i];
            INT_FETCH(2, ld.type);
            INT_FETCH(3, ld.datetime);
            [ld finish];
            [lds addObject:ld];
        }
        DB_FINISH;
    }

    return lds;
}

+ (NSArray<dbListData *> *)dbAllByType:(Flag)type ascending:(BOOL)asc
{
    return [self dbAllXXX:[NSString stringWithFormat:@"where type = ? order by datetime %@", (asc == YES ? @"asc" : @"desc")] keys:@"i" values:@[[NSNumber numberWithInteger:type]]];
}

+ (dbListData *)dbGetByWaypoint:(dbWaypoint *)wp flag:(Flag)flag
{
    return [[self dbAllXXX:@"where type = ? and waypoint_id = ?" keys:@"ii" values:@[[NSNumber numberWithInteger:flag], [NSNumber numberWithInteger:wp._id]]] firstObject];
}

/* Other methods */

+ (void)waypointSetFlag:(dbWaypoint *)wp flag:(Flag)flag
{
    @synchronized (db) {
        DB_PREPARE(@"insert into listdata(waypoint_id, type, datetime) values(?, ?, ?)");

        SET_VAR_INT(1, wp._id);
        SET_VAR_INT(2, flag);
        SET_VAR_INT(3, time(NULL));

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)waypointClearFlag:(dbWaypoint *)wp flag:(Flag)flag
{
    @synchronized (db) {
        DB_PREPARE(@"delete from listdata where waypoint_id = ? and type = ?");

        SET_VAR_INT(1, wp._id);
        SET_VAR_INT(2, flag);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
