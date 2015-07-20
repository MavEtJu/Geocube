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

#ifndef Geocube_dbWaypoint_h
#define Geocube_dbWaypoint_h

@interface dbCache : dbObject {
    NSInteger _id;
    NSString *name, *description, *url;

    NSString *lat, *lon;
    NSInteger lat_int, lon_int;
    float lat_float, lon_float;

    NSString *date_placed;
    NSInteger date_placed_epoch;

    float gc_rating_difficulty, gc_rating_terrain;
    NSInteger gc_favourites;

    dbCacheSymbol *cache_symbol;
    NSInteger cache_symbol_int;
    NSString *cache_symbol_str;

    NSInteger cache_type_int;
    NSString *cache_type_str;
    dbCacheType *cache_type;

    BOOL gc_archived, gc_available;
    NSString *gc_country, *gc_state;

    BOOL gc_short_desc_html, gc_long_desc_html;
    NSString *gc_short_desc, *gc_long_desc;
    NSString *gc_hint, *gc_personal_note;

    NSInteger gc_containerSize_int;
    NSString *gc_containerSize_str;
    dbContainerSize *gc_containerSize;

    /* Not read from the database */
    CLLocationCoordinate2D coordinates;
    NSInteger calculatedDistance;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *lat;
@property (nonatomic, retain) NSString *lon;
@property (nonatomic) NSInteger lat_int;
@property (nonatomic) NSInteger lon_int;
@property (nonatomic) float lat_float;
@property (nonatomic) float lon_float;
@property (nonatomic, retain) NSString *date_placed;
@property (nonatomic) NSInteger date_placed_epoch;
@property (nonatomic) float gc_rating_difficulty;
@property (nonatomic) float gc_rating_terrain;
@property (nonatomic) NSInteger gc_favourites;
@property (nonatomic) dbCacheSymbol *cache_symbol;
@property (nonatomic) NSInteger cache_symbol_int;
@property (nonatomic) NSString *cache_symbol_str;
@property (nonatomic, retain) dbCacheType *cache_type;
@property (nonatomic) NSInteger cache_type_int;
@property (nonatomic) NSString *cache_type_str;
@property (nonatomic, retain) NSString *gc_country;
@property (nonatomic, retain) NSString *gc_state;
@property (nonatomic) BOOL gc_short_desc_html;
@property (nonatomic, retain) NSString *gc_short_desc;
@property (nonatomic) BOOL gc_long_desc_html;
@property (nonatomic, retain) NSString *gc_long_desc;
@property (nonatomic, retain) NSString *gc_hint;
@property (nonatomic, retain) NSString *gc_personal_note;
@property (nonatomic) NSInteger gc_containerSize_int;
@property (nonatomic) NSString *gc_containerSize_str;
@property (nonatomic, retain) dbContainerSize *gc_containerSize;
@property (nonatomic) BOOL gc_archived;
@property (nonatomic) BOOL gc_available;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) CLLocationCoordinate2D coordinates;

- (id)init:(NSInteger)_id;
- (BOOL)hasFieldNotes;
- (NSInteger)hasLogs;
- (NSInteger)hasAttributes;
- (BOOL)hasWaypoints;
- (BOOL)hasInventory;
- (BOOL)hasImages;

+ (NSInteger)dbGetByName:(NSString *)name;
+ (NSInteger)dbCreate:(dbCache *)wp;
- (void)dbUpdate;
+ (NSArray *)dbAll;
+ (dbCache *)dbGet:(NSInteger)id;

@end

#endif
