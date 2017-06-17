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

- (instancetype)init
{
    self = [super init];

    return self;
}

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

+ (NSArray<dbListData *> *)dbAllByType:(Flag)type ascending:(BOOL)asc
{
    NSMutableArray<dbListData *> *lds = [[NSMutableArray alloc] initWithCapacity:20];
    NSString *sql = [NSString stringWithFormat:@"select id, waypoint_id, type, datetime from listdata where type = ? order by datetime %@", (asc == YES ? @"asc" : @"desc")];

    @synchronized (db) {
        DB_PREPARE(sql);
        SET_VAR_INT(1, type);

        DB_WHILE_STEP {
            dbListData *ld = [[dbListData alloc] init];
            INT_FETCH(0, ld._id);
            INT_FETCH(1, ld.waypoint_id);
            INT_FETCH(2, ld.type);
            INT_FETCH(3, ld.datetime);
            [ld finish];
            [lds addObject:ld];
        }
        DB_FINISH;
    }

    return lds;
}

+ (dbListData *)dbGetByWaypoint:(dbWaypoint *)wp flag:(Flag)flag
{
    dbListData *ld = nil;

    @synchronized (db) {
        DB_PREPARE(@"select id, waypoint_id, type, datetime from listdata where type = ? and waypoint_id = ?");
        SET_VAR_INT(1, flag);
        SET_VAR_INT(2, wp._id);

        DB_IF_STEP {
            ld = [[dbListData alloc] init];
            INT_FETCH(0, ld._id);
            INT_FETCH(1, ld.waypoint_id);
            INT_FETCH(2, ld.type);
            INT_FETCH(3, ld.datetime);
            [ld finish];
        }
        DB_FINISH;
    }

    return ld;
}

+ (NSInteger)dbCount
{
    return [dbListData dbCount:@"listdata"];
}

@end
