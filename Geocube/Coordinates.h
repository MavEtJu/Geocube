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

@interface Coordinates : NSObject

- (instancetype)init:(CLLocationDegrees)lat lon:(CLLocationDegrees)log;       // -34.02787 151.07357
- (instancetype)init:(CLLocationCoordinate2D)coor;    // { -34.02787, 151.07357 }
- (instancetype)initString:(NSString *)lat lon:(NSString *)lon;    // S 34 1.672, E 151 4.414
- (CLLocationDegrees)lat;
- (CLLocationDegrees)lon;
- (NSString *)lat_decimalDegreesSigned;     // -34.02787
- (NSString *)lon_decimalDegreesSigned;     // 151.07357
- (NSString *)lat_decimalDegreesCardinal;   // S 34.02787
- (NSString *)lon_decimalDegreesCardinal;   // E 151.07357
- (NSString *)lat_degreesDecimalMinutes;    // S 34° 1.672'
- (NSString *)lon_degreesDecimalMinutes;    // E 151° 4.414'
- (NSString *)lat_degreesDecimalMinutesSimple;    // S 34 1.672
- (NSString *)lon_degreesDecimalMinutesSimple;    // E 151 4.414
- (NSString *)lat_degreesMinutesSeconds;    // S 34° 01' 40"
- (NSString *)lon_degreesMinutesSeconds;    // E 151° 04' 25"
- (NSInteger)distance:(CLLocationCoordinate2D)c;
- (NSInteger)bearing:(CLLocationCoordinate2D)c;

+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSString *)bearing2compass:(CLLocationDegrees)bearing;
+ (NSString *)NiceCoordinates:(CLLocationCoordinate2D)c;
+ (NSString *)NiceCoordinatesForEditing:(CLLocationCoordinate2D)c;
+ (NSString *)NiceLatitude:(CLLocationDegrees)l;
+ (NSString *)NiceLongitude:(CLLocationDegrees)l;
+ (NSString *)NiceLatitudeForEditing:(CLLocationDegrees)l;
+ (NSString *)NiceLongitudeForEditing:(CLLocationDegrees)l;
+ (CLLocationDegrees)degrees2rad:(CLLocationDegrees)d;
+ (void)makeNiceBoundary:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2 d1:(CLLocationCoordinate2D *)d1 d2:(CLLocationCoordinate2D *)d2;

@end
