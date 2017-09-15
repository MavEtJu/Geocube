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

#import "ThemeNight.h"

#import "ManagersLibrary/ImageLibrary.h"

@interface ThemeNight ()

@end

@implementation ThemeNight

- (instancetype)init
{
    self = [super init];

    UIColor *blackColor = [UIColor blackColor];
    UIColor *lightTextColor = [UIColor lightTextColor];
    UIColor *darkGrayColor = [UIColor darkGrayColor];

    self.viewControllerBackgroundColor = blackColor;

    self.labelTextColor = lightTextColor;
    self.labelTextColorDisabled = darkGrayColor;

    self.tableHeaderBackground = darkGrayColor;
    self.tableHeaderTextColor = lightTextColor; //[UIColor greenColor]; //thfv.textLabel.backgroundColor;

    self.imageBackgroundColor = lightTextColor;

    self.labelHighlightBackgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.0 alpha:1];

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:1];
    self.tabBarForegroundColor = lightTextColor;

    self.svProgressHUDStyle = SVProgressHUDStyleLight;

    self.switchTintColor = [UIColor darkGrayColor];
    self.switchOnTintColor = [UIColor darkGrayColor];
    self.switchThumbTintColor = [UIColor lightGrayColor];

    self.menuLocalIcon = [imageLibrary get:ImageIcon_LocalMenuNight];
    self.menuGlobalIcon = [imageLibrary get:ImageIcon_GlobalMenuNight];

    return self;
}

@end
