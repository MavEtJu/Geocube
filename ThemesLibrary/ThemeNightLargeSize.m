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

@interface ThemeNightLargeSize ()

@end

@implementation ThemeNightLargeSize

- (instancetype)init
{
    self = [super init];

    self.menuLocalIcon = [imageManager get:ImageIcon_LocalMenuNight_Large];
    self.menuGlobalIcon = [imageManager get:ImageIcon_GlobalMenuNight_Large];
    self.menuCloseIcon = [imageManager get:ImageIcon_CloseButton_Large];

    self.mapShowBoth = [imageManager get:ImageIcon_ShowBoth_Large];
    self.mapFindTarget = [imageManager get:ImageIcon_FindTarget_Large];
    self.mapFindMe = [imageManager get:ImageIcon_FindMe_Large];
    self.mapFollowMe = [imageManager get:ImageIcon_FollowMe_Large];
    self.mapSeeTarget = [imageManager get:ImageIcon_SeeTarget_Large];
    self.mapGNSSOn = [imageManager get:ImageIcon_GNSSOn_Large];
    self.mapGNSSOff = [imageManager get:ImageIcon_GNSSOff_Large];

    self.tabBarHeightPortrait = 71;
    self.tabBarHeightLandscape = 59;

    return self;
}

@end
