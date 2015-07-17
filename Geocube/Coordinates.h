//
//  Coordinates.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

typedef struct coordinate_type {
    float lat;
    float lon;
} coordinate_type;

@interface Coordinates : NSObject {
    float lat;
    float lon;
}

- (id)init:(float)lat lon:(float)log;       // -34.02787 151.07357
- (id)init:(coordinate_type)coor;           // { -34.02787, 151.07357 }
- (id)initWithCLLocationCoordinate2D:(CLLocationCoordinate2D)coor;    // { -34.02787, 151.07357 }
- (NSString *)lat_decimalDegreesSigned;     // -34.02787
- (NSString *)lon_decimalDegreesSigned;     // 151.07357
- (NSString *)lat_decimalDegreesCardinal;   // S 34.02787
- (NSString *)lon_decimalDegreesCardinal;   // E 151.07357
- (NSString *)lat_degreesDecimalMinutes;    // S 34° 1.672'
- (NSString *)lon_degreesDecimalMinutes;    // E 151° 4.414
- (NSString *)lat_degreesMinutesSeconds;    // S 34° 01' 40"
- (NSString *)lon_degreesMinutesSeconds;    // E 151° 04' 25"
- (NSInteger)distance:(coordinate_type)c;
- (NSInteger)distanceCLLocationCoordinate2D:(CLLocationCoordinate2D)c;
- (NSInteger)bearing:(coordinate_type)c;
- (NSInteger)bearingCLLocationCoordinate2D:(CLLocationCoordinate2D)c;

+ (NSInteger)coordinates2distance:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSInteger)coordinates2bearing:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSInteger)coordinates2distanceCLLocationCoordinate2D:(coordinate_type)c1 to:(CLLocationCoordinate2D)c2;
+ (NSInteger)coordinates2bearingCLLocationCoordinate2D:(coordinate_type)c1 to:(CLLocationCoordinate2D)c2;
+ (NSString *)bearing2compass:(NSInteger)bearing;
+ (NSString *)NiceDistance:(NSInteger)i;

@end

coordinate_type MKCoordinates(float lat, float lon);

