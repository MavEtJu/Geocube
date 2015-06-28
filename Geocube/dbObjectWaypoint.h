//
//  dbObjectWaypoint.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbObjectWaypointType.h"

@interface dbObjectWaypoint : NSObject {
    NSInteger _id;
    NSString *name, *description, *url;

    NSString *lat, *lon;
    NSInteger lat_int, lon_int;
    
    NSString *date_placed;
    NSInteger date_placed_epoch;

    NSInteger wp_type_int;
    dbObjectWaypointType *wp_type;
}

@property NSInteger _id;
@property NSString *name;
@property NSString *description;
@property NSString *url;
@property NSString *lat;
@property NSString *lon;
@property NSInteger lat_int;
@property NSInteger lon_int;
@property NSString *date_placed;
@property NSInteger date_placed_epoch;
@property NSInteger wp_type_int;
@property dbObjectWaypointType *wp_type;

- (id)init:(NSInteger)_id;

@end
