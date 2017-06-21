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

    self.gs_available = YES;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.logstring_logtype = LOGSTRING_LOGTYPE_UNKNOWN;

    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
CONVERT_TO(dbWaypointMutable)
#pragma clang diagnostic pop

- (void)finish
{
    self.coordinates = CLLocationCoordinate2DMake(self.wpt_lat_float, self.wpt_lon_float);

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

+ (NSMutableArray<dbWaypoint *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbWaypoint *> *wps = [[NSMutableArray alloc] initWithCapacity:20];
    dbWaypointMutable *wpm;

    NSMutableString *sql = [NSMutableString stringWithFormat:@"select id, wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, related_id, planned from waypoints wp %@", where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            wpm = [[dbWaypointMutable alloc] init:_id];

            TEXT_FETCH  ( 1, wpm.wpt_name);
            TEXT_FETCH  ( 2, wpm.wpt_description);
            DOUBLE_FETCH( 3, wpm.wpt_lat_float);
            DOUBLE_FETCH( 4, wpm.wpt_lon_float);
            INT_FETCH   ( 5, wpm.wpt_date_placed_epoch);
            TEXT_FETCH  ( 6, wpm.wpt_url);
            INT_FETCH   ( 7, wpm.wpt_type_id);
            INT_FETCH   ( 8, wpm.wpt_symbol_id);
            TEXT_FETCH  ( 9, wpm.wpt_urlname);

            INT_FETCH   (10, wpm.logStatus);
            BOOL_FETCH  (11, wpm.flag_highlight);
            INT_FETCH   (12, wpm.account_id);
            BOOL_FETCH  (13, wpm.flag_ignore);

            INT_FETCH   (14, wpm.gs_country_id);
            INT_FETCH   (15, wpm.gs_state_id);
            DOUBLE_FETCH(16, wpm.gs_rating_difficulty);
            DOUBLE_FETCH(17, wpm.gs_rating_terrain);
            INT_FETCH   (18, wpm.gs_favourites);
            BOOL_FETCH  (19, wpm.gs_long_desc_html);
            TEXT_FETCH  (20, wpm.gs_long_desc);
            BOOL_FETCH  (21, wpm.gs_short_desc_html);
            TEXT_FETCH  (22, wpm.gs_short_desc);
            TEXT_FETCH  (23, wpm.gs_hint);
            INT_FETCH   (24, wpm.gs_container_id);
            BOOL_FETCH  (25, wpm.gs_archived);
            BOOL_FETCH  (26, wpm.gs_available);
            INT_FETCH   (27, wpm.gs_owner_id);
            TEXT_FETCH  (28, wpm.gs_placed_by);

            BOOL_FETCH  (29, wpm.flag_markedfound);
            BOOL_FETCH  (30, wpm.flag_inprogress);
            INT_FETCH   (31, wpm.gs_date_found);
            BOOL_FETCH  (32, wpm.flag_dnf);
            INT_FETCH   (33, wpm.date_lastlog_epoch);
            INT_FETCH   (34, wpm.gca_locale_id);
            INT_FETCH   (35, wpm.date_lastimport_epoch);
            INT_FETCH   (36, wpm.related_id);
            INT_FETCH   (37, wpm.flag_planned);

            [wpm finish];
            dbWaypoint *wp = [wpm dbWaypoint];
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
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@""];
    return wps;
}

+ (NSInteger)dbCount
{
    return [dbWaypoint dbCount:@"waypoints"];
}

+ (NSArray<dbWaypoint *> *)dbAllNotFound
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where wp.gs_date_found = 0 and (wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 0) and logger_id in (select name_id from accounts))) and not (wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts)))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllFound
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where wp.gs_date_found != 0 or wp.id in (select waypoint_id from logs where log_string_id in (select id from log_strings where found = 1) and logger_id in (select name_id from accounts))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllIgnored
{
    NSArray<dbWaypoint *>*wps = [dbWaypoint dbAllXXX:@"where ignore = 1"];
    return wps;
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
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where wp.id = ?" keys:@"i" values:@[[NSNumber numberWithLongLong:_id]]];
    if ([wps count] == 0)
        return nil;
    return [wps objectAtIndex:0];
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update waypoints set wpt_name = ?, wpt_description = ?, wpt_lat = ?, wpt_lon = ?, wpt_date_placed_epoch = ?, wpt_url = ?, wpt_type_id = ?, wpt_symbol_id = ?, wpt_urlname = ?, log_status = ?, highlight = ?, account_id = ?, ignore = ?, gs_country_id = ?, gs_state_id = ?, gs_rating_difficulty = ?, gs_rating_terrain = ?, gs_favourites = ?, gs_long_desc_html = ?, gs_long_desc = ?, gs_short_desc_html = ?, gs_short_desc = ?, gs_hint = ?, gs_container_id = ?, gs_archived = ?, gs_available = ?, gs_owner_id = ?, gs_placed_by = ?, markedfound = ?, inprogress = ?, gs_date_found = ?, dnfed = ?, date_lastlog_epoch = ?, gca_locale_id = ?, date_lastimport_epoch = ?, related_id = ?, planned = ? where id = ?");

        SET_VAR_TEXT  ( 1, self.wpt_name);
        SET_VAR_TEXT  ( 2, self.wpt_description);
        SET_VAR_DOUBLE( 3, self.wpt_lat_float);
        SET_VAR_DOUBLE( 4, self.wpt_lon_float);
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
        SET_VAR_INT   (34, self.gca_locale._id);
        SET_VAR_INT   (35, self.date_lastimport_epoch);
        SET_VAR_INT   (36, self.related_id);
        SET_VAR_INT   (37, self.flag_planned);

        SET_VAR_INT   (38, self._id);

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

    /*
    // Find all the waypoints and their waypoints
    @synchronized(db) {
        NSArray<dbWaypoint *> *waypoints = [dbWaypoint dbAllFound];
        NSLog(@"Checking %ld waypoints", [waypoints count]);
        [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *waypoint, NSUInteger idx, BOOL *stop) {
            NSArray<dbWaypoint *> *wps = [waypoint hasWaypoints];
            if ([wps count] <= 1)
                return;
            NSMutableString *ids = [NSMutableString string];
            [wps enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL *stop) {
                if (wp.logStatus == LOGSTATUS_FOUND)
                    return;
                if ([ids isEqualToString:@""] == NO)
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

    if (self.flag_highlight == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_HIGHLIGHTED];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_HIGHLIGHTED];
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

    if (self.flag_ignore == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_IGNORED];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_IGNORED];
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

    if (self.flag_markedfound == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_MARKEDFOUND];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_MARKEDFOUND];
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

    if (self.flag_dnf == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_MARKEDDNF];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_MARKEDDNF];
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

    if (self.flag_inprogress == YES)
        [dbListData waypointSetFlag:self flag:FLAGS_INPROGRESS];
    else
        [dbListData waypointClearFlag:self flag:FLAGS_INPROGRESS];
}

- (void)dbUpdatePlanned
{
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
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from image2waypoint where type = ?)" keys:@"i" values:@[[NSNumber numberWithInteger:IMAGECATEGORY_USER]]];
    return wps;
}

+ (NSArray<dbWaypoint *> *)waypointsWithLogs
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs)"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)waypointsWithLogsUnsubmitted
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs where needstobelogged = 1)"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)waypointsWithMyLogs
{
    NSArray<dbWaypoint *> *wps = [dbWaypoint dbAllXXX:@"where id in (select waypoint_id from logs where logger_id in (select id from names where name in (select accountname from accounts where accountname != '')))"];
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllByFlag:(Flag)flag
{
    NSArray<dbWaypoint *> *wps = nil;

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
        case FLAGS_PLANNED:
            wps = [dbWaypoint dbAllXXX:@"where planned = 1"];
            break;
    }
    return wps;
}

+ (NSArray<dbWaypoint *> *)dbAllInCountry:(NSString *)country
{
    return [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"where gs_country_id = (select id from countries where name = '%@')", country]];
}

+ (NSArray<dbWaypoint *> *)dbAllInCountryNotFound:(NSString *)country
{
    return [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"where gs_country_id = (select id from countries where name = '%@') and log_status != 2 and markedfound != 1", country]];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationless;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and ignore = 0"];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationlessNotFound;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and log_status != 2 and markedfound != 1 and ignore = 0"];
}

+ (NSArray<dbWaypoint *> *)dbAllLocationlessPlanned;
{
    return [dbWaypoint dbAllXXX:@"where gs_country_id = (select id from countries where name = 'Locationless') and planned = 1 and ignore = 0"];
}

- (BOOL)hasGSData
{
    // If the difficulty or terrain is not zero, then pretend the Groundspeak specific data is available
    return (self.gs_owner != nil);
}

@end
