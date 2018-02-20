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

@interface GCTableViewCellWithSubtitle ()

@property (nonatomic, weak) IBOutlet GCLabel *myTextLabel;
@property (nonatomic, weak) IBOutlet GCLabel *myDetailLabel;

@end

@implementation GCTableViewCellWithSubtitle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.myTextLabel changeTheme];
    [self.myDetailLabel changeTheme];

    self.myTextLabel.font = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
    self.myDetailLabel.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
}

- (UILabel *)textLabel
{
    return self.myTextLabel;
}

- (UILabel *)detailTextLabel
{
    return self.myDetailLabel;
}

@end
