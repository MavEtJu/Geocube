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

@implementation dbWaypoint

@synthesize groundspeak, groundspeak_id, name, description, url, urlname, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, type_id, type_str, type,  symbol_str, symbol_id, symbol, coordinates, calculatedDistance, calculatedBearing, logStatus, highlight, account, account_id;

- (id)init:(NSId)__id
{
    self = [super init];
    self._id = __id;

    self.name = nil;
    self.groundspeak = nil;
    self.description = nil;
    self.url = nil;
    self.urlname = nil;
    self.lat = nil;
    self.lat_int = 0;
    self.lat_float = 0;
    self.lon = nil;
    self.lon_int = 0;
    self.lon_float = 0;
    self.date_placed = nil;
    self.date_placed_epoch = 0;
    self.type_id = 0;
    self.type_str = nil;
    self.type = nil;
    self.symbol_id = 0;
    self.symbol_str = nil;
    self.symbol = nil;
    self.coordinates = CLLocationCoordinate2DMake(0, 0);
    self.calculatedDistance = 0;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.highlight = NO;
    self.account_id = 0;
    self.account = nil;

    return self;
}

- (void)finish
{
    // Conversions from the data retrieved
    lat_float = [lat floatValue];
    lon_float = [lon floatValue];
    lat_int = lat_float * 1000000;
    lon_int = lon_float * 1000000;

    date_placed_epoch = [MyTools secondsSinceEpoch:date_placed];

    coordinates = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);

    // Adjust cache types
    if (type == nil) {
        if (type_id != 0) {
            type = [dbc Type_get:type_id];
            type_str = type.type_full;
        }
        if (type_str != nil) {
            NSArray *as = [type_str componentsSeparatedByString:@"|"];
            if ([as count] == 2) {
                // Geocache|Traditional Cache
                type = [dbc Type_get_byname:[as objectAtIndex:0] minor:[as objectAtIndex:1]];
            } else {
                // Traditional Cache
                [[dbc Types] enumerateObjectsUsingBlock:^(dbType *t, NSUInteger idx, BOOL *stop) {
                    if ([t.type_minor isEqualToString:type_str] == YES) {
                        type = t;
                        *stop = YES;
                    }
                }];
            }
            type_id = type._id;
        }
    }

    // Adjust cache symbol
    if (symbol == nil) {
        if (symbol_id != 0) {
            symbol = [dbc Symbol_get:symbol_id];
            symbol_str = symbol.symbol;
        }
        if (symbol_str != nil) {
            symbol = [dbc Symbol_get_bysymbol:symbol_str];
            symbol_id = symbol._id;
        }
    }

    if (account_id != 0)
        account = [dbc Account_get:account_id];
    if (account != nil)
        account_id = account._id;

    if (groundspeak_id != 0)
        groundspeak = [dbGroundspeak dbGet:groundspeak_id waypoint:self];

    [super finish];
}

- (NSInteger)hasLogs {
    return [dbLog dbCountByWaypoint:_id];
}

- (NSInteger)hasAttributes {
    return [dbAttribute dbCountByWaypoint:_id];
}

- (NSInteger)hasFieldNotes {
    return [[dbLog dbAllByWaypointLogged:_id] count];
}

- (NSInteger)hasImages {
    return [dbImage dbCountByWaypoint:_id];
}

- (NSInteger)hasPersonalNotes {
    return [dbTravelbug dbCountByWaypoint:_id];
}

- (NSInteger)hasInventory {
    return [dbTravelbug dbCountByWaypoint:_id];
}

- (NSArray *)hasWaypoints
{
    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, groundspeak_id, urlname from waypoints where name like ?")

        NSString *sql = [NSString stringWithFormat:@"%%%@", [self.name substringFromIndex:2]];
        SET_VAR_TEXT(1, sql);
        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, __id);
            [wps addObject:[dbWaypoint dbGet:__id]];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSMutableArray *)dbAllXXX:(NSString *)where
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname, log_status, highlight, account_id from waypoints wp"];
    if (where != nil) {
        [sql appendString:@" where "];
        [sql appendString:where];
    }

    @synchronized(db.dbaccess) {
        DB_PREPARE(sql);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            wp = [[dbWaypoint alloc] init:_id];

            TEXT_FETCH( 1, wp.name);
            TEXT_FETCH( 2, wp.description);
            TEXT_FETCH( 3, wp.lat);
            TEXT_FETCH( 4, wp.lon);
            INT_FETCH(  5, wp.lat_int);
            INT_FETCH(  6, wp.lon_int);
            TEXT_FETCH( 7, wp.date_placed);
            INT_FETCH(  8, wp.date_placed_epoch);
            TEXT_FETCH( 9, wp.url);
            INT_FETCH( 10, wp.type_id);
            INT_FETCH( 11, wp.symbol_id);
            INT_FETCH( 12, wp.groundspeak_id);
            TEXT_FETCH(13, wp.urlname);
            INT_FETCH( 14, wp.logStatus);
            BOOL_FETCH(15, wp.highlight);
            INT_FETCH( 16, wp.account_id);

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray *)dbAll
{
    NSArray *wps = [dbWaypoint dbAllXXX:nil];
    return wps;
}

+ (NSInteger)dbCount
{
    return [dbWaypoint dbCount:@"waypoints"];
}

