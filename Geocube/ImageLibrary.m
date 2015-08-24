/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@implementation ImageLibrary

- (id)init
{
    self = [super init];
    NSLog(@"ImageLibrary: %d elements", ImageLibraryImagesMax);

    [self add:@"cache - benchmark - 30x30" index:ImageTypes_Benchmark];
    [self add:@"cache - cito - 30x30" index:ImageTypes_CITO];
    [self add:@"cache - earth - 30x30" index:ImageTypes_EarthCache];
    [self add:@"cache - event - 30x30" index:ImageTypes_Event];
    [self add:@"cache - giga - 30x30" index:ImageTypes_Giga];
    [self add:@"cache - groundspeak hq - 30x30" index:ImageTypes_GroundspeakHQ];
    [self add:@"cache - letterbox - 30x30" index:ImageTypes_Letterbox];
    [self add:@"cache - maze - 30x30" index:ImageTypes_Maze];
    [self add:@"cache - mega - 30x30" index:ImageTypes_Mega];
    [self add:@"cache - multi - 30x30" index:ImageTypes_MultiCache];
    [self add:@"cache - mystery - 30x30" index:ImageTypes_Mystery];
    [self add:@"cache - unknown - 30x30" index:ImageTypes_Other];
    [self add:@"cache - traditional - 30x30" index:ImageTypes_TraditionalCache];
    [self add:@"cache - unknown - 30x30" index:ImageTypes_UnknownCache];
    [self add:@"cache - virtual - 30x30" index:ImageTypes_VirtualCache];
    [self add:@"cache - waymark - 30x30" index:ImageTypes_Waymark];
    [self add:@"cache - webcam - 30x30" index:ImageTypes_WebcamCache];
    [self add:@"cache - whereigo - 30x30" index:ImageTypes_WhereigoCache];

    [self add:@"waypoint - finish - 30x30" index:ImageWaypoints_FinalLocation];
    [self add:@"waypoint - flag - 30x30" index:ImageWaypoints_Flag];
    [self add:@"waypoint - multi - 30x30" index:ImageWaypoints_MultiStage];
    [self add:@"waypoint - parking - 30x30" index:ImageWaypoints_ParkingArea];
    [self add:@"waypoint - flag - 30x30" index:ImageWaypoints_PhysicalStage];
    [self add:@"waypoint - flag - 30x30" index:ImageWaypoints_ReferenceStage];
    //[self add:@"waypoint - question - 30x30" index:ImageWaypoints_QuestionStage];
    [self add:@"waypoint - trailhead - 30x30" index:ImageWaypoints_Trailhead];
    [self add:@"waypoint - trailhead - 30x30" index:ImageWaypoints_VirtualStage];

    [self add:@"cache - unknown - 30x30" index:ImageTypes_NFI];
    [self add:@"waypoint - unknown - 30x30" index:Imagewaypoints_NFI];
    [self add:@"cache - unknown - 30x30" index:ImageNFI];

    [self add:@"log - didnotfind - 30x30" index:ImageLog_DidNotFind];
    [self add:@"log - enabled - 30x30" index:ImageLog_Enabled];
    [self add:@"log - found - 30x30" index:ImageLog_Found];
    [self add:@"log - needsarchiving - 30x30" index:ImageLog_NeedsArchiving];
    [self add:@"log - needsmaintenance - 30x30" index:ImageLog_NeedsMaintenance];
    [self add:@"log - ownermaintenance - 30x30" index:ImageLog_OwnerMaintenance];
    [self add:@"log - reviewernote - 30x30" index:ImageLog_ReviewerNote];
    [self add:@"log - published - 30x30" index:ImageLog_Published];
    [self add:@"log - archived - 30x30" index:ImageLog_Archived];
    [self add:@"log - disabled - 18x18" index:ImageLog_Disabled];
    [self add:@"log - unarchived - 30x30" index:ImageLog_Unarchived];
    [self add:@"log - coordinates - 30x30" index:ImageLog_Coordinates];
    [self add:@"log - unknown - 30x30" index:ImageLog_WebcamPhoto];
    [self add:@"log - note - 30x30" index:ImageLog_Note];
    [self add:@"log - attended - 30x30" index:ImageLog_Attended];
    [self add:@"log - willattend - 30x30" index:ImageLog_WillAttend];
    [self add:@"log - unknown - 30x30" index:ImageLog_Unknown];

    [self add:@"container - large - 70x20" index:ImageSize_Large];
    [self add:@"container - micro - 70x20" index:ImageSize_Micro];
    [self add:@"container - notchosen - 70x20" index:ImageSize_NotChosen];
    [self add:@"container - other - 70x20" index:ImageSize_Other];
    [self add:@"container - regular - 70x20" index:ImageSize_Regular];
    [self add:@"container - small - 70x20" index:ImageSize_Small];
    [self add:@"container - unknown - 70x20" index:ImageSize_Virtual];

    [self add:@"ratings - star base 95x18" index:ImageCacheView_ratingBase];
    [self add:@"ratings - star on 19x18" index:ImageCacheView_ratingOn];
    [self add:@"ratings - star off 18x18" index:ImageCacheView_ratingOff];
    [self add:@"ratings - star half 18x18" index:ImageCacheView_ratingHalf];
    [self add:@"ratings - favourites 20x30" index:ImageCacheView_favourites];

    [self add:@"map - pin stick - 35x42" index:ImageMap_pin];
    [self add:@"map - dnf stick - 35x42" index:ImageMap_dnf];
    [self add:@"map - found stick - 35x42" index:ImageMap_found];
    [self add:@"pinhead - black - 15x15" index:ImageMap_pinheadBlack];
    [self add:@"pinhead - brown - 15x15" index:ImageMap_pinheadBrown];
    [self add:@"pinhead - green - 15x15" index:ImageMap_pinheadGreen];
    [self add:@"pinhead - lightblue - 15x15" index:ImageMap_pinheadLightblue];
    [self add:@"pinhead - purple - 15x15" index:ImageMap_pinheadPurple];
    [self add:@"pinhead - red - 15x15" index:ImageMap_pinheadRed];
    [self add:@"pinhead - white - 15x15" index:ImageMap_pinheadWhite];
    [self add:@"pinhead - yellow - 15x15" index:ImageMap_pinheadYellow];
    [self add:@"pinhead - pink - 15x15" index:ImageMap_pinheadPink];

    [self add:@"map - cross dnf - 9x9" index:ImageMap_pinCrossDNF];
    [self add:@"map - tick found - 9x9" index:ImageMap_pinTickFound];
    [self add:@"map - cross dnf - 19x19" index:ImageMap_typeCrossDNF];
    [self add:@"map - tick found - 24x21" index:ImageMap_typeTickFound];
    [self add:@"map - disabled - 15x15" index:ImageMap_pinOutlineDisabled];
    [self add:@"map - archived - 15x15" index:ImageMap_pinOutlineArchived];

    [self add:@"icons - smiley - 30x30" index:ImageIcon_Smiley];
    [self add:@"icons - sad - 30x30" index:ImageIcon_Sad];
    [self add:@"icons - target - 20x20" index:ImageIcon_Target];

    [self add:@"menu icon - global" index:ImageIcon_GlobalMenu];
    [self add:@"menu icon - local" index:ImageIcon_LocalMenu];
    [self add:@"menu icon - close" index:ImageIcon_CloseButton];

    [self add:@"compass - magnetic" index:ImageCompass_Magnetic];
    [self add:@"compass - redline" index:ImageCompass_Line];
    [self add:@"compass - white arrow on black" index:ImageCompass_WhiteArrowOnBlack];
    [self add:@"compass - airplane - airplane" index:ImageCompass_AirplaneAirplane];
    [self add:@"compass - airplane - compass" index:ImageCompass_AirplaneCompass];

    [self add:@"attributes - unknown" index:ImageAttribute_Unknown];
    [self add:@"attributes - 01" index:ImageAttribute_DogsAllowed];
    [self add:@"attributes - 02" index:ImageAttribute_AccessOrParkingFee];
    [self add:@"attributes - 03" index:ImageAttribute_RockClimbing];
    [self add:@"attributes - 04" index:ImageAttribute_Boat];
    [self add:@"attributes - 05" index:ImageAttribute_ScubaGear];
    [self add:@"attributes - 06" index:ImageAttribute_RecommendedForKids];
    [self add:@"attributes - 07" index:ImageAttribute_TakesLessThanAnHour];
    [self add:@"attributes - 08" index:ImageAttribute_ScenicVIew];
    [self add:@"attributes - 09" index:ImageAttribute_SignificantHike];
    [self add:@"attributes - 10" index:ImageAttribute_DifficultClimbing];
    [self add:@"attributes - 11" index:ImageAttribute_MayRequireWading];
    [self add:@"attributes - 12" index:ImageAttribute_MayRequireSwimming];
    [self add:@"attributes - 13" index:ImageAttribute_AvailableAtAllTimes];
    [self add:@"attributes - 14" index:ImageAttribute_RecommendedAtNight];
    [self add:@"attributes - 15" index:ImageAttribute_AvailableDuringWinter];
    [self add:@"attributes - 17" index:ImageAttribute_PoisonPlants];
    [self add:@"attributes - 18" index:ImageAttribute_DangerousAnimals];
    [self add:@"attributes - 19" index:ImageAttribute_Ticks];
    [self add:@"attributes - 20" index:ImageAttribute_AbandonedMines];
    [self add:@"attributes - 21" index:ImageAttribute_CliffFallingRocks];
    [self add:@"attributes - 22" index:ImageAttribute_Hunting];
    [self add:@"attributes - 23" index:ImageAttribute_DangerousArea];
    [self add:@"attributes - 24" index:ImageAttribute_WheelchairAccessible];
    [self add:@"attributes - 25" index:ImageAttribute_ParkingAvailable];
    [self add:@"attributes - 26" index:ImageAttribute_PublicTransportation];
    [self add:@"attributes - 27" index:ImageAttribute_DrinkingWaterNearby];
    [self add:@"attributes - 28" index:ImageAttribute_ToiletNearby];
    [self add:@"attributes - 29" index:ImageAttribute_TelephoneNearby];
    [self add:@"attributes - 30" index:ImageAttribute_PicnicTablesNearby];
    [self add:@"attributes - 31" index:ImageAttribute_CampingArea];
    [self add:@"attributes - 32" index:ImageAttribute_Bicycles];
    [self add:@"attributes - 33" index:ImageAttribute_Motorcycles];
    [self add:@"attributes - 34" index:ImageAttribute_Quads];
    [self add:@"attributes - 35" index:ImageAttribute_OffRoadVehicles];
    [self add:@"attributes - 36" index:ImageAttribute_Snowmobiles];
    [self add:@"attributes - 37" index:ImageAttribute_Horses];
    [self add:@"attributes - 38" index:ImageAttribute_Campfires];
    [self add:@"attributes - 39" index:ImageAttribute_Thorns];
    [self add:@"attributes - 40" index:ImageAttribute_StealthRequired];
    [self add:@"attributes - 41" index:ImageAttribute_StrollerAccessible];
    [self add:@"attributes - 42" index:ImageAttribute_NeedsMaintenance];
    [self add:@"attributes - 43" index:ImageAttribute_WatchForLivestock];
    [self add:@"attributes - 44" index:ImageAttribute_FlashlightRequired];
    [self add:@"attributes - 45" index:ImageAttribute_LostAndFoundTour];
    [self add:@"attributes - 46" index:ImageAttribute_TruckDriversRV];
    [self add:@"attributes - 47" index:ImageAttribute_FieldPuzzle];
    [self add:@"attributes - 48" index:ImageAttribute_UVTorchRequired];
    [self add:@"attributes - 49" index:ImageAttribute_Snowshoes];
    [self add:@"attributes - 50" index:ImageAttribute_CrossCountrySkies];
    [self add:@"attributes - 51" index:ImageAttribute_LongHike];
    [self add:@"attributes - 52" index:ImageAttribute_SpecialToolRequired];
    [self add:@"attributes - 53" index:ImageAttribute_NightCache];
    [self add:@"attributes - 54" index:ImageAttribute_ParkAndGrab];
    [self add:@"attributes - 55" index:ImageAttribute_AbandonedStructure];
    [self add:@"attributes - 56" index:ImageAttribute_ShortHike];
    [self add:@"attributes - 57" index:ImageAttribute_MediumHike];
    [self add:@"attributes - 58" index:ImageAttribute_FuelNearby];
    [self add:@"attributes - 59" index:ImageAttribute_FoodNearby];
    [self add:@"attributes - 60" index:ImageAttribute_WirelessBeacon];
    [self add:@"attributes - 61" index:ImageAttribute_PartnershipCache];
    [self add:@"attributes - 62" index:ImageAttribute_SeasonalAccess];
    [self add:@"attributes - 63" index:ImageAttribute_TouristFriendly];
    [self add:@"attributes - 64" index:ImageAttribute_TreeClimbing];
    [self add:@"attributes - 65" index:ImageAttribute_FrontYard];
    [self add:@"attributes - 66" index:ImageAttribute_TeamworkRequired];
    [self add:@"attributes - 67" index:ImageAttribute_PartOfGeoTour];

    pin2normal = ImageMap_pinBlack - ImageMap_pinheadBlack;
    pin2found = ImageMap_foundBlack - ImageMap_pinheadBlack;
    pin2dnf = ImageMap_dnfBlack - ImageMap_pinheadBlack;
    pin2disabled = ImageMap_disabledBlack - ImageMap_pinheadBlack;
    pin2archived = ImageMap_archivedBlack - ImageMap_pinheadBlack;
    pin2foundDisabled = ImageMap_disabledFoundBlack - ImageMap_pinheadBlack;
    pin2foundArchived = ImageMap_archivedFoundBlack - ImageMap_pinheadBlack;
    pin2dnfDisabled = ImageMap_disabledDNFBlack - ImageMap_pinheadBlack;
    pin2dnfArchived = ImageMap_archivedDNFBlack - ImageMap_pinheadBlack;

    /* Create pins */
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBlack index:ImageMap_pinBlack];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBrown index:ImageMap_pinBrown];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadGreen index:ImageMap_pinGreen];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadLightblue index:ImageMap_pinLightblue];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPurple index:ImageMap_pinPurple];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadRed index:ImageMap_pinRed];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadWhite index:ImageMap_pinWhite];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadYellow index:ImageMap_pinYellow];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPink index:ImageMap_pinPink];

    /* Create found pins */
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadBlack index:ImageMap_foundBlack];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadBrown index:ImageMap_foundBrown];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadGreen index:ImageMap_foundGreen];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadLightblue index:ImageMap_foundLightblue];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadPurple index:ImageMap_foundPurple];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadRed index:ImageMap_foundRed];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadWhite index:ImageMap_foundWhite];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadYellow index:ImageMap_foundYellow];
    [self mergePinhead:ImageMap_found top:ImageMap_pinheadPink index:ImageMap_foundPink];

    [self mergeFound:ImageMap_foundBlack top:ImageMap_pinTickFound index:ImageMap_foundBlack];
    [self mergeFound:ImageMap_foundBrown top:ImageMap_pinTickFound index:ImageMap_foundBrown];
    [self mergeFound:ImageMap_foundGreen top:ImageMap_pinTickFound index:ImageMap_foundGreen];
    [self mergeFound:ImageMap_foundLightblue top:ImageMap_pinTickFound index:ImageMap_foundLightblue];
    [self mergeFound:ImageMap_foundPurple top:ImageMap_pinTickFound index:ImageMap_foundPurple];
    [self mergeFound:ImageMap_foundRed top:ImageMap_pinTickFound index:ImageMap_foundRed];
    [self mergeFound:ImageMap_foundWhite top:ImageMap_pinTickFound index:ImageMap_foundWhite];
    [self mergeFound:ImageMap_foundYellow top:ImageMap_pinTickFound index:ImageMap_foundYellow];
    [self mergeFound:ImageMap_foundPink top:ImageMap_pinTickFound index:ImageMap_foundPink];

    /* Create DNF pins */
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadBlack index:ImageMap_dnfBlack];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadBrown index:ImageMap_dnfBrown];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadGreen index:ImageMap_dnfGreen];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadLightblue index:ImageMap_dnfLightblue];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadPurple index:ImageMap_dnfPurple];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadRed index:ImageMap_dnfRed];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadWhite index:ImageMap_dnfWhite];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadYellow index:ImageMap_dnfYellow];
    [self mergePinhead:ImageMap_dnf top:ImageMap_pinheadPink index:ImageMap_dnfPink];

    [self mergeDNF:ImageMap_dnfBlack top:ImageMap_pinCrossDNF index:ImageMap_dnfBlack];
    [self mergeDNF:ImageMap_dnfBrown top:ImageMap_pinCrossDNF index:ImageMap_dnfBrown];
    [self mergeDNF:ImageMap_dnfGreen top:ImageMap_pinCrossDNF index:ImageMap_dnfGreen];
    [self mergeDNF:ImageMap_dnfLightblue top:ImageMap_pinCrossDNF index:ImageMap_dnfLightblue];
    [self mergeDNF:ImageMap_dnfPurple top:ImageMap_pinCrossDNF index:ImageMap_dnfPurple];
    [self mergeDNF:ImageMap_dnfRed top:ImageMap_pinCrossDNF index:ImageMap_dnfRed];
    [self mergeDNF:ImageMap_dnfWhite top:ImageMap_pinCrossDNF index:ImageMap_dnfWhite];
    [self mergeDNF:ImageMap_dnfYellow top:ImageMap_pinCrossDNF index:ImageMap_dnfYellow];
    [self mergeDNF:ImageMap_dnfPink top:ImageMap_pinCrossDNF index:ImageMap_dnfPink];

    /* Create disabled pins */
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBlack index:ImageMap_disabledBlack];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBrown index:ImageMap_disabledBrown];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadGreen index:ImageMap_disabledGreen];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadLightblue index:ImageMap_disabledLightblue];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPurple index:ImageMap_disabledPurple];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadRed index:ImageMap_disabledRed];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadWhite index:ImageMap_disabledWhite];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadYellow index:ImageMap_disabledYellow];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPink index:ImageMap_disabledPink];

    [self mergeDisabled:ImageMap_disabledBlack top:ImageMap_pinOutlineDisabled index:ImageMap_disabledBlack];
    [self mergeDisabled:ImageMap_disabledBrown top:ImageMap_pinOutlineDisabled index:ImageMap_disabledBrown];
    [self mergeDisabled:ImageMap_disabledGreen top:ImageMap_pinOutlineDisabled index:ImageMap_disabledGreen];
    [self mergeDisabled:ImageMap_disabledLightblue top:ImageMap_pinOutlineDisabled index:ImageMap_disabledLightblue];
    [self mergeDisabled:ImageMap_disabledPurple top:ImageMap_pinOutlineDisabled index:ImageMap_disabledPurple];
    [self mergeDisabled:ImageMap_disabledRed top:ImageMap_pinOutlineDisabled index:ImageMap_disabledRed];
    [self mergeDisabled:ImageMap_disabledWhite top:ImageMap_pinOutlineDisabled index:ImageMap_disabledWhite];
    [self mergeDisabled:ImageMap_disabledYellow top:ImageMap_pinOutlineDisabled index:ImageMap_disabledYellow];
    [self mergeDisabled:ImageMap_disabledPink top:ImageMap_pinOutlineDisabled index:ImageMap_disabledPink];

    [self mergeDisabled:ImageMap_foundBlack top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundBlack];
    [self mergeDisabled:ImageMap_foundBrown top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundBrown];
    [self mergeDisabled:ImageMap_foundGreen top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundGreen];
    [self mergeDisabled:ImageMap_foundLightblue top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundLightblue];
    [self mergeDisabled:ImageMap_foundPurple top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundPurple];
    [self mergeDisabled:ImageMap_foundRed top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundRed];
    [self mergeDisabled:ImageMap_foundWhite top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundWhite];
    [self mergeDisabled:ImageMap_foundYellow top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundYellow];
    [self mergeDisabled:ImageMap_foundPink top:ImageMap_pinOutlineDisabled index:ImageMap_disabledFoundPink];

    [self mergeDisabled:ImageMap_dnfBlack top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFBlack];
    [self mergeDisabled:ImageMap_dnfBrown top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFBrown];
    [self mergeDisabled:ImageMap_dnfGreen top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFGreen];
    [self mergeDisabled:ImageMap_dnfLightblue top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFLightblue];
    [self mergeDisabled:ImageMap_dnfPurple top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFPurple];
    [self mergeDisabled:ImageMap_dnfRed top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFRed];
    [self mergeDisabled:ImageMap_dnfWhite top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFWhite];
    [self mergeDisabled:ImageMap_dnfYellow top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFYellow];
    [self mergeDisabled:ImageMap_dnfPink top:ImageMap_pinOutlineDisabled index:ImageMap_disabledDNFPink];

    /* Create archived pins */
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBlack index:ImageMap_archivedBlack];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadBrown index:ImageMap_archivedBrown];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadGreen index:ImageMap_archivedGreen];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadLightblue index:ImageMap_archivedLightblue];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPurple index:ImageMap_archivedPurple];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadRed index:ImageMap_archivedRed];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadWhite index:ImageMap_archivedWhite];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadYellow index:ImageMap_archivedYellow];
    [self mergePinhead:ImageMap_pin top:ImageMap_pinheadPink index:ImageMap_archivedPink];

    [self mergeArchived:ImageMap_archivedBlack top:ImageMap_pinOutlineArchived index:ImageMap_archivedBlack];
    [self mergeArchived:ImageMap_archivedBrown top:ImageMap_pinOutlineArchived index:ImageMap_archivedBrown];
    [self mergeArchived:ImageMap_archivedGreen top:ImageMap_pinOutlineArchived index:ImageMap_archivedGreen];
    [self mergeArchived:ImageMap_archivedLightblue top:ImageMap_pinOutlineArchived index:ImageMap_archivedLightblue];
    [self mergeArchived:ImageMap_archivedPurple top:ImageMap_pinOutlineArchived index:ImageMap_archivedPurple];
    [self mergeArchived:ImageMap_archivedRed top:ImageMap_pinOutlineArchived index:ImageMap_archivedRed];
    [self mergeArchived:ImageMap_archivedWhite top:ImageMap_pinOutlineArchived index:ImageMap_archivedWhite];
    [self mergeArchived:ImageMap_archivedYellow top:ImageMap_pinOutlineArchived index:ImageMap_archivedYellow];
    [self mergeArchived:ImageMap_archivedPink top:ImageMap_pinOutlineArchived index:ImageMap_archivedPink];

    [self mergeArchived:ImageMap_foundBlack top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundBlack];
    [self mergeArchived:ImageMap_foundBrown top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundBrown];
    [self mergeArchived:ImageMap_foundGreen top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundGreen];
    [self mergeArchived:ImageMap_foundLightblue top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundLightblue];
    [self mergeArchived:ImageMap_foundPurple top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundPurple];
    [self mergeArchived:ImageMap_foundRed top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundRed];
    [self mergeArchived:ImageMap_foundWhite top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundWhite];
    [self mergeArchived:ImageMap_foundYellow top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundYellow];
    [self mergeArchived:ImageMap_foundPink top:ImageMap_pinOutlineArchived index:ImageMap_archivedFoundPink];

    [self mergeArchived:ImageMap_dnfBlack top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFBlack];
    [self mergeArchived:ImageMap_dnfBrown top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFBrown];
    [self mergeArchived:ImageMap_dnfGreen top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFGreen];
    [self mergeArchived:ImageMap_dnfLightblue top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFLightblue];
    [self mergeArchived:ImageMap_dnfPurple top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFPurple];
    [self mergeArchived:ImageMap_dnfRed top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFRed];
    [self mergeArchived:ImageMap_dnfWhite top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFWhite];
    [self mergeArchived:ImageMap_dnfYellow top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFYellow];
    [self mergeArchived:ImageMap_dnfPink top:ImageMap_pinOutlineArchived index:ImageMap_archivedDNFPink];

    /* Make ratings images */
    [self mergeRating:0 full:0 half:0];
    [self mergeRating:1 full:0 half:1];
    [self mergeRating:2 full:1 half:0];
    [self mergeRating:3 full:1 half:1];
    [self mergeRating:4 full:2 half:0];
    [self mergeRating:5 full:2 half:1];
    [self mergeRating:6 full:3 half:0];
    [self mergeRating:7 full:3 half:1];
    [self mergeRating:8 full:4 half:0];
    [self mergeRating:9 full:4 half:1];
    [self mergeRating:10 full:5 half:0];

    /* Types */
    type2found = ImageTypes_foundBenchmark - ImageTypes_Benchmark;
    type2dnf = ImageTypes_dnfBenchmark - ImageTypes_Benchmark;

    /* Create found types */
    [self mergeFound:ImageTypes_Benchmark top:ImageMap_typeTickFound index:ImageTypes_foundBenchmark];
    [self mergeFound:ImageTypes_CITO top:ImageMap_typeTickFound index:ImageTypes_foundCITO];
    [self mergeFound:ImageTypes_EarthCache top:ImageMap_typeTickFound index:ImageTypes_foundEarthCache];
    [self mergeFound:ImageTypes_Event top:ImageMap_typeTickFound index:ImageTypes_foundEvent];
    [self mergeFound:ImageTypes_Giga top:ImageMap_typeTickFound index:ImageTypes_foundGiga];
    [self mergeFound:ImageTypes_GroundspeakHQ top:ImageMap_typeTickFound index:ImageTypes_foundGroundspeakHQ];
    [self mergeFound:ImageTypes_Letterbox top:ImageMap_typeTickFound index:ImageTypes_foundLetterbox];
    [self mergeFound:ImageTypes_Maze top:ImageMap_typeTickFound index:ImageTypes_foundMaze];
    [self mergeFound:ImageTypes_Mega top:ImageMap_typeTickFound index:ImageTypes_foundMega];
    [self mergeFound:ImageTypes_MultiCache top:ImageMap_typeTickFound index:ImageTypes_foundMultiCache];
    [self mergeFound:ImageTypes_Mystery top:ImageMap_typeTickFound index:ImageTypes_foundMystery];
    [self mergeFound:ImageTypes_Other top:ImageMap_typeTickFound index:ImageTypes_foundOther];
    [self mergeFound:ImageTypes_TraditionalCache top:ImageMap_typeTickFound index:ImageTypes_foundTraditionalCache];
    [self mergeFound:ImageTypes_UnknownCache top:ImageMap_typeTickFound index:ImageTypes_foundUnknownCache];
    [self mergeFound:ImageTypes_VirtualCache top:ImageMap_typeTickFound index:ImageTypes_foundVirtualCache];
    [self mergeFound:ImageTypes_Waymark top:ImageMap_typeTickFound index:ImageTypes_foundWaymark];
    [self mergeFound:ImageTypes_WebcamCache top:ImageMap_typeTickFound index:ImageTypes_foundWebcamCache];
    [self mergeFound:ImageTypes_WhereigoCache top:ImageMap_typeTickFound index:ImageTypes_foundWhereigoCache];
    [self mergeFound:ImageTypes_NFI top:ImageMap_typeTickFound index:ImageTypes_foundNFI];

    /* Create DNF types */
    [self mergeFound:ImageTypes_Benchmark top:ImageMap_typeCrossDNF index:ImageTypes_dnfBenchmark];
    [self mergeFound:ImageTypes_CITO top:ImageMap_typeCrossDNF index:ImageTypes_dnfCITO];
    [self mergeFound:ImageTypes_EarthCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfEarthCache];
    [self mergeFound:ImageTypes_Event top:ImageMap_typeCrossDNF index:ImageTypes_dnfEvent];
    [self mergeFound:ImageTypes_Giga top:ImageMap_typeCrossDNF index:ImageTypes_dnfGiga];
    [self mergeFound:ImageTypes_GroundspeakHQ top:ImageMap_typeCrossDNF index:ImageTypes_dnfGroundspeakHQ];
    [self mergeFound:ImageTypes_Letterbox top:ImageMap_typeCrossDNF index:ImageTypes_dnfLetterbox];
    [self mergeFound:ImageTypes_Maze top:ImageMap_typeCrossDNF index:ImageTypes_dnfMaze];
    [self mergeFound:ImageTypes_Mega top:ImageMap_typeCrossDNF index:ImageTypes_dnfMega];
    [self mergeFound:ImageTypes_MultiCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfMultiCache];
    [self mergeFound:ImageTypes_Mystery top:ImageMap_typeCrossDNF index:ImageTypes_dnfMystery];
    [self mergeFound:ImageTypes_Other top:ImageMap_typeCrossDNF index:ImageTypes_dnfOther];
    [self mergeFound:ImageTypes_TraditionalCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfTraditionalCache];
    [self mergeFound:ImageTypes_UnknownCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfUnknownCache];
    [self mergeFound:ImageTypes_VirtualCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfVirtualCache];
    [self mergeFound:ImageTypes_Waymark top:ImageMap_typeCrossDNF index:ImageTypes_dnfWaymark];
    [self mergeFound:ImageTypes_WebcamCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfWebcamCache];
    [self mergeFound:ImageTypes_WhereigoCache top:ImageMap_typeCrossDNF index:ImageTypes_dnfWhereigoCache];
    [self mergeFound:ImageTypes_NFI top:ImageMap_typeCrossDNF index:ImageTypes_dnfNFI];

    return self;
}

