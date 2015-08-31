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

@implementation NoticeTableViewCell

@synthesize noteLabel, senderLabel, dateLabel, seen;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;

    /*
     +---------------------+------+
     | Sender              | Date |
     +---------------------+------|
     | Note                       |
     |                            |
     +----------------------------+
     */
#define BORDER 1
#define HEIGHT_NAME  15
#define WIDTH_DATE 100

    CGRect rectSender = CGRectMake(BORDER, BORDER, width - 2 * BORDER - WIDTH_DATE, HEIGHT_NAME);
    CGRect rectDate = CGRectMake(width - WIDTH_DATE - BORDER, BORDER, WIDTH_DATE, HEIGHT_NAME);
    CGRect rectNote = CGRectMake(BORDER, BORDER + HEIGHT_NAME, width - 2 * BORDER, 30);

    // Name
    senderLabel = [[UILabel alloc] initWithFrame:rectSender];
    senderLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:senderLabel];

    // Date
    dateLabel = [[UILabel alloc] initWithFrame:rectDate];
    dateLabel.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:dateLabel];

    // Log
    noteLabel = [[UILabel alloc] initWithFrame:rectNote];
    noteLabel.font = [UIFont systemFontOfSize:14.0];
    noteLabel.numberOfLines = 0;
    [self.contentView addSubview:noteLabel];
    
    return self;
}

@end
