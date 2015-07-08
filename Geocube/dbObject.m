//
//  dbObjects.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dbObjects.h"

@implementation dbObject

- (id)init
{
    self = [super init];
    finished = NO;
    return self;
}

- (void)finish
{
    finished = YES;
}

@end