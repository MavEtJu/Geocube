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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

typedef enum {
    ImageLibraryImagesMin = -1,

    /* Do not reorder, index matches schema.sql */
    ImageCaches_Benchmark = 100,
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
    ImageCaches_NFI,

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

    ImageContainer_Virtual = 300,
    ImageContainer_Micro,
    ImageContainer_Small,
    ImageContainer_Regular,
    ImageContainer_Large,
    ImageContainer_NotChosen,
    ImageContainer_Other,
    ImageContainer_Unknown,

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

    /* Up to here: Do not reorder */

    ImageLibraryImagesUnsorted = 700,

    ImageMap_pin,
    ImageMap_dnf,
    ImageMap_found,

    ImageMap_crossDNF,
    ImageMap_tickFound,

    ImageCacheView_ratingBase,
    ImageCacheView_ratingOff,
    ImageCacheView_ratingHalf,
    ImageCacheView_ratingOn,
    ImageCacheView_favourites,

    ImageIcon_Smiley,
    ImageIcon_Sad,
    ImageIcon_Target,

    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject {
    UIImage *imgs[ImageLibraryImagesMax];
    UIImage *ratingImages[11];
    NSString *names[ImageLibraryImagesMax];

    NSInteger pin2normal;
    NSInteger pin2found;
    NSInteger pin2dnf;
};

- (id)init;
- (UIImage *)get:(NSInteger)imgnum;
- (UIImage *)getNormal:(NSInteger)imgnum;
- (UIImage *)getFound:(NSInteger)imgnum;
- (UIImage *)getDNF:(NSInteger)imgnum;
- (NSString *)getName:(NSInteger)imgnum;
- (UIImage *)getRating:(float)rating;

@end
