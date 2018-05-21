/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

@interface dbLogData ()

@end

@implementation dbLogData

TABLENAME(@"log_data")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into log_data(waypoint_id, datetime_epoch, type) values(?, ?, ?)");

        SET_VAR_INT(1, self.waypoint._id);
        SET_VAR_INT(2, self.datetime_epoch);
        SET_VAR_INT(3, self.type);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update log_data set waypoint_id = ?, datetime_epoch = ?, type_id = ? where id = ?");

        SET_VAR_INT(1, self.waypoint._id);
        SET_VAR_INT(2, self.datetime_epoch);
        SET_VAR_INT(3, self.type);
        SET_VAR_INT(4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbLogData *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLogData *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, waypoint_id, datetime_epoch, type from log_data "];
    if (where != nil)
        [sql appendString:where];

    NSId i;

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbLogData *ld = [[dbLogData alloc] init];
            INT_FETCH (0, ld._id);
            INT_FETCH (1, i);
            ld.waypoint = [dbWaypoint dbGet:i];
            INT_FETCH (2, ld.datetime_epoch);
            INT_FETCH (3, ld.type);
            [ss addObject:ld];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbLogData *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbLogData *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

// Other methods

+ (void)addEntry:(dbWaypoint *)waypoint type:(LogDataType)type datetime:(time_t)datetime_epoch
{
    // You can have multiple DNFs per waypoint.
    // You can habe only one Found per waypoint.

    if (type == LOGDATATYPE_FOUND) {
        NSArray<dbLogData *> *lds = [dbLogData dbAllXXX:@"where waypoint_id = ? and type = ?" keys:@"ii" values:@[[NSNumber numberWithLongLong:waypoint._id], [NSNumber numberWithInteger:type]]];
        [lds enumerateObjectsUsingBlock:^(dbLogData * _Nonnull ld, NSUInteger idx, BOOL * _Nonnull stop) {
            [ld dbDelete];
        }];
    }

    dbLogData *ld = [[dbLogData alloc] init];
    ld.waypoint = waypoint;
    ld.type = type;
    ld.datetime_epoch = datetime_epoch;
    [ld dbCreate];
}

+ (NSArray<dbLogData *> *)dbAllByType:(LogDataType)type datetime:(NSInteger)datetime
{
    datetime -= (datetime % 86400);
    return [dbLogData dbAllXXX:@"where type = ? and ? < datetime_epoch and datetime_epoch < ?" keys:@"iii" values:@[[NSNumber numberWithInteger:type], [NSNumber numberWithInteger:datetime], [NSNumber numberWithInteger:datetime + 86400]]];
}

@end
