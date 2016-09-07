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

@interface ThemeNormal ()

@end

@implementation ThemeNormal

- (instancetype)init
{
    self = [super init];

    UILabel *label = [[UILabel alloc] init];
    UISwitch *switch_ = [[UISwitch alloc] init];
    UIView *view = [[UIView alloc] init];
    UITableView *tableView = [[UITableView alloc] init];
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];

    labelTextColor = label.textColor;
    labelTextColorDisabled = [UIColor lightGrayColor];
    labelBackgroundColor = label.backgroundColor;

    backgroundColor = label.backgroundColor;
    textColor = label.textColor;

    tableViewCellBackgroundColor = tableViewCell.backgroundColor;
    tableViewBackgroundColor = tableView.backgroundColor;
    viewBackgroundColor = view.backgroundColor;

    tableViewCellGradient = NO;

    svProgressHUDStyle = SVProgressHUDStyleDark;

    switchTintColor = switch_.tintColor;
    switchOnTintColor = switch_.onTintColor;
    switchThumbTintColor = switch_.thumbTintColor;

    return self;
}

@end
