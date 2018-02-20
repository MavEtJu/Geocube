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

#import "DeveloperRemoteAPITableViewCell.h"

@interface DeveloperRemoteAPITableViewCell ()

@end

@implementation DeveloperRemoteAPITableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelLoadWaypoint changeTheme];
    [self.labelStatus changeTheme];
    [self.labelTest changeTheme];
    [self.labelLoadWaypointsByCodes changeTheme];
    [self.labelLoadWaypointsByBoundingBox changeTheme];
    [self.labelUserStatistics changeTheme];
    [self.labelUpdatePersonalNote changeTheme];
    [self.labelListQueries changeTheme];
    [self.labelRetrieveQuery changeTheme];
    [self.labelTrackablesMine changeTheme];
    [self.labelTrackablesInventory changeTheme];
    [self.labelTrackableFind changeTheme];
    [self.labelTrackableDrop changeTheme];
    [self.labelTrackableGrab changeTheme];
    [self.labelTrackableDiscover changeTheme];
}

@end
