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

TABLENAME(@"logs")

- (instancetype)init:(NSId)_id gc_id:(NSInteger)gc_id waypoint:(dbWaypoint *)wp logstring:(dbLogString *)ls datetime:(NSInteger)datetime logger:(dbName *)logger log:(NSString *)log needstobelogged:(BOOL)needstobelogged locallog:(BOOL)locallog coordinates:(CLLocationCoordinate2D)coordinates;
{
    ASSERT_FIELD_EXISTS(wp);
    ASSERT_FIELD_EXISTS(ls);
    ASSERT_FIELD_EXISTS(logger);
    self = [super init];
    self._id = _id;
    self.gc_id = gc_id;
    self.waypoint = wp;
    self.logstring = ls;
    self.datetime_epoch = datetime;
    self.logger = logger;
    self.log = log;
    self.needstobelogged = needstobelogged;
    self.localLog = locallog;
    self.latitude = coordinates.latitude;
    self.longitude = coordinates.longitude;

    [self finish];

    self.cellHeight = 0;

    return self;
}

- (void)set_logstring_str:(NSString *)s account:(dbAccount *)account
{
    ASSERT_FIELD_EXISTS(account);
    NSAssert(FALSE, @"to be checked");
//    self.logstring = [dbc LogString_get_bytype:account logtype:self.waypoint.logstring_logtype type:self.logstring_string];
}

+ (NSInteger)dbCountByWaypoint:(dbWaypoint *)wp
{
    return [self dbCountXXX:@"where waypoint_id = ?" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (NSInteger)dbCountByWaypointLogString:(dbWaypoint *)wp LogString:(NSString *)string
{
    NSString *s = [NSString stringWithFormat:@"%%%@%%", string];
    return [self dbCountXXX:@"where waypoint_id = ? and log like ?" keys:@"is" values:@[[NSNumber numberWithId:wp._id], s]];
}

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(waypoint);
    ASSERT_SELF_FIELD_EXISTS(logstring);
    ASSERT_SELF_FIELD_EXISTS(logger);
    @synchronized(db) {
        DB_PREPARE(@"insert into logs(waypoint_id, log_string_id, datetime_epoch, logger_id, log, gc_id, needstobelogged, locallog, lat, lon) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_INT   ( 1, self.waypoint._id);
        SET_VAR_INT   ( 2, self.logstring._id);
        SET_VAR_INT   ( 3, self.datetime_epoch);
        SET_VAR_INT   ( 4, self.logger._id);
        SET_VAR_TEXT  ( 5, self.log);
        SET_VAR_INT   ( 6, self.gc_id);
        SET_VAR_BOOL  ( 7, self.needstobelogged);
        SET_VAR_BOOL  ( 8, self.localLog);
        SET_VAR_DOUBLE( 9, self.latitude);
        SET_VAR_DOUBLE(10, self.longitude);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
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
        SET_VAR_DOUBLE( 9, self.latitude);
        SET_VAR_DOUBLE(10, self.longitude);
        SET_VAR_INT   (11, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateWaypoint:(dbWaypoint *)wp;
{
    @synchronized(db) {
        DB_PREPARE(@"update logs set waypoint_id = ? where id = ?");

        SET_VAR_INT(1, wp._id);
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

+ (NSArray<dbLog *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLog *> *ls = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, gc_id, waypoint_id, log_string_id, datetime_epoch, logger_id, log, needstobelogged, locallog, lat, lon from logs "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbLog *l = [[dbLog alloc] init];
            INT_FETCH   ( 0, l._id);
            INT_FETCH   ( 1, l.gc_id);
            INT_FETCH   ( 2, i);
            l.waypoint = [dbWaypoint dbGet:i];
            INT_FETCH   ( 3, i);
            l.logstring = [dbc logStringGet:i];
            INT_FETCH   ( 4, l.datetime_epoch);
            INT_FETCH   ( 5, i);
            l.logger = [dbc nameGet:i];
            TEXT_FETCH  ( 6, l.log);
            BOOL_FETCH  ( 7, l.needstobelogged);
            BOOL_FETCH  ( 8, l.localLog);
            DOUBLE_FETCH( 9, l.latitude);
            DOUBLE_FETCH(10, l.longitude);
            [l finish];
            [ls addObject:l];
        }
        DB_FINISH;
    }
    return ls;
}

+ (NSArray<dbLog *> *)dbAllByWaypoint:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where waypoint_id = ? order by datetime_epoch desc" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (NSArray<dbLog *> *)dbLast7ByWaypoint:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where waypoint_id = ? order by datetime_epoch desc limit 7" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (NSArray<dbLog *> *)dbAllByWaypointLoggedByMe:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where waypoint_id = ? and logger_id in (select id from names where id in (select accountname_id from accounts where accountname_id != 0)) order by datetime_epoch desc" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (NSArray<dbLog *> *)dbAllByWaypointUnsubmitted:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where waypoint_id = ? and needstobelogged = 1 and logger_id in (select id from names where id in (select accountname_id from accounts where accountname_id != 0)) order by datetime_epoch desc" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (NSArray<dbLog *> *)dbLast7ByWaypointLoggedByMe:(dbWaypoint *)wp
{
    return [self dbAllXXX:@"where waypoint_id = ? and logger_id in (select id from names where id in (select accountname_id from accounts where accountname_id != 0)) order by datetime_epoch desc limit 7" keys:@"i" values:@[[NSNumber numberWithId:wp._id]]];
}

+ (dbLog *)dbGetIdByGC:(NSInteger)gc_id account:(dbAccount *)account
{
    return [[self dbAllXXX:@"where gc_id = ? and waypoint_id in (select id from waypoints where account_id = ?) order by datetime_epoch desc" keys:@"ii" values:@[[NSNumber numberWithInteger:gc_id], [NSNumber numberWithId:account._id]]] firstObject];
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

/* Other methods */

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

    log.latitude = coordinates.latitude;
    log.longitude = coordinates.longitude;

    [log finish];

    [log dbCreate];
    return log;
}

@end
