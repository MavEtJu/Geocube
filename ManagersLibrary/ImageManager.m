/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

@interface ImageManager ()
{
    UIImage *imgs[ImageLibraryImagesMax];
    NSString *names[ImageLibraryImagesMax];
    NSMutableDictionary *pinImages, *typeImages;
};

@end

@implementation ImageManager

- (instancetype)init
{
    self = [super init];
    NSLog(@"ImageLibrary: %ld elements", (long)ImageLibraryImagesMax);

    [self addToLibrary:@"image - nil - 1x1" index:Image_Nil];

    [self addToLibrary:@"cache - benchmark - 30x30" index:ImageTypes_Benchmark];
    [self addToLibrary:@"cache - cito - 30x30" index:ImageTypes_CITO];
    [self addToLibrary:@"cache - earth - 30x30" index:ImageTypes_EarthCache];
    [self addToLibrary:@"cache - event - 30x30" index:ImageTypes_Event];
    [self addToLibrary:@"cache - giga - 30x30" index:ImageTypes_Giga];
    [self addToLibrary:@"cache - groundspeak hq - 30x30" index:ImageTypes_GroundspeakHQ];
    [self addToLibrary:@"cache - letterbox - 30x30" index:ImageTypes_Letterbox];
    [self addToLibrary:@"cache - maze - 30x30" index:ImageTypes_Maze];
    [self addToLibrary:@"cache - mega - 30x30" index:ImageTypes_Mega];
    [self addToLibrary:@"cache - multi - 30x30" index:ImageTypes_MultiCache];
    [self addToLibrary:@"cache - mystery - 30x30" index:ImageTypes_Mystery];
    [self addToLibrary:@"cache - unknown - 30x30" index:ImageTypes_Other];
    [self addToLibrary:@"cache - traditional - 30x30" index:ImageTypes_TraditionalCache];
    [self addToLibrary:@"cache - unknown - 30x30" index:ImageTypes_UnknownCache];
    [self addToLibrary:@"cache - virtual - 30x30" index:ImageTypes_VirtualCache];
    [self addToLibrary:@"cache - waymark - 30x30" index:ImageTypes_Waymark];
    [self addToLibrary:@"cache - webcam - 30x30" index:ImageTypes_WebcamCache];
    [self addToLibrary:@"cache - whereigo - 30x30" index:ImageTypes_WhereigoCache];
    [self addToLibrary:@"cache - moveable - 30x30" index:ImageTypes_Moveable];
    [self addToLibrary:@"cache - trigpoint - 30x30" index:ImageTypes_Trigpoint];
    [self addToLibrary:@"cache - history - 30x30" index:ImageTypes_History];
    [self addToLibrary:@"cache - podcast - 30x30" index:ImageTypes_Podcast];
    [self addToLibrary:@"cache - beacon - 30x30" index:ImageTypes_Beacon];
    [self addToLibrary:@"cache - burke-wills - 30x30" index:ImageTypes_BurkeWills];
    [self addToLibrary:@"cache - night - 30x30" index:ImageTypes_Night];
    [self addToLibrary:@"cache - reverse - 30x30" index:ImageTypes_Reverse];
    [self addToLibrary:@"cache - gadget - 30x30" index:ImageTypes_Gadget];
    [self addToLibrary:@"cache - geocacher - 30x30" index:ImageTypes_Geocacher];

    [self addToLibrary:@"waypoint - finish - 30x30" index:ImageWaypoints_FinalLocation];
    [self addToLibrary:@"waypoint - flag - 30x30" index:ImageWaypoints_Flag];
    [self addToLibrary:@"waypoint - multi - 30x30" index:ImageWaypoints_MultiStage];
    [self addToLibrary:@"waypoint - parking - 30x30" index:ImageWaypoints_ParkingArea];
    [self addToLibrary:@"waypoint - flag - 30x30" index:ImageWaypoints_PhysicalStage];
    [self addToLibrary:@"waypoint - flag - 30x30" index:ImageWaypoints_ReferenceStage];
    //[self addToLibrary:@"waypoint - question - 30x30" index:ImageWaypoints_QuestionStage];
    [self addToLibrary:@"waypoint - trailhead - 30x30" index:ImageWaypoints_Trailhead];
    [self addToLibrary:@"waypoint - trailhead - 30x30" index:ImageWaypoints_VirtualStage];
    [self addToLibrary:@"waypoint - manually entered - 30x30" index:ImageWaypoints_ManuallyEntered];

    [self addToLibrary:@"cache - unknowntype - 30x30" index:ImageTypes_NFI];
    [self addToLibrary:@"waypoint - unknown - 30x30" index:Imagewaypoints_NFI];
    [self addToLibrary:@"cache - unknown - 30x30" index:ImageNFI];

    [self addToLibrary:@"log - didnotfind - 30x30" index:ImageLog_DidNotFind];
    [self addToLibrary:@"log - enabled - 30x30" index:ImageLog_Enabled];
    [self addToLibrary:@"log - found - 30x30" index:ImageLog_Found];
    [self addToLibrary:@"log - needsarchiving - 30x30" index:ImageLog_NeedsArchiving];
    [self addToLibrary:@"log - needsmaintenance - 30x30" index:ImageLog_NeedsMaintenance];
    [self addToLibrary:@"log - ownermaintenance - 30x30" index:ImageLog_OwnerMaintenance];
    [self addToLibrary:@"log - reviewernote - 30x30" index:ImageLog_ReviewerNote];
    [self addToLibrary:@"log - published - 30x30" index:ImageLog_Published];
    [self addToLibrary:@"log - archived - 30x30" index:ImageLog_Archived];
    [self addToLibrary:@"log - disabled - 30x30" index:ImageLog_Disabled];
    [self addToLibrary:@"log - unarchived - 30x30" index:ImageLog_Unarchived];
    [self addToLibrary:@"log - coordinates - 30x30" index:ImageLog_Coordinates];
    [self addToLibrary:@"log - photographed - 30x30" index:ImageLog_WebcamPhoto];
    [self addToLibrary:@"log - note - 30x30" index:ImageLog_Note];
    [self addToLibrary:@"log - attended - 30x30" index:ImageLog_Attended];
    [self addToLibrary:@"log - willattend - 30x30" index:ImageLog_WillAttend];
    [self addToLibrary:@"log - unknown - 30x30" index:ImageLog_Unknown];
    [self addToLibrary:@"log - moved - 30x30" index:ImageLog_Moved];
    [self addToLibrary:@"log - announcement - 30x30" index:ImageLog_Announcement];
    [self addToLibrary:@"log - empty - 30x30" index:ImageLog_Empty];

    [self addToLibrary:@"container size - large - 35x11" index:ImageContainerSize_Large];
    [self addToLibrary:@"container size - micro - 35x11" index:ImageContainerSize_Micro];
    [self addToLibrary:@"container size - notchosen - 35x11" index:ImageContainerSize_NotChosen];
    [self addToLibrary:@"container size - other - 35x11" index:ImageContainerSize_Other];
    [self addToLibrary:@"container size - regular - 35x11" index:ImageContainerSize_Regular];
    [self addToLibrary:@"container size - small - 35x11" index:ImageContainerSize_Small];
    [self addToLibrary:@"container size - nano - 35x11" index:ImageContainerSize_Nano];
    [self addToLibrary:@"container size - unknown - 35x11" index:ImageContainerSize_Virtual];
    [self addToLibrary:@"container size - xlarge - 35x11" index:ImageContainerSize_XLarge];

    [self addToLibrary:@"ratings - favourites 20x30" index:ImageCacheView_favourites];

    [self addToLibrary:@"map - pin stick - 35x42" index:ImageMap_pin];
    [self addToLibrary:@"map - dnf stick - 35x42" index:ImageMap_dnf];
    [self addToLibrary:@"map - found stick - 35x42" index:ImageMap_found];

    [self addToLibrary:@"map - cross dnf - 9x9" index:ImageMap_pinCrossDNF];
    [self addToLibrary:@"map - tick found - 9x9" index:ImageMap_pinTickFound];
    [self addToLibrary:@"map - marked found - 9x9" index:ImageMap_pinMarkedFound];
    [self addToLibrary:@"map - disabled - 15x15" index:ImageMap_pinOutlineDisabled];
    [self addToLibrary:@"map - archived - 15x15" index:ImageMap_pinOutlineArchived];
    [self addToLibrary:@"map - highlight - 21x21" index:ImageMap_pinOutlineHighlight];
    [self addToLibrary:@"map - background - 35x42" index:ImageMap_background];
    [self addToLibrary:@"map - own overlay - 18x18" index:ImageMap_pinOwner];
    [self addToLibrary:@"map - in progress - 18x18" index:ImageMap_pinInProgress];
    [self addToLibrary:@"container flag - cross dnf - 19x19" index:ImageContainerFlag_crossDNF];
    [self addToLibrary:@"container flag - tick found - 24x21" index:ImageContainerFlag_tickFound];
    [self addToLibrary:@"container flag - marked found - 24x21" index:ImageContainerFlag_markedFound];
    [self addToLibrary:@"container flag - disabled - 24x24" index:ImageContainerFlag_outlineDisabled];
    [self addToLibrary:@"container flag - archived - 24x24" index:ImageContainerFlag_outlineArchived];
    [self addToLibrary:@"container flag - in progress - 24x24" index:ImageContainerFlag_inProgress];
    [self addToLibrary:@"container flag - owner - 24x24" index:ImageContainerFlag_owner];
    [self addToLibrary:@"container flag - planned - 24x21" index:ImageContainerFlag_planned];

    [self addToLibrary:@"icons - smiley - 30x30" index:ImageIcon_Smiley];
    [self addToLibrary:@"icons - sad - 30x30" index:ImageIcon_Sad];
    [self addToLibrary:@"icons - dead - 30x30" index:ImageIcon_Dead];
    [self addToLibrary:@"icons - target - 30x30" index:ImageIcon_Target];

    [self addToLibrary:@"menu icon - global default - 27x27" index:ImageIcon_GlobalMenuDefault_Small];
    [self addToLibrary:@"menu icon - local default - 27x27" index:ImageIcon_LocalMenuDefault_Small];
    [self addToLibrary:@"menu icon - global night - 27x27" index:ImageIcon_GlobalMenuNight_Small];
    [self addToLibrary:@"menu icon - local night - 27x27" index:ImageIcon_LocalMenuNight_Small];
    [self addToLibrary:@"menu icon - close - 15x15" index:ImageIcon_CloseButton_Small];
    [self addToLibrary:@"menu icon - see target - 27x27" index:ImageIcon_SeeTarget_Small];
    [self addToLibrary:@"menu icon - show both - 27x27" index:ImageIcon_ShowBoth_Small];
    [self addToLibrary:@"menu icon - follow me - 27x27" index:ImageIcon_FollowMe_Small];
    [self addToLibrary:@"menu icon - find me - 27x27" index:ImageIcon_FindMe_Small];
    [self addToLibrary:@"menu icon - find target - 27x27" index:ImageIcon_FindTarget_Small];
    [self addToLibrary:@"menu icon - gnss-on - 27x27" index:ImageIcon_GNSSOn_Small];
    [self addToLibrary:@"menu icon - gnss-off - 27x27" index:ImageIcon_GNSSOff_Small];

    [self addToLibrary:@"menu icon - global default - 40x40" index:ImageIcon_GlobalMenuDefault_Normal];
    [self addToLibrary:@"menu icon - local default - 40x40" index:ImageIcon_LocalMenuDefault_Normal];
    [self addToLibrary:@"menu icon - global night - 40x40" index:ImageIcon_GlobalMenuNight_Normal];
    [self addToLibrary:@"menu icon - local night - 40x40" index:ImageIcon_LocalMenuNight_Normal];
    [self addToLibrary:@"menu icon - close - 30x30" index:ImageIcon_CloseButton_Normal];
    [self addToLibrary:@"menu icon - see target - 40x40" index:ImageIcon_SeeTarget_Normal];
    [self addToLibrary:@"menu icon - show both - 40x40" index:ImageIcon_ShowBoth_Normal];
    [self addToLibrary:@"menu icon - follow me - 40x40" index:ImageIcon_FollowMe_Normal];
    [self addToLibrary:@"menu icon - find me - 40x40" index:ImageIcon_FindMe_Normal];
    [self addToLibrary:@"menu icon - find target - 40x40" index:ImageIcon_FindTarget_Normal];
    [self addToLibrary:@"menu icon - gnss-on - 40x40" index:ImageIcon_GNSSOn_Normal];
    [self addToLibrary:@"menu icon - gnss-off - 40x40" index:ImageIcon_GNSSOff_Normal];

    [self addToLibrary:@"compass - red on blue compass - compass" index:ImageCompass_RedArrowOnBlueCompass];
    [self addToLibrary:@"compass - red on blue compass - arrow" index:ImageCompass_RedArrowOnBlueArrow];
    [self addToLibrary:@"compass - white arrow on black" index:ImageCompass_WhiteArrowOnBlack];
    [self addToLibrary:@"compass - red arrow on black" index:ImageCompass_RedArrowOnBlack];
    [self addToLibrary:@"compass - airplane - airplane" index:ImageCompass_AirplaneAirplane];
    [self addToLibrary:@"compass - airplane - compass" index:ImageCompass_AirplaneCompass];

    [self addToLibrary:@"attributes - unknown" index:ImageAttribute_Unknown];
    [self addToLibrary:@"attributes - 01" index:ImageAttribute_DogsAllowed];
    [self addToLibrary:@"attributes - 02" index:ImageAttribute_AccessOrParkingFee];
    [self addToLibrary:@"attributes - 03" index:ImageAttribute_RockClimbing];
    [self addToLibrary:@"attributes - 04" index:ImageAttribute_Boat];
    [self addToLibrary:@"attributes - 05" index:ImageAttribute_ScubaGear];
    [self addToLibrary:@"attributes - 06" index:ImageAttribute_RecommendedForKids];
    [self addToLibrary:@"attributes - 07" index:ImageAttribute_TakesLessThanAnHour];
    [self addToLibrary:@"attributes - 08" index:ImageAttribute_ScenicVIew];
    [self addToLibrary:@"attributes - 09" index:ImageAttribute_SignificantHike];
    [self addToLibrary:@"attributes - 10" index:ImageAttribute_DifficultClimbing];
    [self addToLibrary:@"attributes - 11" index:ImageAttribute_MayRequireWading];
    [self addToLibrary:@"attributes - 12" index:ImageAttribute_MayRequireSwimming];
    [self addToLibrary:@"attributes - 13" index:ImageAttribute_AvailableAtAllTimes];
    [self addToLibrary:@"attributes - 14" index:ImageAttribute_RecommendedAtNight];
    [self addToLibrary:@"attributes - 15" index:ImageAttribute_AvailableDuringWinter];
    [self addToLibrary:@"attributes - 17" index:ImageAttribute_PoisonPlants];
    [self addToLibrary:@"attributes - 18" index:ImageAttribute_DangerousAnimals];
    [self addToLibrary:@"attributes - 19" index:ImageAttribute_Ticks];
    [self addToLibrary:@"attributes - 20" index:ImageAttribute_AbandonedMines];
    [self addToLibrary:@"attributes - 21" index:ImageAttribute_CliffFallingRocks];
    [self addToLibrary:@"attributes - 22" index:ImageAttribute_Hunting];
    [self addToLibrary:@"attributes - 23" index:ImageAttribute_DangerousArea];
    [self addToLibrary:@"attributes - 24" index:ImageAttribute_WheelchairAccessible];
    [self addToLibrary:@"attributes - 25" index:ImageAttribute_ParkingAvailable];
    [self addToLibrary:@"attributes - 26" index:ImageAttribute_PublicTransportation];
    [self addToLibrary:@"attributes - 27" index:ImageAttribute_DrinkingWaterNearby];
    [self addToLibrary:@"attributes - 28" index:ImageAttribute_ToiletNearby];
    [self addToLibrary:@"attributes - 29" index:ImageAttribute_TelephoneNearby];
    [self addToLibrary:@"attributes - 30" index:ImageAttribute_PicnicTablesNearby];
    [self addToLibrary:@"attributes - 31" index:ImageAttribute_CampingArea];
    [self addToLibrary:@"attributes - 32" index:ImageAttribute_Bicycles];
    [self addToLibrary:@"attributes - 33" index:ImageAttribute_Motorcycles];
    [self addToLibrary:@"attributes - 34" index:ImageAttribute_Quads];
    [self addToLibrary:@"attributes - 35" index:ImageAttribute_OffRoadVehicles];
    [self addToLibrary:@"attributes - 36" index:ImageAttribute_Snowmobiles];
    [self addToLibrary:@"attributes - 37" index:ImageAttribute_Horses];
    [self addToLibrary:@"attributes - 38" index:ImageAttribute_Campfires];
    [self addToLibrary:@"attributes - 39" index:ImageAttribute_Thorns];
    [self addToLibrary:@"attributes - 40" index:ImageAttribute_StealthRequired];
    [self addToLibrary:@"attributes - 41" index:ImageAttribute_StrollerAccessible];
    [self addToLibrary:@"attributes - 42" index:ImageAttribute_NeedsMaintenance];
    [self addToLibrary:@"attributes - 43" index:ImageAttribute_WatchForLivestock];
    [self addToLibrary:@"attributes - 44" index:ImageAttribute_FlashlightRequired];
    [self addToLibrary:@"attributes - 45" index:ImageAttribute_LostAndFoundTour];
    [self addToLibrary:@"attributes - 46" index:ImageAttribute_TruckDriversRV];
    [self addToLibrary:@"attributes - 47" index:ImageAttribute_FieldPuzzle];
    [self addToLibrary:@"attributes - 48" index:ImageAttribute_UVTorchRequired];
    [self addToLibrary:@"attributes - 49" index:ImageAttribute_Snowshoes];
    [self addToLibrary:@"attributes - 50" index:ImageAttribute_CrossCountrySkies];
    [self addToLibrary:@"attributes - 51" index:ImageAttribute_LongHike];
    [self addToLibrary:@"attributes - 52" index:ImageAttribute_SpecialToolRequired];
    [self addToLibrary:@"attributes - 53" index:ImageAttribute_NightCache];
    [self addToLibrary:@"attributes - 54" index:ImageAttribute_ParkAndGrab];
    [self addToLibrary:@"attributes - 55" index:ImageAttribute_AbandonedStructure];
    [self addToLibrary:@"attributes - 56" index:ImageAttribute_ShortHike];
    [self addToLibrary:@"attributes - 57" index:ImageAttribute_MediumHike];
    [self addToLibrary:@"attributes - 58" index:ImageAttribute_FuelNearby];
    [self addToLibrary:@"attributes - 59" index:ImageAttribute_FoodNearby];
    [self addToLibrary:@"attributes - 60" index:ImageAttribute_WirelessBeacon];
    [self addToLibrary:@"attributes - 61" index:ImageAttribute_PartnershipCache];
    [self addToLibrary:@"attributes - 62" index:ImageAttribute_SeasonalAccess];
    [self addToLibrary:@"attributes - 63" index:ImageAttribute_TouristFriendly];
    [self addToLibrary:@"attributes - 64" index:ImageAttribute_TreeClimbing];
    [self addToLibrary:@"attributes - 65" index:ImageAttribute_FrontYard];
    [self addToLibrary:@"attributes - 66" index:ImageAttribute_TeamworkRequired];
    [self addToLibrary:@"attributes - 67" index:ImageAttribute_PartOfGeoTour];

    [self addToLibrary:@"image - no image - 32x32" index:Image_NoImageFile];

    /* Pin and type images */
    pinImages = [NSMutableDictionary dictionaryWithCapacity:25];
    typeImages = [NSMutableDictionary dictionaryWithCapacity:25];

    return self;
}

