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

@interface dbOwnTrack ()

@end

@implementation dbOwnTrack

TABLENAME(@"owntracks")

- (instancetype)init
{
    NSAssert(FALSE, @"Should not be called");
    return nil;
}

- (instancetype)initInitialized
{
    self = [super init];

    self.timeSubmitted = time(NULL);
    self.coord = LM.coordsRealNotFake;
    self.altitude = LM.altitude;
    self.accuracy = LM.accuracy;
    self.batteryLevel = [[UIDevice currentDevice] batteryLevel];

    return self;
}

- (instancetype)initEmpty
{
    self = [super init];
    return self;
}

- (NSId)dbCreate
{
    @synchronized(db) {
        CLLocationDegrees lat = 0, lon = 0;

        DB_PREPARE(@"insert into owntracks(info, pw, time_submitted, coord_lat, coord_lon, accuracy, altitude, battery_level) values(?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT  (1, self.info);
        SET_VAR_TEXT  (2, self.password);
        SET_VAR_INT   (3, self.timeSubmitted);
        SET_VAR_DOUBLE(4, lat);
        SET_VAR_DOUBLE(5, lon);
        self.coord = CLLocationCoordinate2DMake(lat, lon);
        SET_VAR_INT   (6, self.accuracy);
        SET_VAR_INT   (7, self.altitude);
        SET_VAR_DOUBLE(8, self.batteryLevel);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }
    return self._id;
}

+ (NSArray<dbOwnTrack *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbOwnTrack *>*ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, info, pw, time_submitted, coord_lat, coord_lon, accuracy, altitude, battery_level from owntracks "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        CLLocationDegrees lat, lon;

        DB_WHILE_STEP {
            dbOwnTrack *ot = [[dbOwnTrack alloc] initEmpty];
            INT_FETCH   (0, ot._id);
            TEXT_FETCH  (1, ot.info);
            TEXT_FETCH  (2, ot.password);
            INT_FETCH   (3, ot.timeSubmitted);
            DOUBLE_FETCH(4, lat);
            DOUBLE_FETCH(5, lon);
            ot.coord = CLLocationCoordinate2DMake(lat, lon);
            INT_FETCH   (6, ot.accuracy);
            INT_FETCH   (7, ot.altitude);
            DOUBLE_FETCH(8, ot.batteryLevel);
            [ss addObject:ot];
        }
        DB_FINISH;
    }

    return ss;
}

+ (dbOwnTrack *)dbGetFirst
{
    return [[self dbAllXXX:@"order by id limit 1" keys:nil values:nil] firstObject];
}


@end
