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
    NSLog(@"ImageLibrary: %d elements", ImageLibraryImagesMax);
    
#define ADD(__s__, __idx__) \
    { \
        NSString *s = [NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], __s__]; \
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:s]; \
        if (img == nil) { \
            NSLog(@"ImageLibrary: Image %@ not found", s); \
        } else { \
            imgs[__idx__] = img; \
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
    
    ADD(@"container - other - 70x20", ImageContainer_Virtual);
    ADD(@"container - micro - 70x20", ImageContainer_Micro);
    ADD(@"container - small - 70x20", ImageContainer_Small);
    ADD(@"container - regular - 70x20", ImageContainer_Regular);
    ADD(@"container - large - 70x20", ImageContainer_Large);
    ADD(@"container - notchosen - 70x20", ImageContainer_NotChosen);
    ADD(@"container - other - 70x20", ImageContainer_Other);
    ADD(@"container - unknown - 70x20", ImageContainer_Unknown);
    
    ADD(@"log - didnotfind - 30x30", ImageLog_DidNotFind);
    ADD(@"log - enabled - 30x30", ImageLog_Enabled);
    ADD(@"log - found - 30x30", ImageLog_Found);
    ADD(@"log - needsarchiving - 30x30", ImageLog_NeedsArchiving);
    ADD(@"log - needsmaintenance - 30x30", ImageLog_NeedsMaintenance);
    ADD(@"log - ownermaintenance - 30x30", ImageLog_OwnerMaintenance);
    ADD(@"log - reviewernote - 30x30", ImageLog_ReviewerNote);
    ADD(@"log - published - 30x30", ImageLog_Published);
    ADD(@"log - archived - 30x30", ImageLog_Archived);
    ADD(@"log - disabled - 18x18", ImageLog_Disabled);
    ADD(@"log - unarchived - 30x30", ImageLog_Unarchived);
    ADD(@"log - coordinates - 30x30", ImageLog_Coordinates);
    ADD(@"log - unknown - 30x30", ImageLog_WebcamPhoto);
    ADD(@"log - note - 30x30", ImageLog_Note);
    ADD(@"log - attended - 30x30", ImageLog_Attended);
    ADD(@"log - willattend - 30x30", ImageLog_WillAttend);
    ADD(@"log - unknown - 30x30", ImageLog_Unknown);
    
    ADD(@"container - large - 70x20", ImageSize_Large);
    ADD(@"container - micro - 70x20", ImageSize_Micro);
    ADD(@"container - notchosen - 70x20", ImageSize_NotChosen);
    ADD(@"container - other - 70x20", ImageSize_Other);
    ADD(@"container - regular - 70x20", ImageSize_Regular);
    ADD(@"container - small - 70x20", ImageSize_Small);
    ADD(@"container - unknown - 70x20", ImageSize_Virtual);

    ADD(@"waypoint rating star on 19x18", ImageCacheView_ratingOn);
    ADD(@"waypoint rating star off 18x18", ImageCacheView_ratingOff);
    ADD(@"waypoint rating star half 18x18", ImageCacheView_ratingHalf);
    ADD(@"waypoint favourites 20x30", ImageCacheView_favourites);
    
    ADD(@"map - pin stick - 35x42", ImageMap_pin);
    ADD(@"map - dnf stick - 35x42", ImageMap_dnf);
    ADD(@"map - found stick - 35x42", ImageMap_found);
    ADD(@"map - pinhead black - 15x15", ImageMap_pinheadBlack);
    ADD(@"map - pinhead green - 15x15", ImageMap_pinheadGreen);
    ADD(@"map - pinhead pink - 15x15", ImageMap_pinheadPink);
    ADD(@"map - pinhead purple - 15x15", ImageMap_pinheadPurple);
    ADD(@"map - pinhead red - 15x15", ImageMap_pinheadRed);
    ADD(@"map - pinhead white - 15x15", ImageMap_pinheadWhite);
    ADD(@"map - pinhead yellow - 15x15", ImageMap_pinheadYellow);
    
    ADD(@"map - cross dnf - 19x19", ImageMap_crossDNF);
    ADD(@"map - tick found - 24x21", ImageMap_tickFound);

#define MERGE_PINHEAD(__i1__, __i2__, __idx__) {\
    UIImage *out = [self addImageToImage:[self get:__i1__] withImage2:[self get:__i2__] andRect:CGRectMake(3, 3, 15, 15)]; \
    imgs[__idx__] = out; \
    }
    
