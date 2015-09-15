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

@implementation ThemeNormal

- (id)init
{
    self = [super init];

    {
        UILabel *tv = [[UILabel alloc] init];
        labelTextColor = tv.textColor;
        labelTextColorDisabled = [UIColor darkGrayColor];
        labelBackgroundColor = tv.backgroundColor;

        textColor = tv.textColor;
        backgroundColor = tv.backgroundColor;
    }
    {
        UITableViewCell *tvc = [[UITableViewCell alloc] init];
        tableViewCellBackgroundColor = tvc.backgroundColor;
    }
    {
        UITableView *tv = [[UITableView alloc] init];
        tableViewBackgroundColor = tv.backgroundColor;
    }
    {
        UIView *v = [[UIView alloc] init];
        viewBackgroundColor = v.backgroundColor;
    }

    tableViewCellGradient = NO;

    return self;
}

@end
