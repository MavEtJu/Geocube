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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

@implementation LogTableViewCell

@synthesize logtype, datetime, logger, log;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;

    /*
     +---+------+-----------------+
     | I | date | by Name         |  logtypeImage
     +---+------+-----------------|
     | Log                        |
     |                            |
     +----------------------------+
     */
#define BORDER 1
#define IMAGE_WIDTH 10
#define IMAGE_HEIGHT 10
#define DATE_WIDTH 100

    CGRect rectImage = CGRectMake(BORDER, BORDER, IMAGE_WIDTH, IMAGE_HEIGHT);
    CGRect rectDatetime = CGRectMake(BORDER + IMAGE_WIDTH, BORDER, DATE_WIDTH, IMAGE_HEIGHT);
    CGRect rectLogger = CGRectMake(BORDER + IMAGE_WIDTH + DATE_WIDTH, BORDER, width - 2 * BORDER - DATE_WIDTH - IMAGE_HEIGHT, IMAGE_HEIGHT);
    CGRect rectLog = CGRectMake(BORDER, BORDER + IMAGE_HEIGHT, width - 2 * BORDER, 30);

    // Image
    logtype = [[UIImageView alloc] initWithFrame:rectImage];
    logtype.image = [imageLibrary get:ImageCaches_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:logtype];

    // Date
    datetime = [[UILabel alloc] initWithFrame:rectDatetime];
    datetime.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:datetime];

    // Logger
    logger = [[UILabel alloc] initWithFrame:rectLogger];
    logger.font = [UIFont boldSystemFontOfSize:10.0];
    [self.contentView addSubview:logger];

    // Log
    log = [[UILabel alloc] initWithFrame:rectLog];
    log.font = [UIFont systemFontOfSize:12.0];
    log.numberOfLines = 0;
    //bearing.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:log];

    return self;
}

@end
