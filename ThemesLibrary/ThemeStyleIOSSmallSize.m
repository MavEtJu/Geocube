/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface ThemeStyleIOSSmallSize ()

@end

@implementation ThemeStyleIOSSmallSize

- (instancetype)init
{
    self = [super init];

    self.menuLocalIcon = [imageManager get:ImageIcon_LocalMenuDefault_Small];
    self.menuGlobalIcon = [imageManager get:ImageIcon_GlobalMenuDefault_Small];
    self.menuCloseIcon = [imageManager get:ImageIcon_CloseButton_Small];

    self.mapShowBoth = [imageManager get:ImageIcon_ShowBoth_Small];
    self.mapFindTarget = [imageManager get:ImageIcon_FindTarget_Small];
    self.mapFindMe = [imageManager get:ImageIcon_FindMe_Small];
    self.mapFollowMe = [imageManager get:ImageIcon_FollowMe_Small];
    self.mapSeeTarget = [imageManager get:ImageIcon_SeeTarget_Small];
    self.mapGNSSOn = [imageManager get:ImageIcon_GNSSOn_Small];
    self.mapGNSSOff = [imageManager get:ImageIcon_GNSSOff_Small];

    self.tabBarHeightPortrait = 44;
    self.tabBarHeightLandscape = 32;

    return self;
}

@end