#define MERGE_DNF(__i1__, __i2__, __idx__) {\
    UIImage *out = [self addImageToImage:[self get:__i1__] withImage2:[self get:__i2__] andRect:CGRectMake(1, 1, 16, 16)]; \
    imgs[__idx__] = out; \
    }

#define MERGE_FOUND(__i1__, __i2__, __idx__) {\
    UIImage *out = [self addImageToImage:[self get:__i1__] withImage2:[self get:__i2__] andRect:CGRectMake(1, -4, 24, 21)]; \
    imgs[__idx__] = out; \
    }

    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadBlack, ImageMap_pinBlack);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadGreen, ImageMap_pinGreen);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadPink, ImageMap_pinPink);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadPurple, ImageMap_pinPurple);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadRed, ImageMap_pinRed);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadWhite, ImageMap_pinWhite);
    MERGE_PINHEAD(ImageMap_pin, ImageMap_pinheadYellow, ImageMap_pinYellow);

    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadBlack, ImageMap_foundBlack);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadGreen, ImageMap_foundGreen);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadPink, ImageMap_foundPink);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadPurple, ImageMap_foundPurple);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadRed, ImageMap_foundRed);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadWhite, ImageMap_foundWhite);
    MERGE_PINHEAD(ImageMap_found, ImageMap_pinheadYellow, ImageMap_foundYellow);
    MERGE_FOUND(ImageMap_foundBlack, ImageMap_tickFound, ImageMap_foundBlack);
    MERGE_FOUND(ImageMap_foundGreen, ImageMap_tickFound, ImageMap_foundGreen);
    MERGE_FOUND(ImageMap_foundPink, ImageMap_tickFound, ImageMap_foundPink);
    MERGE_FOUND(ImageMap_foundPurple, ImageMap_tickFound, ImageMap_foundPurple);
    MERGE_FOUND(ImageMap_foundRed, ImageMap_tickFound, ImageMap_foundRed);
    MERGE_FOUND(ImageMap_foundWhite, ImageMap_tickFound, ImageMap_foundWhite);
    MERGE_FOUND(ImageMap_foundYellow, ImageMap_tickFound, ImageMap_foundYellow);

    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadBlack, ImageMap_dnfBlack);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadGreen, ImageMap_dnfGreen);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadPink, ImageMap_dnfPink);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadPurple, ImageMap_dnfPurple);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadRed, ImageMap_dnfRed);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadWhite, ImageMap_dnfWhite);
    MERGE_PINHEAD(ImageMap_dnf, ImageMap_pinheadYellow, ImageMap_dnfYellow);
    MERGE_DNF(ImageMap_dnfBlack, ImageMap_crossDNF, ImageMap_dnfBlack);
    MERGE_DNF(ImageMap_dnfGreen, ImageMap_crossDNF, ImageMap_dnfGreen);
    MERGE_DNF(ImageMap_dnfPink, ImageMap_crossDNF, ImageMap_dnfPink);
    MERGE_DNF(ImageMap_dnfPurple, ImageMap_crossDNF, ImageMap_dnfPurple);
    MERGE_DNF(ImageMap_dnfRed, ImageMap_crossDNF, ImageMap_dnfRed);
    MERGE_DNF(ImageMap_dnfWhite, ImageMap_crossDNF, ImageMap_dnfWhite);
    MERGE_DNF(ImageMap_dnfYellow, ImageMap_crossDNF, ImageMap_dnfYellow);

    ADD(@"icons - smiley - 30x30", ImageIcon_Smiley);
    ADD(@"icons - sad - 30x30", ImageIcon_Sad);
    ADD(@"icons - target - 20x20", ImageIcon_Target);

    return self;
}

- (UIImage *)addImageToImage:(UIImage *)img1 withImage2:(UIImage *)img2 andRect:(CGRect)cropRect
{
    CGSize size = img1.size;
    UIGraphicsBeginImageContext(size);
    
    CGPoint pointImg1 = CGPointMake(0, 0);
    [img1 drawAtPoint:pointImg1];
    
    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint: pointImg2];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)get:(NSInteger)imgnum
{
    UIImage *img = imgs[imgnum];
    if (img == nil)
        NSLog(@"ImageLibrary: imgnum %ld not found", imgnum);
    return img;
}

@end
