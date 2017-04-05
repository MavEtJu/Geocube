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

@interface dbWaypoint ()

@end

@implementation dbWaypoint

- (instancetype)init
{
    self = [self init:0];
    return self;
}

- (instancetype)init:(NSId)__id
{
    self = [super init];
    self._id = __id;
    self.related_id = 0;

    self.wpt_name = nil;
    self.wpt_description = nil;
    self.wpt_url = nil;
    self.wpt_urlname = nil;
    self.wpt_lat = nil;
    self.wpt_lat_int = 0;
    self.wpt_lat_float = 0;
    self.wpt_lon = nil;
    self.wpt_lon_int = 0;
    self.wpt_lon_float = 0;
    self.wpt_date_placed = nil;
    self.wpt_date_placed_epoch = 0;
    self.wpt_type_str = nil;
    self.wpt_type_id = 0;
    self.wpt_type = nil;
    self.wpt_symbol_str = nil;
    self.wpt_symbol_id = 0;
    self.wpt_symbol = nil;

    self.gs_archived = NO;
    self.gs_available = YES;
    self.gs_country = nil;
    self.gs_state = nil;
    self.gs_short_desc = nil;
    self.gs_short_desc_html = NO;
    self.gs_long_desc = nil;
    self.gs_long_desc_html = NO;
    self.gs_hint = nil;
    self.gs_container = nil;
    self.gs_favourites = 0;
    self.gs_rating_difficulty = 0;
    self.gs_rating_terrain = 0;
    self.gs_placed_by = nil;
    self.gs_owner_gsid = nil;
    self.gs_owner_str = nil;
    self.gs_owner_id = 0;
    self.gs_owner = nil;
    self.gs_date_found = 0;

    self.gca_locale = nil;
    self.gca_locale_id = 0;
    self.gca_locale_str = nil;

    self.coordinates = CLLocationCoordinate2DMake(0, 0);
    self.coordinatesUncorrected = CLLocationCoordinate2DMake(0, 0);
    self.calculatedDistance = 0;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.account_id = 0;
    self.account = nil;
    self.flag_highlight = NO;
    self.flag_ignore = NO;
    self.flag_inprogress = NO;
    self.flag_markedfound = NO;
    self.flag_dnf = NO;
    self.date_lastlog_epoch = 0;
    self.date_lastimport_epoch = 0;
    self.logstring_logtype = LOGSTRING_LOGTYPE_UNKNOWN;

    return self;
}

