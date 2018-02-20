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

@interface ThemeTemplate : NSObject

@property (nonatomic, retain) UIColor *viewControllerBackgroundColor;

@property (nonatomic, retain) UIColor *labelHighlightBackgroundColor;
@property (nonatomic, retain) UIColor *labelTextColor;
@property (nonatomic, retain) UIColor *labelTextColorDisabled;

@property (nonatomic, retain) UIColor *tableHeaderBackground;
@property (nonatomic, retain) UIColor *tableHeaderTextColor;

@property (nonatomic, retain) UIColor *imageBackgroundColor;

@property (nonatomic, retain) UIColor *tabBarBackgroundColor;
@property (nonatomic, retain) UIColor *tabBarForegroundColor;

@property (nonatomic        ) SVProgressHUDStyle svProgressHUDStyle;
@property (nonatomic        ) NSInteger tabBarHeightLandscape;
@property (nonatomic        ) NSInteger tabBarHeightPortrait;

@property (nonatomic, retain) UIColor *switchTintColor;
@property (nonatomic, retain) UIColor *switchOnTintColor;
@property (nonatomic, retain) UIColor *switchThumbTintColor;

@property (nonatomic, retain) UIImage *menuLocalIcon;
@property (nonatomic, retain) UIImage *menuGlobalIcon;
@property (nonatomic, retain) UIImage *menuCloseIcon;

@property (nonatomic, retain) UIImage *mapShowBoth;
@property (nonatomic, retain) UIImage *mapFindTarget;
@property (nonatomic, retain) UIImage *mapFindMe;
@property (nonatomic, retain) UIImage *mapFollowMe;
@property (nonatomic, retain) UIImage *mapSeeTarget;
@property (nonatomic, retain) UIImage *mapGNSSOff;
@property (nonatomic, retain) UIImage *mapGNSSOn;

@property (nonatomic, retain) GMSMapStyle *googleMapsStyle;

// UI settings

@property (nonatomic, retain) UIFont *GCLabelSmallSizeFont;
@property (nonatomic, retain) UIFont *GCLabelNormalSizeFont;
@property (nonatomic, retain) UIFont *GCTextblockFont;

@end
