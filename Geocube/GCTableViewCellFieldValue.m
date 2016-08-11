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

#define __CLASS__GCTABLEVIEWCELLFIELDVALUE__
#import "Geocube-Prefix.pch"

@interface GCTableViewCellFieldValue ()

@end

@implementation GCTableViewCellFieldValue

@synthesize fieldLabel, valueLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:nil];
    CGRect frame = cell.frame;
    frame.origin.x += 10;
    frame.size.width -= 2 * 10;

    // Name
    fieldLabel = [[GCLabel alloc] initWithFrame:frame];
    [self.contentView addSubview:fieldLabel];

    valueLabel = [[GCLabel alloc] initWithFrame:frame];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:valueLabel];

    [self changeTheme];

    return self;
}

- (void)viewWillTransitionToSize
{
    [super viewWillTransitionToSize];

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect labelFrame = fieldLabel.frame;

    labelFrame.size.width = bounds.size.width - 2 * 10;

    fieldLabel.frame = labelFrame;
    valueLabel.frame = labelFrame;
}

- (void)changeTheme
{
    /*
    [fieldLabel changeTheme];
     */
    [super changeTheme];
    [themeManager changeThemeArray:[self.contentView subviews]];

    // Ugh hack because the frame of the value label and the field label overlap
    valueLabel.backgroundColor = [UIColor clearColor];
}

@end
