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

@interface ThemeIOSNormalSize ()

@end

@implementation ThemeIOSNormalSize

- (instancetype)init
{
    self = [super init];

    UISwitch *switch_ = [[UISwitch alloc] init];

    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *blackColor = [UIColor blackColor];

    self.viewControllerBackgroundColor = whiteColor;

    self.labelTextColor = blackColor;
    self.labelTextColorDisabled = [UIColor lightGrayColor];

    UITableViewHeaderFooterView *thfv = [[UITableViewHeaderFooterView alloc] init];
    self.tableHeaderBackground = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    self.tableHeaderTextColor = thfv.textLabel.textColor;

    self.imageBackgroundColor = whiteColor;

    self.labelHighlightBackgroundColor = [UIColor yellowColor];

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.tabBarForegroundColor = blackColor;

    self.svProgressHUDStyle = SVProgressHUDStyleDark;

    self.switchTintColor = switch_.tintColor;
    self.switchOnTintColor = switch_.onTintColor;
    self.switchThumbTintColor = switch_.thumbTintColor;

    self.menuLocalIcon = [imageManager get:ImageIcon_LocalMenuDefault_Normal];
    self.menuGlobalIcon = [imageManager get:ImageIcon_GlobalMenuDefault_Normal];
    self.menuCloseIcon = [imageManager get:ImageIcon_CloseButton_Normal];

    self.mapShowBoth = [imageManager get:ImageIcon_ShowBoth_Normal];
    self.mapFindTarget = [imageManager get:ImageIcon_FindTarget_Normal];
    self.mapFindMe = [imageManager get:ImageIcon_FindMe_Normal];
    self.mapFollowMe = [imageManager get:ImageIcon_FollowMe_Normal];
    self.mapSeeTarget = [imageManager get:ImageIcon_SeeTarget_Normal];
    self.mapGNSSOn = [imageManager get:ImageIcon_GNSSOn_Normal];
    self.mapGNSSOff = [imageManager get:ImageIcon_GNSSOff_Normal];

    self.tabBarHeightPortrait = 58;
    self.tabBarHeightLandscape = 43;

    return self;
}

@end
