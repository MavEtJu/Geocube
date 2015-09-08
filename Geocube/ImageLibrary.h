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

typedef enum {
    ImageLibraryImagesMin = -1,

    /* Do not reorder, index matches schema.sql */
    ImageTypes_Benchmark = 100,
    ImageTypes_CITO,
    ImageTypes_EarthCache,
    ImageTypes_Event,
    ImageTypes_Giga,
    ImageTypes_GroundspeakHQ,
    ImageTypes_Letterbox,
    ImageTypes_Maze,
    ImageTypes_Mega,
    ImageTypes_MultiCache,
    ImageTypes_Mystery,
    ImageTypes_Other,
    ImageTypes_TraditionalCache,
    ImageTypes_UnknownCache,
    ImageTypes_VirtualCache,
    ImageTypes_Waymark,
    ImageTypes_WebcamCache,
    ImageTypes_WhereigoCache,
    ImageTypes_NFI,

    /*
    ImageTypes_foundBenchmark,
    ImageTypes_foundCITO,
    ImageTypes_foundEarthCache,
    ImageTypes_foundEvent,
    ImageTypes_foundGiga,
    ImageTypes_foundGroundspeakHQ,
    ImageTypes_foundLetterbox,
    ImageTypes_foundMaze,
    ImageTypes_foundMega,
    ImageTypes_foundMultiCache,
    ImageTypes_foundMystery,
    ImageTypes_foundOther,
    ImageTypes_foundTraditionalCache,
    ImageTypes_foundUnknownCache,
    ImageTypes_foundVirtualCache,
    ImageTypes_foundWaymark,
    ImageTypes_foundWebcamCache,
    ImageTypes_foundWhereigoCache,
    ImageTypes_foundNFI,

    ImageTypes_dnfBenchmark,
    ImageTypes_dnfCITO,
    ImageTypes_dnfEarthCache,
    ImageTypes_dnfEvent,
    ImageTypes_dnfGiga,
    ImageTypes_dnfGroundspeakHQ,
    ImageTypes_dnfLetterbox,
    ImageTypes_dnfMaze,
    ImageTypes_dnfMega,
    ImageTypes_dnfMultiCache,
    ImageTypes_dnfMystery,
    ImageTypes_dnfOther,
    ImageTypes_dnfTraditionalCache,
    ImageTypes_dnfUnknownCache,
    ImageTypes_dnfVirtualCache,
    ImageTypes_dnfWaymark,
    ImageTypes_dnfWebcamCache,
    ImageTypes_dnfWhereigoCache,
    ImageTypes_dnfNFI,
     */

    ImageWaypoints_FinalLocation = 200,
    ImageWaypoints_Flag,
    ImageWaypoints_MultiStage,
    ImageWaypoints_ParkingArea,
    ImageWaypoints_PhysicalStage,
    ImageWaypoints_ReferenceStage,
    ImageWaypoints_Trailhead,
    ImageWaypoints_VirtualStage,
    Imagewaypoints_NFI,
    ImageNFI,

    ImageLog_DidNotFind = 400,
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

    ImageSize_Large = 450,
    ImageSize_Micro,
    ImageSize_NotChosen,
    ImageSize_Other,
    ImageSize_Regular,
    ImageSize_Small,
    ImageSize_Virtual,

    ImageAttribute_Unknown = 500,
    ImageAttribute_DogsAllowed,
    ImageAttribute_AccessOrParkingFee,
    ImageAttribute_RockClimbing,
    ImageAttribute_Boat,
    ImageAttribute_ScubaGear,
    ImageAttribute_RecommendedForKids,
    ImageAttribute_TakesLessThanAnHour,
    ImageAttribute_ScenicVIew,
    ImageAttribute_SignificantHike,
    ImageAttribute_DifficultClimbing,
    ImageAttribute_MayRequireWading,
    ImageAttribute_MayRequireSwimming,
    ImageAttribute_AvailableAtAllTimes,
    ImageAttribute_RecommendedAtNight,
    ImageAttribute_AvailableDuringWinter,
    ImageAttribute_,
    ImageAttribute_PoisonPlants,
    ImageAttribute_DangerousAnimals,
    ImageAttribute_Ticks,
    ImageAttribute_AbandonedMines,
    ImageAttribute_CliffFallingRocks,
    ImageAttribute_Hunting,
    ImageAttribute_DangerousArea,
    ImageAttribute_WheelchairAccessible,
    ImageAttribute_ParkingAvailable,
    ImageAttribute_PublicTransportation,
    ImageAttribute_DrinkingWaterNearby,
    ImageAttribute_ToiletNearby,
    ImageAttribute_TelephoneNearby,
    ImageAttribute_PicnicTablesNearby,
    ImageAttribute_CampingArea,
    ImageAttribute_Bicycles,
    ImageAttribute_Motorcycles,
    ImageAttribute_Quads,
    ImageAttribute_OffRoadVehicles,
    ImageAttribute_Snowmobiles,
    ImageAttribute_Horses,
    ImageAttribute_Campfires,
    ImageAttribute_Thorns,
    ImageAttribute_StealthRequired,
    ImageAttribute_StrollerAccessible,
    ImageAttribute_NeedsMaintenance,
    ImageAttribute_WatchForLivestock,
    ImageAttribute_FlashlightRequired,
    ImageAttribute_LostAndFoundTour,
    ImageAttribute_TruckDriversRV,
    ImageAttribute_FieldPuzzle,
    ImageAttribute_UVTorchRequired,
    ImageAttribute_Snowshoes,
    ImageAttribute_CrossCountrySkies,
    ImageAttribute_SpecialToolRequired,
    ImageAttribute_NightCache,
    ImageAttribute_ParkAndGrab,
    ImageAttribute_AbandonedStructure,
    ImageAttribute_ShortHike,
    ImageAttribute_MediumHike,
    ImageAttribute_LongHike,
    ImageAttribute_FuelNearby,
    ImageAttribute_FoodNearby,
    ImageAttribute_WirelessBeacon,
    ImageAttribute_PartnershipCache,
    ImageAttribute_SeasonalAccess,
    ImageAttribute_TouristFriendly,
    ImageAttribute_TreeClimbing,
    ImageAttribute_FrontYard,
    ImageAttribute_TeamworkRequired,
    ImageAttribute_PartOfGeoTour,

    ImageMap_pinheadBlack = 600,
    ImageMap_pinheadBrown,
    ImageMap_pinheadGreen,
    ImageMap_pinheadLightblue,
    ImageMap_pinheadPurple,
    ImageMap_pinheadRed,
    ImageMap_pinheadWhite,
    ImageMap_pinheadYellow,
    ImageMap_pinheadPink,

    ImageMap_pinBlack,
    ImageMap_pinBrown,
    ImageMap_pinGreen,
    ImageMap_pinLightblue,
    ImageMap_pinPurple,
    ImageMap_pinRed,
    ImageMap_pinWhite,
    ImageMap_pinYellow,
    ImageMap_pinPink,

    /*
    ImageMap_foundBlack,
    ImageMap_foundBrown,
    ImageMap_foundGreen,
    ImageMap_foundLightblue,
    ImageMap_foundPurple,
    ImageMap_foundRed,
    ImageMap_foundWhite,
    ImageMap_foundYellow,
    ImageMap_foundPink,

    ImageMap_dnfBlack,
    ImageMap_dnfBrown,
    ImageMap_dnfGreen,
    ImageMap_dnfLightblue,
    ImageMap_dnfPurple,
    ImageMap_dnfRed,
    ImageMap_dnfWhite,
    ImageMap_dnfYellow,
    ImageMap_dnfPink,

    ImageMap_disabledBlack,
    ImageMap_disabledBrown,
    ImageMap_disabledGreen,
    ImageMap_disabledLightblue,
    ImageMap_disabledPurple,
    ImageMap_disabledRed,
    ImageMap_disabledWhite,
    ImageMap_disabledYellow,
    ImageMap_disabledPink,

    ImageMap_archivedBlack,
    ImageMap_archivedBrown,
    ImageMap_archivedGreen,
    ImageMap_archivedLightblue,
    ImageMap_archivedPurple,
    ImageMap_archivedRed,
    ImageMap_archivedWhite,
    ImageMap_archivedYellow,
    ImageMap_archivedPink,

    ImageMap_disabledFoundBlack,
    ImageMap_disabledFoundBrown,
    ImageMap_disabledFoundGreen,
    ImageMap_disabledFoundLightblue,
    ImageMap_disabledFoundPurple,
    ImageMap_disabledFoundRed,
    ImageMap_disabledFoundWhite,
    ImageMap_disabledFoundYellow,
    ImageMap_disabledFoundPink,

    ImageMap_archivedFoundBlack,
    ImageMap_archivedFoundBrown,
    ImageMap_archivedFoundGreen,
    ImageMap_archivedFoundLightblue,
    ImageMap_archivedFoundPurple,
    ImageMap_archivedFoundRed,
    ImageMap_archivedFoundWhite,
    ImageMap_archivedFoundYellow,
    ImageMap_archivedFoundPink,

    ImageMap_disabledDNFBlack,
    ImageMap_disabledDNFBrown,
    ImageMap_disabledDNFGreen,
    ImageMap_disabledDNFLightblue,
    ImageMap_disabledDNFPurple,
    ImageMap_disabledDNFRed,
    ImageMap_disabledDNFWhite,
    ImageMap_disabledDNFYellow,
    ImageMap_disabledDNFPink,

    ImageMap_archivedDNFBlack,
    ImageMap_archivedDNFBrown,
    ImageMap_archivedDNFGreen,
    ImageMap_archivedDNFLightblue,
    ImageMap_archivedDNFPurple,
    ImageMap_archivedDNFRed,
    ImageMap_archivedDNFWhite,
    ImageMap_archivedDNFYellow,
    ImageMap_archivedDNFPink,
     */

    /* Up to here: Do not reorder */

    ImageLibraryImagesUnsorted = 700,

    ImageMap_pin,
    ImageMap_dnf,
    ImageMap_found,
    ImageMap_disabled,
    ImageMap_archived,

    ImageMap_pinCrossDNF,
    ImageMap_pinTickFound,
    ImageMap_typeCrossDNF,
    ImageMap_typeTickFound,
    ImageMap_pinOutlineDisabled,
    ImageMap_pinOutlineArchived,

    ImageCacheView_ratingBase,
    ImageCacheView_ratingOff,
    ImageCacheView_ratingHalf,
    ImageCacheView_ratingOn,
    ImageCacheView_favourites,

    ImageIcon_Smiley,
    ImageIcon_Sad,
    ImageIcon_Target,

    ImageIcon_GlobalMenu,
    ImageIcon_LocalMenu,
    ImageIcon_CloseButton,

    ImageCompass_RedArrowOnBlueCompass,
    ImageCompass_RedArrowOnBlueArrow,
    ImageCompass_WhiteArrowOnBlack,
    ImageCompass_RedArrowOnBlack,
    ImageCompass_AirplaneAirplane,
    ImageCompass_AirplaneCompass,

    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject {
    UIImage *imgs[ImageLibraryImagesMax];
    UIImage *ratingImages[11];
    NSString *names[ImageLibraryImagesMax];

    /*
    NSInteger pin2normal;
    NSInteger pin2found;
    NSInteger pin2dnf;
    NSInteger pin2disabled;
    NSInteger pin2archived;
    NSInteger pin2foundDisabled;
    NSInteger pin2foundArchived;
    NSInteger pin2dnfDisabled;
    NSInteger pin2dnfArchived;

    NSInteger type2normal;
    NSInteger type2found;
    NSInteger type2dnf;
     */
};

- (id)init;
- (UIImage *)get:(NSInteger)imgnum;
- (UIImage *)getPin:(NSInteger)imgnum found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight;
- (UIImage *)getType:(NSInteger)imgnum found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight;
/*
- (UIImage *)getPinNormal:(NSInteger)imgnum;
- (UIImage *)getPinFound:(NSInteger)imgnum;
- (UIImage *)getPinDNF:(NSInteger)imgnum;
- (UIImage *)getPinDisabled:(NSInteger)imgnum;
- (UIImage *)getPinArchived:(NSInteger)imgnum;
- (UIImage *)getTypeNormal:(NSInteger)imgnum;
- (UIImage *)getTypeFound:(NSInteger)imgnum;
- (UIImage *)getTypeDNF:(NSInteger)imgnum;
- (UIImage *)getPinDisabledFound:(NSInteger)imgnum;
- (UIImage *)getPinArchivedFound:(NSInteger)imgnum;
- (UIImage *)getPinDisabledDNF:(NSInteger)imgnum;
- (UIImage *)getPinArchivedDNF:(NSInteger)imgnum;
 */
- (NSString *)getName:(NSInteger)imgnum;
- (UIImage *)getRating:(float)rating;


@end
