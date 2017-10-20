/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface MapTrackViewController ()

@property (nonatomic, retain) dbTrack *currentTrack;

@end

@implementation MapTrackViewController

- (instancetype)init
{
    self = [super init:YES];
    self.followWhom = SHOW_NEITHER;

    [lmi disableItem:MVCmenuLoadWaypoints];
    [lmi disableItem:MVCmenuExportVisible];

    [lmi disableItem:MVCmenuLoadWaypoints];
    [lmi disableItem:MVCmenuDirections];
    [lmi disableItem:MVCmenuAutoZoom];
    [lmi disableItem:MVCmenuRecenter];
    [lmi disableItem:MVCmenuRemoveTarget];
    [lmi disableItem:MVCmenuShowBoundaries];
    [lmi disableItem:MVCmenuExportVisible];
    [lmi disableItem:MVCmenuRemoveHistory];

    self.currentTrack = nil;

    return self;
}

- (void)showTrack:(dbTrack *)track
{
    self.currentTrack = track;
    [self.map showTrack:track];
}

- (void)showTrack
{
    [self.map showTrack];
}

- (void)refreshWaypointsData
{
    // Nothing
}

- (void)menuChangeMapbrand:(MapBrand *)mapBrand
{
    [super menuChangeMapbrand:mapBrand];
    [self showTrack:self.currentTrack];
}

@end
