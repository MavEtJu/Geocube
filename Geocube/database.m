//
//  database.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation database

- (id)init
{
    NSString *dbname = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DocumentRoot], DB_NAME];
    NSLog(@"Using %@ as the database.", dbname);
    NSString *dbempty = [[NSString alloc] initWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], DB_EMPTY];
    
    [self checkAndCreateDatabase:dbname empty:dbempty];
    
    sqlite3_open([dbempty UTF8String], &db);
    dbConfig *c_empty = [self config_get:@"version"];
    sqlite3_close(db);
    
    sqlite3_open([dbname UTF8String], &db);
    dbConfig *c_real = [self config_get:@"version"];
    sqlite3_close(db);
    
    NSLog(@"Database version %@, distribution is %@.", c_real.value, c_empty.value);
    if ([c_real.value compare:c_empty.value] != NSOrderedSame) {
        NSLog(@"Empty is newer, overwriting old one");
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"option_cleardatabase"];
        [self checkAndCreateDatabase:dbname empty:dbempty];
    }

    sqlite3_open([dbname UTF8String], &db);
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

- (dbConfig *)config_get:(NSString *)key
{
    NSString *sql = @"select id, key, value from config where key = ?";
    sqlite3_stmt *req;
    
    dbConfig *c;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"config_get:prepare: %s", sqlite3_errmsg(db));
        SET_VAR_TEXT(req, 1, key);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, key);
            TEXT_FETCH_AND_ASSIGN(req, 2, value);
            c = [[dbConfig alloc] init:_id key:key value:value];
        }
        sqlite3_finalize(req);
    }
    return c;
}

- (void)config_update:(NSString *)key value:(NSString *)value
{
    NSString *sql = @"update config set value = ? where key = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"config_update:prepare: %s", sqlite3_errmsg(db));

        SET_VAR_TEXT(req, 1, value);
        SET_VAR_TEXT(req, 2, key);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"onfig_update:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

// ------------------------

- (dbWaypointGroup *)WaypointGroups_get_byName:(NSString *)name
{
    NSString *sql = @"select id, name, usergroup from waypoint_groups where name = ?";
    sqlite3_stmt *req;
    dbWaypointGroup *wpg;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_get_byNamee:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, name);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbWaypointGroup alloc] init:_id name:name usergroup:ug];
        }
        sqlite3_finalize(req);
    }
    return wpg;
}

- (NSMutableArray *)WaypointGroups_all
{
    NSString *sql = @"select id, name, usergroup from waypoint_groups";
    sqlite3_stmt *req;
    NSMutableArray *wpgs = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypointGroup *wpg;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, name);
            INT_FETCH_AND_ASSIGN(req, 2, ug);
            wpg = [[dbWaypointGroup alloc] init:_id name:name usergroup:ug];
            [wpgs addObject:wpg];
        }
        sqlite3_finalize(req);
    }
    return wpgs;
}

- (NSInteger)WaypointGroups_count_waypoints:(NSInteger)wpgid
{
    NSString *sql = @"select count(id) from waypoint_groups2waypoints where waypoint_group_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_count_waypoints:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, wpgid);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}

- (void)WaypointGroups_new:(NSString *)name isUser:(BOOL)isUser
{
    NSString *sql = @"insert into waypoint_groups(name, usergroup) values(?, ?)";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_new:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, name);
        SET_VAR_BOOL(req, 2, isUser);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_new:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_delete:(NSInteger)_id
{
    NSString *sql = @"delete from waypoint_groups where id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_delete:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_delete:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_empty:(NSInteger)_id
{
    NSString *sql = @"delete from waypoint_groups2waypoints where waypoint_group_id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_empty:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_empty:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_rename:(NSInteger)_id newName:(NSString *)newname
{
    NSString *sql = @"update waypoint_groups set name = ? where id = ?";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_rename:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, newname);
        SET_VAR_INT(req, 2, _id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WaypointGroups_rename:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (void)WaypointGroups_add_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid
{
    NSString *sql = @"insert into waypoint_groups2waypoints(waypoint_group_id, waypoint_id) values(?, ?)";
    sqlite3_stmt *req;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_add_waypoint:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, wpgid);
        SET_VAR_INT(req, 2, wpid);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"WWaypointGroups_add_waypoint:step: %s", sqlite3_errmsg(db));
        sqlite3_finalize(req);
    }
}

- (BOOL)WaypointGroups_contains_waypoint:(NSInteger)wpgid waypoint_id:(NSInteger)wpid
{
    NSString *sql = @"select count(id) from waypoint_groups2waypoints where waypoint_group_id = ? and waypoint_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointGroups_count_waypoints:prepare: %s", sqlite3_errmsg(db));
        
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

- (dbWaypointType *)WaypointTypes_get_byType:(NSString *)type
{
    NSString *sql = @"select id, type, icon from waypoint_types where type = ?";
    sqlite3_stmt *req;
    dbWaypointType *wpt;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointTypes_get_byType:prepare %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, type);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, type);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            wpt = [[dbWaypointType alloc] init:_id type:type icon:icon];
        }
        sqlite3_finalize(req);
    }
    return wpt;
}

