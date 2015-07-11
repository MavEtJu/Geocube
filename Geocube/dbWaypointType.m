//
//  dbWaypointType.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbWaypointType

@synthesize _id, type, icon;

- (id)init:(NSInteger)__id type:(NSString *)_type icon:(NSInteger)_icon
{
    self = [super init];
    _id = __id;
    type = _type;
    icon = _icon;
    [self finish];
    return self;
}

@end
