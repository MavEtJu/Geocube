//
//  dbImage.h
//  Geocube
//
//  Created by Edwin Groothuis on 10/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbImage : dbObject {
    NSString *url;
    NSString *datafile;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *datafile;

- (id)init:(NSString *)url datafile:(NSString *)datafile;
+ (NSString *)createDataFilename:(NSString *)url;
+ (dbImage *)dbGetByURL:(NSString *)url;
+ (NSId)dbCreate:(dbImage *)img;

@end
