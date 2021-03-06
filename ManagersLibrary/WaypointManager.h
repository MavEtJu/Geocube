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

@interface WaypointManager : NSObject <LocationManagerLocationDelegate>

@property (nonatomic, retain, readonly) dbWaypoint *currentWaypoint;
@property (nonatomic, retain) NSMutableArray<dbWaypoint *> *currentWaypoints;

- (instancetype)init;
- (void)applyFilters:(CLLocationCoordinate2D)coords;
- (NSString *)configGet:(NSString *)name;
- (void)configSet:(NSString *)name value:(NSString *)value;
- (void)needsRefreshAll;
- (void)needsRefreshRemove:(dbWaypoint *)wp;
- (void)needsRefreshAdd:(dbWaypoint *)wp;
- (void)needsRefreshUpdate:(dbWaypoint *)wp;
- (void)setTheCurrentWaypoint:(dbWaypoint *)wp;

- (void)startDelegationWaypoints:(id<WaypointManagerWaypointDelegate>)_delegate;
- (void)stopDelegationWaypoints:(id<WaypointManagerWaypointDelegate>)_delegate;
- (void)startDelegationKML:(id<WaypointManagerKMLDelegate>)_delegate;
- (void)stopDelegationKML:(id<WaypointManagerKMLDelegate>)_delegate;

- (dbWaypoint *)waypoint_byId:(NSId)id;
- (dbWaypoint *)waypoint_byName:(NSString *)name;

- (void)refreshKMLs;

@end

extern WaypointManager *waypointManager;
