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

@interface dbTrackElement ()

@end

@implementation dbTrackElement

- (void)finish
{
    self.lat = self.lat_int / 1000000.0;
    self.lon = self.lon_int / 1000000.0;
    self.coords = CLLocationCoordinate2DMake(self.lat, self.lon);

    [super finish];
}

+ (NSArray<dbTrackElement *> *)dbAllByTrack:(NSId)track_id
{
    NSMutableArray<dbTrackElement *> *tes = [NSMutableArray arrayWithCapacity:500];

    @synchronized(db) {
        DB_PREPARE(@"select id, track_id, lat_int, lon_int, height, timestamp, restart from trackelements where track_id = ? order by timestamp");

        SET_VAR_INT(1, track_id);

        DB_WHILE_STEP {
            dbTrackElement *te = [[dbTrackElement alloc] init];
            INT_FETCH (0, te._id);
            INT_FETCH (1, te.track_id);
            INT_FETCH (2, te.lat_int);
            INT_FETCH (3, te.lon_int);
            INT_FETCH (4, te.height);
            INT_FETCH (5, te.timestamp_epoch);
            BOOL_FETCH(6, te.restart);
            [te finish];
            [tes addObject:te];
        }
        DB_FINISH;
    }
    return tes;
}

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into trackelements(track_id, lat_int, lon_int, height, timestamp, restart) values(?, ?, ?, ?, ?, ?)");

        SET_VAR_INT (1, self.track_id);
        SET_VAR_INT (2, self.lat_int);
        SET_VAR_INT (3, self.lon_int);
        SET_VAR_INT (4, self.height);
        SET_VAR_INT (5, self.timestamp_epoch);
        SET_VAR_BOOL(6, self.restart);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

+ (dbTrackElement *)createElement:(CLLocationCoordinate2D)_coords height:(NSInteger)_height restart:(BOOL)_restart
{
    dbTrackElement *te = [[dbTrackElement alloc] init];
    te.track_id = configManager.currentTrack;
    te.height = _height;
    te.lat_int = _coords.latitude * 1000000;
    te.lon_int = _coords.longitude * 1000000;
    te.timestamp_epoch = time(NULL);
    te.restart = _restart;
    [te finish];
    return te;
}

+ (NSInteger)dbCount
{
    return [dbWaypoint dbCount:@"trackelements"];
}

+ (void)dbDeleteByTrack:(NSId)trackId
{
    @synchronized(db) {
        DB_PREPARE(@"delete from trackelements where track_id = ?");

        SET_VAR_INT(1, trackId);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
