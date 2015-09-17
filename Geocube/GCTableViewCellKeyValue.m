//
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

@implementation GCTableViewCellKeyValue

@synthesize keyLabel, valueLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:nil];
    CGRect frame = cell.frame;
    UIFont *font = cell.textLabel.font;

    frame.origin.x += 10;
    frame.size.width -= 2 * 10;

    CGRect rectKey = CGRectMake(frame.origin.x + 10, frame.origin.y, 10 * 10 - 5, frame.size.height);
    CGRect rectValue = CGRectMake(frame.origin.x + 100, frame.origin.y, frame.size.width - 10 * 10, frame.size.height);

    // Name
    keyLabel = [[GCLabel alloc] initWithFrame:rectKey];
    keyLabel.font = font;
    valueLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:keyLabel];

    valueLabel = [[GCLabel alloc] initWithFrame:rectValue];
    valueLabel.font = font;
    [self.contentView addSubview:valueLabel];

    [self changeTheme];

    return self;
}

- (void)changeTheme
{
    [keyLabel changeTheme];
    [valueLabel changeTheme];

    [super changeTheme];
}

@end
