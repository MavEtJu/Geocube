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

#import "Geocube-Prefix.pch"

@implementation ThemeGeosphere

- (instancetype)init
{
    self = [super init];

    tableViewBackgroundColor = [UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1];
    viewBackgroundColor = [UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1];
    tableViewCellBackgroundColor = [UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1];

    tableViewCellGradient = YES;
    tableViewCellGradient1 = [UIColor colorWithRed:232/255.0 green:223/255.0 blue:175/255.0 alpha:1];
    tableViewCellGradient2 = [UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1];

    return self;
}

@end
