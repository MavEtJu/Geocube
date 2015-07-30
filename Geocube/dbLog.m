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

#import "Geocube-Prefix.pch"

@implementation dbLog

@synthesize gc_id, waypoint, waypoint_id, logtype_id, logtype_string, logtype, datetime, datetime_epoch, logger_gsid, logger_id, logger, logger_str, log, cellHeight;

- (id)init:(NSId)_gc_id
{
    self = [super init];
    gc_id = _gc_id;
    return self;
}

- (id)init:(NSId)__id gc_id:(NSId)_gc_id waypoint_id:(NSId)_wpid logtype_id:(NSId)_ltid datetime:(NSString *)_datetime logger_id:(NSId)_logger_id log:(NSString *)_log
{
    self = [super init];
    _id = __id;
    gc_id = _gc_id;
    waypoint_id = _wpid;
    logtype_id = _ltid;
    datetime = _datetime;
    logger_id = _logger_id;
    log = _log;

    [self finish];

    cellHeight = 0;

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
    waypoint = [dbWaypoint dbGet:waypoint_id]; // This can be nil when an import is happening

    if (logger == nil) {
        if (logger_id != 0) {
            logger = [dbName dbGet:logger_id];
            logger_str = logger.name;
        }
        if (logger_str != nil) {
            if (logger_gsid == nil)
                logger = [dbName dbGetByName:logger_str];
            else
                logger = [dbName dbGetByNameCode:logger_str code:logger_gsid];
            logger_id = logger._id;
        }
    }

    [super finish];
}


+ (NSId)dbGetIdByGC:(NSId)_gc_id
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from logs where gc_id = ?");

        SET_VAR_INT(1, _gc_id);

        DB_IF_STEP {
            INT_FETCH(0, _id);
        }
        DB_FINISH;
    }
    return _id;
}

- (NSId)dbCreate
{
    return [dbLog dbCreate:self];
}

+ (NSId)dbCreate:(dbLog *)log
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into logs(waypoint_id, log_type_id, datetime, datetime_epoch, logger_id, log, gc_id) values(?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT( 1, log.waypoint_id);
        SET_VAR_INT( 2, log.logtype_id);
        SET_VAR_TEXT(3, log.datetime);
        SET_VAR_INT( 4, log.datetime_epoch);
        SET_VAR_INT( 5, log.logger_id);
        SET_VAR_TEXT(6, log.log);
        SET_VAR_INT( 7, log.gc_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    log._id = _id;
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update logs set log_type_id = ?, waypoint_id = ?, datetime = ?, datetime_epoch = ?, logger_id = ?, log = ?, gc_id = ? where id = ?");

        SET_VAR_INT( 1, logtype_id);
        SET_VAR_INT( 2, waypoint_id);
        SET_VAR_TEXT(3, datetime);
        SET_VAR_INT( 4, datetime_epoch);
        SET_VAR_INT( 5, logger_id);
        SET_VAR_TEXT(6, log);
        SET_VAR_INT( 7, gc_id);
        SET_VAR_INT( 8, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateCache:(NSId)c_id;
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update logs set waypoint_id = ? where id = ?");

        SET_VAR_INT(1, c_id);
        SET_VAR_INT(2, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from logs where waypoint_id = ?");

        SET_VAR_INT(1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByWaypoint:(NSId)_wp_id
{
    NSMutableArray *ls = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, gc_id, waypoint_id, log_type_id, datetime, datetime_epoch, logger_id, log from logs where waypoint_id = ?");

        SET_VAR_INT(1, _wp_id);

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];;
            INT_FETCH( 0, l._id);
            INT_FETCH( 1, l.gc_id);
            INT_FETCH( 2, l.waypoint_id);
            INT_FETCH( 3, l.logtype_id);
            TEXT_FETCH(4, l.datetime);
            //INT_FETCH_AND_ASSIGN(5, l.datetime_epoch);
            INT_FETCH( 6, l.logger_id);
            TEXT_FETCH(7, l.log);
            [l finish];
            [ls addObject:l];
        }
        DB_FINISH;
    }
    return ls;
}

+ (NSInteger)dbCountByWaypointLogString:(dbWaypoint *)wp LogString:(NSString *)string
{
    NSInteger c = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from logs where waypoint_id = ? and log like ?");

        SET_VAR_INT(1, wp._id);
        NSString *s = [NSString stringWithFormat:@"%%%@%%", string];
        SET_VAR_TEXT(2, s);

        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

@end