- (void)add:(NSString *)name index:(NSInteger)idx
{
    [self add2:idx name:name];
}
- (void)add2:(NSInteger)index name:(NSString *)name
{
    NSString *s = [NSString stringWithFormat:@"%@/%@", [MyTools DataDistributionDirectory], name];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:s];
    if (img == nil) {
        NSLog(@"ImageLibrary: Image %@ not found", s);
        return;
    }
    imgs[index] = img;
    names[index] = name;
}

- (void)mergePinhead2:(NSInteger)index bottom:(NSInteger)bottom top:(NSInteger)top
{
    UIImage *out = [self addImageToImage:[self get:bottom] withImage2:[self get:top] andRect:CGRectMake(3, 3, 15, 15)];
    imgs[index] = out;
    names[index] = [NSString stringWithFormat:@"PINHEAD: %ld + %ld", (long)bottom, (long)top];
}
- (void)mergePinhead:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    [self mergePinhead2:index bottom:bottom top:top];
}

- (void)mergeXXX:(NSInteger)index bottom:(NSInteger)bottom top:(NSInteger)top name:(NSString *)name
{
    UIImage *out = [self addImageToImage:[self get:bottom] withImage2:[self get:top] andRect:CGRectMake(6, 6, 13, 13)];
    imgs[index] = out;
    names[index] = [NSString stringWithFormat:@"%@: %ld + %ld", name, (long)bottom, (long)top];
}
- (void)mergeDNF:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    [self mergeXXX:index bottom:bottom top:top name:@"DNF"];
}
- (void)mergeFound:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    [self mergeXXX:index bottom:bottom top:top name:@"FOUND"];
}

