//
//  dbSizes.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbContainerSize

@synthesize _id, size, icon;

- (id)init:(NSInteger)__id size:(NSString *)_size icon:(NSInteger)_icon
{
    self = [super init];
    _id = __id;
    size = _size;
    icon = _icon;
    [self finish];
    return self;
}

@end
