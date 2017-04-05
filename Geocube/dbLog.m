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

@interface dbLog ()

@end

@implementation dbLog

- (instancetype)init:(NSInteger)gc_id
{
    self = [super init];
    self.gc_id = gc_id;
    self.needstobelogged = NO;
    return self;
}

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id waypoint_id:(NSId)wpid logstring_id:(NSId)lsid datetime:(NSString *)datetime logger_id:(NSId)logger_id log:(NSString *)log needstobelogged:(BOOL)needstobelogged
{
    self = [super init];
    self._id = _id;
    self.gc_id = gc_id;
    self.waypoint_id = wpid;
    self.logstring_id = lsid;
    self.datetime = datetime;
    self.logger_id = logger_id;
    self.log = log;
    self.needstobelogged = needstobelogged;

    [self finish];

    self.cellHeight = 0;

    return self;
}

- (void)finish
{
    self.waypoint = [dbWaypoint dbGet:self.waypoint_id]; // This can be nil when an import is happening
    self.datetime_epoch = [MyTools secondsSinceEpochFromISO8601:self.datetime];

    if (self.logstring_id == 0) {
        self.logstring = [dbc LogString_get_bytype:self.waypoint.account logtype:self.waypoint.logstring_logtype type:self.logstring_string];
        self.logstring_id = self.logstring._id;
    } else {
        self.logstring = [dbc LogString_get:self.logstring_id];
        self.logstring_string = self.logstring.text;
    }

    if (self.logger == nil) {
        if (self.logger_id != 0) {
            self.logger = [dbName dbGet:self.logger_id];
            self.logger_str = self.logger.name;
        }
        if (self.logger_str != nil) {
            if (self.logger_gsid == nil)
                self.logger = [dbName dbGetByName:self.logger_str account:self.waypoint.account];
            else
                self.logger = [dbName dbGetByNameCode:self.logger_str code:self.logger_gsid account:self.waypoint.account];
            self.logger_id = self.logger._id;
        }
        if (self.logger_gsid == nil)
            self.logger_gsid = self.logger.code;
    }

    if (self.logstring_string == nil) {
        if (self.logstring != nil) {
            self.logstring_string = self.logstring.text;
            self.logstring_id = self.logstring._id;
        } else if (self.logstring_id != 0) {
            self.logstring = [dbc LogString_get:self.logstring_id];
            self.logstring_string = self.logstring.text;
        }
    }
    if (self.logstring == nil) {
        if (self.logstring_id != 0) {
            self.logstring = [dbc LogString_get:self.logstring_id];
            self.logstring_string = self.logstring.text;
        }
    }

    [super finish];
}


+ (NSId)dbGetIdByGC:(NSInteger)_gc_id account:(dbAccount *)account
{
    NSId _id = 0;

    @synchronized(db) {
        DB_PREPARE(@"select id from logs where gc_id = ? and waypoint_id in (select id from waypoints where account_id = ?) order by datetime_epoch desc");

        SET_VAR_INT(1, _gc_id);
        SET_VAR_INT(2, account._id);

        DB_IF_STEP {
            INT_FETCH(0, _id);
        }
        DB_FINISH;
    }
    return _id;
}

+ (NSDictionary *)dbAllIdGCId
{
    NSMutableDictionary *ss = [NSMutableDictionary dictionaryWithCapacity:4000];

    @synchronized(db) {
        DB_PREPARE(@"select id, gc_id from logs order by datetime_epoch desc");

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];
            INT_FETCH(0, l._id);
            INT_FETCH(1, l.gc_id);
            [ss setObject:l forKey:[NSString stringWithFormat:@"%ld", (long)l.gc_id]];
        }
        DB_FINISH;
    }
    return ss;
}

- (NSId)dbCreate
{
    return [dbLog dbCreate:self];
}

