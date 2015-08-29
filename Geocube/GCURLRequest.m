//
//  GCURLRequest.m
//  Geocube
//
//  Created by Edwin Groothuis on 29/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation GCURLRequest

+ (GCURLRequest *)requestWithURL:url
{
    // Stay out of the local cache as it sucks
    return [GCURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
}

@end

@implementation GCMutableURLRequest

+ (GCMutableURLRequest *)requestWithURL:url
{
    // Stay out of the local cache as it sucks
    return [GCMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
}

@end
