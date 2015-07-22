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

@synthesize gc_id, waypoint, waypoint_id, logtype_id, logtype_string, logtype, datetime, datetime_epoch, logger, log, cellHeight;

- (id)init:(NSId)_gc_id
{
    self = [super init];
    gc_id = _gc_id;
    return self;
}

- (id)init:(NSId)__id gc_id:(NSId)_gc_id waypoint_id:(NSId)_wpid logtype_id:(NSId)_ltid datetime:(NSString *)_datetime logger:(NSString *)_logger log:(NSString *)_log
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

    [super finish];
}


+ (NSId)dbGetIdByGC:(NSId)_gc_id
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from logs where gc_id = ?");

        SET_VAR_INT(req, 1, _gc_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, ___id);
            __id = ___id;
        }
        DB_FINISH;
    }
    return __id;
}

- (NSId)dbCreate
{
    return [dbLog dbCreate:self];
}

+ (NSId)dbCreate:(dbLog *)log
{
    NSId __id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into logs(cache_id, log_type_id, datetime, datetime_epoch, logger, log, gc_id) values(?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT(req, 1, log.waypoint_id);
        SET_VAR_INT(req, 2, log.logtype_id);
        SET_VAR_TEXT(req, 3, log.datetime);
        SET_VAR_INT(req, 4, log.datetime_epoch);
        SET_VAR_TEXT(req, 5, log.logger);
        SET_VAR_TEXT(req, 6, log.log);
        SET_VAR_INT(req, 7, log.gc_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update logs set log_type_id = ?, cache_id = ?, datetime = ?, datetime_epoch = ?, logger = ?, log = ?, gc_id = ? where id = ?");

        SET_VAR_INT(req, 1, logtype_id);
        SET_VAR_INT(req, 2, waypoint_id);
        SET_VAR_TEXT(req, 3, datetime);
        SET_VAR_INT(req, 4, datetime_epoch);
        SET_VAR_TEXT(req, 5, logger);
        SET_VAR_TEXT(req, 6, log);
        SET_VAR_INT(req, 7, gc_id);
        SET_VAR_INT(req, 8, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateCache:(NSId)c_id;
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update logs set cache_id = ? where id = ?");

        SET_VAR_INT(req, 1, c_id);
        SET_VAR_INT(req, 2, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select count(id) from logs where cache_id = ?");

        SET_VAR_INT(req, 1, wp_id);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        DB_FINISH;
    }
    return count;
}

+ (NSArray *)dbAllByWaypoint:(NSId)_wp_id
{
    NSMutableArray *ls = [[NSMutableArray alloc] initWithCapacity:20];
    dbLog *l;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, gc_id, waypoint_id, log_type_id, datetime, datetime_epoch, logger, log from logs where waypoint_id = ?");

        SET_VAR_INT(req, 1, _wp_id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            INT_FETCH_AND_ASSIGN(req, 1, gc_id);
            INT_FETCH_AND_ASSIGN(req, 2, wp_id);
            INT_FETCH_AND_ASSIGN(req, 3, log_type_id);
            TEXT_FETCH_AND_ASSIGN(req, 4, datetime);
            //INT_FETCH_AND_ASSIGN(req, 5, datetime_epoch);
            TEXT_FETCH_AND_ASSIGN(req, 6, logger);
            TEXT_FETCH_AND_ASSIGN(req, 7, log);
            l = [[dbLog alloc] init:__id gc_id:gc_id waypoint_id:wp_id logtype_id:log_type_id datetime:datetime logger:logger log:log];
            [l finish];
            [ls addObject:l];
        }
        DB_FINISH;
    }
    return ls;
}

@end
