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

@interface ThemeTemplate : NSObject

@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;

@property (nonatomic, retain) UIColor *labelBackgroundColor;
@property (nonatomic, retain) UIColor *labelTextColor;
@property (nonatomic, retain) UIColor *labelTextColorDisabled;

@property (nonatomic, retain) UIColor *viewBackgroundColor;
@property (nonatomic, retain) UIColor *viewControllerBackgroundColour;

@property (nonatomic, retain) UIColor *tableViewBackgroundColor;

@property (nonatomic, retain) UIColor *tableViewCellBackgroundColor;

@property (nonatomic, retain) UIColor *tabBarBackgroundColor;
@property (nonatomic, retain) UIColor *tabBarForegroundColor;

@property (nonatomic        ) SVProgressHUDStyle svProgressHUDStyle;

@property (nonatomic, retain) UIColor *switchTintColor;
@property (nonatomic, retain) UIColor *switchOnTintColor;
@property (nonatomic, retain) UIColor *switchThumbTintColor;

@property (nonatomic, retain) UIImage *menuLocalIcon;
@property (nonatomic, retain) UIImage *menuGlobalIcon;

@end
