//
//  ImageLibrary.h
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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
 
    ImageContainer_Virtual,
    ImageContainer_Micro,
    ImageContainer_Small,
    ImageContainer_Regular,
    ImageContainer_Large,
    ImageContainer_NotChosen,
    ImageContainer_Other,
    ImageContainer_Unknown,
    
    ImageLog_DidNotFind,
    ImageLog_Enabled,
    ImageLog_Found,
    ImageLog_NeedsArchiving,
    ImageLog_NeedsMaintenance,
    ImageLog_OwnerMaintenance,
    ImageLog_ReviewerNote,
    ImageLog_Published,
    ImageLog_Archived,
    ImageLog_Disabled,
    ImageLog_Unarchived,
    ImageLog_Coordinates,
    ImageLog_WebcamPhoto,
    ImageLog_Note,
    ImageLog_Attended,
    ImageLog_WillAttend,
    ImageLog_Unknown,
   /* Up to here: Do not reorder */

    ImageWaypointView_ratingOn,
    ImageWaypointView_ratingOff,
    ImageWaypointView_ratingHalf,
    ImageWaypointView_favourites,

    ImageIcon_Smiley,
    ImageIcon_Sad,
    ImageIcon_Target,

    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject {
    NSMutableArray *imgs;
};

- (id)init;
- (UIImage *)get:(NSInteger)imgnum;

@end
