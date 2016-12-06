/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface ThemeNight ()

@end

@implementation ThemeNight

- (instancetype)init
{
    self = [super init];

    UIColor *bgColor = [UIColor blackColor];
    UIColor *fgColor = [UIColor lightTextColor];
    UIColor *clearColor = [UIColor clearColor];

    self.labelTextColor = fgColor;
    self.labelTextColorDisabled = [UIColor darkGrayColor];
    self.labelBackgroundColor = clearColor;

    self.backgroundColor = bgColor;
    self.textColor = fgColor;

    self.tableViewBackgroundColor = bgColor;
    self.tableViewCellBackgroundColor = bgColor;

    self.viewBackgroundColor = bgColor;
    self.viewControllerBackgroundColour = bgColor;

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:1];
    self.tabBarForegroundColor = fgColor;

    self.svProgressHUDStyle = SVProgressHUDStyleLight;

    self.switchTintColor = [UIColor darkGrayColor];
    self.switchOnTintColor = [UIColor darkGrayColor];
    self.switchThumbTintColor = [UIColor lightGrayColor];

    self.menuLocalIcon = [imageLibrary get:ImageIcon_LocalMenuNight];
    self.menuGlobalIcon = [imageLibrary get:ImageIcon_GlobalMenuNight];

    return self;
}

@end
