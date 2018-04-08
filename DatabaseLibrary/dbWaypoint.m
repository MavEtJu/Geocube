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

@interface dbWaypoint ()

@end

@implementation dbWaypoint

TABLENAME(@"waypoints")

- (instancetype)init
{
    self = [super init];

    self.gs_available = YES;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.logstring_wptype = LOGSTRING_WPTYPE_UNKNOWN;

    return self;
}

- (void)finish
{
    self.logstring_wptype = [dbLogString wptTypeToWPType:self.wpt_type.type_full];
    [super finish];
}

- (void)set_gs_country_str:(NSString *)s
{
    self.gs_country = [dbc countryGetByNameCode:s];
}
- (void)set_gs_state_str:(NSString *)s
{
    self.gs_state = [dbc stateGetByNameCode:s];
}
- (void)set_gca_locality_str:(NSString *)s
{
    self.gca_locality = [dbc localityGetByName:s];
}
- (void)set_gs_container_str:(NSString *)s
{
    self.gs_container = [dbc containerGetBySize:s];
}
- (void)set_gs_owner_str:(NSString *)s
{
    ASSERT_SELF_FIELD_EXISTS(account);
    self.gs_owner = [dbName dbGetByName:s account:self.account];
    if (self.gs_owner_gsid == nil)
        self.gs_owner = [dbName dbGetByName:s account:self.account];
    else
        self.gs_owner = [dbName dbGetByNameCode:s code:self.gs_owner_gsid account:self.account];
}
- (void)set_wpt_symbol_str:(NSString *)s
{
    self.wpt_symbol = [dbc symbolGetBySymbol:s];
}
- (void)set_wpt_type_str:(NSString *)s
{
    NSArray<NSString *> *as = [s componentsSeparatedByString:@"|"];
    if ([as count] == 2) {
        // Geocache|Traditional Cache
        self.wpt_type = [dbc typeGetByName:[as objectAtIndex:0] minor:[as objectAtIndex:1]];
    } else {
        // Traditional Cache
        [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([t.type_minor isEqualToString:s] == YES) {
                self.wpt_type = t;
                *stop = YES;
            }
        }];
        if (self.wpt_type == nil)
            self.wpt_type = [dbc typeGetByName:@"Geocache" minor:@"*"];
    }
}
- (void)set_wpt_lat_str:(NSString *)s
{
    self.wpt_latitude = [s floatValue];
}
- (void)set_wpt_lon_str:(NSString *)s
{
    self.wpt_longitude = [s floatValue];
}
- (void)set_wpt_date_placed:(NSString *)s
{
    self.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromISO8601:s];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@ - %@", self.wpt_name, [Coordinates niceCoordinates:self.wpt_latitude longitude:self.wpt_longitude], self.wpt_urlname];
}

