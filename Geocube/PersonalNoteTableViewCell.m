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

@implementation PersonalNoteTableViewCell

@synthesize log, name;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;

    /*
     +---+------+-----------------+
     | Name                       |
     +---+------+-----------------|
     | Log                        |
     |                            |
     +----------------------------+
     */
#define BORDER 1
#define HEIGHT_NAME  15

    CGRect rectName = CGRectMake(BORDER, BORDER, width - 2 * BORDER, HEIGHT_NAME);
    CGRect rectLog = CGRectMake(BORDER, BORDER + HEIGHT_NAME, width - 2 * BORDER, 30);

    // Name
    name = [[UILabel alloc] initWithFrame:rectName];
    name.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:name];

    // Log
    log = [[UILabel alloc] initWithFrame:rectLog];
    log.font = [UIFont systemFontOfSize:12.0];
    log.numberOfLines = 0;
    [self.contentView addSubview:log];

    return self;
}

@end
