/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

- (instancetype)init
{
    self = [super init:NO];
    self.followWhom = SHOW_SHOWBOTH;

    [self.lmi disableItem:MVCmenuLoadWaypoints];
    [self.lmi disableItem:MVCmenuExportVisible];

    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // The analyze feature of Xcode will throw here a false positive on:
    // The 'viewDidAppear:' instance method in UIViewController subclass 'MapAllWPViewController' is missing a [super viewDidAppear:] call
    [super viewDidAppear:animated isNavigating:YES];
}

- (void)refreshWaypointsData
{
    [bezelManager showBezel:self];
    [bezelManager setText:_(@"maponewpviewcontroller-Refreshing database")];

    [waypointManager applyFilters:LM.coords];

    if (waypointManager.currentWaypoint != nil) {
        waypointManager.currentWaypoint.calculatedDistance = [Coordinates coordinates2distance:LM.coords toLatitude:waypointManager.currentWaypoint.wpt_latitude toLongitude:waypointManager.currentWaypoint.wpt_longitude];
        self.waypointsArray = [NSMutableArray arrayWithArray:@[waypointManager.currentWaypoint]];
    } else {
        self.waypointsArray = nil;
    }

    MAINQUEUE(
        [self.map removeMarkers];
        [self.map placeMarkers];
    )

    [bezelManager removeBezel];
}

@end