- (void)finish
{
    // Conversions from the data retrieved
    self.wpt_lat_float = [self.wpt_lat floatValue];
    self.wpt_lon_float = [self.wpt_lon floatValue];
    self.wpt_lat_int = self.wpt_lat_float * 1000000;
    self.wpt_lon_int = self.wpt_lon_float * 1000000;

    self.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromISO8601:self.wpt_date_placed];

    self.coordinates = CLLocationCoordinate2DMake([self.wpt_lat floatValue], [self.wpt_lon floatValue]);

    // Adjust cache types
    if (self.wpt_type == nil) {
        if (self.wpt_type_str != nil) {
            NSArray *as = [self.wpt_type_str componentsSeparatedByString:@"|"];
            if ([as count] == 2) {
                // Geocache|Traditional Cache
                self.wpt_type = [dbc Type_get_byname:[as objectAtIndex:0] minor:[as objectAtIndex:1]];
            } else {
                // Traditional Cache
                [[dbc Types] enumerateObjectsUsingBlock:^(dbType *t, NSUInteger idx, BOOL *stop) {
                    if ([t.type_minor isEqualToString:self.wpt_type_str] == YES) {
                        self.wpt_type = t;
                        *stop = YES;
                    }
                }];
                if (self.wpt_type == nil)
                    self.wpt_type = [dbc Type_get_byname:@"Geocache" minor:@"*"];
            }
            self.wpt_type_id = self.wpt_type._id;
        }
        if (self.wpt_type_id != 0) {
            self.wpt_type = [dbc Type_get:self.wpt_type_id];
            self.wpt_type_str = self.wpt_type.type_full;
        }
    }

    // Adjust cache symbol
    if (self.wpt_symbol == nil) {
        if (self.wpt_symbol_str != nil) {
            self.wpt_symbol = [dbc Symbol_get_bysymbol:self.wpt_symbol_str];
            self.wpt_symbol_id = self.wpt_symbol._id;
        }
        if (self.wpt_symbol_id != 0) {
            self.wpt_symbol = [dbc Symbol_get:self.wpt_symbol_id];
            self.wpt_symbol_str = self.wpt_symbol.symbol;
        }
    }

    if (self.account_id != 0)
        self.account = [dbc Account_get:self.account_id];
    if (self.account != nil)
        self.account_id = self.account._id;

    // Adjust container size
    if (self.gs_container == nil) {
        if (self.gs_container_str != nil) {
            self.gs_container = [dbc Container_get_bysize:self.gs_container_str];
            self.gs_container_id = self.gs_container._id;
        }
        if (self.gs_container_id != 0) {
            self.gs_container = [dbc Container_get:self.gs_container_id];
            self.gs_container_str = self.gs_container.size;
        }
    }

    if (self.gs_owner == nil) {
        if (self.gs_owner_str != nil) {
            if (self.gs_owner_gsid == nil)
                self.gs_owner = [dbName dbGetByName:self.gs_owner_str account:self.account];
            else
                self.gs_owner = [dbName dbGetByNameCode:self.gs_owner_str code:self.gs_owner_gsid account:self.account];
            self.gs_owner_id = self.gs_owner._id;
        }
        if (self.gs_owner_id != 0) {
            self.gs_owner = [dbc Name_get:self.gs_owner_id];
            self.gs_owner_str = self.gs_owner.name;
        }
    }

    if (self.gs_state == nil) {
        if (self.gs_state_str != nil) {
            self.gs_state = [dbc State_get_byNameCode:self.gs_state_str];
            self.gs_state_id = self.gs_state._id;
        }
        if (self.gs_state_id != 0) {
            self.gs_state = [dbc State_get:self.gs_state_id];
            self.gs_state_str = self.gs_state.name;
        }
    }

    if (self.gs_country == nil) {
        if (self.gs_country_str != nil) {
            self.gs_country = [dbc Country_get_byNameCode:self.gs_country_str];
            self.gs_country_id = self.gs_country._id;
        }
        if (self.gs_country_id != 0) {
            self.gs_country = [dbc Country_get:self.gs_country_id];
            self.gs_country_str = self.gs_country.name;
        }
    }

    if (self.gca_locale == nil) {
        if (self.gca_locale_str != nil) {
            self.gca_locale = [dbc Locale_get_byName:self.gca_locale_str];
            self.gca_locale_id = self.gca_locale._id;
        }
        if (self.gca_locale_id != 0) {
            self.gca_locale = [dbc Locale_get:self.gca_locale_id];
            self.gca_locale_str = self.gca_locale.name;
        }
    }

    self.logstring_logtype = [dbLogString wptTypeToLogType:self.wpt_type.type_full];

    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.wpt_name, [Coordinates NiceCoordinates:CLLocationCoordinate2DMake(self.wpt_lat_float, self.wpt_lon_float)], self.wpt_urlname];
}

- (NSInteger)hasLogs
{
    return [dbLog dbCountByWaypoint:self._id];
}

- (NSInteger)hasAttributes
{
    return [dbAttribute dbCountByWaypoint:self._id];
}

- (NSInteger)hasFieldNotes
{
    return [[dbLog dbAllByWaypointLogged:self._id] count];
}

- (NSInteger)hasImages
{
    return [dbImage dbCountByWaypoint:self._id];
}

- (NSInteger)hasPersonalNotes
{
    return [dbTrackable dbCountByWaypoint:self._id];
}

- (NSInteger)hasInventory
{
    return [dbTrackable dbCountByWaypoint:self._id];
}

