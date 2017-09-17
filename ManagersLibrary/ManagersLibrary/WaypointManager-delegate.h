//
//  WaypointManager-delegate.h
//  ManagersLibrary
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

@class dbWaypoint;

@protocol WaypointManagerWaypointDelegate

- (void)refreshWaypoints;
- (void)removeWaypoint:(dbWaypoint *)wp;
- (void)addWaypoint:(dbWaypoint *)wp;
- (void)updateWaypoint:(dbWaypoint *)wp;

@end

@protocol WaypointManagerKMLDelegate

- (void)reloadKMLFiles;

@end
