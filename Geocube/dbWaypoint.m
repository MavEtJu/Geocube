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

@interface dbWaypoint ()
{
    /* Waypoint related data */
    NSString *wpt_name, *wpt_description, *wpt_url, *wpt_urlname;

    NSString *wpt_lat, *wpt_lon;
    NSInteger wpt_lat_int, wpt_lon_int;
    float wpt_lat_float, wpt_lon_float;

    NSString *wpt_date_placed;
    NSInteger wpt_date_placed_epoch;

    dbSymbol *wpt_symbol;
    NSId wpt_symbol_id;
    NSString *wpt_symbol_str;

    dbType *wpt_type;
    NSId wpt_type_id;
    NSString *wpt_type_str;

    /* Geocube related data */
    NSId account_id;
    dbAccount *account;

    NSInteger logStatus;
    BOOL flag_highlight;
    BOOL flag_ignore;
    BOOL flag_inprogress;
    BOOL flag_markedfound;

    /* Groundspeak related data */
    BOOL gs_hasdata;

    float gs_rating_difficulty, gs_rating_terrain;
    NSInteger gs_favourites;

    BOOL gs_archived, gs_available;

    NSString *gs_country_str;
    NSId gs_country_id;
    dbCountry *gs_country;

    NSString *gs_state_str;
    NSId gs_state_id;
    dbState *gs_state;

    BOOL gs_short_desc_html, gs_long_desc_html;
    NSString *gs_short_desc, *gs_long_desc;
    NSString *gs_hint;

    NSString *gs_placed_by;

    NSString *gs_owner_gsid;
    NSString *gs_owner_str;
    NSId gs_owner_id;
    dbName *gs_owner;

    NSId gs_container_id;
    NSString *gs_container_str;
    dbContainer *gs_container;

    NSInteger gs_date_found;

    /* Not read from the database */
    CLLocationCoordinate2D coordinates;
    NSInteger calculatedDistance;
    NSInteger calculatedBearing;
}

@end

@implementation dbWaypoint

@synthesize wpt_name, wpt_description, wpt_url, wpt_urlname, wpt_lat, wpt_lon, wpt_date_placed, wpt_type_str, wpt_symbol_str, wpt_lat_int, wpt_lon_int, wpt_lat_float, wpt_lon_float, wpt_date_placed_epoch, wpt_type_id, wpt_type, wpt_symbol_id, wpt_symbol;
@synthesize coordinates, calculatedDistance, calculatedBearing, logStatus, flag_highlight, account, account_id, flag_ignore, flag_markedfound, flag_inprogress;
@synthesize gs_hasdata, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_country, gs_country_id, gs_country_str, gs_state, gs_state_id, gs_state_str, gs_short_desc_html, gs_short_desc, gs_long_desc_html, gs_long_desc, gs_hint, gs_container, gs_container_str, gs_container_id, gs_archived, gs_available, gs_placed_by, gs_owner_gsid, gs_owner, gs_owner_id, gs_owner_str, gs_date_found;

- (instancetype)init:(NSId)__id
{
    self = [super init];
    self._id = __id;

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

    self.gs_hasdata = NO;
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

    self.coordinates = CLLocationCoordinate2DMake(0, 0);
    self.calculatedDistance = 0;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.account_id = 0;
    self.account = nil;
    self.flag_highlight = NO;
    self.flag_ignore = NO;
    self.flag_inprogress = NO;
    self.flag_markedfound = NO;

    return self;
}

