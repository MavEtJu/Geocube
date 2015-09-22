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

@interface dbLog : dbObject {
    NSId gc_id;
    NSId waypoint_id;
    dbWaypoint *waypoint;
    NSId logtype_id;
    NSString *logtype_string;
    dbLogType *logtype;
    NSString *datetime;
    NSString *logger_gsid;
    NSString *logger_str;
    NSId logger_id;
    dbName *logger;
    BOOL needstobelogged;

    NSString *log;

    // Internal values
    NSInteger cellHeight;
}

@property (nonatomic) NSId gc_id;
@property (nonatomic) NSId waypoint_id;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic) NSId logtype_id;
@property (nonatomic, retain) dbLogType *logtype;
@property (nonatomic, retain) NSString *logtype_string;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic) NSInteger datetime_epoch;
@property (nonatomic, retain) NSString *logger_gsid;
@property (nonatomic, retain) NSString *logger_str;
@property (nonatomic) NSId logger_id;
@property (nonatomic, retain) dbName *logger;
@property (nonatomic, retain) NSString *log;
@property (nonatomic) BOOL needstobelogged;

// Internal values
@property (nonatomic) NSInteger cellHeight;

- (instancetype)init:(NSId)__id gc_id:(NSId)gc_id waypoint_id:(NSId)wp_id logtype_id:(NSId)_ltid datetime:(NSString *)_datetime logger_id:(NSId)_logger_id log:(NSString *)_log needstobelogged:(BOOL)needtobelogged;
- (instancetype)init:(NSId)gc_id;

+ (NSId)dbGetIdByGC:(NSId)gc_id account:(dbAccount *)account;
+ (NSMutableDictionary *)dbAllIdGCId;
+ (NSInteger)dbCountByWaypoint:(NSId)wp_id;
+ (NSArray *)dbAllByWaypoint:(NSId)wp_id;
+ (NSArray *)dbAllByWaypointLogged:(NSId)wp_id;
+ (NSId)dbCreate:(dbLog *)log;
- (NSId)dbCreate;
- (void)dbUpdateCache:(NSId)wp_id;
- (void)dbUpdateNote;
+ (NSInteger)dbCountByWaypointLogString:(dbWaypoint *)wp LogString:(NSString *)string;
+ (dbLog *)CreateLogNote:(NSString *)logtype waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)date note:(NSString *)note needstobelogged:(BOOL)needstobelogged;

@end
