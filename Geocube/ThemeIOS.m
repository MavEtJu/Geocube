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

@interface ThemeIOS ()

@end

@implementation ThemeIOS

- (instancetype)init
{
    self = [super init];

    UISwitch *switch_ = [[UISwitch alloc] init];

    UIColor *bgColor = [UIColor whiteColor];
    UIColor *fgColor = [UIColor blackColor];
    UIColor *clearColor = [UIColor clearColor];

    self.labelTextColor = fgColor;
    self.labelTextColorDisabled = [UIColor lightGrayColor];
    self.labelBackgroundColor = clearColor;

    self.labelHighlightBackgroundColor = [UIColor yellowColor];

    self.backgroundColor = bgColor;
    self.textColor = fgColor;

    self.tableViewCellBackgroundColor = bgColor;
    self.tableViewBackgroundColor = bgColor;

    // Use label here instead of an UIView because that UIView is always black for the background colour.
    self.viewBackgroundColor = bgColor;
    self.viewControllerBackgroundColour = bgColor;

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    self.tabBarForegroundColor = fgColor;

    self.svProgressHUDStyle = SVProgressHUDStyleDark;

    self.switchTintColor = switch_.tintColor;
    self.switchOnTintColor = switch_.onTintColor;
    self.switchThumbTintColor = switch_.thumbTintColor;

    self.menuLocalIcon = [imageLibrary get:ImageIcon_LocalMenuDefault];
    self.menuGlobalIcon = [imageLibrary get:ImageIcon_GlobalMenuDefault];

    return self;
}

@end
