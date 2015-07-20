/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 * 
 * This file is part of Geocube.
 * 
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation MapTemplateViewController

NEEDS_OVERLOADING(initCamera)
NEEDS_OVERLOADING(initMenu)
NEEDS_OVERLOADING(initMap)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)coord)
NEEDS_OVERLOADING(moveCameraTo:(CLLocationCoordinate2D)c1 c2:(CLLocationCoordinate2D)c2)
NEEDS_OVERLOADING(placeMarkers)
NEEDS_OVERLOADING(setMapType:(NSInteger)mapType)
NEEDS_OVERLOADING(updateMyPosition:(CLLocationCoordinate2D)c);

- (id)init:(NSInteger)_type
{
    self = [super init];
    cachesArray = nil;
    cacheCount = 0;

    showType = _type; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    showWhom = (showType == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_ME;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMenu];
    [self initMap];
    [self initCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshCachesData:nil];
    [self placeMarkers];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@/viewDidAppear", [self class]);
    [super viewDidAppear:animated];
    [LM startDelegation:self isNavigating:(showType == SHOW_ONECACHE)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%@/viewWillDisappear", [self class]);
    [LM stopDelegation:self];
    [super viewWillDisappear:animated];
}

- (void)updateData
{
    meLocation = [LM coords];
    if (showWhom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (showWhom == SHOW_BOTH)
        [self moveCameraTo:currentCache.coordinates c2:meLocation];
}


- (void)refreshCachesData:(NSString *)searchString
{
    NSMutableArray *_caches = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [[dbCache dbAll] objectEnumerator];
    dbCache *cache;

    if (showType == SHOW_ONECACHE) {
        if (currentCache != nil) {
            cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:LM.coords];
            cachesArray = @[currentCache];
            cacheCount = [cachesArray count];
        } else {
            cachesArray = nil;
            cacheCount = 0;
        }
        return;
    }

    if (showType == SHOW_ALLCACHES) {
        while ((cache = [e nextObject]) != nil) {
            if (searchString != nil && [[cache.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                continue;
            cache.calculatedDistance = [Coordinates coordinates2distance:cache.coordinates to:LM.coords];

            [_caches addObject:cache];
        }
        cachesArray = [_caches sortedArrayUsingComparator: ^(dbCache *obj1, dbCache *obj2) {

            if (obj1.calculatedDistance > obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            if (obj1.calculatedDistance < obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        cacheCount = [cachesArray count];
        return;
    }
}

- (void)refreshCachesData
{
    [self refreshCachesData:nil];
}

#pragma mark -- Menu related functions

- (void)menuShowWhom:(NSInteger)whom
{
    showWhom = whom;
    if (whom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (whom == SHOW_CACHE && currentCache != nil)
        [self moveCameraTo:currentCache.coordinates];
    if (whom == SHOW_BOTH && currentCache != nil)
        [self moveCameraTo:currentCache.coordinates c2:meLocation];
}

- (void)menuMapType:(NSInteger)maptype
{
    [self setMapType:maptype];
}

#pragma mark -- User interaction

- (void)userInteraction
{
    showWhom = SHOW_NEITHER;
}

@end
