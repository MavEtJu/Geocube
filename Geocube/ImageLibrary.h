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

    /* Do not reorder, index matches schema.sql */
    ImageCaches_Benchmark,
    ImageCaches_CITO,
    ImageCaches_EarthCache,
    ImageCaches_Event,
    ImageCaches_Giga,
    ImageCaches_GroundspeakHQ,
    ImageCaches_Letterbox,
    ImageCaches_Maze,
    ImageCaches_Mega,
    ImageCaches_MultiCache,
    ImageCaches_Mystery,
    ImageCaches_Other,
    ImageCaches_TraditionalCache,
    ImageCaches_UnknownCache,
    ImageCaches_VirtualCache,
    ImageCaches_Waymark,
    ImageCaches_WebcamCache,
    ImageCaches_WhereigoCache,

    ImageWaypoints_FinalLocation,
    ImageWaypoints_Flag,
    ImageWaypoints_MultiStage,
    ImageWaypoints_ParkingArea,
    ImageWaypoints_PhysicalStage,
    ImageWaypoints_ReferenceStage,
    ImageWaypoints_Trailhead,
    ImageWaypoints_VirtualStage,
    
    ImageCaches_NFI,
    Imagewaypoints_NFI,
    ImageNFI,
    /* Up to here: Do not reorder */

    ImageWaypointView_ratingOn,
    ImageWaypointView_ratingOff,
    ImageWaypointView_ratingHalf,
    ImageWaypointView_favourites,
    
    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject {
    NSMutableArray *imgs;
};

- (id)init;
- (UIImage *)get:(NSInteger)imgnum;

@end
