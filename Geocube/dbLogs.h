//
//  dbLogs.h
//  Geocube
//
//  Created by Edwin Groothuis on 10/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbLog : dbObject {
    NSInteger _id;
    NSInteger gc_id;
    NSInteger waypoint_id;
    dbWaypoint *waypoint;
    NSInteger logtype_id;
    NSString *logtype_string;
    dbLogType *logtype;
    NSString *datetime;
    NSString *logger;
    NSString *log;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger gc_id;
@property (nonatomic) NSInteger waypoint_id;
@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic) NSInteger logtype_id;
@property (nonatomic, retain) dbLogType *logtype;
@property (nonatomic, retain) NSString *logtype_string;
@property (nonatomic, retain) NSString *datetime;
@property (nonatomic) NSInteger datetime_epoch;
@property (nonatomic, retain) NSString *logger;
@property (nonatomic, retain) NSString *log;

- (id)init:(NSInteger)__id gc_id:(NSInteger)gc_id waypoint_id:(NSInteger)_wpid logtype_id:(NSInteger)_ltid datetime:(NSString *)_datetime logger:(NSString *)_logger log:(NSString *)_log;
- (id)init:(NSInteger)gc_id;

@end
