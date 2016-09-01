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
    Image_Nil = 0,

    /* Do not reorder, index matches schema.sql */
    ImageTypes_Benchmark = 100,     // 100
    ImageTypes_CITO,                // 101
    ImageTypes_EarthCache,          // 102
    ImageTypes_Event,               // 103
    ImageTypes_Giga,                // 104
    ImageTypes_GroundspeakHQ,       // 105
    ImageTypes_Letterbox,           // 106
    ImageTypes_Maze,                // 107
    ImageTypes_Mega,                // 108
    ImageTypes_MultiCache,          // 109
    ImageTypes_Mystery,             // 110
    ImageTypes_Other,               // 111
    ImageTypes_TraditionalCache,    // 112
    ImageTypes_UnknownCache,        // 113
    ImageTypes_VirtualCache,        // 114
    ImageTypes_Waymark,             // 115
    ImageTypes_WebcamCache,         // 116
    ImageTypes_WhereigoCache,       // 117
    ImageTypes_Trigpoint,           // 118
    ImageTypes_Moveable,            // 119
    ImageTypes_History,             // 120
    ImageTypes_Podcast,             // 121
    ImageTypes_Beacon,              // 122
    ImageTypes_BurkeWills,          // 123
    ImageTypes_Night,               // 124
    ImageTypes_NFI,                 // 125

    ImageWaypoints_FinalLocation = 200, // 200
    ImageWaypoints_Flag,                // 201
    ImageWaypoints_MultiStage,          // 202
    ImageWaypoints_ParkingArea,         // 203
    ImageWaypoints_PhysicalStage,       // 204
    ImageWaypoints_ReferenceStage,      // 205
    ImageWaypoints_Trailhead,           // 206
    ImageWaypoints_VirtualStage,        // 207
    Imagewaypoints_NFI,                 // 208
    ImageWaypoints_ManuallyEntered,     // 209
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
    ImageLog_Moved,
    ImageLog_Announcement,

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

    ImageLibraryImagesUnsorted = 700,

    ImageMap_pin,
    ImageMap_dnf,
    ImageMap_found,
    ImageMap_disabled,
    ImageMap_archived,
    ImageMap_background,
    ImageMap_pinOutlineHighlight,

    ImageMap_pinCrossDNF,
    ImageMap_pinMarkedFound,
    ImageMap_pinInProgress,
    ImageMap_pinTickFound,
    ImageMap_pinOwner,
    ImageMap_pinOutlineDisabled,
    ImageMap_pinOutlineArchived,
    ImageMap_typeCrossDNF,
    ImageMap_typeMarkedFound,
    ImageMap_typeInProgress,
    ImageMap_typeTickFound,
    ImageMap_typeOutlineDisabled,
    ImageMap_typeOutlineArchived,
    ImageMap_typeOwner,

    ImageCacheView_ratingBase,
    ImageCacheView_ratingOff,
    ImageCacheView_ratingHalf,
    ImageCacheView_ratingOn,
    ImageCacheView_favourites,

    ImageIcon_Smiley,
    ImageIcon_Sad,
    ImageIcon_Dead,
    ImageIcon_Target,

    ImageIcon_GlobalMenu,
    ImageIcon_LocalMenu,
    ImageIcon_CloseButton,
    ImageIcon_ShowBoth,
    ImageIcon_SeeTarget,
    ImageIcon_FollowMe,
    ImageIcon_FindMe,
    ImageIcon_FindTarget,

    Image_NoImageFile,

    ImageCompass_RedArrowOnBlueCompass,
    ImageCompass_RedArrowOnBlueArrow,
    ImageCompass_WhiteArrowOnBlack,
    ImageCompass_RedArrowOnBlack,
    ImageCompass_AirplaneAirplane,
    ImageCompass_AirplaneCompass,

    ImageLibraryImagesMax
} ImageLibraryImages;

@interface ImageLibrary : NSObject

- (instancetype)init;
- (UIImage *)get:(NSInteger)imgnum;
- (UIImage *)getPin:(dbWaypoint *)wp;
- (UIImage *)getType:(dbWaypoint *)wp;

- (UIImage *)getPin:(dbPin *)pin found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF;
- (UIImage *)getType:(dbType *)type found:(NSInteger)found disabled:(BOOL)disabled archived:(BOOL)archived highlight:(BOOL)highlight owner:(BOOL)owner markedFound:(BOOL)markedFound inProgress:(BOOL)inProgress markedDNF:(BOOL)markedDNF;

- (UIImage *)getSquareWithNumber:(NSInteger)num;

- (NSString *)getName:(NSInteger)imgnum;
- (UIImage *)getRating:(float)rating;

+ (UIImage *)newPinHead:(UIColor *)color;

+ (void)RGBtoFloat:(NSString *)rgb r:(float *)r g:(float *)g b:(float *)b;
+ (UIColor *)RGBtoColor:(NSString *)rgb;
+ (NSString *)ColorToRGB:(UIColor *)c;
+ (UIImage *)circleWithColour:(UIColor *)c;


@end
