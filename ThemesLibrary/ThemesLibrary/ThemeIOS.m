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

#import "ThemeIOS.h"

@interface ThemeIOS ()

@end

@implementation ThemeIOS

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
    self.tableHeaderBackground = thfv.textLabel.backgroundColor;
    self.tableHeaderTextColor = thfv.textLabel.textColor;

    self.imageBackgroundColor = whiteColor;

    self.labelHighlightBackgroundColor = [UIColor yellowColor];

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.tabBarForegroundColor = blackColor;

    self.svProgressHUDStyle = SVProgressHUDStyleDark;

    self.switchTintColor = switch_.tintColor;
    self.switchOnTintColor = switch_.onTintColor;
    self.switchThumbTintColor = switch_.thumbTintColor;

    self.menuLocalIcon = [imageLibrary get:ImageIcon_LocalMenuDefault];
    self.menuGlobalIcon = [imageLibrary get:ImageIcon_GlobalMenuDefault];

    return self;
}

@end
