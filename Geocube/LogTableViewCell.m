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
#define BORDER 10
#define IMAGE_WIDTH 10
#define DATE_WIDTH 150

    NSInteger height_name = myConfig.GCSmallFont.lineHeight;

    CGRect rectImage = CGRectMake(BORDER, BORDER, IMAGE_WIDTH, height_name);
    CGRect rectDatetime = CGRectMake(BORDER + IMAGE_WIDTH + BORDER, BORDER, DATE_WIDTH, height_name);
    CGRect rectLogger = CGRectMake(BORDER + IMAGE_WIDTH + DATE_WIDTH, BORDER, width - 2 * BORDER - DATE_WIDTH - height_name, height_name);
           rectLog = CGRectMake(BORDER, BORDER + height_name, width - 2 * BORDER, 30);

    // Image
    logtype = [[UIImageView alloc] initWithFrame:rectImage];
    logtype.image = [imageLibrary get:ImageTypes_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:logtype];

    // Date
    datetime = [[GCSmallLabel alloc] initWithFrame:rectDatetime];
    [datetime bold:YES];
    [self.contentView addSubview:datetime];

    // Logger
    logger = [[GCSmallLabel alloc] initWithFrame:rectLogger];
    [logger bold:YES];
    logger.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:logger];

    // Log
    log = [[GCTextblock alloc] initWithFrame:rectLog];
    [self.contentView addSubview:log];

    [self changeTheme];

    return self;
}

- (void)setLogString:(NSString *)logString
{
    log.lineBreakMode = NSLineBreakByWordWrapping;
    log.frame = rectLog;
    log.text = logString;
    [log sizeToFit];
}

- (void)changeTheme
{
    datetime.backgroundColor = currentTheme.backgroundColor;
    datetime.textColor = currentTheme.textColor;
    logger.backgroundColor = currentTheme.backgroundColor;
    logger.textColor = currentTheme.textColor;
    log.backgroundColor = currentTheme.backgroundColor;
    log.textColor = currentTheme.textColor;
    [super changeTheme];
}

@end
