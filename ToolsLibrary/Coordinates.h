/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface Coordinates : NSObject

#define CLLocationCoordinate2DZero  CLLocationCoordinate2DMake(0, 0)

typedef NS_ENUM(NSInteger, CoordinatesType) {
    COORDINATES_DEGREES_DECIMALMINUTES = 0,
    COORDINATES_DEGREES_SIGNED,
    COORDINATES_DEGREES_CARDINAL,
    COORDINATES_DEGREES_MINUTES_SECONDS,
    COORDINATES_OPENLOCATIONCODE,
    COORDINATES_UTM,
    COORDINATES_MGRS,
    COORDINATES_MAX,
};

- (instancetype)init:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude; // -34.02787 151.07357
- (instancetype)init:(CLLocationCoordinate2D)coor;                      // { -34.02787, 151.07357 }
- (instancetype)initString:(NSString *)latitude longitude:(NSString *)longitude;         // S 34 1.672, E 151 4.414
- (CLLocationDegrees)latitude;
- (CLLocationDegrees)longitude;
- (CLLocationCoordinate2D)coordinates;
- (NSString *)lat_decimalDegreesSigned;         // -34.02787
- (NSString *)lon_decimalDegreesSigned;         // 151.07357
- (NSString *)lat_decimalDegreesCardinal;       // S 34.02787
- (NSString *)lon_decimalDegreesCardinal;       // E 151.07357
- (NSString *)lat_degreesDecimalMinutes;        // S 34° 1.672'
- (NSString *)lon_degreesDecimalMinutes;        // E 151° 4.414'
- (NSString *)lat_degreesDecimalMinutesSimple;  // S 34 1.672
- (NSString *)lon_degreesDecimalMinutesSimple;  // E 151 4.414
- (NSString *)lat_degreesMinutesSeconds;        // S 34° 01' 40"
- (NSString *)lon_degreesMinutesSeconds;        // E 151° 04' 25"
- (NSInteger)distance:(CLLocationCoordinate2D)c;
- (NSInteger)distance:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
- (NSInteger)bearing:(CLLocationCoordinate2D)c;
- (NSInteger)bearing:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

+ (NSInteger)latitudeToTile:(CLLocationDegrees)latitude zoom:(NSInteger)zoom;
+ (NSInteger)longitudeToTile:(CLLocationDegrees)longitude zoom:(NSInteger)zoom;

+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude;
+ (NSInteger)coordinates2distance:(CLLocationDegrees)c1Latitude fromLongitude:(CLLocationDegrees)c1Longitude toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude;
+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 toLatitude:(CLLocationDegrees)c2Latitude toLongitude:(CLLocationDegrees)c2Longitude;
+ (NSInteger)coordinates2bearing:(CLLocationDegrees)c1Latitude fromLongitude:(CLLocationDegrees)c1Longitude to:(CLLocationCoordinate2D)c2;
+ (NSString *)bearing2compass:(CLLocationDegrees)bearing;

+ (CLLocationCoordinate2D)coordinatesPlusOffset:(CLLocationCoordinate2D)c offset:(CLLocationCoordinate2D)o;
+ (CLLocationCoordinate2D)coordinatesMinusOffset:(CLLocationCoordinate2D)c offset:(CLLocationCoordinate2D)o;
+ (CLLocationCoordinate2D)location:(CLLocationCoordinate2D)origin bearing:(float)bearing distance:(float)distanceMeters;

- (NSString *)niceCoordinates;
+ (NSString *)niceCoordinates:(CLLocationCoordinate2D)c;
+ (NSString *)niceCoordinates:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (NSString *)niceCoordinatesForEditing:(CLLocationCoordinate2D)c;
+ (NSString *)niceLatitude:(CLLocationDegrees)l;
+ (NSString *)niceLongitude:(CLLocationDegrees)l;
+ (NSString *)niceLatitudeForEditing:(CLLocationDegrees)l;
+ (NSString *)niceLongitudeForEditing:(CLLocationDegrees)l;

+ (CLLocationDegrees)degrees2rad:(CLLocationDegrees)d;
+ (CLLocationDegrees)rad2degrees:(CLLocationDegrees)r;

+ (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2 boundaryPercentage:(NSInteger)boundaryPercentage;

+ (BOOL)checkCoordinate:(NSString *)text;
+ (NSInteger)scanForWaypoints:(NSArray<NSString *> *)lines waypoint:(NSObject *)waypoint view:(UIViewController *)vc;

+ (NSArray<NSString *> *)coordinateTypes;

@end
