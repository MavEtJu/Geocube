/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface dbGroup : dbObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) BOOL usergroup;
@property (nonatomic) BOOL deletable;
@property (nonatomic) BOOL selected;

+ (NSMutableArray<dbGroup *> *)dbAll;
+ (NSArray<dbGroup *> *)dbAllByWaypoint:(dbWaypoint *)wp;
+ (NSArray<dbGroup *> *)dbAllByUserGroup:(BOOL)isUser;
+ (dbGroup *)dbGet:(NSId)_id;
+ (dbGroup *)dbGetByName:(NSString *)name;
- (void)dbUpdateName:(NSString *)newname;
- (void)emptyGroup;
- (void)addWaypointToGroup:(dbWaypoint *)wp;
- (void)addWaypointsToGroup:(NSArray<dbWaypoint *> *)waypoints;
- (void)removeWaypointFromGroup:(dbWaypoint *)wp;
- (BOOL)containsWaypoint:(dbWaypoint *)wp;
- (NSInteger)countWaypoints;

@end
