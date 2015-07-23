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

@synthesize groundspeak, groundspeak_id, name, description, url, urlname, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, type_id, type_str, type,  symbol_str, symbol_id, symbol, coordinates, calculatedDistance;

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
    if (type == nil) {
        type = [dbc Type_get_byname:symbol_str];
        type_id = type._id;
        type_str = symbol_str;
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
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            wp = [[dbWaypoint alloc] init:_id];

            TEXT_FETCH(req,  1, wp.name);
            TEXT_FETCH(req,  2, wp.description);
            TEXT_FETCH(req,  3, wp.lat);
            TEXT_FETCH(req,  4, wp.lon);
            INT_FETCH(req,   5, wp.lat_int);
            INT_FETCH(req,   6, wp.lon_int);
            TEXT_FETCH(req,  7, wp.date_placed);
            INT_FETCH(req,   8, wp.date_placed_epoch);
            TEXT_FETCH(req,  9, wp.url);
            INT_FETCH(req,  10, wp.type_id);
            INT_FETCH(req,  11, wp.symbol_id);
            INT_FETCH(req,  12, wp.groundspeak_id);
            TEXT_FETCH(req, 13, wp.urlname);

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

        SET_VAR_TEXT(req, 1, name);

        DB_IF_STEP {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
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
        DB_PREPARE(@"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol, groundspeak_id, urlname from waypoints where id = ?");

        SET_VAR_INT(req, 1, _id);

        DB_IF_STEP {
            INT_FETCH(req,   0, _id);
            wp = [[dbWaypoint alloc] init:_id];

            TEXT_FETCH(req,  1, wp.name);
            TEXT_FETCH(req,  2, wp.description);
            TEXT_FETCH(req,  3, wp.lat);
            TEXT_FETCH(req,  4, wp.lon);
            INT_FETCH(req,   5, wp.lat_int);
            INT_FETCH(req,   6, wp.lon_int);
            TEXT_FETCH(req,  7, wp.date_placed);
            INT_FETCH(req,   8, wp.date_placed_epoch);
            TEXT_FETCH(req,  9, wp.url);
            INT_FETCH(req,  10, wp.type_id);
            INT_FETCH(req,  11, wp.symbol_id);
            INT_FETCH(req,  12, wp.groundspeak_id);
            TEXT_FETCH(req, 13, wp.urlname);

            [wp finish];
        }
        DB_FINISH;
    }

    return wp;
}

+ (NSId)dbCreate:(dbWaypoint *)wp
{
    NSId _id = 0;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into waypoints(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, type_id, symbol, urlname, groundspeak_id) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?)");

        SET_VAR_TEXT(req,  1, wp.name);
        SET_VAR_TEXT(req,  2, wp.description);
        SET_VAR_TEXT(req,  3, wp.lat);
        SET_VAR_TEXT(req,  4, wp.lon);
        SET_VAR_INT(req,   5, wp.lat_int);
        SET_VAR_INT(req,   6, wp.lon_int);
        SET_VAR_TEXT(req,  7, wp.date_placed);
        SET_VAR_INT(req,   8, wp.date_placed_epoch);
        SET_VAR_TEXT(req,  9, wp.url);
        SET_VAR_INT(req,  10, wp.type_id);
        SET_VAR_INT(req,  11, wp.symbol_id);
        SET_VAR_TEXT(req, 12, wp.urlname);
        SET_VAR_INT(req,  13, wp.groundspeak_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, type_id = ?, symbol = ?, groundspeak_id = ?, urlname = ? where id = ?");

        SET_VAR_TEXT(req,  1, name);
        SET_VAR_TEXT(req,  2, description);
        SET_VAR_TEXT(req,  3, lat);
        SET_VAR_TEXT(req,  4, lon);
        SET_VAR_INT(req,   5, lat_int);
        SET_VAR_INT(req,   6, lon_int);
        SET_VAR_TEXT(req,  7, date_placed);
        SET_VAR_INT(req,   8, date_placed_epoch);
        SET_VAR_TEXT(req,  9, url);
        SET_VAR_INT(req,  10, type_id);
        SET_VAR_INT(req,  11, symbol_id);
        SET_VAR_INT(req,  12, groundspeak_id);
        SET_VAR_TEXT(req, 13, urlname);
        SET_VAR_INT(req,  14, _id);
        
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