- (void)finish
{
    // Conversions from the data retrieved
    wpt_lat_float = [wpt_lat floatValue];
    wpt_lon_float = [wpt_lon floatValue];
    wpt_lat_int = wpt_lat_float * 1000000;
    wpt_lon_int = wpt_lon_float * 1000000;

    wpt_date_placed_epoch = [MyTools secondsSinceEpoch:wpt_date_placed];

    coordinates = CLLocationCoordinate2DMake([wpt_lat floatValue], [wpt_lon floatValue]);

    // Adjust cache types
    if (wpt_type == nil) {
        if (wpt_type_str != nil) {
            NSArray *as = [wpt_type_str componentsSeparatedByString:@"|"];
            if ([as count] == 2) {
                // Geocache|Traditional Cache
                wpt_type = [dbc Type_get_byname:[as objectAtIndex:0] minor:[as objectAtIndex:1]];
            } else {
                // Traditional Cache
                [[dbc Types] enumerateObjectsUsingBlock:^(dbType *t, NSUInteger idx, BOOL *stop) {
                    if ([t.type_minor isEqualToString:wpt_type_str] == YES) {
                        wpt_type = t;
                        *stop = YES;
                    }
                }];
                if (wpt_type == nil)
                    wpt_type = [dbc Type_get_byname:@"Geocache" minor:@"*"];
            }
            wpt_type_id = wpt_type._id;
        }
        if (wpt_type_id != 0) {
            wpt_type = [dbc Type_get:wpt_type_id];
            wpt_type_str = wpt_type.type_full;
        }
    }

    // Adjust cache symbol
    if (wpt_symbol == nil) {
        if (wpt_symbol_str != nil) {
            wpt_symbol = [dbc Symbol_get_bysymbol:wpt_symbol_str];
            wpt_symbol_id = wpt_symbol._id;
        }
        if (wpt_symbol_id != 0) {
            wpt_symbol = [dbc Symbol_get:wpt_symbol_id];
            wpt_symbol_str = wpt_symbol.symbol;
        }
    }

    if (account_id != 0)
        account = [dbc Account_get:account_id];
    if (account != nil)
        account_id = account._id;

    // Adjust container size
    if (gs_container == nil) {
        if (gs_container_str != nil) {
            gs_container = [dbc Container_get_bysize:gs_container_str];
            gs_container_id = gs_container._id;
        }
        if (gs_container_id != 0) {
            gs_container = [dbc Container_get:gs_container_id];
            gs_container_str = gs_container.size;
        }
    }

    if (gs_owner == nil) {
        if (gs_owner_str != nil) {
            if (gs_owner_gsid == nil)
                gs_owner = [dbName dbGetByName:gs_owner_str account:self.account];
            else
                gs_owner = [dbName dbGetByNameCode:gs_owner_str code:gs_owner_gsid account:self.account];
            gs_owner_id = gs_owner._id;
        }
        if (gs_owner_id != 0) {
            gs_owner = [dbc Name_get:gs_owner_id];
            gs_owner_str = gs_owner.name;
        }
    }

    if (gs_state == nil) {
        if (gs_state_str != nil) {
            gs_state = [dbc State_get_byName:gs_state_str];
            gs_state_id = gs_state._id;
        }
        if (gs_state_id != 0) {
            gs_state = [dbc State_get:gs_state_id];
            gs_state_str = gs_state.name;
        }
    }

    if (gs_country == nil) {
        if (gs_country_str != nil) {
            gs_country = [dbc Country_get_byName:gs_country_str];
            gs_country_id = gs_country._id;
        }
        if (gs_country_id != 0) {
            gs_country = [dbc Country_get:gs_country_id];
            gs_country_str = gs_country.name;
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

- (NSInteger)hasFieldNotes {
    return [[dbLog dbAllByWaypointLogged:_id] count];
}

- (NSInteger)hasImages {
    return [dbImage dbCountByWaypoint:_id];
}

- (NSInteger)hasPersonalNotes {
    return [dbTrackable dbCountByWaypoint:_id];
}

- (NSInteger)hasInventory {
    return [dbTrackable dbCountByWaypoint:_id];
}

- (NSArray *)hasWaypoints
{
    NSMutableArray *wps = [NSMutableArray arrayWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id from waypoints where wpt_name like ?")

        NSString *sql = [NSString stringWithFormat:@"%%%@", [self.wpt_name substringFromIndex:2]];
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

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_lat_int, wpt_lon_int, wpt_date_placed, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, gs_hasdata, markedfound, inprogress, gs_date_found from waypoints wp"];
    if (where != nil) {
        [sql appendString:@" where "];
        [sql appendString:where];
    }

    @synchronized(db.dbaccess) {
        DB_PREPARE(sql);

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            wp = [[dbWaypoint alloc] init:_id];

            TEXT_FETCH(   1, wp.wpt_name);
            TEXT_FETCH(   2, wp.wpt_description);
            TEXT_FETCH(   3, wp.wpt_lat);
            TEXT_FETCH(   4, wp.wpt_lon);
            INT_FETCH(    5, wp.wpt_lat_int);
            INT_FETCH(    6, wp.wpt_lon_int);
            TEXT_FETCH(   7, wp.wpt_date_placed);
            INT_FETCH(    8, wp.wpt_date_placed_epoch);
            TEXT_FETCH(   9, wp.wpt_url);
            INT_FETCH(   10, wp.wpt_type_id);
            INT_FETCH(   11, wp.wpt_symbol_id);
            TEXT_FETCH(  12, wp.wpt_urlname);

            INT_FETCH(   13, wp.logStatus);
            BOOL_FETCH(  14, wp.flag_highlight);
            INT_FETCH(   15, wp.account_id);
            BOOL_FETCH(  16, wp.flag_ignore);

            INT_FETCH(   17, wp.gs_country_id);
            INT_FETCH(   18, wp.gs_state_id);
            DOUBLE_FETCH(19, wp.gs_rating_difficulty);
            DOUBLE_FETCH(20, wp.gs_rating_terrain);
            INT_FETCH(   21, wp.gs_favourites);
            BOOL_FETCH(  22, wp.gs_long_desc_html);
            TEXT_FETCH(  23, wp.gs_long_desc);
            BOOL_FETCH(  24, wp.gs_short_desc_html);
            TEXT_FETCH(  25, wp.gs_short_desc);
            TEXT_FETCH(  26, wp.gs_hint);
            INT_FETCH(   27, wp.gs_container_id);
            BOOL_FETCH(  28, wp.gs_archived);
            BOOL_FETCH(  29, wp.gs_available);
            INT_FETCH(   30, wp.gs_owner_id);
            TEXT_FETCH(  31, wp.gs_placed_by);
            BOOL_FETCH(  32, wp.gs_hasdata);

            BOOL_FETCH(  33, wp.flag_markedfound);
            BOOL_FETCH(  34, wp.flag_inprogress);
            INT_FETCH(   35, wp.gs_date_found);

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

+ (NSArray *)dbAllIgnored
{
    NSArray *wps = [dbWaypoint dbAllXXX:@"ignore = 1"];
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
    NSArray *wps = [dbWaypoint dbAllXXX:[NSString stringWithFormat:@"wp.id = %ld", (long)_id]];
    if ([wps count] == 0)
        return nil;
    return [wps objectAtIndex:0];
}

+ (void)dbCreate:(dbWaypoint *)wp
{
    NSId _id = 0;
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into waypoints(wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_lat_int, wpt_lon_int, wpt_date_placed, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, gs_hasdata, markedfound, inprogress, gs_date_found) values(?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT(   1, wp.wpt_name);
        SET_VAR_TEXT(   2, wp.wpt_description);
        SET_VAR_TEXT(   3, wp.wpt_lat);
        SET_VAR_TEXT(   4, wp.wpt_lon);
        SET_VAR_INT(    5, wp.wpt_lat_int);
        SET_VAR_INT(    6, wp.wpt_lon_int);
        SET_VAR_TEXT(   7, wp.wpt_date_placed);
        SET_VAR_INT(    8, wp.wpt_date_placed_epoch);
        SET_VAR_TEXT(   9, wp.wpt_url);
        SET_VAR_INT(   10, wp.wpt_type_id);
        SET_VAR_INT(   11, wp.wpt_symbol_id);
        SET_VAR_TEXT(  12, wp.wpt_urlname);

        SET_VAR_INT(   13, wp.logStatus);
        SET_VAR_BOOL(  14, wp.flag_highlight);
        SET_VAR_INT(   15, wp.account_id);
        SET_VAR_BOOL(  16, wp.flag_ignore);

        SET_VAR_INT(   17, wp.gs_country_id);
        SET_VAR_INT(   18, wp.gs_state_id);
        SET_VAR_DOUBLE(19, wp.gs_rating_difficulty);
        SET_VAR_DOUBLE(20, wp.gs_rating_terrain);
        SET_VAR_INT(   21, wp.gs_favourites);
        SET_VAR_BOOL(  22, wp.gs_long_desc_html);
        SET_VAR_TEXT(  23, wp.gs_long_desc);
        SET_VAR_BOOL(  24, wp.gs_short_desc_html);
        SET_VAR_TEXT(  25, wp.gs_short_desc);
        SET_VAR_TEXT(  26, wp.gs_hint);
        SET_VAR_INT(   27, wp.gs_container_id);
        SET_VAR_BOOL(  28, wp.gs_archived);
        SET_VAR_BOOL(  29, wp.gs_available);
        SET_VAR_INT(   30, wp.gs_owner_id);
        SET_VAR_TEXT(  31, wp.gs_placed_by);
        SET_VAR_BOOL(  32, wp.gs_hasdata);

        SET_VAR_BOOL(  33, wp.flag_markedfound);
        SET_VAR_BOOL(  34, wp.flag_inprogress);
        SET_VAR_INT(   35, wp.gs_date_found);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    wp._id = _id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set wpt_name = ?, wpt_description = ?, wpt_lat = ?, wpt_lon = ?, wpt_lat_int = ?, wpt_lon_int = ?, wpt_date_placed = ?, wpt_date_placed_epoch = ?, wpt_url = ?, wpt_type_id = ?, wpt_symbol_id = ?, wpt_urlname = ?, log_status = ?, highlight = ?, account_id = ?, ignore = ?, gs_country_id = ?, gs_state_id = ?, gs_rating_difficulty = ?, gs_rating_terrain = ?, gs_favourites = ?, gs_long_desc_html = ?, gs_long_desc = ?, gs_short_desc_html = ?, gs_short_desc = ?, gs_hint = ?, gs_container_id = ?, gs_archived = ?, gs_available = ?, gs_owner_id = ?, gs_placed_by = ?, gs_hasdata = ?, markedfound = ?, inprogress = ?, gs_date_found = ? where id = ?");

        SET_VAR_TEXT(   1, wpt_name);
        SET_VAR_TEXT(   2, wpt_description);
        SET_VAR_TEXT(   3, wpt_lat);
        SET_VAR_TEXT(   4, wpt_lon);
        SET_VAR_INT(    5, wpt_lat_int);
        SET_VAR_INT(    6, wpt_lon_int);
        SET_VAR_TEXT(   7, wpt_date_placed);
        SET_VAR_INT(    8, wpt_date_placed_epoch);
        SET_VAR_TEXT(   9, wpt_url);
        SET_VAR_INT(   10, wpt_type_id);
        SET_VAR_INT(   11, wpt_symbol_id);
        SET_VAR_TEXT(  12, wpt_urlname);

        SET_VAR_INT(   13, logStatus);
        SET_VAR_BOOL(  14, flag_highlight);
        SET_VAR_INT(   15, account_id);
        SET_VAR_BOOL(  16, flag_ignore);

        SET_VAR_INT(   17, gs_country_id);
        SET_VAR_INT(   18, gs_state_id);
        SET_VAR_DOUBLE(19, gs_rating_difficulty);
        SET_VAR_DOUBLE(20, gs_rating_terrain);
        SET_VAR_INT(   21, gs_favourites);
        SET_VAR_BOOL(  22, gs_long_desc_html);
        SET_VAR_TEXT(  23, gs_long_desc);
        SET_VAR_BOOL(  24, gs_short_desc_html);
        SET_VAR_TEXT(  25, gs_short_desc);
        SET_VAR_TEXT(  26, gs_hint);
        SET_VAR_INT(   27, gs_container_id);
        SET_VAR_BOOL(  28, gs_archived);
        SET_VAR_BOOL(  29, gs_available);
        SET_VAR_INT(   30, gs_owner_id);
        SET_VAR_TEXT(  31, gs_placed_by);
        SET_VAR_BOOL(  32, gs_hasdata);

        SET_VAR_BOOL(  33, flag_markedfound);
        SET_VAR_BOOL(  34, flag_inprogress);
        SET_VAR_INT(   35, gs_date_found);

        SET_VAR_INT(   36, _id);

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

- (void)dbUpdateLogStatus
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set log_status = ? where id = ?");
        SET_VAR_INT(1, self.logStatus);
        SET_VAR_INT(2, self._id);
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateHighlight
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set highlight = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_highlight);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateIgnore
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set ignore = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_ignore);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateMarkedFound
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set markedfound = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_markedfound);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateInProgress
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update waypoints set inprogress = ? where id = ?");

        SET_VAR_BOOL(1, self.flag_inprogress);
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

+ (NSArray *)dbAllByFlag:(NSInteger)flag
{
    NSArray *wps = nil;

    switch (flag) {
        case FLAGS_HIGHLIGHTED:
            wps = [dbWaypoint dbAllXXX:@"highlight = 1"];
            break;
        case FLAGS_IGNORED:
            wps = [dbWaypoint dbAllXXX:@"ignore = 1"];
            break;
        case FLAGS_INPROGRESS:
            wps = [dbWaypoint dbAllXXX:@"inprogress = 1"];
            break;
        case FLAGS_MARKEDFOUND:
            wps = [dbWaypoint dbAllXXX:@"markedfound = 1"];
            break;
    }
    return wps;
}

@end
