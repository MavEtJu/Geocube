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

@protocol WaypointManagerDelegate

- (void)refreshWaypoints;
- (void)removeWaypoint:(dbWaypoint *)wp;
- (void)addWaypoint:(dbWaypoint *)wp;
- (void)updateWaypoint:(dbWaypoint *)wp;

@end

@interface WaypointManager : NSObject <LocationManagerDelegate>

@property (nonatomic, retain, readonly) dbWaypoint *currentWaypoint;
@property (nonatomic, retain) NSMutableArray *currentWaypoints;

- (instancetype)init;
- (void)applyFilters:(CLLocationCoordinate2D)coords;
- (NSString *)configGet:(NSString *)name;
- (void)configSet:(NSString *)name value:(NSString *)value;
- (void)needsRefreshAll;
- (void)needsRefreshRemove:(dbWaypoint *)wp;
- (void)needsRefreshAdd:(dbWaypoint *)wp;
- (void)needsRefreshUpdate:(dbWaypoint *)wp;
- (void)setCurrentWaypoint:(dbWaypoint *)wp;
- (void)startDelegation:(id<WaypointManagerDelegate>)_delegate;
- (void)stopDelegation:(id<WaypointManagerDelegate>)_delegate;

- (dbWaypoint *)waypoint_byId:(NSId)id;
- (dbWaypoint *)waypoint_byName:(NSString *)name;

@end
