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

@interface Coordinates : NSObject {
    CLLocationCoordinate2D coords;
}

- (id)init:(float)lat lon:(float)log;       // -34.02787 151.07357
- (id)init:(CLLocationCoordinate2D)coor;    // { -34.02787, 151.07357 }
- (id)initString:(NSString *)lat lon:(NSString *)lon;    // S 34 1.672, E 151 4.414
- (float)lat;
- (float)lon;
- (NSString *)lat_decimalDegreesSigned;     // -34.02787
- (NSString *)lon_decimalDegreesSigned;     // 151.07357
- (NSString *)lat_decimalDegreesCardinal;   // S 34.02787
- (NSString *)lon_decimalDegreesCardinal;   // E 151.07357
- (NSString *)lat_degreesDecimalMinutes;    // S 34° 1.672'
- (NSString *)lon_degreesDecimalMinutes;    // E 151° 4.414
- (NSString *)lat_degreesMinutesSeconds;    // S 34° 01' 40"
- (NSString *)lon_degreesMinutesSeconds;    // E 151° 04' 25"
- (NSInteger)distance:(CLLocationCoordinate2D)c;
- (NSInteger)bearing:(CLLocationCoordinate2D)c;

+ (NSInteger)coordinates2distance:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSInteger)coordinates2bearing:(CLLocationCoordinate2D)c1 to:(CLLocationCoordinate2D)c2;
+ (NSString *)bearing2compass:(NSInteger)bearing;
+ (NSString *)NiceCoordinates:(CLLocationCoordinate2D)c;
+ (float)degrees2rad:(NSInteger)d;

@end