- (void)addToLibrary:(NSString *)name index:(NSInteger)idx
{
    NSString *s = [NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], name];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:s];
    NSAssert1(img != nil, @"ImageLibrary: Image %@ not found", s);
    imgs[idx] = img;
    names[idx] = name;
}

// -------------------------------------------------------------
- (void)addpinhead:(NSInteger)index image:(UIImage *)img
{
    imgs[index] = img;
    names[index] = [NSString stringWithFormat:@"pinhead: %ld", (long)index];
}

- (UIImage *)mergePinhead:(UIImage *)bottom topImg:(UIImage *)top
{
    UIImage *out = [self addImageToImage:bottom withImage2:top andRect:CGRectMake(3, 3, 15, 15)];
    return out;
}
- (UIImage *)mergePinhead2:(UIImage *)bottom top:(NSInteger)top
{
    UIImage *out = [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(3, 3, 15, 15)];
    return out;
}
- (UIImage *)mergePinhead:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergePinhead2:bottom top:top];
}
- (void)mergePinhead:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    UIImage *out = [self mergePinhead2:[self get:bottom] top:top];
    imgs[index] = out;
    names[index] = [NSString stringWithFormat:@"Merge of %ld and %ld", (long)bottom, (long)top];
}

- (UIImage *)mergeXXX:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(6, 6, 13, 13)];
}
- (UIImage *)mergeDNF:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergeXXX:bottom top:top];
}
- (UIImage *)mergeFound:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergeXXX:bottom top:top];
}