- (NSArray<dbWaypoint *> *)hasWaypoints
{
    NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:20];
    NSString *currentSuffix, *currentPrefix, *otherPrefix;
    NSArray<NSString *> *GCCodes = @[
                         @"GA", // Geocaching Australia
                         @"MY", // Geocube internal
                         @"TP", // Geocaching Australia Trigpoint
                         @"GC", // Groundspeak Geocaching.com
                         @"VI", // Geocaching.su virtual
                         @"TR", // Geocaching.su traditional
                         @"MS", // Geocaching.su multistep
                         @"TC", // Terracaching
                         @"OB", // OpenCaching NL
                         @"OP", // OpenCaching PL
                         @"OK", // OpenCaching UK
                         @"OU", // OpenCaching US
                         @"OR", // OpenCaching RO
                         @"OZ", // OpenCaching CZ
                         @"OC", // OpenCaching DE/FR/IT
                       ];

    @synchronized(db) {
        DB_PREPARE(@"select id, wpt_name from waypoints where wpt_name like ? and (account_id = ? or account_id = 0)")

        currentSuffix = [self.wpt_name substringFromIndex:2];
        currentPrefix = [self.wpt_name substringToIndex:2];
        NSString *sql = [NSString stringWithFormat:@"%%%@", currentSuffix];
        SET_VAR_TEXT(1, sql);
        SET_VAR_INT (2, self.account_id);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN (0, __id);
            TEXT_FETCH_AND_ASSIGN(1, otherName);

            otherPrefix = [otherName substringToIndex:2];

//          NSLog(@"self.wpt_name: %@", self.wpt_name);
//          NSLog(@"currentPrefix: %@", currentPrefix);
//          NSLog(@"otherName: %@", otherName);
//          NSLog(@"otherPrefix: %@", otherPrefix);
//          NSLog(@"[otherName isEqualToString:self.wpt_name]: %d", [otherName isEqualToString:self.wpt_name]);
//          NSLog(@"[GCCodes indexOfObject:otherPrefix]: %ld", (long)[GCCodes indexOfObject:otherPrefix]);
            if ([otherName isEqualToString:self.wpt_name] == YES) {
                // Add itself, always.
                [wps addObject:[dbWaypoint dbGet:__id]];
            } else if ([GCCodes indexOfObject:otherPrefix] == NSNotFound) {
                // otherPrefix isn't in the prefixes of other listing services, then add it.
                [wps addObject:[dbWaypoint dbGet:__id]];
            } else if ([GCCodes indexOfObject:otherPrefix] != NSNotFound &&
                       [GCCodes indexOfObject:currentPrefix] == NSNotFound) {
                // It the other is in another listing service, but the current one isn't, then add it.
                // (This can give false positives, but it's all we got...)
                [wps addObject:[dbWaypoint dbGet:__id]];
            }
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSMutableArray<dbWaypoint *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray *)values
{
    NSMutableArray<dbWaypoint *> *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    NSMutableString *sql = [NSMutableString stringWithFormat:@"select id, wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_lat_int, wpt_lon_int, wpt_date_placed, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, related_id from waypoints wp %@", where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            wp = [[dbWaypoint alloc] init:_id];

            TEXT_FETCH  ( 1, wp.wpt_name);
            TEXT_FETCH  ( 2, wp.wpt_description);
            TEXT_FETCH  ( 3, wp.wpt_lat);
            TEXT_FETCH  ( 4, wp.wpt_lon);
            INT_FETCH   ( 5, wp.wpt_lat_int);
            INT_FETCH   ( 6, wp.wpt_lon_int);
            TEXT_FETCH  ( 7, wp.wpt_date_placed);
            INT_FETCH   ( 8, wp.wpt_date_placed_epoch);
            TEXT_FETCH  ( 9, wp.wpt_url);
            INT_FETCH   (10, wp.wpt_type_id);
            INT_FETCH   (11, wp.wpt_symbol_id);
            TEXT_FETCH  (12, wp.wpt_urlname);

            INT_FETCH   (13, wp.logStatus);
            BOOL_FETCH  (14, wp.flag_highlight);
            INT_FETCH   (15, wp.account_id);
            BOOL_FETCH  (16, wp.flag_ignore);

            INT_FETCH   (17, wp.gs_country_id);
            INT_FETCH   (18, wp.gs_state_id);
            DOUBLE_FETCH(19, wp.gs_rating_difficulty);
            DOUBLE_FETCH(20, wp.gs_rating_terrain);
            INT_FETCH   (21, wp.gs_favourites);
            BOOL_FETCH  (22, wp.gs_long_desc_html);
            TEXT_FETCH  (23, wp.gs_long_desc);
            BOOL_FETCH  (24, wp.gs_short_desc_html);
            TEXT_FETCH  (25, wp.gs_short_desc);
            TEXT_FETCH  (26, wp.gs_hint);
            INT_FETCH   (27, wp.gs_container_id);
            BOOL_FETCH  (28, wp.gs_archived);
            BOOL_FETCH  (29, wp.gs_available);
            INT_FETCH   (30, wp.gs_owner_id);
            TEXT_FETCH  (31, wp.gs_placed_by);

            BOOL_FETCH  (32, wp.flag_markedfound);
            BOOL_FETCH  (33, wp.flag_inprogress);
            INT_FETCH   (34, wp.gs_date_found);
            BOOL_FETCH  (35, wp.flag_dnf);
            INT_FETCH   (36, wp.date_lastlog_epoch);
            INT_FETCH   (37, wp.gca_locale_id);
            INT_FETCH   (38, wp.date_lastimport_epoch);
            INT_FETCH   (39, wp.related_id);

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}
+ (NSMutableArray<dbWaypoint *> *)dbAllXXX:(NSString *)where
{
    return [dbWaypoint dbAllXXX:where keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAll
{
    NSArray *wps = [dbWaypoint dbAllXXX:@""];
    return wps;
}

+ (NSInteger)dbCount
{
    return [dbWaypoint dbCount:@"waypoints"];
}

+ (NSArray<dbWaypoint *> *)dbAllNotFound
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where wp.gs_date_found = 0 and (wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select name_id from accounts))) and not (wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts)))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllFound
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllIgnored
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where ignore = 1"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllInRect:(CLLocationCoordinate2D)lt RT:(CLLocationCoordinate2D)rt
{
    // -34040000 < wpt_lat_int and wpt_lat_int < 34050000 and 151093000 < wpt_lon_int and wpt_lon_int < 1510950000;
    return [dbWaypoint dbAllXXX:@"where ? < wpt_lat_int and wpt_lat_int < ? and ? < wpt_lon_int and wpt_lon_int < ?"
                           keys:@"ffff"
                         values:@[[NSNumber numberWithFloat:1000000 * lt.latitude],
                                  [NSNumber numberWithFloat:1000000 * rt.latitude],
                                  [NSNumber numberWithFloat:1000000 * lt.longitude],
                                  [NSNumber numberWithFloat:1000000 * rt.longitude]]];
}

