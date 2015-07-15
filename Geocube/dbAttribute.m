//
//  dbAttribute.m
//  Geocube
//
//  Created by Edwin Groothuis on 13/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-prefix.pch"

@implementation dbAttribute

@synthesize _id, icon, label, gc_id, _YesNo;

- (id)init:(NSInteger)__id gc_id:(NSInteger)_gc_id label:(NSString *)_label icon:(NSInteger)_icon
{
    self = [super init];

    icon = _icon;
    label = _label;
    gc_id = _gc_id;
    _id = __id;

    [self finish];
    return self;
}

@end