- (UIImage *)mergeHighlight:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(0, 0, 21, 21)];
}

- (UIImage *)mergeStick:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergePin:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergePin:(UIImage *)bottom topImg:(UIImage *)top
{
    return [self addImageToImage:bottom withImage2:top andRect:CGRectMake(0, 0, 35, 42)];
}
- (UIImage *)mergeOwner:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(3, 3, 15, 15)];
}

- (UIImage *)mergeYYY:(UIImage *)bottom top:(NSInteger)top
{
    return [self addImageToImage:bottom withImage2:[self get:top] andRect:CGRectMake(3, 3, 15, 15)];
}
- (UIImage *)mergeDisabled:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergeYYY:bottom top:top];
}
- (UIImage *)mergeArchived:(UIImage *)bottom top:(NSInteger)top
{
    return [self mergeYYY:bottom top:top];
}

- (UIImage *)addImageToImage:(UIImage *)img1 withImage2:(UIImage *)img2 andRect:(CGRect)cropRect
{
    CGSize size = img1.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    CGPoint pointImg1 = CGPointMake(0, 0);
    [img1 drawAtPoint:pointImg1];

    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint:pointImg2];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)get:(ImageNumber)imgnum
{
    UIImage *img = imgs[imgnum];
    if (img == nil)
        NSLog(@"ImageLibrary/get: imgnum %ld not found", (long)imgnum);
    return img;
}

