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

@interface GCTableViewCell ()

@end

@implementation GCTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self changeTheme];

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self changeTheme];
}

- (void)changeTheme
{
    self.textLabel.textColor = currentStyleTheme.labelTextColor;
    self.textLabel.font = currentStyleTheme.GCLabelNormalSizeFont;
    self.detailTextLabel.textColor = currentStyleTheme.labelTextColor;
    self.detailTextLabel.font = currentStyleTheme.GCLabelSmallSizeFont;
    self.backgroundColor = [UIColor clearColor];

    [themeManager changeThemeStyleArray:self.subviews];
}

- (void)calculateRects
{
    /* NOP */
}

- (void)calculateCellHeight
{
    /* NOP */
}

- (void)viewWillTransitionToSize
{
    /* NOP */
}

@end
