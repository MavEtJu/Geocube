//
//  My Tools.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_My_Tools_h
#define Geocube_My_Tools_h

@interface MyTools : NSObject

+ (NSString *)DocumentRoot;
+ (NSString *)DataDistributionDirectory;
+ (NSString *)FilesDir;
+ (NSInteger)secondsSinceEpoch:(NSString *)datetime;
+ (NSString *)simpleHTML:(NSString *)plainText;
+ (NSInteger)numberOfLines:(NSString *)s;

@end
#endif