- (NSString *)getName:(ImageNumber)imgnum
{
    NSString *name = names[imgnum];
    if (name == nil)
        NSLog(@"ImageLibrary/getName: imgnum %ld not found", (long)imgnum);
    return name;
}

// -----------------------------------------------------------

- (NSString *)getCode:(dbObject *)o found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    NSMutableString *s = [NSMutableString stringWithString:@""];

    if (highlight == YES)
        [s appendString:@"H"];
    else
        [s appendString:@"h"];

    [s appendFormat:@"-%ld-", (long)o._id];

    if (disabled == YES)
        [s appendString:@"D"];
    else
        [s appendString:@"d"];

    if (archived == YES)
        [s appendString:@"A"];
    else
        [s appendString:@"a"];

    switch (found) {
        case LOGSTATUS_NOTLOGGED:
            [s appendString:@"-"];
            break;
        case LOGSTATUS_NOTFOUND:
            [s appendString:@"l"];
            break;
        case LOGSTATUS_FOUND:
            [s appendString:@"L"];
            break;
    }

    if (owner == YES)
        [s appendString:@"O"];
    else
        [s appendString:@"o"];

    if (markedFound == YES)
        [s appendString:@"M"];
    else
        [s appendString:@"m"];

    if (inProgress == YES)
        [s appendString:@"I"];
    else
        [s appendString:@"i"];

    if (markedDNF == YES)
        [s appendString:@"N"];
    else
        [s appendString:@"n"];

    if (planned == YES)
        [s appendString:@"P"];
    else
        [s appendString:@"p"];
    return s;
}

