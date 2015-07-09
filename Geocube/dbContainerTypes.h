//
//  dbContainerTypes.h
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbContainerType : dbObject {
    NSInteger _id;
    NSString *size;
    NSInteger icon;
}

@property (nonatomic, retain) NSString *size;
@property (nonatomic) NSInteger _id;
@property (nonatomic) NSInteger icon;

- (id)init:(NSInteger)_id size:(NSString *)size icon:(NSInteger)icon;

@end
