//
//  MapViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 17/11/2015.
//  Copyright © 2015 Edwin Groothuis. All rights reserved.
//

@interface MapViewController : GCViewController <LocationManagerDelegate, CacheFilterManagerDelegate>

enum {
    SHOW_ONECACHE = 1,
    SHOW_ALLCACHES,

    SHOW_NEITHER = 10,
    SHOW_CACHE,
    SHOW_ME,
    SHOW_BOTH,

    MAPTYPE_NORMAL = 20,
    MAPTYPE_SATELLITE,
    MAPTYPE_HYBRID,
    MAPTYPE_TERRAIN,

    MAPBRAND_GOOGLEMAPS = 30,
    MAPBRAND_APPLEMAPS,
    MAPBRAND_OPENSTREETMAPS,
};

@property (nonatomic, retain) NSArray *waypointsArray;

- (instancetype)init:(NSInteger)maptype;
- (void)userInteraction;
- (void)refreshWaypointsData;
- (void)refreshWaypointsData:(NSString *)searchString;

@end