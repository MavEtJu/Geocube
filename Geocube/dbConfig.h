//
//  dbConfig.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbConfig_h
#define Geocube_dbConfig_h

@interface dbConfig : dbObject {
    NSString *key;
    NSString *value;
    NSInteger _id;
}

@property (nonatomic) NSInteger _id;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

- (id)init:(NSInteger)_id key:(NSString *)key value:(NSString *)value;

@end

#endif
