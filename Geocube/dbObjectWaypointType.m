//
//  dbObjectWaypointType.m
//  Geocube
//
//  Created by Edwin Groothuis on 28/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "dbObjectWaypointType.h"

@implementation dbObjectWaypointType

@synthesize _id, type, icon;

- (id)init:(NSInteger)__id type:(NSString *)_type icon:(NSInteger)_icon
{
    _id = __id;
    type = _type;
    icon = _icon;
    return self;
}

@end