+ (NSArray<dbWaypoint *> *)dbAllInGroups:(NSArray *)groups
{
    NSMutableString *keys = [NSMutableString stringWithString:@""];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[groups count]];
    NSMutableString *where = [NSMutableString stringWithString:@""];
    [groups enumerateObjectsUsingBlock:^(dbGroup *group, NSUInteger idx, BOOL *stop) {
        if ([where isEqualToString:@""] == NO)
            [where appendString:@" or "];
        [where appendString:@"group_id = ?"];
        [keys appendString:@"i"];
        [values addObject:[NSNumber numberWithLongLong:group._id]];
    }];
    // Stop selecting this criteria without actually selecting a group!
    if ([where isEqualToString:@""] == YES)
        return nil;

    return [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"where wp.id in (select waypoint_id from group2waypoints where %@)", where]
                           keys:keys
                         values:values];
}

+ (NSId)dbGetByName:(NSString *)name
{
    NSId _id = 0;

    @synchronized(db) {
        DB_PREPARE(@"select id from waypoints where wpt_name = ?");

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
    NSArray *wps = [dbWaypoint dbAllXXX:@"where wp.id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:_id]]];
    if ([wps count] == 0)
        return nil;
    return [wps objectAtIndex:0];
}

+ (void)dbCreate:(dbWaypoint *)wp
{
    NSId _id = 0;
    @synchronized(db) {
        DB_PREPARE(@"insert into waypoints(wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_lat_int, wpt_lon_int, wpt_date_placed, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, related_id) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT  ( 1, wp.wpt_name);
        SET_VAR_TEXT  ( 2, wp.wpt_description);
        SET_VAR_TEXT  ( 3, wp.wpt_lat);
        SET_VAR_TEXT  ( 4, wp.wpt_lon);
        SET_VAR_INT   ( 5, wp.wpt_lat_int);
        SET_VAR_INT   ( 6, wp.wpt_lon_int);
        SET_VAR_TEXT  ( 7, wp.wpt_date_placed);
        SET_VAR_INT   ( 8, wp.wpt_date_placed_epoch);
        SET_VAR_TEXT  ( 9, wp.wpt_url);
        SET_VAR_INT   (10, wp.wpt_type_id);
        SET_VAR_INT   (11, wp.wpt_symbol_id);
        SET_VAR_TEXT  (12, wp.wpt_urlname);

        SET_VAR_INT   (13, wp.logStatus);
        SET_VAR_BOOL  (14, wp.flag_highlight);
        SET_VAR_INT   (15, wp.account_id);
        SET_VAR_BOOL  (16, wp.flag_ignore);

        SET_VAR_INT   (17, wp.gs_country_id);
        SET_VAR_INT   (18, wp.gs_state_id);
        SET_VAR_DOUBLE(19, wp.gs_rating_difficulty);
        SET_VAR_DOUBLE(20, wp.gs_rating_terrain);
        SET_VAR_INT   (21, wp.gs_favourites);
        SET_VAR_BOOL  (22, wp.gs_long_desc_html);
        SET_VAR_TEXT  (23, wp.gs_long_desc);
        SET_VAR_BOOL  (24, wp.gs_short_desc_html);
        SET_VAR_TEXT  (25, wp.gs_short_desc);
        SET_VAR_TEXT  (26, wp.gs_hint);
        SET_VAR_INT   (27, wp.gs_container_id);
        SET_VAR_BOOL  (28, wp.gs_archived);
        SET_VAR_BOOL  (29, wp.gs_available);
        SET_VAR_INT   (30, wp.gs_owner_id);
        SET_VAR_TEXT  (31, wp.gs_placed_by);

        SET_VAR_BOOL  (32, wp.flag_markedfound);
        SET_VAR_BOOL  (33, wp.flag_inprogress);
        SET_VAR_INT   (34, wp.gs_date_found);
        SET_VAR_BOOL  (35, wp.flag_dnf);
        SET_VAR_INT   (36, wp.date_lastlog_epoch);
        SET_VAR_INT   (37, wp.gca_locale_id);
        SET_VAR_INT   (38, wp.date_lastimport_epoch);
        SET_VAR_INT   (39, wp.related_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    wp._id = _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set wpt_name = ?, wpt_description = ?, wpt_lat = ?, wpt_lon = ?, wpt_lat_int = ?, wpt_lon_int = ?, wpt_date_placed = ?, wpt_date_placed_epoch = ?, wpt_url = ?, wpt_type_id = ?, wpt_symbol_id = ?, wpt_urlname = ?, log_status = ?, highlight = ?, account_id = ?, ignore = ?, gs_country_id = ?, gs_state_id = ?, gs_rating_difficulty = ?, gs_rating_terrain = ?, gs_favourites = ?, gs_long_desc_html = ?, gs_long_desc = ?, gs_short_desc_html = ?, gs_short_desc = ?, gs_hint = ?, gs_container_id = ?, gs_archived = ?, gs_available = ?, gs_owner_id = ?, gs_placed_by = ?, markedfound = ?, inprogress = ?, gs_date_found = ?, dnfed = ?, date_lastlog_epoch = ?, gca_locale_id = ?, date_lastimport_epoch = ?, related_id = ? where id = ?");

        SET_VAR_TEXT  ( 1, self.wpt_name);
        SET_VAR_TEXT  ( 2, self.wpt_description);
        SET_VAR_TEXT  ( 3, self.wpt_lat);
        SET_VAR_TEXT  ( 4, self.wpt_lon);
        SET_VAR_INT   ( 5, self.wpt_lat_int);
        SET_VAR_INT   ( 6, self.wpt_lon_int);
        SET_VAR_TEXT  ( 7, self.wpt_date_placed);
        SET_VAR_INT   ( 8, self.wpt_date_placed_epoch);
        SET_VAR_TEXT  ( 9, self.wpt_url);
        SET_VAR_INT   (10, self.wpt_type_id);
        SET_VAR_INT   (11, self.wpt_symbol_id);
        SET_VAR_TEXT  (12, self.wpt_urlname);

        SET_VAR_INT   (13, self.logStatus);
        SET_VAR_BOOL  (14, self.flag_highlight);
        SET_VAR_INT   (15, self.account_id);
        SET_VAR_BOOL  (16, self.flag_ignore);

        SET_VAR_INT   (17, self.gs_country_id);
        SET_VAR_INT   (18, self.gs_state_id);
        SET_VAR_DOUBLE(19, self.gs_rating_difficulty);
        SET_VAR_DOUBLE(20, self.gs_rating_terrain);
        SET_VAR_INT   (21, self.gs_favourites);
        SET_VAR_BOOL  (22, self.gs_long_desc_html);
        SET_VAR_TEXT  (23, self.gs_long_desc);
        SET_VAR_BOOL  (24, self.gs_short_desc_html);
        SET_VAR_TEXT  (25, self.gs_short_desc);
        SET_VAR_TEXT  (26, self.gs_hint);
        SET_VAR_INT   (27, self.gs_container_id);
        SET_VAR_BOOL  (28, self.gs_archived);
        SET_VAR_BOOL  (29, self.gs_available);
        SET_VAR_INT   (30, self.gs_owner_id);
        SET_VAR_TEXT  (31, self.gs_placed_by);

        SET_VAR_BOOL  (32, self.flag_markedfound);
        SET_VAR_BOOL  (33, self.flag_inprogress);
        SET_VAR_INT   (34, self.gs_date_found);
        SET_VAR_BOOL  (35, self.flag_dnf);
        SET_VAR_INT   (36, self.date_lastlog_epoch);
        SET_VAR_INT   (37, self.gca_locale_id);
        SET_VAR_INT   (38, self.date_lastimport_epoch);
        SET_VAR_INT   (39, self.related_id);

        SET_VAR_INT   (40, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbUpdateLogStatus
{
    MyClock *clock = [[MyClock alloc] initClock:@"dbUpdateLogStatus"];
    [clock clockEnable:YES];
    [clock clockShowAndReset:@"start"];

    // Make all not logged
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ?");
        SET_VAR_INT(1, LOGSTATUS_NOTLOGGED);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"1"];

    // Find all the logs about non-found caches and mark these caches as not found.
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ? where gs_date_found = 0 and (id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select name_id from accounts))) and not (gs_date_found != 0 or id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts)))");
        SET_VAR_INT(1, LOGSTATUS_NOTFOUND);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"2"];

    // Find all the logs about found caches and mark these caches as found.
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ? where gs_date_found != 0 or id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts))");
        SET_VAR_INT(1, LOGSTATUS_FOUND);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"3"];

