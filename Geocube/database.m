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

@implementation database

- (id)init
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];

    [self checkAndCreateDatabase:dbname empty:dbempty];
    dbO.dbaccess = self;

    sqlite3_open([dbempty UTF8String], &db);
    dbO.db = db;
    dbConfig *c_empty = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    sqlite3_open([dbname UTF8String], &db);
    dbO.db = db;
    dbConfig *c_real = [dbConfig dbGetByKey:@"version"];
    sqlite3_close(db);

    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value compare:c_empty.value] != NSOrderedSame) {
        NSLog(@"Empty is newer, overwriting old one");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase:dbname empty:dbempty];
    }

    sqlite3_open([dbname UTF8String], &db);
    dbO.db = db;

    return self;
}

- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty
{
    BOOL success;
    NSFileManager *fm = [[NSFileManager alloc] init];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"option_cleardatabase"] == TRUE) {
        NSLog(@"Erasing database on user request.");
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"option_cleardatabase"];
        [fm removeItemAtPath:dbname error:NULL];
    }

    success = [fm fileExistsAtPath:dbname];
    if (success == NO) {
        [fm copyItemAtPath:dbempty toPath:dbname error:nil];
        NSLog(@"Initializing database from %@ to %@.", dbempty, dbname);
    }
}


- (void)dealloc
{
    sqlite3_close(db);
}

// ------------------------



// ------------------------

- (dbCacheGroup *)CacheGroups_get_byName:(NSString *)name
{
    NSString *sql = @"select id, name, usergroup from cache_groups where name = ?";
    sqlite3_stmt *req;
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbCacheGroup alloc] init:_id name:name usergroup:ug];
        }
        sqlite3_finalize(req);
    }
    return wpg;
}

- (NSMutableArray *)CacheGroups_all
{
    NSString *sql = @"select id, name, usergroup from cache_groups";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbCacheGroup alloc] init:_id name:name usergroup:ug];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSArray *)CacheGroups_all_byCacheId:(NSInteger)wp_id
{
    NSString *sql = @"select cache_group_id from cache_group2caches where cache_id = ?";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheGroup *wpg;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wp_id);

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, wpgid);
            wpg = [dbc CacheGroup_get:wpgid];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSInteger)CacheGroups_count_caches:(NSInteger)wpgid
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

