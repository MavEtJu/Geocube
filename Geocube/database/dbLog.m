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

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id waypoint_id:(NSId)wpid logstring_id:(NSId)lsid datetime:(NSInteger)datetime logger_id:(NSId)logger_id log:(NSString *)log needstobelogged:(BOOL)needstobelogged locallog:(BOOL)locallog coordinates:(CLLocationCoordinate2D)coordinates
{
    self = [super init];
    self._id = _id;
    self.gc_id = gc_id;
    self.waypoint = [dbWaypoint dbGet:wpid];
    self.logstring = [dbc LogString_get:lsid];
    self.datetime_epoch = datetime;
    self.logger = [dbc Name_get:logger_id];
    self.log = log;
    self.needstobelogged = needstobelogged;
    self.localLog = locallog;
    self.lat = coordinates.latitude;
    self.lon = coordinates.longitude;

    [self finish];

    self.cellHeight = 0;

    return self;
}

- (void)set_logstring_str:(NSString *)s account:(dbAccount *)account
{
    NSAssert(account != nil, @"account should not be nil");
    NSAssert(FALSE, @"to be checked");
//    self.logstring = [dbc LogString_get_bytype:account logtype:self.waypoint.logstring_logtype type:self.logstring_string];
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
        DB_PREPARE(@"insert into logs(waypoint_id, log_string_id, datetime_epoch, logger_id, log, gc_id, needstobelogged, locallog, lat, lon) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT   ( 1, log.waypoint._id);
        SET_VAR_INT   ( 2, log.logstring._id);
        SET_VAR_INT   ( 3, log.datetime_epoch);
        SET_VAR_INT   ( 4, log.logger._id);
        SET_VAR_TEXT  ( 5, log.log);
        SET_VAR_INT   ( 6, log.gc_id);
        SET_VAR_BOOL  ( 7, log.needstobelogged);
        SET_VAR_BOOL  ( 8, log.localLog);
        SET_VAR_DOUBLE( 9, log.lat);
        SET_VAR_DOUBLE(10, log.lon);

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
        DB_PREPARE(@"update logs set log_string_id = ?, waypoint_id = ?, datetime_epoch = ?, logger_id = ?, log = ?, gc_id = ?, needstobelogged = ?, locallog = ?, lat = ?, lon = ? where id = ?");

        SET_VAR_INT   ( 1, self.logstring._id);
        SET_VAR_INT   ( 2, self.waypoint._id);
        SET_VAR_INT   ( 3, self.datetime_epoch);
        SET_VAR_INT   ( 4, self.logger._id);
        SET_VAR_TEXT  ( 5, self.log);
        SET_VAR_INT   ( 6, self.gc_id);
        SET_VAR_BOOL  ( 7, self.needstobelogged);
        SET_VAR_BOOL  ( 8, self.localLog);
        SET_VAR_DOUBLE( 9, self.lat);
        SET_VAR_DOUBLE(10, self.lon);
        SET_VAR_INT   (11, self._id);

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

+ (NSArray<dbLog *> *)dbAllByXXX:(NSString *)where limit:(NSInteger)limit
{
    NSMutableArray<dbLog *> *ls = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithFormat:@"select id, gc_id, waypoint_id, log_string_id, datetime_epoch, logger_id, log, needstobelogged, locallog, lat, lon, lat_int, lon_int from logs where %@ order by datetime_epoch desc", where];
    if (limit != -1)
        [sql appendFormat:@" limit %ld", (long)limit];

    @synchronized(db) {
        DB_PREPARE(sql);

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];
            INT_FETCH   ( 0, l._id);
            INT_FETCH   ( 1, l.gc_id);
            INT_FETCH   ( 2, i);
            l.waypoint = [dbWaypoint dbGet:i];
            INT_FETCH   ( 3, i);
            l.logstring = [dbc LogString_get:i];
            INT_FETCH   ( 4, l.datetime_epoch);
            INT_FETCH   ( 5, i);
            l.logger = [dbc Name_get:i];
            TEXT_FETCH  ( 6, l.log);
            BOOL_FETCH  ( 7, l.needstobelogged);
            BOOL_FETCH  ( 8, l.localLog);
            DOUBLE_FETCH( 9, l.lat);
            DOUBLE_FETCH(10, l.lon);
            [l finish];
            [ls addObject:l];
        }
        DB_FINISH;
    }
    return ls;
}

+ (NSArray<dbLog *> *)dbAllByWaypoint:(NSId)wp_id
{
    return [self dbAllByXXX:[NSString stringWithFormat:@"waypoint_id = %ld", (long)wp_id] limit:-1];
}

+ (NSArray<dbLog *> *)dbLast7ByWaypoint:(NSId)wp_id
{
    return [self dbAllByXXX:[NSString stringWithFormat:@"waypoint_id = %ld", (long)wp_id] limit:7];
}

+ (NSArray<dbLog *> *)dbAllByWaypointLogged:(NSId)wp_id
{
    return [self dbAllByXXX:[NSString stringWithFormat:@"waypoint_id = %ld and logger_id in (select id from names where name in (select accountname from accounts where accountname != ''))", (long)wp_id] limit:-1];
}

+ (NSArray<dbLog *> *)dbAllByWaypointUnsubmitted:(NSId)wp_id
{
    return [self dbAllByXXX:[NSString stringWithFormat:@"waypoint_id = %ld and needstobelogged = 1 and logger_id in (select id from names where name in (select accountname from accounts where accountname != ''))", (long)wp_id] limit:-1];
}

+ (NSArray<dbLog *> *)dbLast7ByWaypointLogged:(NSId)wp_id
{
    return [self dbAllByXXX:[NSString stringWithFormat:@"waypoint_id = %ld and logger_id in (select id from names where name in (select accountname from accounts where accountname != ''))", (long)wp_id] limit:7];
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

+ (dbLog *)CreateLogNote:(dbLogString *)logstring waypoint:(dbWaypoint *)waypoint dateLogged:(NSInteger)date note:(NSString *)note needstobelogged:(BOOL)needstobelogged locallog:(BOOL)locallog coordinates:(CLLocationCoordinate2D)coordinates
{
    dbLog *log = [[dbLog alloc] init];

    log.needstobelogged = needstobelogged;
    log.localLog = locallog;
    log.logstring = logstring;
    log.log = note;
    log.datetime_epoch = date;
    log.waypoint = waypoint;

    log.logstring = logstring;

    dbName *name = waypoint.account.accountname;
    log.logger = name;
    log.logger_gsid = name.code;

    log.lat = coordinates.latitude;
    log.lon = coordinates.longitude;

    [log finish];

    [log dbCreate];
    return log;
}

- (void)dbDelete
{
    @synchronized(db) {
        DB_PREPARE(@"delete from logs where id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
