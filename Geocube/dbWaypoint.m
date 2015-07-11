//
//  dbWaypoint.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbWaypoint

@synthesize _id, name, description, url, lat, lon, lat_int, lon_int, lat_float, lon_float, date_placed, date_placed_epoch, gc_rating_difficulty, gc_rating_terrain, gc_favourites, wp_type_int, wp_type_str, wp_type, gc_country, gc_state, gc_short_desc_html, gc_short_desc, gc_long_desc_html, gc_long_desc, gc_hint, gc_personal_note, calculatedDistance, coordinates, gc_containerSize, gc_containerSize_str, gc_containerSize_int;

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
    wp_type = [dbc WaypointType_get:wp_type_int];
    
    date_placed_epoch = [MyTools secondsSinceEpoch:date_placed];

    coordinates = MKCoordinates([lat floatValue], [lon floatValue]);
    
    // Adjust container size
    if (gc_containerSize == nil) {
        if (gc_containerSize_int != 0) {
            gc_containerSize = [dbc ContainerSize_get:gc_containerSize_int];
            gc_containerSize_str = gc_containerSize.size;
        }
        if (gc_containerSize_str != nil) {
            gc_containerSize = [dbc ContainerSize_get_bysize:gc_containerSize_str];
            gc_containerSize_int = gc_containerSize._id;
        }
    }
    
    // Adjust waypoint types
    if (wp_type == nil) {
        if (wp_type_int != 0) {
            wp_type = [dbc WaypointType_get:wp_type_int];
            wp_type_str = wp_type.type;
        }
        if (wp_type_str != nil) {
            wp_type = [dbc WaypointType_get_byname:wp_type_str];
            wp_type_int = wp_type._id;
        }
    }
    
    [super finish];
}

- (NSInteger)hasLogs {
    return [db Logs_count_byWaypoint_id:_id];
}

- (BOOL)hasFieldNotes { return NO; }
- (BOOL)hasAttributes { return NO; }
- (BOOL)hasWaypoints { return NO; }
- (BOOL)hasInventory { return NO; }
- (BOOL)hasImages { return NO; }

@end
