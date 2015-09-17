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

@implementation GCTableViewCellRightImage

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect oldImageView = self.imageView.frame;
    CGRect oldTextLabel = self.textLabel.frame;

    /*
     * Swap from 
     * +---+---------------+---+
     * | I | Label         | A |
     * +---+---------------+---+
     * to
     * +---------------+---+---+
     * | Label         | I | A |
     * +---------------+---+---+
     */

    CGRect newImageView = CGRectMake(oldTextLabel.origin.x + oldTextLabel.size.width - oldImageView.size.width, oldImageView.origin.y, oldImageView.size.width, oldImageView.size.height);
    CGRect newTextLabel = CGRectMake(oldImageView.origin.x, oldTextLabel.origin.y, oldTextLabel.size.width, oldTextLabel.size.height);

    self.imageView.frame = newImageView;
    self.textLabel.frame = newTextLabel;

    [self changeTheme];
}

- (void)changeTheme
{
    /*
    self.textLabel.textColor = currentTheme.labelTextColor;
    self.textLabel.backgroundColor = currentTheme.labelBackgroundColor;
     */
    [super changeTheme];
}

@end
