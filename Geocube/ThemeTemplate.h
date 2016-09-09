/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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
{
    UIColor *backgroundColor;
    UIColor *textColor;

    UIColor *labelTextColor;
    UIColor *labelTextColorDisabled;
    UIColor *labelBackgroundColor;

    UIColor *viewBackgroundColor;
    UIColor *viewControllerBackgroundColour;

    UIColor *tableViewBackgroundColor;
    UIColor *tableViewCellBackgroundColor;

    SVProgressHUDStyle svProgressHUDStyle;

    UIColor *switchTintColor;
    UIColor *switchOnTintColor;
    UIColor *switchThumbTintColor;
}

@property (readonly, nonatomic, retain) UIColor *backgroundColor;
@property (readonly, nonatomic, retain) UIColor *textColor;

@property (readonly, nonatomic, retain) UIColor *labelBackgroundColor;
@property (readonly, nonatomic, retain) UIColor *labelTextColor;
@property (readonly, nonatomic, retain) UIColor *labelTextColorDisabled;

@property (readonly, nonatomic, retain) UIColor *viewBackgroundColor;
@property (readonly, nonatomic, retain) UIColor *viewControllerBackgroundColour;

@property (readonly, nonatomic, retain) UIColor *tableViewBackgroundColor;

@property (readonly, nonatomic, retain) UIColor *tableViewCellBackgroundColor;

@property (readonly, nonatomic        ) SVProgressHUDStyle svProgressHUDStyle;

@property (readonly, nonatomic, retain) UIColor *switchTintColor;
@property (readonly, nonatomic, retain) UIColor *switchOnTintColor;
@property (readonly, nonatomic, retain) UIColor *switchThumbTintColor;

@end