- (void)mergeYYY:(NSInteger)index bottom:(NSInteger)bottom top:(NSInteger)top name:(NSString *)name
{
    UIImage *out = [self addImageToImage:[self get:bottom] withImage2:[self get:top] andRect:CGRectMake(3, 3, 15, 15)];
    imgs[index] = out;
    names[index] = [NSString stringWithFormat:@"%@: %ld + %ld", name, (long)bottom, (long)top];
}
- (void)mergeDisabled:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    [self mergeYYY:index bottom:bottom top:top name:@"DISABLED"];
}
- (void)mergeArchived:(NSInteger)bottom top:(NSInteger)top index:(NSInteger)index
{
    [self mergeYYY:index bottom:bottom top:top name:@"ARCHIVED"];
}

- (void)mergeRating:(NSInteger)index full:(NSInteger)full half:(NSInteger)half
{
    UIImage *out = [UIImage imageWithCGImage:[self get:ImageCacheView_ratingBase].CGImage];
    NSInteger w = 19;
    NSInteger h = 19;
    for (NSInteger i = 0; i < full; i++) {
        UIImage *_out = [self addImageToImage:out withImage2:[self get:ImageCacheView_ratingOn] andRect:CGRectMake(i * w, 0, w, h)];
        out = [UIImage imageWithCGImage:_out.CGImage];
    }

    if (half == 1) {
        UIImage *_out = [self addImageToImage:out withImage2:[self get:ImageCacheView_ratingHalf] andRect:CGRectMake(full * w, 0, w, h)];
        out = [UIImage imageWithCGImage:_out.CGImage];
    }

    ratingImages[index] = [UIImage imageWithCGImage:out.CGImage];
}

