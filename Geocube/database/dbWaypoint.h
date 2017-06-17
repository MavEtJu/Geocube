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

@interface dbWaypoint : dbObject

typedef NS_ENUM(NSInteger, LogStatus) {
    LOGSTATUS_NOTLOGGED = 0,
    LOGSTATUS_NOTFOUND,
    LOGSTATUS_FOUND,
};

@property (nonatomic, retain) NSString *wpt_name;
@property (nonatomic, retain) NSString *wpt_description;
@property (nonatomic, retain) NSString *wpt_url;
@property (nonatomic, retain) NSString *wpt_urlname;
@property (nonatomic, retain) NSString *wpt_lat;
@property (nonatomic, retain) NSString *wpt_lon;
@property (nonatomic) NSInteger wpt_lat_int;
@property (nonatomic) NSInteger wpt_lon_int;
@property (nonatomic) float wpt_lat_float;
@property (nonatomic) float wpt_lon_float;
@property (nonatomic, retain) NSString *wpt_date_placed;
@property (nonatomic) NSInteger wpt_date_placed_epoch;
@property (nonatomic) NSId wpt_symbol_id;
@property (nonatomic, retain) NSString *wpt_symbol_str;
@property (nonatomic, retain) dbSymbol *wpt_symbol;
@property (nonatomic) NSId wpt_type_id;
@property (nonatomic, retain) NSString *wpt_type_str;
@property (nonatomic, retain) dbType *wpt_type;

@property (nonatomic) LogStringLogType logstring_logtype;
@property (nonatomic) LogStatus logStatus;
@property (nonatomic) BOOL flag_highlight;
@property (nonatomic) BOOL flag_ignore;
@property (nonatomic) BOOL flag_markedfound;
@property (nonatomic) BOOL flag_inprogress;
@property (nonatomic) BOOL flag_dnf;
@property (nonatomic) NSId account_id;
@property (nonatomic, retain) dbAccount *account;
@property (nonatomic) NSId related_id;

@property (nonatomic) float gs_rating_difficulty;
@property (nonatomic) float gs_rating_terrain;
@property (nonatomic) NSInteger gs_favourites;
@property (nonatomic) NSId gs_country_id;
@property (nonatomic, retain) NSString *gs_country_str;
@property (nonatomic, retain) dbCountry *gs_country;
@property (nonatomic) NSId gs_state_id;
@property (nonatomic, retain) NSString *gs_state_str;
@property (nonatomic, retain) dbState *gs_state;
@property (nonatomic) BOOL gs_short_desc_html;
@property (nonatomic, retain) NSString *gs_short_desc;
@property (nonatomic) BOOL gs_long_desc_html;
@property (nonatomic, retain) NSString *gs_long_desc;
@property (nonatomic, retain) NSString *gs_hint;
@property (nonatomic) NSId gs_container_id;
@property (nonatomic, retain) NSString *gs_container_str;
@property (nonatomic, retain) dbContainer *gs_container;
@property (nonatomic) BOOL gs_archived;
@property (nonatomic) BOOL gs_available;
@property (nonatomic, retain) NSString *gs_placed_by;
@property (nonatomic, retain) NSString *gs_owner_str;
@property (nonatomic, retain) NSString *gs_owner_gsid;
@property (nonatomic) NSId gs_owner_id;
@property (nonatomic, retain) dbName *gs_owner;
@property (nonatomic) NSInteger gs_date_found;

@property (nonatomic) NSInteger date_lastlog_epoch;
@property (nonatomic) NSInteger date_lastimport_epoch;

@property (nonatomic) NSId gca_locale_id;
@property (nonatomic) dbLocale *gca_locale;
@property (nonatomic) NSString *gca_locale_str;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) NSInteger calculatedBearing;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (nonatomic) CLLocationCoordinate2D coordinatesUncorrected;

- (instancetype)init:(NSId)_id;
- (NSInteger)hasFieldNotes;
- (NSInteger)hasLogs;
- (NSInteger)hasAttributes;
- (NSArray<dbWaypoint *> *)hasWaypoints;
- (NSInteger)hasInventory;
- (NSInteger)hasImages;

+ (NSId)dbGetByName:(NSString *)name;
+ (void)dbCreate:(dbWaypoint *)wp;
- (void)dbUpdate;
+ (NSArray<dbWaypoint *> *)dbAll;
+ (NSArray<dbWaypoint *> *)dbAllFound;
+ (NSArray<dbWaypoint *> *)dbAllNotFound;
+ (NSArray<dbWaypoint *> *)dbAllIgnored;
+ (NSArray<dbWaypoint *> *)dbAllInGroups:(NSArray<dbGroup *> *)groups;
+ (NSArray<dbWaypoint *> *)dbAllInCountry:(NSString *)country;
+ (NSArray<dbWaypoint *> *)dbAllInCountryNotFound:(NSString *)country;
+ (dbWaypoint *)dbGet:(NSId)id;

+ (void)dbUpdateLogStatus;
- (void)dbUpdateLogStatus;
- (void)dbUpdateHighlight;
- (void)dbUpdateIgnore;
- (void)dbUpdateMarkedFound;
- (void)dbUpdateInProgress;
- (void)dbUpdateMarkedDNF;

- (NSString *)makeLocaleStateCountry;
+ (NSString *)makeName:(NSString *)suffix;
+ (NSArray<dbWaypoint *> *)waypointsWithImages;
+ (NSArray<dbWaypoint *> *)waypointsWithLogs;
+ (NSArray<dbWaypoint *> *)waypointsWithLogsUnsubmitted;
+ (NSArray<dbWaypoint *> *)waypointsWithMyLogs;
+ (NSArray<dbWaypoint *> *)dbAllByFlag:(Flag)flag;
+ (NSArray<dbWaypoint *> *)dbAllInRect:(CLLocationCoordinate2D)lt RT:(CLLocationCoordinate2D)rt;

- (BOOL)hasGSData;

@end
