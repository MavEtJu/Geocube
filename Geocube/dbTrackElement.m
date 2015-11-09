/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface dbTrackElement ()
{
    NSId track_id;
    dbTrack *track;

    CLLocationCoordinate2D coords;
    NSInteger lat_int;
    CLLocationDegrees lat;
    NSInteger lon_int;
    CLLocationDegrees lon;

    NSInteger height;
    NSInteger timestamp_epoch;
}

@end

@implementation dbTrackElement

@synthesize track_id, track, coords, lat_int, lat, lon_int, lon, height, timestamp_epoch;

- (void)finish
{
    lat = lat_int / 1000000.0;
    lon = lon_int / 1000000.0;
    coords = CLLocationCoordinate2DMake(lat, lon);

    [super finish];
}

+ (NSArray *)dbAllByTrack:(NSId)track_id
{
    NSMutableArray *tes = [NSMutableArray arrayWithCapacity:500];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, track_id, lat_int, lon_int, height, timestamp from trackelements where track_id = ? order by timestamp");

        SET_VAR_INT(1, track_id);

        DB_WHILE_STEP {
            dbTrackElement *te = [[dbTrackElement alloc] init];;
            INT_FETCH( 0, te._id);
            INT_FETCH( 1, te.track_id);
            INT_FETCH( 2, te.lat_int);
            INT_FETCH( 3, te.lon_int);
            INT_FETCH( 4, te.height);
            INT_FETCH( 5, te.timestamp_epoch);
            [te finish];
            [tes addObject:te];
        }
        DB_FINISH;
    }
    return tes;
}

- (NSId)dbCreate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into trackelements(track_id, lat_int, lon_int, height, timestamp) values(?, ?, ?, ?, ?)");

        SET_VAR_INT( 1, track_id);
        SET_VAR_INT( 2, lat_int);
        SET_VAR_INT( 3, lon_int);
        SET_VAR_INT( 4, height);
        SET_VAR_INT( 5, timestamp_epoch);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

+ (void)addElement:(CLLocationCoordinate2D)_coords height:(NSInteger)_height
{
    dbTrackElement *te = [[dbTrackElement alloc] init];
    te.track_id = myConfig.currentTrack;
    te.height = _height;
    te.lat_int = _coords.latitude * 1000000;
    te.lon_int = _coords.longitude * 1000000;
    te.timestamp_epoch = time(NULL);
    [te finish];
    [te dbCreate];
}

+ (NSInteger)dbCount
{
    return [dbWaypoint dbCount:@"trackelements"];
}

@end
