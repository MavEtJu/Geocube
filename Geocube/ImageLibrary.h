//
//  ImageLibrary.h
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKIt.h"

typedef enum {
    ImageLibraryImagesMin = -1,
    
    ImageWaypointView_ratingOn,
    ImageWaypointView_ratingOff,
    ImageWaypointView_ratingHalf,
    ImageWaypointView_favourites,
    
    ImageWaypoints_Finish,
    ImageWaypoints_Flag,
    ImageWaypoints_Multi,
    ImageWaypoints_Parking,
    ImageWaypoints_Question,
    ImageWaypoints_Trailhead,
    ImageWaypoints_Unknown,
    
    ImageCaches_Benchmark,
    ImageCaches_Cito,
    ImageCaches_Earth,
    ImageCaches_Event,
    ImageCaches_GroundspeakHQ,
    ImageCaches_Letterbox,
    ImageCaches_Maze,
    ImageCaches_Mega,
    ImageCaches_Multi,
    ImageCaches_Mystery,
    ImageCaches_Traditional,
    ImageCaches_Unknown,
    ImageCaches_Virtual,
    ImageCaches_Waymark,
    ImageCaches_Webcam,
    ImageCaches_Whereigo,

    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject {
    NSMutableArray *imgs;
};

- (id)init;
- (UIImage *)get:(NSInteger)imgnum;

@end