// -----------------------------------------------------------

- (UIImage *)getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    NSString *s = [self getCode:pin found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:NO];
    UIImage *img = [pinImages valueForKey:s];
    if (img == nil) {
        NSLog(@"Creating pin %@s", s);
        img = [self getPinImage:pin found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF];
        [pinImages setObject:img forKey:s];
    }

    return img;
}

- (UIImage *)getPin:(dbWaypoint *)wp
{
    __block BOOL owner = NO;
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a._id == wp.account._id && a.accountname._id == wp.gs_owner._id) {
            *stop = YES;
            owner = YES;
        }
    }];

    return [self getPin:wp.wpt_type.pin found:wp.logStatus disabled:(wp.gs_available == NO) archived:(wp.gs_archived == YES) highlight:wp.flag_highlight owner:owner markedFound:wp.flag_markedfound inProgress:wp.flag_inprogress markedDNF:wp.flag_dnf];
}

- (UIImage *)getPinImage:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF
{
    UIImage *img = [imageManager get:ImageMap_background];

    switch (found) {
        case LOGSTATUS_NOTLOGGED:
            // Do not overlay anything
            img = [self mergeStick:img top:ImageMap_pin];
            break;
        case LOGSTATUS_NOTFOUND:
            img = [self mergeStick:img top:ImageMap_dnf];
            // Overlay the blue cross
            break;
        case LOGSTATUS_FOUND:
            img = [self mergeStick:img top:ImageMap_found];
            // Overlay the yellow tick
            break;
    }

    if (highlight == YES)
        img = [self mergeHighlight:img top:ImageMap_pinOutlineHighlight];

    img = [self mergePinhead:img topImg:pin.img];

    if (owner == YES)
        img = [self mergeOwner:img top:ImageMap_pinOwner];

    if (inProgress == YES)
        img = [self mergeOwner:img top:ImageMap_pinInProgress];

    if (markedFound == YES) {
        img = [self mergeFound:img top:ImageMap_pinMarkedFound];
    } else {
        switch (found) {
            case LOGSTATUS_NOTLOGGED:
                // Do not overlay anything
                break;
            case LOGSTATUS_NOTFOUND:
                img = [self mergeFound:img top:ImageMap_pinCrossDNF];
                // Overlay the blue cross
                break;
            case LOGSTATUS_FOUND:
                img = [self mergeFound:img top:ImageMap_pinTickFound];
                // Overlay the yellow tick
                break;
        }
    }

    if (markedDNF == YES)
        img = [self mergeDNF:img top:ImageMap_pinCrossDNF];

    if (disabled == YES)
        img = [self mergeDisabled:img top:ImageMap_pinOutlineDisabled];

    if (archived == YES)
        img = [self mergeArchived:img top:ImageMap_pinOutlineArchived];

    return img;
}

