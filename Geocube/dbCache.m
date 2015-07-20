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

@implementation dbCache

@synthesize _id, name, description, url, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, gc_rating_difficulty, gc_rating_terrain, gc_favourites, cache_type_int, cache_type_str, cache_type, gc_country, gc_state, gc_short_desc_html, gc_short_desc, gc_long_desc_html, gc_long_desc, gc_hint, gc_personal_note, calculatedDistance, coordinates, gc_containerSize, gc_containerSize_str, gc_containerSize_int, gc_archived, gc_available, cache_symbol, cache_symbol_int, cache_symbol_str;

- (id)init:(NSInteger)__id
{
    self = [super init];
    _id = __id;

    self.gc_archived = NO;
    self.gc_available = YES;
    self.gc_country = nil;
    self.gc_state = nil;
    self.gc_short_desc = nil;
    self.gc_short_desc_html = NO;
    self.gc_long_desc = nil;
    self.gc_long_desc_html = NO;
    self.gc_hint = nil;
    self.gc_personal_note = nil;
    self.gc_containerSize = nil;
    self.gc_favourites = 0;
    self.gc_rating_difficulty = 0;
    self.gc_rating_terrain = 0;

    return self;
}

- (void)finish
{
    // Conversions from the data retrieved
    lat_float = [lat floatValue];
    lon_float = [lon floatValue];
    lat_int = lat_float * 1000000;
    lon_int = lon_float * 1000000;
    cache_type = [dbc CacheType_get:cache_type_int];

    date_placed_epoch = [MyTools secondsSinceEpoch:date_placed];

    coordinates = CLLocationCoordinate2DMake([lat floatValue], [lon floatValue]);

    // Adjust container size
    if (gc_containerSize == nil) {
        if (gc_containerSize_int != 0) {
            gc_containerSize = [dbc ContainerSize_get:gc_containerSize_int];
            gc_containerSize_str = gc_containerSize.size;
        }
        if (gc_containerSize_str != nil) {
            gc_containerSize = [dbc ContainerSize_get_bysize:gc_containerSize_str];
            gc_containerSize_int = gc_containerSize._id;
        }
    }

    // Adjust cache types
    if (cache_type == nil) {
        if (cache_type_int != 0) {
            cache_type = [dbc CacheType_get:cache_type_int];
            cache_type_str = cache_type.type;
        }
        if (cache_type_str != nil) {
            cache_type = [dbc CacheType_get_byname:cache_type_str];
            cache_type_int = cache_type._id;
        }
    }

    // Adjust cache symbol
    if (cache_symbol == nil) {
        if (cache_symbol_int != 0) {
            cache_symbol = [dbc CacheSymbol_get:cache_symbol_int];
            cache_symbol_str = cache_symbol.symbol;
        }
        if (cache_symbol_str != nil) {
            cache_symbol = [dbc CacheSymbol_get_bysymbol:cache_symbol_str];
            cache_symbol_int = cache_symbol._id;
        }
    }

    [super finish];
}

- (NSInteger)hasLogs {
    return [dbLog dbCountByCache:_id];
}

- (NSInteger)hasAttributes {
    return [dbAttribute dbCountByCache:_id];
}

- (BOOL)hasFieldNotes { return NO; }
- (BOOL)hasWaypoints { return NO; }
- (BOOL)hasInventory { return NO; }
- (BOOL)hasImages { return NO; }

+ (NSMutableArray *)dbAll
{
    NSString *sql = @"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, cache_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint, gc_container_size_id, gc_archived, gc_available, cache_symbol from caches";
    sqlite3_stmt *req;
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbCache *wp;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _name);
            TEXT_FETCH_AND_ASSIGN(req, 2, _desc);
            TEXT_FETCH_AND_ASSIGN(req, 3, _lat);
            TEXT_FETCH_AND_ASSIGN(req, 4, _lon);
            INT_FETCH_AND_ASSIGN(req, 5, _lat_int);
            INT_FETCH_AND_ASSIGN(req, 6, _lon_int);
            TEXT_FETCH_AND_ASSIGN(req, 7, _date_placed);
            INT_FETCH_AND_ASSIGN(req, 8, _date_placed_epoch);
            TEXT_FETCH_AND_ASSIGN(req, 9, _url);
            INT_FETCH_AND_ASSIGN(req, 10, _cache_type);
            TEXT_FETCH_AND_ASSIGN(req, 11, _country);
            TEXT_FETCH_AND_ASSIGN(req, 12, _state);
            DOUBLE_FETCH_AND_ASSIGN(req, 13, _ratingD);
            DOUBLE_FETCH_AND_ASSIGN(req, 14, _ratingT);
            INT_FETCH_AND_ASSIGN(req, 15, _favourites);
            BOOL_FETCH_AND_ASSIGN(req, 16, _gc_long_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 17, _gc_long_desc);
            BOOL_FETCH_AND_ASSIGN(req, 18, _gc_short_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 19, _gc_short_desc);
            TEXT_FETCH_AND_ASSIGN(req, 20, _gc_hint);
            INT_FETCH_AND_ASSIGN(req, 21, _gc_container_size);
            BOOL_FETCH_AND_ASSIGN(req, 22, _gc_archived);
            BOOL_FETCH_AND_ASSIGN(req, 23, _gc_available);
            BOOL_FETCH_AND_ASSIGN(req, 24, _cache_symbol);

            wp = [[dbCache alloc] init:__id];
            [wp setName:_name];
            [wp setDescription:_desc];
            [wp setLat:_lat];
            [wp setLon:_lon];

            [wp setLat_int:_lat_int];
            [wp setLon_int:_lon_int];
            [wp setDate_placed:_date_placed];
            [wp setDate_placed_epoch:_date_placed_epoch];
            [wp setUrl:_url];
            [wp setCache_type_int:_cache_type];
            [wp setGc_country:_country];
            [wp setGc_state:_state];
            [wp setGc_rating_difficulty:_ratingD];
            [wp setGc_rating_terrain:_ratingT];
            [wp setGc_favourites:_favourites];
            [wp setGc_long_desc_html:_gc_long_desc_html];
            [wp setGc_long_desc:_gc_long_desc];
            [wp setGc_short_desc_html:_gc_short_desc_html];
            [wp setGc_short_desc:_gc_short_desc];
            [wp setGc_hint:_gc_hint];
            [wp setGc_containerSize_int:_gc_container_size];
            [wp setGc_archived:_gc_archived];
            [wp setGc_available:_gc_available];
            [wp setCache_symbol_int:_cache_symbol];
            [wp finish];
            [wps addObject:wp];
        }
        sqlite3_finalize(req);
    }
    return wps;
}

