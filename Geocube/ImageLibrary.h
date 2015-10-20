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

    ImageMap_pinheadStart = 600,    // 600 - 630
    ImageMap_pinheadEnd = 630,      // 600 - 630
    ImageMap_pinStart = 631,        // 631 - 662
    ImageMap_pinEnd = 662,          // 631 - 662
    ImageMap_pinEdit,

    /* Up to here: Do not reorder */

    ImageLibraryImagesUnsorted = 700,

    ImageMap_pin,
    ImageMap_dnf,
    ImageMap_found,
    ImageMap_disabled,
    ImageMap_archived,
    ImageMap_background,
    ImageMap_pinOutlineHighlight,

    ImageMap_pinCrossDNF,
    ImageMap_pinTickFound,
    ImageMap_pinOutlineDisabled,
    ImageMap_pinOutlineArchived,
    ImageMap_typeCrossDNF,
    ImageMap_typeTickFound,
    ImageMap_typeOutlineDisabled,
    ImageMap_typeOutlineArchived,

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
    NSMutableDictionary *pinImages, *typeImages;
};

- (instancetype)init;
- (UIImage *)get:(NSInteger)imgnum;
- (UIImage *)getPin:(dbWaypoint *)wp;
- (UIImage *)getType:(dbWaypoint *)wp;
- (UIImage *)getPin:(NSInteger)imgnum found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight;
- (UIImage *)getType:(NSInteger)imgnum found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight;
- (UIImage *)getSquareWithNumber:(NSInteger)num;

- (NSString *)getName:(NSInteger)imgnum;
- (UIImage *)getRating:(float)rating;

- (UIImage *)newPinHead:(UIColor *)color;
- (void)recreatePin:(NSInteger)pin color:(UIColor *)pinColor;
+ (void)RGBtoFloat:(NSString *)rgb r:(float *)r g:(float *)g b:(float *)b;


@end