- (NSMutableArray *)WaypointTypes_all
{
    NSString *sql = @"select id, type, icon from waypoint_types";
    sqlite3_stmt *req;
    NSMutableArray *wpts = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypointType *wpt;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"WaypointTypes_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, type);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            wpt = [[dbWaypointType alloc] init:_id type:type icon:icon];
            [wpts addObject:wpt];
        }
        sqlite3_finalize(req);
    }
    return wpts;
}

// ------------------------

- (NSMutableArray *)Waypoints_all
{
    NSString *sql = @"select id, name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, wp_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint from waypoints";
    sqlite3_stmt *req;
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Waypoints_all:prepare: %s", sqlite3_errmsg(db));
        
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
            INT_FETCH_AND_ASSIGN(req, 10, wp_type);
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
            
            wp = [[dbWaypoint alloc] init:_id];
            [wp setName:name];
            [wp setDescription:desc];
            [wp setLat:lat];
            [wp setLon:lon];
            
            [wp setLat_int:lat_int];
            [wp setLon_int:lon_int];
            [wp setDate_placed:date_placed];
            [wp setDate_placed_epoch:date_placed_epoch];
            [wp setUrl:url];
            [wp setWp_type_int:wp_type];
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
            [wp finish];
            [wps addObject:wp];
        }
        sqlite3_finalize(req);
    }
    return wps;
}

- (NSInteger)Waypoint_get_byname:(NSString *)name
{
    NSString *sql = @"select id from waypoints where name = ?";
    sqlite3_stmt *req;
    NSInteger _id = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Waypoint_get_byname:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, name);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            _id = __id;
        }
        sqlite3_finalize(req);
    }
    return _id;
}

- (NSInteger)Waypoint_add:(dbWaypoint *)wp
{
    NSString *sql = @"insert into waypoints(name, description, lat, lon, lat_int, lon_int, date_placed, date_placed_epoch, url, wp_type, gc_country, gc_state, gc_rating_difficulty, gc_rating_terrain, gc_favourites, gc_long_desc_html, gc_long_desc, gc_short_desc_html, gc_short_desc, gc_hint) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger _id = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Waypoint_add:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, wp.name);
        SET_VAR_TEXT(req, 2, wp.description);
        SET_VAR_TEXT(req, 3, wp.lat);
        SET_VAR_TEXT(req, 4, wp.lon);
        SET_VAR_INT(req, 5, wp.lat_int);
        SET_VAR_INT(req, 6, wp.lon_int);
        SET_VAR_TEXT(req, 7, wp.date_placed);
        SET_VAR_INT(req, 8, wp.date_placed_epoch);
        SET_VAR_TEXT(req, 9, wp.url);
        SET_VAR_INT(req, 10, wp.wp_type_int);
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

        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"Waypoint_add:step: %s", sqlite3_errmsg(db));

        _id = sqlite3_last_insert_rowid(db);
        sqlite3_finalize(req);
    }
    return _id;
}

- (void)Waypoint_update:(dbWaypoint *)wp
{
    NSString *sql = @"update waypoints set name = ?, description = ?, lat = ?, lon = ?, lat_int = ?, lon_int  = ?, date_placed = ?, date_placed_epoch = ?, url = ?, wp_type = ?, gc_country = ?, gc_state = ?, gc_rating_difficulty = ?, gc_rating_terrain = ?, gc_favourites = ?, gc_long_desc_html = ?, gc_long_desc = ?, gc_short_desc_html = ?, gc_short_desc = ?, gc_hint = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Waypoint_update:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_TEXT(req, 1, wp.name);
        SET_VAR_TEXT(req, 2, wp.description);
        SET_VAR_TEXT(req, 3, wp.lat);
        SET_VAR_TEXT(req, 4, wp.lon);
        SET_VAR_INT(req, 5, wp.lat_int);
        SET_VAR_INT(req, 6, wp.lon_int);
        SET_VAR_TEXT(req, 7, wp.date_placed);
        SET_VAR_INT(req, 8, wp.date_placed_epoch);
        SET_VAR_TEXT(req, 9, wp.url);
        SET_VAR_INT(req, 10, wp.wp_type_int);
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
        SET_VAR_INT(req, 21, wp._id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"Waypoint_update:step: %s", sqlite3_errmsg(db));
        
        sqlite3_finalize(req);
    }
}

