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
#define BORDER 10
#define WIDTH_DATE 60

    NSInteger height_name = myConfig.GCSmallFont.lineHeight;
    CGRect rectSender = CGRectMake(BORDER, BORDER, width - 2 * BORDER - WIDTH_DATE, height_name);
    CGRect rectDate = CGRectMake(width - WIDTH_DATE - BORDER, BORDER, WIDTH_DATE, height_name);
    CGRect rectNote = CGRectMake(BORDER, BORDER + height_name, width - 2 * BORDER, 0);

    // Sender
    senderLabel = [[GCSmallLabel alloc] initWithFrame:rectSender];
    [senderLabel bold:YES];
    [self.contentView addSubview:senderLabel];

    // Date
    dateLabel = [[GCSmallLabel alloc] initWithFrame:rectDate];
    [dateLabel bold:YES];
    [self.contentView addSubview:dateLabel];

    // Note
    noteLabel = [[GCTextblock alloc] initWithFrame:rectNote];
    [self.contentView addSubview:noteLabel];
    
    return self;
}

@end
