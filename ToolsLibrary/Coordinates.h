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
    COORDINATES_DEGREES_DECIMALMINUTES = 0,     // S 12° 34.567
    COORDINATES_DECIMALDEGREES_SIGNED,          // -12.34567
    COORDINATES_DECIMALDEGREES_CARDINAL,        // S 12.34567
    COORDINATES_DEGREES_MINUTES_SECONDS,        // S 12° 34′ 56″
    COORDINATES_OPENLOCATIONCODE,               // 2345678+9CF
    COORDINATES_UTM,                            // 51H 326625E 6222609N
    COORDINATES_MAX,
    COORDINATES_MGRS,                           // 51H 326625E 6222609N
};

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;    // -34.02787 151.07357
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coor;                                       // { -34.02787, 151.07357 }
- (instancetype)initWithStringLatitude:(NSString *)latitude longitude:(NSString *)longitude;            // S 34 1.672, E 151 4.414

- (CLLocationDegrees)latitude;
- (CLLocationDegrees)longitude;
- (CLLocationCoordinate2D)coordinates;
- (NSString *)lat;
- (NSString *)lat:(CoordinatesType)coordType;
- (NSString *)lon;
- (NSString *)lon:(CoordinatesType)coordType;
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
- (NSString *)niceCoordinates:(CoordinatesType)coordType;
+ (NSString *)niceCoordinates:(CLLocationCoordinate2D)c;
+ (NSString *)niceCoordinates:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
+ (NSString *)niceCoordinatesForEditing:(CLLocationCoordinate2D)c;

+ (NSString *)niceLatitude:(CLLocationDegrees)l;
+ (NSString *)niceLatitude:(CLLocationDegrees)l coordType:(CoordinatesType)coordType;
+ (NSString *)niceLongitude:(CLLocationDegrees)l;
+ (NSString *)niceLongitude:(CLLocationDegrees)l coordType:(CoordinatesType)coordType;
+ (NSString *)niceLatitudeForEditing:(CLLocationDegrees)l;
+ (NSString *)niceLatitudeForEditing:(CLLocationDegrees)l coordType:(CoordinatesType)coordType;
+ (NSString *)niceLongitudeForEditing:(CLLocationDegrees)l;
+ (NSString *)niceLongitudeForEditing:(CLLocationDegrees)l coordType:(CoordinatesType)coordType;

+ (CLLocationDegrees)degrees2rad:(CLLocationDegrees)d;
+ (CLLocationDegrees)rad2degrees:(CLLocationDegrees)r;

+ (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2 boundaryPercentage:(NSInteger)boundaryPercentage;

+ (BOOL)checkCoordinate:(NSString *)text;
+ (BOOL)checkCoordinate:(NSString *)text coordType:(CoordinatesType)coordType;
+ (NSInteger)scanForWaypoints:(NSArray<NSString *> *)lines waypoint:(NSObject *)waypoint view:(UIViewController *)vc;

+ (NSArray<NSString *> *)coordinateTypes;

@end
