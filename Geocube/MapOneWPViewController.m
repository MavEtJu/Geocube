/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface MapOneWPViewController ()

@end

@implementation MapOneWPViewController

- (instancetype)init:(GCMapHowMany)mapWhat
{
    self = [super init:mapWhat];

    [lmi disableItem:MVCmenuLoadWaypoints];
    [lmi disableItem:MVCmenuExportVisible];

    return self;
}

- (void)refreshWaypointsData
{
    [bezelManager showBezel:self];
    [bezelManager setText:@"Refreshing database"];

    [waypointManager applyFilters:LM.coords];

    if (waypointManager.currentWaypoint != nil) {
        waypointManager.currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:waypointManager.currentWaypoint.coordinates to:LM.coords];
        self.waypointsArray = [NSMutableArray arrayWithArray:@[waypointManager.currentWaypoint]];
        self.waypointCount = [self.waypointsArray count];
    } else {
        self.waypointsArray = nil;
        self.waypointCount = 0;
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.map removeMarkers];
        [self.map placeMarkers];
    }];

    [bezelManager removeBezel];
}

@end
