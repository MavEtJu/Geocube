//
//  Coordinates.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct coordinate_type {
    float lat;
    float lon;
} coordinate_type;

@interface Coordinates : NSObject

+ (NSInteger)coordinates2distance:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSInteger)coordinates2bearing:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSString *)bearing2compass:(NSInteger)bearing;
+ (coordinate_type)myLocation;
+ (NSString *)NiceDistance:(NSInteger)i;

@end

coordinate_type MKCoordinates(float lat, float lon);

