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

@interface dbTrackable : dbObject

typedef NS_ENUM(NSInteger, TrackableLog) {
    TRACKABLE_LOG_NONE = 0,
    TRACKABLE_LOG_VISIT,
    TRACKABLE_LOG_DROPOFF,
    TRACKABLE_LOG_PICKUP,
    TRACKABLE_LOG_DISCOVER,
    TRACKABLE_LOG_MAX
};

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *ref;
@property (nonatomic) NSInteger gc_id;
@property (nonatomic, retain) dbName *carrier;
@property (nonatomic, retain) dbName *owner;
@property (nonatomic, retain) NSString *waypoint_name;
@property (nonatomic) TrackableLog logtype;

- (void)set_carrier_str:(NSString *)name account:(dbAccount *)account;
- (void)set_owner_str:(NSString *)name account:(dbAccount *)account;

+ (NSArray<dbTrackable *> *)dbAll;
+ (NSArray<dbTrackable *> *)dbAllMine;
+ (NSArray<dbTrackable *> *)dbAllInventory;
+ (void)dbUnlinkAllFromWaypoint:(dbWaypoint *)wp;
- (void)dbLinkToWaypoint:(dbWaypoint *)wp;
+ (dbTrackable *)dbGet:(NSId)_id;
+ (NSId)dbGetIdByGC:(NSInteger)_gc_id;
+ (dbTrackable *)dbGetByCode:(NSString *)code;
+ (dbTrackable *)dbGetByRef:(NSString *)ref;
+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp_id;
+ (NSArray<dbTrackable *> *)dbAllByWaypoint:(dbWaypoint *)wp;

@end
