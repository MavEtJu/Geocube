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

@interface dbObjectWaypoint : NSObject {
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
    
    NSInteger wp_type_int;
    NSString *wp_type_str;
    dbObjectWaypointType *wp_type;
}

@property NSInteger _id;
@property NSInteger wp_group_int;
@property dbObjectWaypointGroup *wp_group;
@property NSString *name;
@property NSString *description;
@property NSString *url;
@property NSString *lat;
@property NSString *lon;
@property NSInteger lat_int;
@property NSInteger lon_int;
@property float lat_float;
@property float lon_float;
@property NSString *date_placed;
@property NSInteger date_placed_epoch;
@property float rating_difficulty;
@property float rating_terrain;
@property NSInteger wp_type_int;
@property NSString *wp_type_str;
@property dbObjectWaypointType *wp_type;

- (id)init:(NSInteger)_id;

@end

#endif
