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
NEEDS_OVERLOADING(removeMarkers)
NEEDS_OVERLOADING(addLineMeToWaypoint)
NEEDS_OVERLOADING(removeLineMeToWaypoint)
NEEDS_OVERLOADING(setMapType:(NSInteger)mapType)
NEEDS_OVERLOADING(updateMyPosition:(CLLocationCoordinate2D)c);

- (id)init:(NSInteger)_type
{
    self = [super init];
    waypointsArray = nil;
    waypointCount = 0;

    showType = _type; /* SHOW_ONECACHE or SHOW_ALLCACHES */
    showWhom = (showType == SHOW_ONECACHE) ? SHOW_BOTH : SHOW_ME;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self initMenu];
    [self initMap];
    [self initCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshWaypointsData:nil];
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

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%@/viewDidDisappear", [self class]);
    [self removeMarkers];
    [super viewWillDisappear:animated];
}

/* Delegated from CLLocation */
- (void)updateData
{
    meLocation = [LM coords];
    if (showWhom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (showWhom == SHOW_BOTH)
        [self moveCameraTo:currentWaypoint.coordinates c2:meLocation];

    [self removeLineMeToWaypoint];
    if (currentWaypoint != nil)
        [self addLineMeToWaypoint];
}


- (void)refreshWaypointsData:(NSString *)searchString
{
    NSMutableArray *wps = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [[dbWaypoint dbAll] objectEnumerator];
    dbWaypoint *wp;

    if (showType == SHOW_ONECACHE) {
        if (currentWaypoint != nil) {
            currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:currentWaypoint.coordinates to:LM.coords];
            waypointsArray = @[currentWaypoint];
            waypointCount = [waypointsArray count];
        } else {
            waypointsArray = nil;
            waypointCount = 0;
        }
        return;
    }

    if (showType == SHOW_ALLCACHES) {
        while ((wp = [e nextObject]) != nil) {
            if (searchString != nil && [[wp.description lowercaseString] containsString:[searchString lowercaseString]] == NO)
                continue;
            wp.calculatedDistance = [Coordinates coordinates2distance:wp.coordinates to:LM.coords];

            [wps addObject:wp];
        }
        waypointsArray = [wps sortedArrayUsingComparator: ^(dbWaypoint *obj1, dbWaypoint *obj2) {

            if (obj1.calculatedDistance > obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedDescending;
            }

            if (obj1.calculatedDistance < obj2.calculatedDistance) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        waypointCount = [waypointsArray count];
        return;
    }
}

- (void)refreshWaypointsData
{
    [self refreshWaypointsData:nil];
}

#pragma mark -- Menu related functions

- (void)menuShowWhom:(NSInteger)whom
{
    showWhom = whom;
    if (whom == SHOW_ME)
        [self moveCameraTo:meLocation];
    if (whom == SHOW_CACHE && currentWaypoint != nil)
        [self moveCameraTo:currentWaypoint.coordinates];
    if (whom == SHOW_BOTH && currentWaypoint != nil)
        [self moveCameraTo:currentWaypoint.coordinates c2:meLocation];
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

- (void)openWaypointView:(NSString *)name
{
    NSId _id = [dbWaypoint dbGetByName:name];
    dbWaypoint *wp = [dbWaypoint dbGet:_id];

    CacheViewController *newController = [[CacheViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [newController showWaypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = wp.name;
    [self.navigationController pushViewController:newController animated:YES];
}

@end
