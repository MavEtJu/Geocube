//
//  dbObjectConfig.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dbObjectConfig : NSObject {
    NSString *key;
    NSString *value;
    NSInteger _id;
}

@property NSString *key;
@property NSString *value;
@property NSInteger _id;


- (id)init:(NSInteger)_id key:(NSString *)key value:(NSString *)value;

@end
