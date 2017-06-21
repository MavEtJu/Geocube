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

@interface dbWaypointMutable ()

@end

@implementation dbWaypointMutable

- (instancetype)init:(NSId)__id
{
    self = [super init:0];
    self._id = __id;

    self.gs_available = YES;
    self.logStatus = LOGSTATUS_NOTLOGGED;
    self.logstring_logtype = LOGSTRING_LOGTYPE_UNKNOWN;

    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
CONVERT_TO(dbWaypoint)
#pragma clang diagnostic pop

- (void)finish
{
    // Conversions from the data retrieved
    if (self.wpt_lat != nil) {
        self.wpt_lat_float = [self.wpt_lat floatValue];
        self.wpt_lat_int = self.wpt_lat_float * 1000000;
    }
    if (self.wpt_lon != nil) {
        self.wpt_lon_float = [self.wpt_lon floatValue];
        self.wpt_lon_int = self.wpt_lon_float * 1000000;
    }
    if (self.wpt_lat_float != 0) {
        self.wpt_lat_int = self.wpt_lat_float * 1000000;
        self.wpt_lat = [NSString stringWithFormat:@"%f", self.wpt_lat_float];
    }
    if (self.wpt_lon_float != 0) {
        self.wpt_lon_int = self.wpt_lon_float * 1000000;
        self.wpt_lon = [NSString stringWithFormat:@"%f", self.wpt_lon_float];
    }

    if (self.wpt_date_placed_epoch == 0)
        self.wpt_date_placed_epoch = [MyTools secondsSinceEpochFromISO8601:self.wpt_date_placed];
    if (self.wpt_date_placed == nil)
        self.wpt_date_placed = [MyTools dateTimeString_YYYY_MM_DDThh_mm_ss:self.wpt_date_placed_epoch];

    self.coordinates = CLLocationCoordinate2DMake([self.wpt_lat floatValue], [self.wpt_lon floatValue]);

    // Adjust cache types
    if (self.wpt_type == nil) {
        if (self.wpt_type_str != nil) {
            NSArray<NSString *> *as = [self.wpt_type_str componentsSeparatedByString:@"|"];
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

- (NSId)dbCreate
{
    NSId _id = 0;
    @synchronized(db) {
        DB_PREPARE(@"insert into waypoints(wpt_name, wpt_description, wpt_lat, wpt_lon, wpt_date_placed_epoch, wpt_url, wpt_type_id, wpt_symbol_id, wpt_urlname, log_status, highlight, account_id, ignore, gs_country_id, gs_state_id, gs_rating_difficulty, gs_rating_terrain, gs_favourites, gs_long_desc_html, gs_long_desc, gs_short_desc_html, gs_short_desc, gs_hint, gs_container_id, gs_archived, gs_available, gs_owner_id, gs_placed_by, markedfound, inprogress, gs_date_found, dnfed, date_lastlog_epoch, gca_locale_id, date_lastimport_epoch, related_id, planned) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT  ( 1, self.wpt_name);
        SET_VAR_TEXT  ( 2, self.wpt_description);
        SET_VAR_TEXT  ( 3, self.wpt_lat);
        SET_VAR_TEXT  ( 4, self.wpt_lon);
        SET_VAR_INT   ( 5, self.wpt_date_placed_epoch);
        SET_VAR_TEXT  ( 6, self.wpt_url);
        SET_VAR_INT   ( 7, self.wpt_type_id);
        SET_VAR_INT   ( 8, self.wpt_symbol_id);
        SET_VAR_TEXT  ( 9, self.wpt_urlname);

        SET_VAR_INT   (10, self.logStatus);
        SET_VAR_BOOL  (11, self.flag_highlight);
        SET_VAR_INT   (12, self.account_id);
        SET_VAR_BOOL  (13, self.flag_ignore);

        SET_VAR_INT   (14, self.gs_country_id);
        SET_VAR_INT   (15, self.gs_state_id);
        SET_VAR_DOUBLE(16, self.gs_rating_difficulty);
        SET_VAR_DOUBLE(17, self.gs_rating_terrain);
        SET_VAR_INT   (18, self.gs_favourites);
        SET_VAR_BOOL  (19, self.gs_long_desc_html);
        SET_VAR_TEXT  (20, self.gs_long_desc);
        SET_VAR_BOOL  (21, self.gs_short_desc_html);
        SET_VAR_TEXT  (22, self.gs_short_desc);
        SET_VAR_TEXT  (23, self.gs_hint);
        SET_VAR_INT   (24, self.gs_container_id);
        SET_VAR_BOOL  (25, self.gs_archived);
        SET_VAR_BOOL  (26, self.gs_available);
        SET_VAR_INT   (27, self.gs_owner_id);
        SET_VAR_TEXT  (28, self.gs_placed_by);

        SET_VAR_BOOL  (29, self.flag_markedfound);
        SET_VAR_BOOL  (30, self.flag_inprogress);
        SET_VAR_INT   (31, self.gs_date_found);
        SET_VAR_BOOL  (32, self.flag_dnf);
        SET_VAR_INT   (33, self.date_lastlog_epoch);
        SET_VAR_INT   (34, self.gca_locale_id);
        SET_VAR_INT   (35, self.date_lastimport_epoch);
        SET_VAR_INT   (36, self.related_id);
        SET_VAR_INT   (37, self.flag_planned);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    self._id = _id;
    return _id;
}

+ (dbWaypointMutable *)dbGet:(NSId)_id
{
    dbWaypoint *wp = [dbWaypoint dbGet:_id];
    return [wp dbWaypointMutable];
}

@end
