//
//  ImageLibrary.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

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
    
    ADD(@"cache - benchmark - 30x30", ImageCaches_Benchmark);
    ADD(@"cache - cito - 30x30", ImageCaches_CITO);
    ADD(@"cache - earth - 30x30", ImageCaches_EarthCache);
    ADD(@"cache - event - 30x30", ImageCaches_Event);
    ADD(@"cache - giga - 30x30", ImageCaches_Giga);
    ADD(@"cache - groundspeak hq - 30x30", ImageCaches_GroundspeakHQ);
    ADD(@"cache - letterbox - 30x30", ImageCaches_Letterbox);
    ADD(@"cache - maze - 30x30", ImageCaches_Maze);
    ADD(@"cache - mega - 30x30", ImageCaches_Mega);
    ADD(@"cache - multi - 30x30", ImageCaches_MultiCache);
    ADD(@"cache - mystery - 30x30", ImageCaches_Mystery);
    ADD(@"cache - unknown - 30x30", ImageCaches_Other);
    ADD(@"cache - traditional - 30x30", ImageCaches_TraditionalCache);
    ADD(@"cache - unknown - 30x30", ImageCaches_UnknownCache);
    ADD(@"cache - virtual - 30x30", ImageCaches_VirtualCache);
    ADD(@"cache - waymark - 30x30", ImageCaches_Waymark);
    ADD(@"cache - webcam - 30x30", ImageCaches_WebcamCache);
    ADD(@"cache - whereigo - 30x30", ImageCaches_WhereigoCache);
    
    ADD(@"waypoint - finish - 30x30", ImageWaypoints_FinalLocation);
    ADD(@"waypoint - flag - 30x30", ImageWaypoints_Flag);
    ADD(@"waypoint - multi - 30x30", ImageWaypoints_MultiStage);
    ADD(@"waypoint - parking - 30x30", ImageWaypoints_ParkingArea);
    ADD(@"waypoint - flag - 30x30", ImageWaypoints_PhysicalStage);
    ADD(@"waypoint - flag - 30x30", ImageWaypoints_ReferenceStage);
    //ADD(@"waypoint - question - 30x30", ImageWaypoints_QuestionStage);
    ADD(@"waypoint - trailhead - 30x30", ImageWaypoints_Trailhead);
    ADD(@"waypoint - trailhead - 30x30", ImageWaypoints_VirtualStage);

    ADD(@"cache - unknown - 30x30", ImageCaches_NFI);
    ADD(@"waypoint - unknown - 30x30", Imagewaypoints_NFI);
    ADD(@"cache - unknown - 30x30", ImageNFI);

    ADD(@"log - archived - 30x30", ImageLog_Archived);
    ADD(@"log - attended - 30x30", ImageLog_Attended);
    ADD(@"log - coordinates - 30x30", ImageLog_Coordinates);
    ADD(@"log - didnotfind - 30x30", ImageLog_DidNotFind);
    ADD(@"log - disabled - 18x18", ImageLog_Disabled);
    ADD(@"log - enabled - 30x30", ImageLog_Enabled);
    ADD(@"log - found - 30x30", ImageLog_Found);
    ADD(@"log - needsarchiving - 30x30", ImageLog_NeedsArchiving);
    ADD(@"log - needsmaintenance - 30x30", ImageLog_NeedsMaintenance);
    ADD(@"log - note - 30x30", ImageLog_Note);
    ADD(@"log - ownermaintenance - 30x30", ImageLog_OwnerMaintenance);
    ADD(@"log - published - 30x30", ImageLog_Published);
    ADD(@"log - reviewernote - 30x30", ImageLog_ReviewerNote);
    ADD(@"log - unarchived - 30x30", ImageLog_Unarchived);
    ADD(@"log - unknown - 30x30", ImageLog_Unknown);
    ADD(@"log - willattend - 30x30", ImageLog_WillAttend);

    ADD(@"waypoint rating star on 19x18", ImageWaypointView_ratingOn);
    ADD(@"waypoint rating star off 18x18", ImageWaypointView_ratingOff);
    ADD(@"waypoint rating star half 18x18", ImageWaypointView_ratingHalf);
    ADD(@"waypoint favourites 20x30", ImageWaypointView_favourites);
    
    ADD(@"icons - smiley - 30x30", ImageIcon_Smiley);
    ADD(@"icons - sad - 30x30", ImageIcon_Sad);
    ADD(@"icons - target - 20x20", ImageIcon_Target);

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
