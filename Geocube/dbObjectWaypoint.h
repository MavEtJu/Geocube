//
//  dbObjectWaypoint.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbObjectWaypoint_h
#define Geocube_dbObjectWaypoint_h

#import <Foundation/Foundation.h>
#import "dbObjects.h"
#import "My Tools.h"

@interface dbObjectWaypoint : dbObject {
    NSInteger _id;
    NSInteger wp_group_int;
    dbObjectWaypointGroup *wp_group;
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
    dbObjectWaypointType *wp_type;
    
    NSString *country;
    NSString *state;
    
    /* Not read from the database */
    coordinate_type coordinates;
    NSInteger calculatedDistance;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger wp_group_int;
@property (nonatomic, retain) dbObjectWaypointGroup *wp_group;
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
@property (nonatomic, retain) dbObjectWaypointType *wp_type;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *state;

@property (nonatomic) NSInteger calculatedDistance;
@property (nonatomic) coordinate_type coordinates;

- (id)init:(NSInteger)_id;

@end

#endif
