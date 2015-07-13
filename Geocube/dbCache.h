//
//  dbWaypoint.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
    coordinate_type coordinates;
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
@property (nonatomic) NSInteger cache_type_int;
@property (nonatomic) NSString *cache_type_str;
@property (nonatomic, retain) dbCacheType *cache_type;
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
@property (nonatomic) coordinate_type coordinates;

- (id)init:(NSInteger)_id;
- (BOOL)hasFieldNotes;
- (NSInteger)hasLogs;
- (NSInteger)hasAttributes;
- (BOOL)hasWaypoints;
- (BOOL)hasInventory;
- (BOOL)hasImages;

@end

#endif
