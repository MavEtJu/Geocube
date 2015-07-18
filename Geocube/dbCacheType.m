//
//  dbWaypointType.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbCacheType

@synthesize _id, type, icon, pin;

- (id)init:(NSInteger)__id type:(NSString *)_type icon:(NSInteger)_icon pin:(NSInteger)_pin
{
    self = [super init];
    _id = __id;
    type = _type;
    icon = _icon;
    pin = _pin;
    [self finish];
    return self;
}

@end
