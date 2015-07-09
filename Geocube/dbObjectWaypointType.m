//
//  dbObjectWaypointType.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geosphere-Prefix.pch"

@implementation dbObjectWaypointType

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

- (void)finish
{
    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %ld", type, icon];
}

@end
