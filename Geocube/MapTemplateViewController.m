//
//  MapTemplateViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 14/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation MapTemplateViewController

- (id)init:(NSInteger)_type
{
    NSAssert(0, @"loadMarkers should be overloaded for %@", [self class]);
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadMarkers];
}

- (void)whichCachesToSnow:(NSInteger)_type whichCache:(dbCache *)_cache
{
    type = _type;
    thatCache = _cache;
}

- (void)loadMarkers
{
    NSAssert(0, @"loadMarkers should be overloaded for %@", [self class]);
}

- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_caches = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.Caches objectEnumerator];
    dbCache *cache;

    if (type == SHOW_ONECACHE) {
        cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:[Coordinates myLocation]];
        caches = @[thatCache];
        cacheCount = [caches count];
        return;
    }

    if (type == SHOW_ALLCACHES) {
        while ((cache = [e nextObject]) != nil) {
            if (searchString != nil && [[cache.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                continue;
            cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:[Coordinates myLocation]];

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

#pragma mark ----

@end