// -----------------------------------------------------------

- (UIImage *)getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    NSString *s = [self getCode:type found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:planned];
    UIImage *img = [typeImages valueForKey:s];
    if (img == nil) {
        img = [self getTypeImage:type found:found disabled:disabled archived:archived highlight:highlight owner:owner markedFound:markedFound inProgress:inProgress markedDNF:markedDNF planned:planned];
        [typeImages setObject:img forKey:s];
    }

    return img;
}

- (UIImage *)getTypeImage:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF planned:(BOOL)planned
{
    UIImage *img = [imageManager get:type.icon];

    if (owner == YES)
        img = [self mergeOwner:img top:ImageContainerFlag_owner];

    if (inProgress == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_inProgress];

    if (markedFound == YES) {
        img = [self mergeFound:img top:ImageContainerFlag_markedFound];
    } else {
        switch (found) {
            case LOGSTATUS_NOTLOGGED:
                // Do not overlay anything
                break;
            case LOGSTATUS_NOTFOUND:
                img = [self mergeFound:img top:ImageContainerFlag_crossDNF];
                // Overlay the blue cross
                break;
            case LOGSTATUS_FOUND:
                img = [self mergeFound:img top:ImageContainerFlag_tickFound];
                // Overlay the yellow tick
                break;
        }
    }

    if (markedDNF == YES)
        img = [self mergeDNF:img top:ImageContainerFlag_crossDNF];

    if (disabled == YES)
        img = [self mergeDisabled:img top:ImageContainerFlag_outlineDisabled];

    if (archived == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_outlineArchived];

    if (planned == YES)
        img = [self mergeArchived:img top:ImageContainerFlag_planned];

    return img;
}