- (NSId)dbCreate
{
    ASSERT_FINISHED;
    ASSERT_SELF_FIELD_EXISTS(wpt_type);
    ASSERT_SELF_FIELD_EXISTS(wpt_type);
    ASSERT_SELF_FIELD_EXISTS(wpt_symbol);
    ASSERT_SELF_FIELD_EXISTS(account);
    if (self.gs_state != nil) {             // Groundspeak extensions, not everybody uses them.
        ASSERT_SELF_FIELD_EXISTS(gs_state);      // additional waypoints by LiveAPI don't have this
        ASSERT_SELF_FIELD_EXISTS(gs_country);    // additional waypoints by LiveAPI don't have this
        ASSERT_SELF_FIELD_EXISTS(gs_container);
        ASSERT_SELF_FIELD_EXISTS(gs_owner);
    }
    // ASSERT_SELF_FIELD_EXISTS(gca_locality);    -- This is only for GCA by default.
    ASSERT_SELF_FIELD_EXISTS(account);
    NSId _id = 0;
    @synchronized(db) {
        DB_PREPARE(@"insert into waypoints(wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, planned) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT  ( 1, self.wpt_name);
        SET_VAR_TEXT  ( 2, self.wpt_description);
        SET_VAR_DOUBLE( 3, self.wpt_latitude);
        SET_VAR_DOUBLE( 4, self.wpt_longitude);
        SET_VAR_INT   ( 5, self.wpt_date_placed_epoch);
        SET_VAR_TEXT  ( 6, self.wpt_url);
        SET_VAR_INT   ( 7, self.wpt_type._id);
        SET_VAR_INT   ( 8, self.wpt_symbol._id)
        SET_VAR_TEXT  ( 9, self.wpt_urlname);

        SET_VAR_INT   (10, self.logStatus);
        SET_VAR_BOOL  (11, self.flag_highlight);
        SET_VAR_INT   (12, self.account._id);
        SET_VAR_BOOL  (13, self.flag_ignore);

        SET_VAR_INT   (14, self.gs_country._id);
        SET_VAR_INT   (15, self.gs_state._id);
        SET_VAR_DOUBLE(16, self.gs_rating_difficulty);
        SET_VAR_DOUBLE(17, self.gs_rating_terrain);
        SET_VAR_INT   (18, self.gs_favourites);
        SET_VAR_BOOL  (19, self.gs_long_desc_html);
        SET_VAR_TEXT  (20, self.gs_long_desc);
        SET_VAR_BOOL  (21, self.gs_short_desc_html);
        SET_VAR_TEXT  (22, self.gs_short_desc);
        SET_VAR_TEXT  (23, self.gs_hint);
        SET_VAR_INT   (24, self.gs_container._id);
        SET_VAR_BOOL  (25, self.gs_archived);
        SET_VAR_BOOL  (26, self.gs_available);
        SET_VAR_INT   (27, self.gs_owner._id);
        SET_VAR_TEXT  (28, self.gs_placed_by);

        SET_VAR_BOOL  (29, self.flag_markedfound);
        SET_VAR_BOOL  (30, self.flag_inprogress);
        SET_VAR_INT   (31, self.gs_date_found);
        SET_VAR_BOOL  (32, self.flag_dnf);
        SET_VAR_INT   (33, self.date_lastlog_epoch);
        SET_VAR_INT   (34, self.gca_locality._id);
        SET_VAR_INT   (35, self.date_lastimport_epoch);
        SET_VAR_INT   (36, self.flag_planned);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    self._id = _id;
    return _id;
}

- (void)dbUpdate
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set wpt_name = ?, wpt_description = ?, wpt_lat = ?, wpt_lon = ?, wpt_date_placed_epoch = ?, wpt_url = ?, wpt_type_id = ?, wpt_symbol_id = ?, wpt_urlname = ?, log_status = ?, highlight = ?, account_id = ?, ignore = ?, gs_country_id = ?, gs_state_id = ?, gs_rating_difficulty = ?, gs_rating_terrain = ?, gs_favourites = ?, gs_long_desc_html = ?, gs_long_desc = ?, gs_short_desc_html = ?, gs_short_desc = ?, gs_hint = ?, gs_container_id = ?, gs_archived = ?, gs_available = ?, gs_owner_id = ?, gs_placed_by = ?, markedfound = ?, inprogress = ?, gs_date_found = ?, dnfed = ?, date_lastlog_epoch = ?, gca_locale_id = ?, date_lastimport_epoch = ?, planned = ? where id = ?");

        SET_VAR_TEXT  ( 1, self.wpt_name);
        SET_VAR_TEXT  ( 2, self.wpt_description);
        SET_VAR_DOUBLE( 3, self.wpt_latitude);
        SET_VAR_DOUBLE( 4, self.wpt_longitude);
        SET_VAR_INT   ( 5, self.wpt_date_placed_epoch);
        SET_VAR_TEXT  ( 6, self.wpt_url);
        SET_VAR_INT   ( 7, self.wpt_type._id);
        SET_VAR_INT   ( 8, self.wpt_symbol._id);
        SET_VAR_TEXT  ( 9, self.wpt_urlname);

        SET_VAR_INT   (10, self.logStatus);
        SET_VAR_BOOL  (11, self.flag_highlight);
        SET_VAR_INT   (12, self.account._id);
        SET_VAR_BOOL  (13, self.flag_ignore);

        SET_VAR_INT   (14, self.gs_country._id);
        SET_VAR_INT   (15, self.gs_state._id);
        SET_VAR_DOUBLE(16, self.gs_rating_difficulty);
        SET_VAR_DOUBLE(17, self.gs_rating_terrain);
        SET_VAR_INT   (18, self.gs_favourites);
        SET_VAR_BOOL  (19, self.gs_long_desc_html);
        SET_VAR_TEXT  (20, self.gs_long_desc);
        SET_VAR_BOOL  (21, self.gs_short_desc_html);
        SET_VAR_TEXT  (22, self.gs_short_desc);
        SET_VAR_TEXT  (23, self.gs_hint);
        SET_VAR_INT   (24, self.gs_container._id);
        SET_VAR_BOOL  (25, self.gs_archived);
        SET_VAR_BOOL  (26, self.gs_available);
        SET_VAR_INT   (27, self.gs_owner._id);
        SET_VAR_TEXT  (28, self.gs_placed_by);

        SET_VAR_BOOL  (29, self.flag_markedfound);
        SET_VAR_BOOL  (30, self.flag_inprogress);
        SET_VAR_INT   (31, self.gs_date_found);
        SET_VAR_BOOL  (32, self.flag_dnf);
        SET_VAR_INT   (33, self.date_lastlog_epoch);
        SET_VAR_INT   (34, self.gca_locality._id);
        SET_VAR_INT   (35, self.date_lastimport_epoch);
        SET_VAR_INT   (36, self.flag_planned);

        SET_VAR_INT   (37, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)dbUpdateLogStatus
{
    MyClock *clock = [[MyClock alloc] initClock:@"dbUpdateLogStatus"];
    [clock clockEnable:YES];
    [clock clockShowAndReset:@"start"];

    // Remove this, it will never get unlogged.
    // Make all not logged
//    @synchronized(db) {
//        DB_PREPARE(@"update waypoints set log_status = ?");
//        SET_VAR_INT(1, LOGSTATUS_NOTLOGGED);
//        DB_CHECK_OKAY;
//        DB_FINISH;
//    }
    [clock clockShowAndReset:@"1"];

    // Find all the logs about non-found caches and mark these caches as not found.
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ? where gs_date_found = 0 and (id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select accountname_id from accounts))) and not (gs_date_found != 0 or id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts)))");
        SET_VAR_INT(1, LOGSTATUS_NOTFOUND);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"2"];

    // Find all the logs about found caches and mark these caches as found.
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set log_status = ? where gs_date_found != 0 or id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts))");
        SET_VAR_INT(1, LOGSTATUS_FOUND);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [clock clockShowAndReset:@"3"];

    /*
     // Find all the waypoints and their waypoints
     @synchronized(db) {
         NSArray<dbWaypoint *> *waypoints = [dbWaypoint dbAllFound];
         NSLog(@"Checking %ld waypoints", [waypoints count]);
         [waypoints enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull waypoint, NSUInteger idx, BOOL * _Nonnull stop) {
         NSArray<dbWaypoint *> *wps = [waypoint hasWaypoints];
         if ([wps count] <= 1)
             return;
         NSMutableString *ids = [NSMutableString string];
         [wps enumerateObjectsUsingBlock:^(dbWaypoint * _Nonnull wp, NSUInteger idx, BOOL * _Nonnull stop) {
             if (wp.logStatus == LOGSTATUS_FOUND)
                 return;
             if (IS_EMPTY(ids) == NO)
                 [ids appendFormat:@" or id = %ld", (long)wp._id];
             else
                 [ids appendFormat:@"id = %ld", (long)wp._id];
         }];
         NSString *sql = [NSString stringWithFormat:@"update waypoints set log_status = ? where %@", ids];
         DB_PREPARE(sql);
         SET_VAR_INT(1, LOGSTATUS_FOUND);
         DB_CHECK_OKAY;
         DB_FINISH;
         }];
     }
     [clock clockShowAndReset:@"4"];
     */

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
    ASSERT_FINISHED;
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
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set highlight = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_highlight);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_highlight == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_HIGHLIGHTED];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_HIGHLIGHTED];
}

