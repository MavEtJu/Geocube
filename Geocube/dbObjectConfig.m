//
//  dbObjectConfig.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "dbObjectConfig.h"

@implementation dbObjectConfig

@synthesize _id, key, value;

- (id)init:(NSInteger)__id key:(NSString *)_key value:(NSString *)_value
{
    _id = __id;
    key = _key;
    value = _value;
    return self;
}

@end
