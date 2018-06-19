/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017, 2018 Edwin Groothuis
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

    [self.lmi disableItem:MVCmenuLoadWaypoints];

    [self.lmi disableItem:MVCmenuLoadWaypoints];
    [self.lmi disableItem:MVCmenuDirections];
    [self.lmi disableItem:MVCmenuAutoZoom];
    [self.lmi disableItem:MVCmenuRecenter];
    [self.lmi disableItem:MVCmenuRemoveTarget];
    [self.lmi disableItem:MVCmenuShowBoundaries];
    [self.lmi disableItem:MVCmenuRemoveHistory];

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

- (void)menuExportVisible
{
    NSArray<dbTrackElement *> *tes = [dbTrackElement dbAllByTrack:self.currentTrack];
    NSString *filename = [ExportGPX exportTrack:self.currentTrack elements:tes];
    [MyTools messageBox:self header:_(@"maptrackviewcontroller-Export successful") text:[NSString stringWithFormat:_(@"maptrackviewcontroller-The exported file '%@' can be found in the Files section"), filename]];
}


@end
