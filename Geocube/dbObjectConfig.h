//
//  dbObjectConfig.h
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#ifndef Geocube_dbObjectConfig_h
#define Geocube_dbObjectConfig_h

#import <Foundation/Foundation.h>
#import "dbObject.h"

@interface dbObjectConfig : dbObject {
    NSString *key;
    NSString *value;
    NSInteger _id;
}

@property NSInteger _id;
@property NSString *key;
@property NSString *value;

- (id)init:(NSInteger)_id key:(NSString *)key value:(NSString *)value;

@end

#endif
