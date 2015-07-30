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

@synthesize groundspeak, groundspeak_id, name, description, url, urlname, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, type_id, type_str, type,  symbol_str, symbol_id, symbol, coordinates, calculatedDistance, calculatedBearing;

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
            type_str = type.type;
        }
        if (type_str != nil) {
            type = [dbc Type_get_byname:type_str];
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

    if (groundspeak_id != 0)
        groundspeak = [dbGroundspeak dbGet:groundspeak_id];

    [super finish];
}

- (NSInteger)hasLogs {
    return [dbLog dbCountByWaypoint:_id];
}

- (NSInteger)hasAttributes {
    return [dbAttribute dbCountByWaypoint:_id];
}

- (NSInteger)hasFieldNotes { return 0; }
- (NSInteger)hasWaypoints { return 0; }
- (NSInteger)hasImages { return 0; }

- (NSInteger)hasInventory {
    return [dbTravelbug dbCountByWaypoint:_id];
}

+ (NSMutableArray *)dbAll
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints");

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

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray *)dbAllNotFound
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    @synchronized(db.dbaccess) {
//        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints wp where wp.id in (select waypoint_id from logs where log_type_id = (select id from log_types where logtype = 'Didn''t find it') and logger_id in (select id from names where name = 'Team MavEtJu'))");
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints where id in (select waypoint_id from logs where (logger_id = (select id from names where name in (select account from accounts))) and id in (select id from logs where log_type_id = (select id from log_types where logtype = 'Didn''t find it'))) and not id in (select waypoint_id from logs where (logger_id = (select id from names where name in (select account from accounts))) and id in (select id from logs where log_type_id in (select id from log_types where logtype = 'Attended' or logtype = 'Found it')))");

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

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray *)dbAllFound
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints wp where wp.id in (select waypoint_id from logs where log_type_id = (select id from log_types where logtype = 'Found it') and logger_id in (select id from names where name in (select account from accounts)))");

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

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray *)dbAllAttended
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints wp where wp.id in (select waypoint_id from logs where log_type_id = (select id from log_types where logtype = 'Attended') and logger_id in (select id from names where name in (select account from accounts)))");

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

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray *)dbAllInGroups:(NSArray *)groups
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    NSMutableString *where = [NSMutableString stringWithString:@""];
    NSEnumerator *e = [groups objectEnumerator];
    dbObject *o;
    while ((o = [e nextObject]) != nil) {
        if ([where compare:@""] != NSOrderedSame)
            [where appendString:@" or "];
        [where appendFormat:@"group_id = ?"];
    }

    @synchronized(db.dbaccess) {
        NSString *sql = [NSString stringWithFormat:@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints wp where wp.id in (select waypoint_id from group2waypoints where %@)", where];
        DB_PREPARE(sql);
        NSInteger i = 1;
        NSEnumerator *e = [groups objectEnumerator];
        dbObject *o;
        while ((o = [e nextObject]) != nil) {
            SET_VAR_INT((int)i, o._id);
            i++;
        }

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

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
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
    dbWaypoint *wp;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, groundspeak_id, urlname from waypoints where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            INT_FETCH(  0, _id);
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

            [wp finish];
        }
        DB_FINISH;
    }

    return wp;
}

+ (void)dbCreate:(dbWaypoint *)wp
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into waypoints(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol_id, urlname, groundspeak_id) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?)");

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

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    wp._id = _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, type_id = ?, symbol_id = ?, groundspeak_id = ?, urlname = ? where id = ?");

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
        SET_VAR_INT( 14, _id);
        
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

@end