- (void)CacheGroups_new:(NSString *)name isUser:(BOOL)isUser
{
    NSString *sql = @"insert into cache_groups(name, usergroup) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, name);
        SET_VAR_BOOL(req, 2, isUser);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_delete:(NSInteger)_id
{
    NSString *sql = @"delete from cache_groups where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_empty:(NSInteger)_id
{
    NSString *sql = @"delete from cache_group2caches where cache_group_id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_rename:(NSInteger)_id newName:(NSString *)newname
{
    NSString *sql = @"update cache_groups set name = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, newname);
        SET_VAR_INT(req, 2, _id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (void)CacheGroups_add_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid
{
    NSString *sql = @"insert into cache_group2caches(cache_group_id, cache_id) values(?, ?)";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);
        SET_VAR_INT(req, 2, wpid);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        sqlite3_finalize(req);
    }
}

- (BOOL)CacheGroups_contains_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid
{
    NSString *sql = @"select count(id) from cache_group2caches where cache_group_id = ? and cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wpgid);
        SET_VAR_INT(req, 2, wpid);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count == 0 ? NO : YES;
}


// ------------------------

// ------------------------

- (NSMutableArray *)Caches_all
{
    NSString *sql = @"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, cache_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint, gc_container_size_id, gc_archived, gc_available, cache_symbol from caches";
    sqlite3_stmt *req;
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbCache *wp;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            TEXT_FETCH_AND_ASSIGN(req, 2, desc);
            TEXT_FETCH_AND_ASSIGN(req, 3, lat);
            TEXT_FETCH_AND_ASSIGN(req, 4, lon);
            INT_FETCH_AND_ASSIGN(req, 5, lat_int);
            INT_FETCH_AND_ASSIGN(req, 6, lon_int);
            TEXT_FETCH_AND_ASSIGN(req, 7, date_placed);
            INT_FETCH_AND_ASSIGN(req, 8, date_placed_epoch);
            TEXT_FETCH_AND_ASSIGN(req, 9, url);
            INT_FETCH_AND_ASSIGN(req, 10, cache_type);
            TEXT_FETCH_AND_ASSIGN(req, 11, country);
            TEXT_FETCH_AND_ASSIGN(req, 12, state);
            DOUBLE_FETCH_AND_ASSIGN(req, 13, ratingD);
            DOUBLE_FETCH_AND_ASSIGN(req, 14, ratingT);
            INT_FETCH_AND_ASSIGN(req, 15, favourites);
            BOOL_FETCH_AND_ASSIGN(req, 16, gc_long_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 17, gc_long_desc);
            BOOL_FETCH_AND_ASSIGN(req, 18, gc_short_desc_html);
            TEXT_FETCH_AND_ASSIGN(req, 19, gc_short_desc);
            TEXT_FETCH_AND_ASSIGN(req, 20, gc_hint);
            INT_FETCH_AND_ASSIGN(req, 21, gc_container_size);
            BOOL_FETCH_AND_ASSIGN(req, 22, gc_archived);
            BOOL_FETCH_AND_ASSIGN(req, 23, gc_available);
            BOOL_FETCH_AND_ASSIGN(req, 24, cache_symbol);

            wp = [[dbCache alloc] init:_id];
            [wp setName:name];
            [wp setDescription:desc];
            [wp setLat:lat];
            [wp setLon:lon];

            [wp setLat_int:lat_int];
            [wp setLon_int:lon_int];
            [wp setDate_placed:date_placed];
            [wp setDate_placed_epoch:date_placed_epoch];
            [wp setUrl:url];
            [wp setCache_type_int:cache_type];
            [wp setGc_country:country];
            [wp setGc_state:state];
            [wp setGc_rating_difficulty:ratingD];
            [wp setGc_rating_terrain:ratingT];
            [wp setGc_favourites:favourites];
            [wp setGc_long_desc_html:gc_long_desc_html];
            [wp setGc_long_desc:gc_long_desc];
            [wp setGc_short_desc_html:gc_short_desc_html];
            [wp setGc_short_desc:gc_short_desc];
            [wp setGc_hint:gc_hint];
            [wp setGc_containerSize_int:gc_container_size];
            [wp setGc_archived:gc_archived];
            [wp setGc_available:gc_available];
            [wp setCache_symbol_int:cache_symbol];
            [wp finish];
            [wps addObject:wp];
        }
        sqlite3_finalize(req);
    }
    return wps;
}

- (NSInteger)Cache_get_byname:(NSString *)name
{
    NSString *sql = @"select id from caches where name = ?";
    sqlite3_stmt *req;
    NSInteger _id = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

- (NSInteger)Cache_add:(dbCache *)wp
{
    NSString *sql = @"insert into caches(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, cache_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint, gc_container_size_id, gc_archived, gc_available, cache_symbol_int) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger _id = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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

        _id = sqlite3_last_insert_rowid(db);
        sqlite3_finalize(req);
    }
    return _id;
}

- (void)Cache_update:(dbCache *)wp
{
    NSString *sql = @"update caches set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, cache_type = ?, gc_country = ?, gc_state = ?, gc_rating_difficulty = ?, gc_rating_terrain = ?, gc_favourites = ?, gc_long_desc_html = ?, gc_long_desc = ?, gc_short_desc_html = ?, gc_short_desc = ?, gc_hint = ?, gc_container_size_id = ?, gc_archived = ?, gc_available = ?, cache_symbol = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
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
        SET_VAR_INT(req, 25, wp._id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

// ------------------------



// ------------------------

// ------------------------

- (NSInteger)Log_by_gcid:(NSInteger)gc_id
{
    NSString *sql = @"select id from logs where gc_id = ?";
    sqlite3_stmt *req;
    NSInteger _id = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, gc_id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            _id = __id;
        }
        sqlite3_finalize(req);
    }
    return _id;
}

- (NSInteger)Logs_add:(dbLog *)log
{
    NSString *sql = @"insert into logs(cache_id, log_type_id, datetime, datetime_epoch, logger, log, gc_id) values(?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger _id = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, log.cache_id);
        SET_VAR_INT(req, 2, log.logtype_id);
        SET_VAR_TEXT(req, 3, log.datetime);
        SET_VAR_INT(req, 4, log.datetime_epoch);
        SET_VAR_TEXT(req, 5, log.logger);
        SET_VAR_TEXT(req, 6, log.log);
        SET_VAR_INT(req, 7, log.gc_id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        _id = sqlite3_last_insert_rowid(db);
        sqlite3_finalize(req);
    }
    return _id;
}

- (void)Logs_update:(NSInteger)_id log:(dbLog *)log
{
    NSString *sql = @"update logs set log_type_id = ?, cache_id = ?, datetime = ?, datetime_epoch = ?, logger = ?, log = ?, gc_id = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, log.logtype_id);
        SET_VAR_INT(req, 2, log.cache_id);
        SET_VAR_TEXT(req, 3, log.datetime);
        SET_VAR_INT(req, 4, log.datetime_epoch);
        SET_VAR_TEXT(req, 5, log.logger);
        SET_VAR_TEXT(req, 6, log.log);
        SET_VAR_INT(req, 7, log.gc_id);
        SET_VAR_INT(req, 8, log._id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

- (void)Logs_update_cache_id:(dbLog *)log cache_id:(NSInteger)wp_id;
{
    NSString *sql = @"update logs set cache_id = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wp_id);
        SET_VAR_INT(req, 2, log._id);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;

        sqlite3_finalize(req);
    }
}

- (NSInteger)Logs_count_byCache_id:(NSInteger)wp_id
{
    NSString *sql = @"select count(id) from logs where cache_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wp_id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

- (NSArray *)Logs_all_bycacheid:(NSInteger)wp_id
{
    NSString *sql = @"select id, gc_id, cache_id, log_type_id, datetime, datetime_epoch, logger, log from logs where cache_id = ?";
    sqlite3_stmt *req;
    NSMutableArray *ls = [[NSMutableArray alloc] initWithCapacity:20];
    dbLog *l;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_INT(req, 1, wp_id);

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            INT_FETCH_AND_ASSIGN(req, 1, gc_id);
            INT_FETCH_AND_ASSIGN(req, 2, cache_id);
            INT_FETCH_AND_ASSIGN(req, 3, log_type_id);
            TEXT_FETCH_AND_ASSIGN(req, 4, datetime);
            //INT_FETCH_AND_ASSIGN(req, 5, datetime_epoch);
            TEXT_FETCH_AND_ASSIGN(req, 6, logger);
            TEXT_FETCH_AND_ASSIGN(req, 7, log);
            l = [[dbLog alloc] init:__id gc_id:gc_id cache_id:cache_id logtype_id:log_type_id datetime:datetime logger:logger log:log];
            [l finish];
            [ls addObject:l];
        }
        sqlite3_finalize(req);
    }
    return ls;

}

// ------------------------

// ------------------------

// ------------------------

// ------------------------

// ------------------------

// ------------------------



@end