- (void)dbUpdateIgnore
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set ignore = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_ignore);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_ignore == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_IGNORED];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_IGNORED];
}

- (void)dbUpdateMarkedFound
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set markedfound = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_markedfound);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_markedfound == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_MARKEDFOUND];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_MARKEDFOUND];
}

- (void)dbUpdateMarkedDNF
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set dnfed = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_dnf);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_dnf == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_MARKEDDNF];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_MARKEDDNF];
}

- (void)dbUpdateInProgress
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set inprogress = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_inprogress);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_inprogress == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_INPROGRESS];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_INPROGRESS];
}

- (void)dbUpdatePlanned
{
    ASSERT_FINISHED;
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set planned = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_planned);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }

    if (self.flag_planned == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_PLANNED];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_PLANNED];
}

- (void)dbUpdateCountryStateLocality
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set gca_locale_id = ?, gs_country_id = ?, gs_state_id = ? where id = ?");

        SET_VAR_INT(1, self.gca_locality._id);
        SET_VAR_INT(2, self.gs_country._id);
        SET_VAR_INT(3, self.gs_state._id);
        SET_VAR_INT(4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSMutableArray<dbWaypoint *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbWaypoint *> *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypoint *wp;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, planned from waypoints wp "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            wp = [[dbWaypoint alloc] init];
            wp._id = _id;

            NSId i = 0;
            TEXT_FETCH  ( 1, wp.wpt_name);
            TEXT_FETCH  ( 2, wp.wpt_description);
            DOUBLE_FETCH( 3, wp.wpt_latitude);
            DOUBLE_FETCH( 4, wp.wpt_longitude);
            INT_FETCH   ( 5, wp.wpt_date_placed_epoch);
            TEXT_FETCH  ( 6, wp.wpt_url);
            INT_FETCH   ( 7, i);
            wp.wpt_type = [dbc typeGet:i];
            INT_FETCH   ( 8, i);
            wp.wpt_symbol = [dbc symbolGet:i];
            TEXT_FETCH  ( 9, wp.wpt_urlname);

            INT_FETCH   (10, wp.logStatus);
            BOOL_FETCH  (11, wp.flag_highlight);
            INT_FETCH   (12, i);
            wp.account = [dbc accountGet:i];
            BOOL_FETCH  (13, wp.flag_ignore);

            INT_FETCH   (14, i);
            wp.gs_country = [dbc countryGet:i];
            INT_FETCH   (15, i);
            wp.gs_state = [dbc stateGet:i];
            DOUBLE_FETCH(16, wp.gs_rating_difficulty);
            DOUBLE_FETCH(17, wp.gs_rating_terrain);
            INT_FETCH   (18, wp.gs_favourites);
            BOOL_FETCH  (19, wp.gs_long_desc_html);
            TEXT_FETCH  (20, wp.gs_long_desc);
            BOOL_FETCH  (21, wp.gs_short_desc_html);
            TEXT_FETCH  (22, wp.gs_short_desc);
            TEXT_FETCH  (23, wp.gs_hint);
            INT_FETCH   (24, i);
            wp.gs_container = [dbc containerGet:i];
            BOOL_FETCH  (25, wp.gs_archived);
            BOOL_FETCH  (26, wp.gs_available);
            INT_FETCH   (27, i);
            wp.gs_owner = [dbc nameGet:i];
            TEXT_FETCH  (28, wp.gs_placed_by);

            BOOL_FETCH  (29, wp.flag_markedfound);
            BOOL_FETCH  (30, wp.flag_inprogress);
            INT_FETCH   (31, wp.gs_date_found);
            BOOL_FETCH  (32, wp.flag_dnf);
            INT_FETCH   (33, wp.date_lastlog_epoch);
            INT_FETCH   (34, i);
            wp.gca_locality = [dbc localityGet:i];
            INT_FETCH   (35, wp.date_lastimport_epoch);
            INT_FETCH   (36, wp.flag_planned);

            [wp finish];
            [wps addObject:wp];
        }
        DB_FINISH;
    }
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAll
{
    return [dbWaypoint dbAllXXX:nil keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllNotFound
{
    return [dbWaypoint dbAllXXX:@"where wp.gs_date_found = 0 and (wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select accountname_id from accounts))) and not (wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts)))" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllNotFoundButNotInGroupAllNotFound
{
    return [dbWaypoint dbAllXXX:@"where (wp.id not in (select waypoint_id from group2waypoints where group_id = ?)) and (wp.gs_date_found = 0 and (wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select accountname_id from accounts))) and not (wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts))))" keys:@"i" values:@[[NSNumber numberWithInteger:dbc.groupAllWaypointsNotFound._id]]];
}

+ (NSArray<dbWaypoint *> *)dbAllFound
{
    return [dbWaypoint dbAllXXX:@"where wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts))" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllFoundButNotInGroupAllFound
{
    return [dbWaypoint dbAllXXX:@"where (wp.id not in (select waypoint_id from group2waypoints where group_id = ?)) and (wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select accountname_id from accounts)))" keys:@"i" values:@[[NSNumber numberWithInteger:dbc.groupAllWaypointsFound._id]]];
}

+ (NSArray<dbWaypoint *> *)dbAllIgnored
{
    return [dbWaypoint dbAllXXX:@"where ignore = 1" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllInRect:(CLLocationCoordinate2D)lt RT:(CLLocationCoordinate2D)rt
{
    // -34040000 < wpt_lat_int and wpt_lat_int < 34050000 and 151093000 < wpt_lon_int and wpt_lon_int < 1510950000;
    return [dbWaypoint dbAllXXX:@"where ? < wpt_lat and wpt_lat < ? and ? < wpt_lon and wpt_lon < ?"
                           keys:@"ffff"
                         values:@[[NSNumber numberWithFloat:lt.latitude],
                                  [NSNumber numberWithFloat:rt.latitude],
                                  [NSNumber numberWithFloat:lt.longitude],
                                  [NSNumber numberWithFloat:rt.longitude]]];
}

+ (NSArray<dbWaypoint *> *)dbAllInGroups:(NSArray<dbGroup *> *)groups
{
    NSMutableString *keys = [NSMutableString stringWithString:@""];
    NSMutableArray<NSNumber *> *values = [NSMutableArray arrayWithCapacity:[groups count]];
    NSMutableString *where = [NSMutableString stringWithString:@""];
    [groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop) {
        if (IS_EMPTY(where) == NO)
            [where appendString:@" or "];
        [where appendString:@"group_id = ?"];
        [keys appendString:@"i"];
        [values addObject:[NSNumber numberWithLongLong:group._id]];
    }];
    // Stop selecting this criteria without actually selecting a group!
    if (IS_EMPTY(where) == YES)
        return nil;

    return [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"where wp.id in (select waypoint_id from group2waypoints where %@)", where]
                           keys:keys
                         values:values];
}

+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithImages
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from image2waypoint where type = ?)" keys:@"i" values:@[[NSNumber numberWithInteger:IMAGECATEGORY_USER]]];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithLogs
{
    return [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs)" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithLogsUnsubmitted
{
    return [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs where needstobelogged = 1)" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithMyLogs
{
    return [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs where logger_id in (select accountname_id from accounts))" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllByFlag:(Flag)flag
{
    NSArray<dbWaypoint *> *wps = nil;

    switch (flag) {
        case FLAGS_HIGHLIGHTED:
            wps = [dbWaypoint dbAllXXX:@"where highlight = 1" keys:nil values:nil];
            break;
        case FLAGS_IGNORED:
            wps = [dbWaypoint dbAllXXX:@"where ignore = 1" keys:nil values:nil];
            break;
        case FLAGS_INPROGRESS:
            wps = [dbWaypoint dbAllXXX:@"where inprogress = 1" keys:nil values:nil];
            break;
        case FLAGS_MARKEDFOUND:
            wps = [dbWaypoint dbAllXXX:@"where markedfound = 1" keys:nil values:nil];
            break;
        case FLAGS_MARKEDDNF:
            wps = [dbWaypoint dbAllXXX:@"where dnfed = 1" keys:nil values:nil];
            break;
        case FLAGS_PLANNED:
            wps = [dbWaypoint dbAllXXX:@"where planned = 1" keys:nil values:nil];
            break;
    }
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllInCountry:(NSString *)country
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = ?)" keys:@"s" values:@[country]];
}

+ (NSArray<dbWaypoint *> *)dbAllInCountryNotFound:(NSString *)country
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = ?) and log_status != 2 and markedfound != 1" keys:@"s" values:@[country]];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationless;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and ignore = 0" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationlessNotFound;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and log_status != 2 and markedfound != 1 and ignore = 0" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationlessPlanned;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and planned = 1 and ignore = 0" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllMoveables
{
    return [dbWaypoint dbAllXXX:@"where wpt_type_id = (select id from types where type_minor = 'Moveable')" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllMoveablesNotFound
{
    return [dbWaypoint dbAllXXX:@"where wpt_type_id = (select id from types where type_minor = 'Moveable') and log_status != 2 and markedfound != 1" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllMoveablesMine
{
    return [dbWaypoint dbAllXXX:@"where wpt_type_id = (select id from types where type_minor = 'Moveable') and gs_owner_id in (select accountname_id from accounts where accountname_id != 0)" keys:nil values:nil];
}

+ (NSArray<dbWaypoint *> *)dbAllMoveablesInventory
{
    return [dbWaypoint dbAllXXX:@"where wpt_type_id = (select id from types where type_minor = 'Moveable') and id in (select waypoint_id from moveable_inventory)" keys:nil values:nil];
}

+ (dbWaypoint *)dbGetByName:(NSString *)name
{
    return [[self dbAllXXX:@"where wpt_name = ?" keys:@"s" values:@[name]] firstObject];
}

+ (dbWaypoint *)dbGet:(NSId)_id
{
    return [[dbWaypoint dbAllXXX:@"where wp.id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:_id]]] firstObject];
}

/* Other methods */

- (NSInteger)hasLogs
{
    ASSERT_FINISHED;
    return [dbLog dbCountByWaypoint:self];
}

- (NSInteger)hasAttributes
{
    ASSERT_FINISHED;
    return [dbAttribute dbCountByWaypoint:self];
}

- (NSInteger)hasFieldNotes
{
    ASSERT_FINISHED;
    return [[dbLog dbAllByWaypointLogged:self] count];
}

- (NSInteger)hasImages
{
    ASSERT_FINISHED;
    return [dbImage dbCountByWaypoint:self];
}

- (NSInteger)hasPersonalNotes
{
    ASSERT_FINISHED;
    dbPersonalNote *pn = [dbPersonalNote dbGetByWaypointName:self.wpt_name];
    return (pn != nil ? 1 : 0);
}

- (NSInteger)hasInventory
{
    ASSERT_FINISHED;
    return [dbTrackable dbCountByWaypoint:self];
}

- (NSArray<dbWaypoint *> *)hasWaypoints
{
    ASSERT_FINISHED;
    NSMutableArray<dbWaypoint *> *wps = [NSMutableArray arrayWithCapacity:20];
    NSString *currentSuffix, *currentPrefix, *otherPrefix;
    NSArray<NSString *> *GCCodes = @[
                         @"GA", // Geocaching Australia
                         @"MY", // Geocube internal
                         @"TP", // Geocaching Australia Trigpoint
                         @"GC", // Groundspeak Geocaching.com
                         @"CC", // Groundspeak Geocaching.com - correct coordinates
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
        SET_VAR_INT (2, self.account._id);

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

- (NSString *)makeLocalityStateCountry
{
    ASSERT_FINISHED;
    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (self.gca_locality != nil)
        [s appendFormat:@"%@", self.gca_locality.name];
    if (self.gs_state != nil) {
        if (IS_EMPTY(s) == NO)
            [s appendFormat:@", "];
        if (configManager.showStateAsAbbrevationIfLocalityExists == YES && self.gca_locality != nil)
            [s appendFormat:@"%@", self.gs_state.code];
        else
            [s appendFormat:@"%@", configManager.showStateAsAbbrevation == YES ? self.gs_state.code : self.gs_state.name];
    }
    if (self.gs_country != nil) {
        if (IS_EMPTY(s) == NO)
            [s appendFormat:@", "];
        NSString *cs = [NSString stringWithFormat:@"country-%@", self.gs_country.name];
        [s appendFormat:@"%@", configManager.showCountryAsAbbrevation == YES ? self.gs_country.code : _(cs)];
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

- (BOOL)hasGSData
{
    // If the difficulty or terrain is not zero, then pretend the Groundspeak specific data is available
    return (self.gs_owner != nil);
}

@end