// ------------------------

- (NSMutableArray *)LogTypes_all
{
    NSString *sql = @"select id, logtype, icon from log_types";
    sqlite3_stmt *req;
    NSMutableArray *lts = [[NSMutableArray alloc] initWithCapacity:20];
    dbLogType *lt;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"LogTypes_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, logtype);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            lt = [[dbLogType alloc] init:_id logtype:logtype icon:icon];
            [lts addObject:lt];
        }
        sqlite3_finalize(req);
    }
    return lts;
}

// ------------------------

- (NSMutableArray *)ContainerTypes_all
{
    NSString *sql = @"select id, size, icon from container_types";
    sqlite3_stmt *req;
    NSMutableArray *cts = [[NSMutableArray alloc] initWithCapacity:20];
    dbContainerType *ct;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"ContainerTypes_all:prepare: %s", sqlite3_errmsg(db));
        
        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, size);
            INT_FETCH_AND_ASSIGN(req, 2, icon);
            ct = [[dbContainerType alloc] init:_id size:size icon:icon];
            [cts addObject:ct];
        }
        sqlite3_finalize(req);
    }
    return cts;
}

// ------------------------

- (NSInteger)Log_by_gcid:(NSInteger)gc_id
{
    NSString *sql = @"select id from logs where gc_id = ?";
    sqlite3_stmt *req;
    NSInteger _id = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Log_by_gcid:prepare %s", sqlite3_errmsg(db));
        
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
    NSString *sql = @"insert into logs(waypoint_id, log_type_id, datetime, datetime_epoch, logger, log, gc_id) values(?, ?, ?, ?, ?, ?, ?)";
    sqlite3_stmt *req;
    NSInteger _id = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Logs_add:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, log.waypoint_id);
        SET_VAR_INT(req, 2, log.logtype_id);
        SET_VAR_TEXT(req, 3, log.datetime);
        SET_VAR_INT(req, 4, log.datetime_epoch);
        SET_VAR_TEXT(req, 5, log.logger);
        SET_VAR_TEXT(req, 6, log.log);
        SET_VAR_INT(req, 7, log.gc_id);

        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"Logs_add:step: %s", sqlite3_errmsg(db));

        _id = sqlite3_last_insert_rowid(db);
        sqlite3_finalize(req);
    }
    return _id;
}

- (void)Logs_update:(NSInteger)_id log:(dbLog *)log
{
    NSString *sql = @"update logs set log_type_id = ?, waypoint_id = ?, datetime = ?, datetime_epoch = ?, logger = ?, log = ?, gc_id = ? where id = ?";
    sqlite3_stmt *req;

    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Logs_update:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, log.logtype_id);
        SET_VAR_INT(req, 2, log.waypoint_id);
        SET_VAR_TEXT(req, 3, log.datetime);
        SET_VAR_INT(req, 4, log.datetime_epoch);
        SET_VAR_TEXT(req, 5, log.logger);
        SET_VAR_TEXT(req, 6, log.log);
        SET_VAR_INT(req, 7, log.gc_id);
        SET_VAR_INT(req, 8, log._id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"Logs_update:step: %s", sqlite3_errmsg(db));
        
        sqlite3_finalize(req);
    }
}

- (void)Logs_update_waypoint_id:(dbLog *)log waypoint_id:(NSInteger)wp_id;
{
    NSString *sql = @"update logs set waypoint_id = ? where id = ?";
    sqlite3_stmt *req;
 
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"LogsWaypoint_update_waypoint_id:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, wp_id);
        SET_VAR_INT(req, 2, log._id);
        
        if (sqlite3_step(req) != SQLITE_DONE)
            NSAssert1(0, @"LogsWaypoint_update_waypoint_id:step: %s", sqlite3_errmsg(db));
        
        sqlite3_finalize(req);
    }
}

- (NSInteger)Logs_count_byWaypoint_id:(NSInteger)wp_id
{
    NSString *sql = @"select count(id) from logs where waypoint_id = ?";
    sqlite3_stmt *req;
    NSInteger count = 0;
    
    @synchronized(dbaccess) {
        if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            NSAssert1(0, @"Logs_count_byWaypoint_id:prepare: %s", sqlite3_errmsg(db));
        
        SET_VAR_INT(req, 1, wp_id);
        
        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, c);
            count = c;
        }
        sqlite3_finalize(req);
    }
    return count;
}


// ------------------------

// ------------------------

// ------------------------

// ------------------------

// ------------------------

// ------------------------



@end
