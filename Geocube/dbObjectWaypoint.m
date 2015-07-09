//
//  dbObjectWaypoint.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbObjectWaypoint

@synthesize _id, wp_group_int, wp_group, name, description, url, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, rating_difficulty, rating_terrain, favourites, wp_type_int, wp_type_str, wp_type, country, state, calculatedDistance, coordinates;

- (id)init:(NSInteger)__id
{
    self = [super init];
    _id = __id;
    return self;
}

- (void)finish
{
    // Conversions from the data retrieved
    lat_float = [lat floatValue];
    lon_float = [lon floatValue];
    lat_int = lat_float * 1000000;
    lon_int = lon_float * 1000000;
    wp_type = [dbc waypointType_get:wp_type_int];
    
    coordinates = MKCoordinates([lat floatValue], [lon floatValue]);

    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", name, description];
}

@end
