//
//  dbWaypoint.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbWaypoint_h
#define Geocube_dbWaypoint_h

@interface dbWaypoint : dbObject {
    NSInteger _id;
    NSInteger wp_group_int;
    dbWaypointGroup *wp_group;
    NSString *name, *description, *url;

    NSString *lat, *lon;
    NSInteger lat_int, lon_int;
    float lat_float, lon_float;
    
    NSString *date_placed;
    NSInteger date_placed_epoch;

    float rating_difficulty, rating_terrain;
    NSInteger favourites;
    
    NSInteger wp_type_int;
    NSString *wp_type_str;
    dbWaypointType *wp_type;
    
    NSString *country, *state;
    
    NSString *gc_short_desc, *gc_long_desc;
    NSString *gc_hint, *gc_personal_note;
    
    /* Not read from the database */
    coordinate_type coordinates;
    NSInteger calculatedDistance;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger wp_group_int;
@property (nonatomic, retain) dbWaypointGroup *wp_group;
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
@property (nonatomic) float rating_difficulty;
@property (nonatomic) float rating_terrain;
@property (nonatomic) NSInteger favourites;
@property (nonatomic) NSInteger wp_type_int;
@property (nonatomic) NSString *wp_type_str;
@property (nonatomic, retain) dbWaypointType *wp_type;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSString *gc_short_desc;
@property (nonatomic, retain) NSString *gc_long_desc;
@property (nonatomic, retain) NSString *gc_hint;
@property (nonatomic, retain) NSString *gc_personal_note;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) coordinate_type coordinates;

- (id)init:(NSInteger)_id;
- (BOOL)hasFieldNotes;
- (BOOL)hasLogs;
- (BOOL)hasAttributes;
- (BOOL)hasWaypoints;
- (BOOL)hasInventory;
- (BOOL)hasImages;
- (BOOL)hasGroups;

@end

#endif
