/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface ThemeTemplate ()

@end

@implementation ThemeTemplate

- (instancetype)init
{
    self = [super init];

    UITableViewCell *tvc = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    self.GCTextblockFont = [UIFont systemFontOfSize:tvc.textLabel.font.pointSize];

    self.GCLabelNormalSizeFont = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
    self.GCLabelSmallSizeFont = [UIFont systemFontOfSize:configManager.fontSmallTextSize];

    self.menuCloseIcon = [imageManager get:ImageIcon_CloseButton_Large];

    self.mapShowBoth = [imageManager get:ImageIcon_ShowBoth_Large];
    self.mapFindTarget = [imageManager get:ImageIcon_FindTarget_Large];
    self.mapFindMe = [imageManager get:ImageIcon_FindMe_Large];
    self.mapFollowMe = [imageManager get:ImageIcon_FollowMe_Large];
    self.mapSeeTarget = [imageManager get:ImageIcon_SeeTarget_Large];
    self.mapGNSSOn = [imageManager get:ImageIcon_GNSSOn_Large];
    self.mapGNSSOff = [imageManager get:ImageIcon_GNSSOff_Large];

    return self;
}

@end
