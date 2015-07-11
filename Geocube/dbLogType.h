//
//  dbLogTypes.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbLogType : dbObject {
    NSInteger _id;
    NSString *logtype;
    NSInteger icon;
}

@property (nonatomic, retain) NSString *logtype;
@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger icon;

- (id)init:(NSInteger)_id logtype:(NSString *)logtype icon:(NSInteger)icon;

@end
