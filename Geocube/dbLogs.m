//
//  dbLogs.m
//  Geocube
//
//  Created by Edwin Groothuis on 10/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbLog

@synthesize _id, gc_id, waypoint_id, waypoint, logtype_id, logtype_string, logtype, datetime, datetime_epoch, logger, log;

- (id)init:(NSInteger)_gc_id
{
    self = [super init];
    gc_id = _gc_id;
    return self;
}

- (id)init:(NSInteger)__id gc_id:(NSInteger)_gc_id waypoint_id:(NSInteger)_wpid logtype_id:(NSInteger)_ltid datetime:(NSString *)_datetime logger:(NSString *)_logger log:(NSString *)_log
{
    self = [super init];
    _id = __id;
    gc_id = _gc_id;
    waypoint_id = _wpid;
    logtype_id = _ltid;
    datetime = _datetime;
    logger = _logger;
    log = _log;
    
    [self finish];
    
    return self;
}

- (void)finish
{
    datetime_epoch = [MyTools secondsSinceEpoch:datetime];
    if (logtype_id == 0) {
        logtype = [dbc LogType_get_bytype:logtype_string];
        logtype_id = logtype._id;
    } else {
        logtype = [dbc LogType_get:logtype_id];
        logtype_string = logtype.logtype;
    }
    waypoint = [dbc Waypoint_get:waypoint_id]; // This can be nil when an import is happening

    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", logger, datetime];
}

@end