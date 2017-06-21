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

@interface dbWaypointMutable : dbWaypoint

@property (nonatomic, retain) NSString *wpt_lat_str;
@property (nonatomic, retain) NSString *wpt_lon_str;
@property (nonatomic, retain) NSString *wpt_date_placed;
@property (nonatomic) NSId wpt_symbol_id;
@property (nonatomic, retain) NSString *wpt_symbol_str;
@property (nonatomic) NSId wpt_type_id;
@property (nonatomic, retain) NSString *wpt_type_str;

@property (nonatomic) NSId account_id;

@property (nonatomic) NSId gs_country_id;
@property (nonatomic, retain) NSString *gs_country_str;
@property (nonatomic) NSId gs_state_id;
@property (nonatomic, retain) NSString *gs_state_str;
@property (nonatomic) NSId gs_container_id;
@property (nonatomic, retain) NSString *gs_container_str;
@property (nonatomic, retain) NSString *gs_owner_str;
@property (nonatomic) NSId gs_owner_id;

@property (nonatomic) NSId gca_locale_id;
@property (nonatomic) NSString *gca_locale_str;

- (dbWaypoint *)dbWaypoint;

- (NSId)dbCreate;
+ (dbWaypointMutable *)dbGet:(NSId)_id;

@end
