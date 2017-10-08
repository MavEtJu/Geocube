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

#import "dbTrackElement.h"

#import "Geocube-defines.h"

#import "DatabaseLibrary/dbTrack.h"

@interface dbTrackElement ()

@end

@implementation dbTrackElement

TABLENAME(@"trackelements")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(track);
    @synchronized(db) {
        DB_PREPARE(@"insert into trackelements(track_id, lat, lon, height, timestamp, restart) values(?, ?, ?, ?, ?, ?)");

        SET_VAR_INT   (1, self.track._id);
        SET_VAR_DOUBLE(2, self.lat);
        SET_VAR_DOUBLE(3, self.lon);
        SET_VAR_INT   (4, self.height);
        SET_VAR_INT   (5, self.timestamp_epoch);
        SET_VAR_BOOL  (6, self.restart);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

+ (NSArray<dbTrackElement *> *)dbAllByTrack:(dbTrack *)track
{
    NSMutableArray<dbTrackElement *> *tes = [NSMutableArray arrayWithCapacity:500];

    @synchronized(db) {
        DB_PREPARE(@"select id, track_id, lat, lon, height, timestamp, restart from trackelements where track_id = ? order by timestamp");

        SET_VAR_INT(1, track._id);

        DB_WHILE_STEP {
            dbTrackElement *te = [[dbTrackElement alloc] init];
            INT_FETCH   (0, te._id);
            INT_FETCH   (1, te.track._id);
            DOUBLE_FETCH(2, te.lat);
            DOUBLE_FETCH(3, te.lon);
            INT_FETCH   (4, te.height);
            INT_FETCH   (5, te.timestamp_epoch);
            BOOL_FETCH  (6, te.restart);
            [te finish];
            [tes addObject:te];
        }
        DB_FINISH;
    }
    return tes;
}

+ (void)dbDeleteByTrack:(dbTrack *)track
{
    @synchronized(db) {
        DB_PREPARE(@"delete from trackelements where track_id = ?");

        SET_VAR_INT(1, track._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

/* Other methods */

@end
