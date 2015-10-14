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

@interface dbTrackElement : dbObject {
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

@property (nonatomic) NSId track_id;
@property (nonatomic, retain) dbTrack *track;

@property (nonatomic) CLLocationCoordinate2D coords;
@property (nonatomic) NSInteger lat_int;
@property (nonatomic) CLLocationDegrees lat;
@property (nonatomic) NSInteger lon_int;
@property (nonatomic) CLLocationDegrees lon;

@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger timestamp_epoch;

+ (void)addElement:(CLLocationCoordinate2D)coords height:(NSInteger)altitude;
+ (NSArray *)dbAllByTrack:(NSId)_track_id;

@end