- (UIImage *)addImageToImage:(UIImage *)img1 withImage2:(UIImage *)img2 andRect:(CGRect)cropRect
{
    CGSize size = img1.size;
    UIGraphicsBeginImageContext(size);

    CGPoint pointImg1 = CGPointMake(0, 0);
    [img1 drawAtPoint:pointImg1];

    CGPoint pointImg2 = cropRect.origin;
    [img2 drawAtPoint:pointImg2];

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (UIImage *)get:(NSInteger)imgnum
{
    UIImage *img = imgs[imgnum];
    if (img == nil)
        NSLog(@"ImageLibrary: imgnum %ld not found", (long)imgnum);
    return img;
}

- (UIImage *)getPinFound:(NSInteger)imgnum
{
    return [self get:imgnum + pin2found];
}

- (UIImage *)getPinDNF:(NSInteger)imgnum
{
    return [self get:imgnum + pin2dnf];
}

- (UIImage *)getPinNormal:(NSInteger)imgnum
{
    return [self get:imgnum + pin2normal];
}

- (UIImage *)getPinDisabled:(NSInteger)imgnum
{
    return [self get:imgnum + pin2disabled];
}

- (UIImage *)getPinArchived:(NSInteger)imgnum
{
    return [self get:imgnum + pin2archived];
}

- (UIImage *)getPinDisabledFound:(NSInteger)imgnum
{
    return [self get:imgnum + pin2foundDisabled];
}

- (UIImage *)getPinArchivedFound:(NSInteger)imgnum
{
    return [self get:imgnum + pin2foundArchived];
}

- (UIImage *)getPinDisabledDNF:(NSInteger)imgnum
{
    return [self get:imgnum + pin2dnfDisabled];
}

- (UIImage *)getPinArchivedDNF:(NSInteger)imgnum
{
    return [self get:imgnum + pin2dnfArchived];
}

- (UIImage *)getTypeFound:(NSInteger)imgnum
{
    return [self get:imgnum + type2found];
}

- (UIImage *)getTypeDNF:(NSInteger)imgnum
{
    return [self get:imgnum + type2dnf];
}

- (UIImage *)getTypeNormal:(NSInteger)imgnum
{
    return [self get:imgnum + type2normal];
}

- (NSString *)getName:(NSInteger)imgnum
{
    NSString *name = names[imgnum];
    if (name == nil)
        NSLog(@"ImageLibrary: imgnum %ld not found", (long)imgnum);
    return name;
}

- (UIImage *)getRating:(float)rating
{
    return ratingImages[(int)(2 * rating)];
}

@end
