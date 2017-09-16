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

#import "database-classes.h"
#import "dbObject.h"

@interface dbListData : dbObject

typedef NS_ENUM(NSInteger, Flag) {
    FLAGS_HIGHLIGHTED,
    FLAGS_IGNORED,
    FLAGS_MARKEDFOUND,
    FLAGS_INPROGRESS,
    FLAGS_MARKEDDNF,
    FLAGS_PLANNED,
};

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic) Flag type;
@property (nonatomic) time_t datetime;

+ (void)waypointSetFlag:(dbWaypoint *)wp flag:(Flag)flag;
+ (void)waypointClearFlag:(dbWaypoint *)wp flag:(Flag)flag;

+ (dbListData *)dbGetByWaypoint:(dbWaypoint *)wp flag:(Flag)flag;
+ (NSArray<dbListData *> *)dbAllByType:(Flag)flag ascending:(BOOL)asc;

@end