//    // Find all the waypoints and their waypoints
//    @synchronized(db) {
//        NSArray *waypoints = [dbWaypoint dbAllFound];
//        NSLog(@"Checking %ld waypoints", [waypoints count]);
//        [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *waypoint, NSUInteger idx, BOOL *stop) {
//            NSArray *wps = [waypoint hasWaypoints];
//            if ([wps count] <= 1)
//                return;
//            NSMutableString *ids = [NSMutableString string];
//            [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
//                if (wp.logStatus == LOGSTATUS_FOUND)
//                    return;
//                if ([ids isEqualToString:@""] == NO)
//                    [ids appendFormat:@" or id = %ld", (long)wp._id];
//                else
//                    [ids appendFormat:@"id = %ld", (long)wp._id];
//            }];
//            NSString *sql = [NSString stringWithFormat:@"update waypoints set log_status = ? where %@", ids];
//            DB_PREPARE(sql);
//            SET_VAR_INT(1, LOGSTATUS_FOUND);
//            DB_CHECK_OKAY;
//            DB_FINISH;
//        }];
//    }
//    [clock clockShowAndReset:@"4"];

    // Set the time of the last log in the waypoint
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set date_lastlog_epoch = (select max(l.datetime_epoch) from logs l where l.waypoint_id = waypoints.id);");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"5"];
}