- (UIImage *)getType:(dbWaypoint *)wp
{
    return [self getType:wp.wpt_type found:wp.logStatus disabled:(wp.gs_available == NO) archived:(wp.gs_archived == YES) highlight:wp.flag_highlight owner:[dbc accountIsOwner:wp] markedFound:wp.flag_markedfound inProgress:wp.flag_inprogress markedDNF:wp.flag_dnf planned:wp.flag_planned];
}

- (NSString *)getCode:(dbWaypoint *)wp
{
    NSString *s = [self getCode:wp.wpt_type found:wp.logStatus disabled:(wp.gs_available == NO) archived:(wp.gs_archived == YES) highlight:wp.flag_highlight owner:[dbc accountIsOwner:wp] markedFound:wp.flag_markedfound inProgress:wp.flag_inprogress markedDNF:wp.flag_dnf planned:wp.flag_planned];
    return s;
}

// -----------------------------------------------------------

+ (void)RGBtoFloat:(NSString *)rgb r:(float *)r g:(float *)g b:(float *)b
{
    unsigned int i;
    NSScanner *s = [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(0, 2)]];
    [s scanHexInt:&i];
    *r = i / 255.0;
    s = [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(2, 2)]];
    [s scanHexInt:&i];
    *g = i / 255.0;
    s = [NSScanner scannerWithString:[rgb substringWithRange:NSMakeRange(4, 2)]];
    [s scanHexInt:&i];
    *b = i / 255.0;
}

