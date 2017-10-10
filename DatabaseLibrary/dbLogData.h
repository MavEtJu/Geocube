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

@interface dbLogData : dbObject

typedef NS_ENUM(NSInteger, LogDataType) {
    LOGDATATYPE_FOUND = 0,
    LOGDATATYPE_DNF,
};

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic) NSInteger datetime_epoch;
@property (nonatomic) LogDataType type;

+ (void)addEntry:(dbWaypoint *)waypoint type:(LogDataType)type datetime:(time_t)datetime_epoch;
+ (NSArray<dbLogData *> *)dbAllByType:(LogDataType)type datetime:(NSInteger)datetime;

@end