- (void)dbUpdateLogStatus
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ? where id = ?");
        SET_VAR_INT(1, self.logStatus);
        SET_VAR_INT(2, self._id);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateHighlight
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set highlight = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_highlight);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateIgnore
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set ignore = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_ignore);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateMarkedFound
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set markedfound = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_markedfound);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateMarkedDNF
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set dnfed = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_dnf);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateInProgress
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set inprogress = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_inprogress);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbDelete
{
    @synchronized(db) {
        DB_PREPARE(@"delete from waypoints where id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (NSString *)makeLocaleStateCountry
{
    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (self.gca_locale != nil)
        [s appendFormat:@"%@", self.gca_locale.name];
    if (self.gs_state != nil) {
        if ([s isEqualToString:@""] == NO)
            [s appendFormat:@", "];
        if (configManager.showStateAsAbbrevationIfLocaleExists == YES && self.gca_locale != nil)
            [s appendFormat:@"%@", self.gs_state.code];
        else
            [s appendFormat:@"%@", configManager.showStateAsAbbrevation == YES ? self.gs_state.code : self.gs_state.name];
    }
    if (self.gs_country != nil) {
        if ([s isEqualToString:@""] == NO)
            [s appendFormat:@", "];
        [s appendFormat:@"%@", configManager.showCountryAsAbbrevation == YES ? self.gs_country.code : self.gs_country.name];
    }
    return s;
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

+ (NSArray<dbWaypoint *> *)waypointsWithImages
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from image2waypoint where type = ?)" keys:@"i" values:@[[NSNumber numberWithInteger:IMAGECATEGORY_USER]] ];
    return wps;
}

+ (NSArray<dbWaypoint *> *)waypointsWithLogs
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs)"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)waypointsWithMyLogs
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs where logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllByFlag:(Flag)flag
{
    NSArray *wps = nil;

    switch (flag) {
        case FLAGS_HIGHLIGHTED:
            wps = [dbWaypoint dbAllXXX:@"where highlight = 1"];
            break;
        case FLAGS_IGNORED:
            wps = [dbWaypoint dbAllXXX:@"where ignore = 1"];
            break;
        case FLAGS_INPROGRESS:
            wps = [dbWaypoint dbAllXXX:@"where inprogress = 1"];
            break;
        case FLAGS_MARKEDFOUND:
            wps = [dbWaypoint dbAllXXX:@"where markedfound = 1"];
            break;
        case FLAGS_MARKEDDNF:
            wps = [dbWaypoint dbAllXXX:@"where dnfed = 1"];
            break;
    }
    return wps;
}

- (BOOL)hasGSData
{
    // If the difficulty or terrain is not zero, then pretend the Groundspeak specific data is available
    return (self.gs_owner != nil);
}

@end