+ (NSArray *)dbAllNotFound
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"id in (select waypoint_id from logs where (logger_id = (select id from names where name in (select accountname from accounts where accountname != ''))) and id in (select id from logs where log_type_id = (select id from log_types where logtype = 'Didn''t find it'))) and not id in (select waypoint_id from logs where (logger_id = (select id from names where name in (select accountname from accounts where accountname != ''))) and id in (select id from logs where log_type_id in (select id from log_types where logtype = 'Attended' or logtype = 'Found it')))"];
    return wps;
}

+ (NSArray *)dbAllFound
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"wp.id in (select waypoint_id from logs where log_type_id = (select id from log_types where logtype = 'Found it') and logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))"];
    return wps;
}

+ (NSArray *)dbAllAttended
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"wp.id in (select waypoint_id from logs where log_type_id = (select id from log_types where logtype = 'Attended') and logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))"];
    return wps;
}

+ (NSArray *)dbAllInGroups:(NSArray *)groups
{
    NSMutableString *where = [NSMutableString stringWithString:@""];
    [groups enumerateObjectsUsingBlock:^(dbGroup *group, NSUInteger idx, BOOL *stop) {
        if ([where isEqualToString:@""] == NO)
            [where appendString:@" or "];
        [where appendFormat:@"group_id = %ld", (long)group._id];
    }];
    // Stop selecting this criteria without actually selecting a group!
    if ([where isEqualToString:@""] == YES)
        return nil;

    NSArray *wps = [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"wp.id in (select waypoint_id from group2waypoints where %@)", where]];
    return wps;
}

+ (NSId)dbGetByName:(NSString *)name
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from waypoints where name = ?");

        SET_VAR_TEXT( 1, name);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN( 0, __id);
            _id = __id;
        }
        DB_FINISH;
    }
    return _id;
}

+ (dbWaypoint *)dbGet:(NSId)_id
{
    NSArray *wps = [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"wp.id = %ld", (long)_id]];
    if ([wps count] == 0)
        return nil;
    return [wps objectAtIndex:0];
}

+ (void)dbCreate:(dbWaypoint *)wp
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into waypoints(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, urlname, groundspeak_id, log_status, highlight, account_id) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, wp.name);
        SET_VAR_TEXT( 2, wp.description);
        SET_VAR_TEXT( 3, wp.lat);
        SET_VAR_TEXT( 4, wp.lon);
        SET_VAR_INT(  5, wp.lat_int);
        SET_VAR_INT(  6, wp.lon_int);
        SET_VAR_TEXT( 7, wp.date_placed);
        SET_VAR_INT(  8, wp.date_placed_epoch);
        SET_VAR_TEXT( 9, wp.url);
        SET_VAR_INT( 10, wp.type_id);
        SET_VAR_INT( 11, wp.symbol_id);
        SET_VAR_TEXT(12, wp.urlname);
        SET_VAR_INT( 13, wp.groundspeak_id);
        SET_VAR_INT( 14, wp.logStatus);
        SET_VAR_BOOL(15, wp.highlight);
        SET_VAR_INT( 16, wp.account_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    wp._id = _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, type_id = ?, symbol_id = ?, groundspeak_id = ?, urlname = ?, log_status = ?, highlight = ?, account_id = ? where id = ?");

        SET_VAR_TEXT( 1, name);
        SET_VAR_TEXT( 2, description);
        SET_VAR_TEXT( 3, lat);
        SET_VAR_TEXT( 4, lon);
        SET_VAR_INT(  5, lat_int);
        SET_VAR_INT(  6, lon_int);
        SET_VAR_TEXT( 7, date_placed);
        SET_VAR_INT(  8, date_placed_epoch);
        SET_VAR_TEXT( 9, url);
        SET_VAR_INT( 10, type_id);
        SET_VAR_INT( 11, symbol_id);
        SET_VAR_INT( 12, groundspeak_id);
        SET_VAR_TEXT(13, urlname);
        SET_VAR_INT( 14, logStatus);
        SET_VAR_BOOL(15, highlight);
        SET_VAR_INT( 16, account_id);
        SET_VAR_INT( 17, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateGroundspeak
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set groundspeak_id = ? where id = ?");

        SET_VAR_INT(1, groundspeak_id);
        SET_VAR_INT(2, _id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbUpdateLogStatus
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set log_status = 1 where id in (select waypoint_id from logs l where log_type_id in (select id from log_types where logtype = 'Didn''t find it') and logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set log_status = 2 where id in (select waypoint_id from logs l where log_type_id in (select id from log_types where logtype = 'Found it' or logtype = 'Attended') and logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateHighlight
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set highlight = ? where id = ?");

        SET_VAR_BOOL(1, self.highlight);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSString *)makeName:(NSString *)suffix
{

    for (char c = 'A'; c <= 'Z'; c++) {
        for (NSInteger i = 0; i < 10; i++) {
            NSString *s = [NSString stringWithFormat:@"%c%ld%@", c, (long)i, suffix];
            if ([dbWaypoint dbGetByName:s] == 0)
                return s;
        }
    }

    return nil;
}

+ (NSArray *)waypointsWithImages
{
    NSArray *wps = [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"id in (select waypoint_id from image2waypoint where type = %d)", IMAGETYPE_USER]];
    return wps;
}

+ (NSArray *)waypointsWithLogs
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"id in (select waypoint_id from logs)"];
    return wps;
}

+ (NSArray *)waypointsWithMyLogs
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"id in (select waypoint_id from logs where logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))"];
    return wps;
}

@end