+ (NSId)dbCreate:(dbLog *)log
{
    NSId _id = 0;

    @synchronized(db) {
        DB_PREPARE(@"insert into logs(waypoint_id, log_string_id, datetime, datetime_epoch, logger_id, log, gc_id, needstobelogged) values(?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT (1, log.waypoint_id);
        SET_VAR_INT (2, log.logstring_id);
        SET_VAR_TEXT(3, log.datetime);
        SET_VAR_INT (4, log.datetime_epoch);
        SET_VAR_INT (5, log.logger_id);
        SET_VAR_TEXT(6, log.log);
        SET_VAR_INT (7, log.gc_id);
        SET_VAR_BOOL(8, log.needstobelogged);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    log._id = _id;
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update logs set log_string_id = ?, waypoint_id = ?, datetime = ?, datetime_epoch = ?, logger_id = ?, log = ?, gc_id = ?, needstobelogged = ? where id = ?");

        SET_VAR_INT (1, self.logstring_id);
        SET_VAR_INT (2, self.waypoint_id);
        SET_VAR_TEXT(3, self.datetime);
        SET_VAR_INT (4, self.datetime_epoch);
        SET_VAR_INT (5, self.logger_id);
        SET_VAR_TEXT(6, self.log);
        SET_VAR_INT (7, self.gc_id);
        SET_VAR_INT (8, self._id);
        SET_VAR_BOOL(9, self.needstobelogged);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateWaypoint:(NSId)c_id;
{
    @synchronized(db) {
        DB_PREPARE(@"update logs set waypoint_id = ? where id = ?");

        SET_VAR_INT(1, c_id);
        SET_VAR_INT(2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateNote
{
    @synchronized(db) {
        DB_PREPARE(@"update logs set log = ? where id = ?");

        SET_VAR_TEXT(1, self.log);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCountByWaypoint:(NSId)wp_id
{
    NSInteger count = 0;

    @synchronized(db) {
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

+ (NSArray<dbLog *> *)dbAllByWaypoint:(NSId)_wp_id
{
    NSMutableArray *ls = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, gc_id, waypoint_id, log_string_id, datetime, datetime_epoch, logger_id, log, needstobelogged from logs where waypoint_id = ? order by datetime_epoch desc");

        SET_VAR_INT(1, _wp_id);

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];
            INT_FETCH (0, l._id);
            INT_FETCH (1, l.gc_id);
            INT_FETCH (2, l.waypoint_id);
            INT_FETCH (3, l.logstring_id);
            TEXT_FETCH(4, l.datetime);
            //INT_FETCH_AND_ASSIGN(5, l.datetime_epoch);
            INT_FETCH (6, l.logger_id);
            TEXT_FETCH(7, l.log);
            BOOL_FETCH(8, l.needstobelogged);
            [l finish];
            [ls addObject:l];
        }
        DB_FINISH;
    }
    return ls;
}

+ (NSArray<dbLog *> *)dbAllByWaypointLogged:(NSId)wp_id
{
    NSMutableArray *ls = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, gc_id, waypoint_id, log_string_id, datetime, datetime_epoch, logger_id, log, needstobelogged from logs where waypoint_id = ? and logger_id in (select id from names where name in (select accountname from accounts where accountname != '')) order by datetime_epoch desc");

        SET_VAR_INT(1, wp_id);

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];
            INT_FETCH (0, l._id);
            INT_FETCH (1, l.gc_id);
            INT_FETCH (2, l.waypoint_id);
            INT_FETCH (3, l.logstring_id);
            TEXT_FETCH(4, l.datetime);
            //INT_FETCH_AND_ASSIGN(5, l.datetime_epoch);
            INT_FETCH (6, l.logger_id);
            TEXT_FETCH(7, l.log);
            BOOL_FETCH(8, l.needstobelogged);
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

    @synchronized(db) {
        DB_PREPARE(@"select count(id) from logs where waypoint_id = ? and log like ?");

        SET_VAR_INT( 1, wp._id);
        NSString *s = [NSString stringWithFormat:@"%%%@%%", string];
        SET_VAR_TEXT(2, s);

        DB_IF_STEP {
            INT_FETCH(0, c);
        }
        DB_FINISH;
    }
    return c;
}

+ (NSInteger)dbCount
{
    return [dbLog dbCount:@"logs"];
}

+ (dbLog *)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSString *)date note:(NSString *)note needstobelogged:(BOOL)needstobelogged
{
    dbLog *log = [[dbLog alloc] init];

    log.needstobelogged = needstobelogged;
    log.logstring_string = logstring.text;
    log.log = note;
    log.datetime = [NSString stringWithFormat:@"%@T00:00:00", date];
    log.waypoint_id = waypoint._id;
    log.waypoint = waypoint;

    log.logstring_id = logstring._id;
    log.logstring = logstring;
    log.logstring_string = logstring.text;

    dbName *name = waypoint.account.accountname;
    log.logger = name;
    log.logger_id = name._id;
    log.logger_gsid = name.code;
    log.logger_str = name.name;

    [log finish];

    [log dbCreate];
    return log;
}

@end