+ (NSInteger)dbGetByName:(NSString *)name
{
    NSString *sql = @"select id from caches where name = ?";
    sqlite3_stmt *req;
    NSInteger _id = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            _id = __id;
        }
        sqlite3_finalize(req);
    }
    return _id;
}

+ (NSInteger)dbCreate:(dbCache *)wp
{
    NSString *sql = @"insert into caches(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, cache_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint, gc_container_size_id, gc_archived, gc_available, cache_symbol_int) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger __id = 0;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, wp.name);
        SET_VAR_TEXT(req, 2, wp.description);
        SET_VAR_TEXT(req, 3, wp.lat);
        SET_VAR_TEXT(req, 4, wp.lon);
        SET_VAR_INT(req, 5, wp.lat_int);
        SET_VAR_INT(req, 6, wp.lon_int);
        SET_VAR_TEXT(req, 7, wp.date_placed);
        SET_VAR_INT(req, 8, wp.date_placed_epoch);
        SET_VAR_TEXT(req, 9, wp.url);
        SET_VAR_INT(req, 10, wp.cache_type_int);
        SET_VAR_TEXT(req, 11, wp.gc_country);
        SET_VAR_TEXT(req, 12, wp.gc_state);
        SET_VAR_DOUBLE(req, 13, wp.gc_rating_difficulty);
        SET_VAR_DOUBLE(req, 14, wp.gc_rating_terrain);
        SET_VAR_INT(req, 15, wp.gc_favourites);
        SET_VAR_BOOL(req, 16, wp.gc_long_desc_html);
        SET_VAR_TEXT(req, 17, wp.gc_long_desc);
        SET_VAR_BOOL(req, 18, wp.gc_short_desc_html);
        SET_VAR_TEXT(req, 19, wp.gc_short_desc);
        SET_VAR_TEXT(req, 20, wp.gc_hint);
        SET_VAR_INT(req, 21, wp.gc_containerSize_int);
        SET_VAR_BOOL(req, 22, wp.gc_archived);
        SET_VAR_BOOL(req, 23, wp.gc_available);
        SET_VAR_INT(req, 24, wp.cache_symbol_int);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        __id = sqlite3_last_insert_rowid(db.db);
        sqlite3_finalize(req);
    }
    return __id;
}

- (void)dbUpdate
{
    NSString *sql = @"update caches set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, cache_type = ?, gc_country = ?, gc_state = ?, gc_rating_difficulty = ?, gc_rating_terrain = ?, gc_favourites = ?, gc_long_desc_html = ?, gc_long_desc = ?, gc_short_desc_html = ?, gc_short_desc = ?, gc_hint = ?, gc_container_size_id = ?, gc_archived = ?, gc_available = ?, cache_symbol = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);
        SET_VAR_TEXT(req, 2, description);
        SET_VAR_TEXT(req, 3, lat);
        SET_VAR_TEXT(req, 4, lon);
        SET_VAR_INT(req, 5, lat_int);
        SET_VAR_INT(req, 6, lon_int);
        SET_VAR_TEXT(req, 7, date_placed);
        SET_VAR_INT(req, 8, date_placed_epoch);
        SET_VAR_TEXT(req, 9, url);
        SET_VAR_INT(req, 10, cache_type_int);
        SET_VAR_TEXT(req, 11, gc_country);
        SET_VAR_TEXT(req, 12, gc_state);
        SET_VAR_DOUBLE(req, 13, gc_rating_difficulty);
        SET_VAR_DOUBLE(req, 14, gc_rating_terrain);
        SET_VAR_INT(req, 15, gc_favourites);
        SET_VAR_BOOL(req, 16, gc_long_desc_html);
        SET_VAR_TEXT(req, 17, gc_long_desc);
        SET_VAR_BOOL(req, 18, gc_short_desc_html);
        SET_VAR_TEXT(req, 19, gc_short_desc);
        SET_VAR_TEXT(req, 20, gc_hint);
        SET_VAR_INT(req, 21, gc_containerSize_int);
        SET_VAR_BOOL(req, 22, gc_archived);
        SET_VAR_BOOL(req, 23, gc_available);
        SET_VAR_INT(req, 24, cache_symbol_int);
        SET_VAR_INT(req, 25, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        
        sqlite3_finalize(req);
    }
}

@end
