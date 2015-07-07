//
//  ImageLibrary.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "ImageLibrary.h"
#import "My Tools.h"

@implementation ImageLibrary

- (id)init
{
    self = [super init];
    imgs = [NSMutableArray arrayWithCapacity:ImageLibraryImagesMax];
    
#define ADD(__s__, __idx__) \
    { \
        NSString *s = [NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], __s__]; \
        UIImage *img = [UIImage imageNamed:s]; \
        if (img == nil) { \
            NSLog(@"ImageLibrary: Image %@ not found", s); \
        } else { \
            [imgs insertObject:img atIndex:__idx__]; \
        } \
    }
    
    ADD(@"waypoint rating star on 19x18", ImageWaypointView_ratingOn);
    ADD(@"waypoint rating star off 18x18", ImageWaypointView_ratingOff);
    ADD(@"waypoint rating star half 18x18", ImageWaypointView_ratingHalf);
    ADD(@"waypoint favourites 20x30", ImageWaypointView_favourites);

    ADD(@"waypoint - finish - 30x30", ImageWaypoints_Finish);
    ADD(@"waypoint - flag - 30x30", ImageWaypoints_Flag);
    ADD(@"waypoint - multi - 30x30", ImageWaypoints_Multi);
    ADD(@"waypoint - parking - 30x30", ImageWaypoints_Parking);
    ADD(@"waypoint - question - 30x30", ImageWaypoints_Question);
    ADD(@"waypoint - trailhead - 30x30", ImageWaypoints_Trailhead);
    ADD(@"waypoint - unknown - 30x30", ImageWaypoints_Unknown);

    ADD(@"cache - benchmark - 30x30", ImageCaches_Benchmark);
    ADD(@"cache - cito - 30x30", ImageCaches_Cito);
    ADD(@"cache - earth - 30x30", ImageCaches_Earth);
    ADD(@"cache - event - 30x30", ImageCaches_Event);
    ADD(@"cache - groundspeak hq - 30x30", ImageCaches_GroundspeakHQ);
    ADD(@"cache - letterbox - 30x30", ImageCaches_Letterbox);
    ADD(@"cache - maze - 30x30", ImageCaches_Maze);
    ADD(@"cache - mega - 30x30", ImageCaches_Mega);
    ADD(@"cache - multi - 30x30", ImageCaches_Multi);
    ADD(@"cache - mystery - 30x30", ImageCaches_Mystery);
    ADD(@"cache - traditional - 30x30", ImageCaches_Traditional);
    ADD(@"cache - unknown - 30x30", ImageCaches_Unknown);
    ADD(@"cache - virtual - 30x30", ImageCaches_Virtual);
    ADD(@"cache - waymark - 30x30", ImageCaches_Waymark);
    ADD(@"cache - webcam - 30x30", ImageCaches_Webcam);
    ADD(@"cache - whereigo - 30x30", ImageCaches_Whereigo);
    
    return self;
}

- (UIImage *)get:(NSInteger)imgnum
{
    UIImage *img = [imgs objectAtIndex:imgnum];
    if (img == nil)
        NSLog(@"ImageLibrary: imgnum %ld not found", imgnum);
    return img;
}

@end
