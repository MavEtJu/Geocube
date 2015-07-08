//
//  dbObjectWaypointGroup.m
//  Geocube
//
//  Created by Edwin Groothuis on 29/06/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "dbObjectWaypointGroup.h"

@implementation dbObjectWaypointGroup

@synthesize _id, name, usergroup;

- (id)init:(NSInteger)__id name:(NSString *)_name usergroup:(BOOL)_usergroup
{
    self = [super init];
    _id = __id;
    name = _name;
    usergroup = _usergroup;
    [self finish];
    return self;
}

- (void)finish
{
    [super finish];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %d", name, usergroup];
}

@end
