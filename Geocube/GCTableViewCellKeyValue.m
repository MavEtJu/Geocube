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

@interface GCTableViewCellKeyValue ()

@end

@implementation GCTableViewCellKeyValue

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
    self.keyLabel = [[GCLabel alloc] initWithFrame:rectKey];
    self.keyLabel.font = font;
    self.keyLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.keyLabel];

    self.valueLabel = [[GCLabel alloc] initWithFrame:rectValue];
    self.valueLabel.font = font;
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.valueLabel];

    [self changeTheme];

    return self;
}

- (void)changeTheme
{
    [self.keyLabel changeTheme];
    [self.valueLabel changeTheme];

    [super changeTheme];
}

@end
