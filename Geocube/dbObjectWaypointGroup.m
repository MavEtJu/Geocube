//
//  dbObjectWaypointGroup.m
//  Geocube
//
//  Created by Edwin Groothuis on 29/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "dbObjectWaypointGroup.h"

@implementation dbObjectWaypointGroup

@synthesize _id, name;

- (id)init:(NSInteger)__id name:(NSString *)_name
{
    _id = __id;
    name = _name;
    return self;
}

@end
