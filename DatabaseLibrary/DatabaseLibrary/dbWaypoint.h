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

#import <CoreLocation/CoreLocation.h>

#import "dbObject.h"

#import "dbWaypoint-enum.h"
#import "dbLogString-enum.h"
#import "dbListData-enum.h"

@class dbSymbol;
@class dbType;
@class dbCountry;
@class dbState;
@class dbGroup;
@class dbName;
@class dbLocality;
@class dbContainer;
@class dbAccount;

@interface dbWaypoint : dbObject

@property (nonatomic, retain) NSString *wpt_name;
@property (nonatomic, retain) NSString *wpt_description;
@property (nonatomic, retain) NSString *wpt_url;
@property (nonatomic, retain) NSString *wpt_urlname;
@property (nonatomic) CLLocationDegrees wpt_latitude;
@property (nonatomic) CLLocationDegrees wpt_longitude;
@property (nonatomic) NSInteger wpt_date_placed_epoch;
@property (nonatomic, retain) dbSymbol *wpt_symbol;
@property (nonatomic, retain) dbType *wpt_type;

@property (nonatomic) LogStringWPType logstring_wptype;
@property (nonatomic) LogStatus logStatus;
@property (nonatomic) BOOL flag_highlight;
@property (nonatomic) BOOL flag_ignore;
@property (nonatomic) BOOL flag_markedfound;
@property (nonatomic) BOOL flag_inprogress;
@property (nonatomic) BOOL flag_dnf;
@property (nonatomic) BOOL flag_planned;
@property (nonatomic, retain) dbAccount *account;

@property (nonatomic) float gs_rating_difficulty;
@property (nonatomic) float gs_rating_terrain;
@property (nonatomic) NSInteger gs_favourites;
@property (nonatomic, retain) dbCountry *gs_country;
@property (nonatomic, retain) dbState *gs_state;
@property (nonatomic) BOOL gs_short_desc_html;
@property (nonatomic, retain) NSString *gs_short_desc;
@property (nonatomic) BOOL gs_long_desc_html;
@property (nonatomic, retain) NSString *gs_long_desc;
@property (nonatomic, retain) NSString *gs_hint;
@property (nonatomic, retain) dbContainer *gs_container;
@property (nonatomic) BOOL gs_archived;
@property (nonatomic) BOOL gs_available;
@property (nonatomic, retain) NSString *gs_placed_by;
@property (nonatomic, retain) NSString *gs_owner_gsid;
@property (nonatomic, retain) dbName *gs_owner;
@property (nonatomic) NSInteger gs_date_found;

@property (nonatomic) NSInteger date_lastlog_epoch;
@property (nonatomic) NSInteger date_lastimport_epoch;

@property (nonatomic) dbLocality *gca_locality;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) NSInteger calculatedBearing;

- (void)set_gs_country_str:(NSString *)s;
- (void)set_gs_state_str:(NSString *)s;
- (void)set_gca_locality_str:(NSString *)s;
- (void)set_gs_container_str:(NSString *)s;
- (void)set_gs_owner_str:(NSString *)s;
- (void)set_wpt_symbol_str:(NSString *)s;
- (void)set_wpt_type_str:(NSString *)s;
- (void)set_wpt_lat_str:(NSString *)s;
- (void)set_wpt_lon_str:(NSString *)s;
- (void)set_wpt_date_placed:(NSString *)s;

- (NSInteger)hasFieldNotes;
- (NSInteger)hasLogs;
- (NSInteger)hasAttributes;
- (NSArray<dbWaypoint *> *)hasWaypoints;
- (NSInteger)hasInventory;
- (NSInteger)hasImages;

+ (dbWaypoint *)dbGetByName:(NSString *)name;
- (void)dbUpdate;
+ (NSArray<dbWaypoint *> *)dbAll;
+ (NSArray<dbWaypoint *> *)dbAllFound;
+ (NSArray<dbWaypoint *> *)dbAllNotFound;
+ (NSArray<dbWaypoint *> *)dbAllIgnored;
+ (NSArray<dbWaypoint *> *)dbAllLocationless;
+ (NSArray<dbWaypoint *> *)dbAllLocationlessNotFound;
+ (NSArray<dbWaypoint *> *)dbAllLocationlessPlanned;
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
- (void)dbUpdatePlanned;
- (void)dbUpdateCountryStateLocality;

- (NSString *)makeLocalityStateCountry;
+ (NSString *)makeName:(NSString *)suffix;
+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithImages;
+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithLogs;
+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithLogsUnsubmitted;
+ (NSArray<dbWaypoint *> *)dbAllWaypointsWithMyLogs;
+ (NSArray<dbWaypoint *> *)dbAllByFlag:(Flag)flag;
+ (NSArray<dbWaypoint *> *)dbAllInRect:(CLLocationCoordinate2D)lt RT:(CLLocationCoordinate2D)rt;

- (BOOL)hasGSData;

@end
