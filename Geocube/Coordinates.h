//
//  Coordinates.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface Coordinates : NSObject {
    CLLocationCoordinate2D coords;
}

- (id)init:(float)lat lon:(float)log;       // -34.02787 151.07357
- (id)init:(CLLocationCoordinate2D)coor;           // { -34.02787, 151.07357 }
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
+ (NSString *)NiceDistance:(NSInteger)i;

@end