+ (UIColor *)RGBtoColor:(NSString *)rgb
{
    float r, g, b;
    [self RGBtoFloat:rgb r:&r g:&g b:&b];
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (NSString *)ColorToRGB:(UIColor *)c
{
    CGFloat r, g, b, a;
    [c getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02lX%02lX%02lX", lround(255 * r), lround(255 * g), lround(255 * b)];
}

+ (UIImage *)newPinHead:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(15, 15), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    /*
     * .....xxxxx.....
     * ...xxXXXXXxx...
     * ..xXXXXXXXXXx..
     * .xXX,::,XXXXXx.
     * .xXX::::XXXXXx.
     * xXXX::::XXXXXXx
     * xXXX'::'XXXXXXx
     * xXXXXXXXXXXXXXx
     * xXXXXXXXXXXXXXx
     * xXXXXXXXXXXXXXx
     * .xXXXXXXXXXXXx.
     * .xXXXXXXXXXXXx.
     * ..xXXXXXXXXXx..
     * ...xxXXXXXxx...
     * .....xxxxx.....
     */

#define VLINE(x, y1, y2) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, x + 0.5, y1); \
    CGContextAddLineToPoint(context, x + 0.5, y2 + 1); \
    CGContextStrokePath(context);
#define HLINE(y, x1, x2) \
    CGContextSetLineWidth(context, 1); \
    CGContextMoveToPoint(context, x1, y + 0.5); \
    CGContextAddLineToPoint(context, x2 + 1, y + 0.5); \
    CGContextStrokePath(context);
#define DOT(x, y) \
    HLINE(y, x, x);

    const CGFloat *vs = CGColorGetComponents([color CGColor]);
    CGFloat r = vs[0];
    CGFloat g = vs[1];
    CGFloat b = vs[2];

    // Outer circle
    for (NSInteger i = 0; i < 2; i++) {
        if (i == 0)
            CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
        else
            CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:r green:g blue:b alpha:0.4] CGColor]);
        HLINE( 0,  5,   9);     // Top
        HLINE( 1,  3,   4);
        DOT  ( 2,  2);
        VLINE( 1,  3,   4);
        VLINE( 0,  5,   9);     // Lefthand side
        VLINE( 1, 10, 11);
        DOT  ( 2, 12);
        HLINE(13,  3,   4);
        HLINE(14,  5,   9);     // Bottom
        HLINE(13, 10,  11);
        DOT  (12, 12);
        VLINE(13, 10, 11);
        VLINE(14,  5,  9);      // Righthand side
        VLINE(13,  3,  4);
        DOT  (12,  2);
        HLINE( 1,  10, 11);
    }

    // Inner circle
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    HLINE( 1, 5,  9);
    HLINE( 2, 3, 11);
    HLINE( 3, 2, 12);
    HLINE( 4, 2, 12);
    HLINE( 5, 1, 13);
    HLINE( 6, 1, 13);
    HLINE( 7, 1, 13);
    HLINE( 8, 1, 13);
    HLINE( 9, 1, 13);
    HLINE(10, 2, 12);
    HLINE(11, 2, 12);
    HLINE(12, 3, 11);
    HLINE(13, 5,  9);

    // Little dot at the top left
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    HLINE( 3, 4, 5);
    HLINE( 4, 3, 6);
    HLINE( 5, 3, 6);
    HLINE( 6, 4, 5);

    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5] CGColor]);
    DOT  ( 3, 3);
    DOT  ( 6, 3);
    DOT  ( 6, 6);
    DOT  ( 3, 6);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)getSquareWithNumber:(NSInteger)num
{
    NSInteger width = 0;
    if (num < 10)
        width = 1 * 14;
    else if (num < 100)
        width = 2 * 14;
    else if (num < 1000)
        width = 3 * 14;
    else
        width = 4 * 14;
    width += 4;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, 20), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    /*
     *              1         2
     *    0123456789012345678901234
     *  0 .........xxxxxxx.........
     *  1 ......xxx.......xxx......
     *  2 ....xx.............xx....
     *  3 ...x.................x...
     *  4 ..x...................x..
     *  5 .x.....................x.
     *  6 .x.....................x.
     *  7 x.......................x
     *  8 x.......................x
     *  9 x.......................x
     * 10 x.......................x
     *  1 x.......................x
     *  2 x.......................x
     *  3 .x.....................x.
     *  4 .x.....................x.
     *  5 ..x...................x..
     *  6 ...x.................x...
     *  7 ....xx.............xx....
     *  8 ......xxx.......xxx......
     *  9 .........xxxxxxx.........
     */

    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] CGColor]);
    NSInteger w = width - 1;
    VLINE(0    ,  7, 12);
    VLINE(w - 0,  7, 12);
    VLINE(1    ,  5,  6);
    VLINE(w - 1,  5,  6);
    VLINE(1    , 13, 14);
    VLINE(w - 1, 13, 14);

    HLINE( 1,     6,     8);
    HLINE( 1, w - 8, w - 6);
    HLINE( 2,     4,     5);
    HLINE( 2, w - 5, w - 4);
    HLINE(17,     4,     5);
    HLINE(17, w - 5, w - 4);
    HLINE(18,     6,     8);
    HLINE(18, w - 8, w - 6);

    DOT  (2,  4);
    DOT  (3,  3);
    DOT  (2, 15);
    DOT  (3, 16);
    DOT  (w - 2,  4);
    DOT  (w - 3,  3);
    DOT  (w - 2, 15);
    DOT  (w - 3, 16);

    HLINE( 0, 9, width - 10);
    HLINE(19, 9, width - 10);

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
    l.text = [NSString stringWithFormat:@"%ld", (long)num];
    l.textAlignment = NSTextAlignmentCenter;
    [l.layer drawInContext:context];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

+ (UIImage *)circleWithColour:(UIColor *)c
{
    NSInteger width = 25;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, 20), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    /*
     *              1         2
     *    0123456789012345678901234
     *  0 .........xxxxxxx.........
     *  1 ......xxx.......xxx......
     *  2 ....xx.............xx....
     *  3 ...x.................x...
     *  4 ..x...................x..
     *  5 .x.....................x.
     *  6 .x.....................x.
     *  7 x.......................x
     *  8 x.......................x
     *  9 x.......................x
     * 10 x.......................x
     *  1 x.......................x
     *  2 x.......................x
     *  3 .x.....................x.
     *  4 .x.....................x.
     *  5 ..x...................x..
     *  6 ...x.................x...
     *  7 ....xx.............xx....
     *  8 ......xxx.......xxx......
     *  9 .........xxxxxxx.........
     */

    CGContextSetStrokeColorWithColor(context, [c CGColor]);
    NSInteger w = width - 1;
    HLINE( 0,     9, w - 10);
    HLINE( 1,     6, w -  7);
    HLINE( 2,     4, w -  5);
    HLINE( 3,     3, w -  4);
    HLINE( 4,     2, w -  3);
    HLINE( 5,     1, w -  2);
    HLINE( 6,     1, w -  2);
    HLINE( 7,     0, w -  1);
    HLINE( 8,     0, w -  1);
    HLINE( 9,     0, w -  1);
    HLINE(10,     0, w -  1);
    HLINE(11,     0, w -  1);
    HLINE(12,     0, w -  1);
    HLINE(13,     1, w -  2);
    HLINE(14,     1, w -  2);
    HLINE(15,     2, w -  3);
    HLINE(16,     3, w -  4);
    HLINE(17,     4, w -  5);
    HLINE(18,     6, w -  7);
    HLINE(19,     9, w - 10);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
