//
//  dbObjectWaypoint.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "dbObjectWaypoint.h"

@implementation dbObjectWaypoint

@synthesize _id, wp_group_int, wp_group, name, description, url, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, rating_difficulty, rating_terrain, wp_type_int, wp_type_str, wp_type, country, state;

- (id)init:(NSInteger)__id
{
    _id = __id;
    return self;
}

@end
