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

@interface ThemeNightNormalSize ()

@end

@implementation ThemeNightNormalSize

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
    self.tableHeaderTextColor = lightTextColor;

    self.imageBackgroundColor = lightTextColor;

    self.labelHighlightBackgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.0 alpha:1];

    self.tabBarBackgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:1];
    self.tabBarForegroundColor = lightTextColor;

    self.svProgressHUDStyle = SVProgressHUDStyleLight;

    self.switchTintColor = [UIColor darkGrayColor];
    self.switchOnTintColor = [UIColor darkGrayColor];
    self.switchThumbTintColor = [UIColor lightGrayColor];

    self.menuLocalIcon = [imageManager get:ImageIcon_LocalMenuNight_Normal];
    self.menuGlobalIcon = [imageManager get:ImageIcon_GlobalMenuNight_Normal];
    self.menuCloseIcon = [imageManager get:ImageIcon_CloseButton_Normal];

    self.mapShowBoth = [imageManager get:ImageIcon_ShowBoth_Normal];
    self.mapFindTarget = [imageManager get:ImageIcon_FindTarget_Normal];
    self.mapFindMe = [imageManager get:ImageIcon_FindMe_Normal];
    self.mapFollowMe = [imageManager get:ImageIcon_FollowMe_Normal];
    self.mapSeeTarget = [imageManager get:ImageIcon_SeeTarget_Normal];
    self.mapGNSSOn = [imageManager get:ImageIcon_GNSSOn_Normal];
    self.mapGNSSOff = [imageManager get:ImageIcon_GNSSOff_Normal];

    NSURL *styleUrl = [[NSBundle mainBundle] URLForResource:@"GoogleMapsNight" withExtension:@"json"];
    NSError *error;
    self.googleMapsStyle = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];

    self.tabBarHeightPortrait = 58;
    self.tabBarHeightLandscape = 43;

    return self;
}

@end
