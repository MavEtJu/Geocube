//
//  dbConfig.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbConfig

@synthesize _id, key, value;

- (id)init:(NSInteger)__id key:(NSString *)_key value:(NSString *)_value
{
    self = [super init];
    _id = __id;
    key = _key;
    value = _value;
    [self finish];
    return self;
}

- (void)finish
{
    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", key, value];
}


@end
