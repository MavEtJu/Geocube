//
//  My Tools.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_My_Tools_h
#define Geocube_My_Tools_h

typedef struct coordinate_type {
    float lat;
    float lon;
} coordinate_type;

@interface MyTools : NSObject

+ (NSString *)DocumentRoot;
+ (NSString *)DataDistributionDirectory;
+ (NSString *)FilesDir;
+ (NSInteger)coordinates2distance:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSInteger)coordinates2bearing:(coordinate_type)c1 to:(coordinate_type)c2;
+ (NSString *)bearing2compass:(NSInteger)bearing;
+ (coordinate_type)myLocation;
+ (NSString *)NiceDistance:(NSInteger)i;

@end

#endif
