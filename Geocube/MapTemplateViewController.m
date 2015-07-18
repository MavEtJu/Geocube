//
//  MapTemplateViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define NEEDS_OVERLOADING(__name__) \
    - (void) __name__ { NSAssert(0, @"%s should be overloaded for %@", __FUNCTION__, [self class]); }

@implementation MapTemplateViewController

- (id)init:(NSInteger)_type
{
    NSAssert(0, @"loadMarkers should be overloaded for %@", [self class]);
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadMarkers];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [LM startDelegation:self isNavigating:(type == SHOW_ONECACHE)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
}

- (void)whichCachesToSnow:(NSInteger)_type whichCache:(dbCache *)_cache
{
    type = _type;
}

- (void)updateData
{
    [self updateMe];
}

NEEDS_OVERLOADING(updateMe)
NEEDS_OVERLOADING(loadMarkers)

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_caches = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.Caches objectEnumerator];
    dbCache *cache;

    if (type == SHOW_ONECACHE && currentCache != nil) {
        cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:LM.coords];
        caches = @[currentCache];
        cacheCount = [caches count];
        return;
    }

    if (type == SHOW_ALLCACHES) {
        while ((cache = [e nextObject]) != nil) {
            if (searchString != nil && [[cache.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                continue;
            cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:LM.coords];

            [_caches addObject:cache];
        }
        caches = [_caches sortedArrayUsingComparator: ^(dbCache *obj1, dbCache *obj2) {

            if (obj1.calculatedDistance > obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            if (obj1.calculatedDistance < obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        cacheCount = [caches count];
        return;
    }
}

#pragma mark -- Menu related functions

- (void)showCache
{
    showWhom = SHOW_CACHE;
}

- (void)showMe
{
    showWhom = SHOW_ME;
}

- (void)showCacheAndMe
{
    showWhom = SHOW_BOTH;
}

- (void)showWhom:(NSInteger)whom
{
    showWhom = whom;
    if (whom == SHOW_ME)
        [self showMe];
    if (whom == SHOW_CACHE)
        [self showCache];
    if (whom == SHOW_BOTH)
        [self showCacheAndMe];

}


@end