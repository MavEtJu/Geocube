//
//  dbLogTypes.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbLogType

@synthesize _id, logtype, icon;

- (id)init:(NSInteger)__id logtype:(NSString *)_logtype icon:(NSInteger)_icon
{
    self = [super init];
    _id = __id;
    logtype = _logtype;
    icon = _icon;
    return self;
}

- (void)finish
{
    [super finish];
}

@end
