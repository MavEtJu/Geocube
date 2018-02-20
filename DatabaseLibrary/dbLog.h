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

@interface dbLog : dbObject

@property (nonatomic) NSInteger gc_id;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) dbLogString *logstring;
@property (nonatomic) NSInteger datetime_epoch;
@property (nonatomic, retain) NSString *logger_gsid;
@property (nonatomic, retain) dbName *logger;
@property (nonatomic, retain) NSString *log;
@property (nonatomic) BOOL needstobelogged;
@property (nonatomic) BOOL localLog;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

// Internal values
@property (nonatomic) NSInteger cellHeight;

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id waypoint:(dbWaypoint *)wp logstring:(dbLogString *)ls datetime:(NSInteger)_datetime logger:(dbName *)logger log:(NSString *)_log needstobelogged:(BOOL)needstobelogged locallog:(BOOL)locallog coordinates:(CLLocationCoordinate2D)coordinates;
- (instancetype)init:(NSInteger)gc_id;
- (void)set_logstring_str:(NSString *)s account:(dbAccount *)account;

+ (dbWaypoint *)dbGetIdByGC:(NSInteger)gc_id account:(dbAccount *)account;
+ (NSMutableDictionary *)dbAllIdGCId;
+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp;
+ (NSArray<dbLog *> *)dbAllByWaypoint:(dbWaypoint *)wp;
+ (NSArray<dbLog *> *)dbAllByWaypointLogged:(dbWaypoint *)wp;
+ (NSArray<dbLog *> *)dbAllByWaypointUnsubmitted:(dbWaypoint *)wp;
+ (NSArray<dbLog *> *)dbLast7ByWaypoint:(dbWaypoint *)wp;
+ (NSArray<dbLog *> *)dbLast7ByWaypointLogged:(dbWaypoint *)wp;
- (void)dbUpdateWaypoint:(dbWaypoint *)wp;
- (void)dbUpdateNote;
+ (NSInteger)dbCountByWaypointLogString:(dbWaypoint *)wp LogString:(NSString *)string;
+ (dbLog *)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSInteger)date note:(NSString *)note needstobelogged:(BOOL)needstobelogged locallog:(BOOL)locallog coordinates:(CLLocationCoordinate2D)coordinates;

@end
