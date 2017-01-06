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

@interface WaypointWaypointsTableViewCell ()
{
    CGRect rectName;
    CGRect rectCode;
    CGRect rectCoordinates;
    CGRect rectIconImage;
}

@end

@implementation WaypointWaypointsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.accessoryType = UITableViewCellAccessoryNone;

    // Name
    self.iconImage = [[GCImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.iconImage];

    // Name
    self.nameLabel = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:self.nameLabel];

    // GCCode
    self.codeLabel = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.codeLabel.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:self.codeLabel];

    // Coordinates
    self.coordinatesLabel = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.coordinatesLabel.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:self.coordinatesLabel];

    [self viewWillTransitionToSize];
    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

#define BORDER 1

    NSInteger labelWidth = width - self.imageView.image.size.width;

    rectIconImage = CGRectMake(BORDER, BORDER, self.iconImage.image.size.width, self.iconImage.image.size.height);
    NSInteger labelOffset = rectIconImage.origin.x + rectIconImage.size.width;
    NSLog(@"labeloffset: %ld", labelOffset);

    NSInteger y = 0 + 1;
    rectName = CGRectMake(labelOffset, y, labelWidth, self.nameLabel.font.lineHeight);
    y += self.nameLabel.font.lineHeight + 1;
    rectCode = CGRectMake(labelOffset, y, labelWidth, self.codeLabel.font.lineHeight);
    y += self.codeLabel.font.lineHeight + 1;
    rectCoordinates = CGRectMake(labelOffset, y, labelWidth, self.coordinatesLabel.font.lineHeight);
    y += self.coordinatesLabel.font.lineHeight + 1;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    self.nameLabel.frame = rectName;
    self.codeLabel.frame = rectCode;
    self.coordinatesLabel.frame = rectCoordinates;
    self.iconImage.frame = rectIconImage;
}

- (void)changeTheme
{
    [self.nameLabel changeTheme];
    [self.codeLabel changeTheme];
    [self.coordinatesLabel changeTheme];

    [super changeTheme];
}

- (NSInteger)cellHeight
{
    return self.nameLabel.frame.size.height + self.codeLabel.frame.size.height + self.coordinatesLabel.frame.size.height;
}

@end
