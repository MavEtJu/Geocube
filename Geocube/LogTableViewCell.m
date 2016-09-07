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

#define __CLASS__LOGTABLEVIEWCELL__
@interface LogTableViewCell ()
{
    CGRect rectLogtype;
    CGRect rectDatetime;
    CGRect rectLogger;
    CGRect rectLog;
}

@end

@implementation LogTableViewCell

@synthesize logtypeImage, datetimeLabel, loggerLabel, logLabel, log;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    // Image
    logtypeImage = [[UIImageView alloc] initWithFrame:rectLogtype];
    logtypeImage.image = [imageLibrary get:ImageTypes_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:logtypeImage];

    // Date
    datetimeLabel = [[GCSmallLabel alloc] initWithFrame:rectDatetime];
    [datetimeLabel bold:YES];
    [self.contentView addSubview:datetimeLabel];

    // Logger
    loggerLabel = [[GCSmallLabel alloc] initWithFrame:rectLogger];
    [loggerLabel bold:YES];
    loggerLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:loggerLabel];

    // Log
    logLabel = [[GCTextblock alloc] initWithFrame:rectLog];
    logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:logLabel];

    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

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

    rectLogtype = CGRectMake(BORDER, BORDER, IMAGE_WIDTH, height_name);
    rectDatetime = CGRectMake(BORDER + IMAGE_WIDTH + BORDER, BORDER, DATE_WIDTH, height_name);
    rectLogger = CGRectMake(BORDER + IMAGE_WIDTH + DATE_WIDTH, BORDER, width - 2 * BORDER - DATE_WIDTH - height_name, height_name);
    rectLog = CGRectMake(BORDER, BORDER + height_name, width - 2 * BORDER, 30);
}

- (void)setLogString:(NSString *)logString
{
    logLabel.frame = rectLog;
    logLabel.text = logString;
    [logLabel sizeToFit];
}

- (void)calculateCellHeight
{
    log.cellHeight = logLabel.frame.size.height + loggerLabel.frame.size.height + 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    logtypeImage.frame = rectLogtype;
    datetimeLabel.frame = rectDatetime;
    loggerLabel.frame = rectLogger;
    logLabel.frame = rectLog;
    [logLabel sizeToFit];
    [self calculateCellHeight];
}

- (void)changeTheme
{
    [datetimeLabel changeTheme];
    [loggerLabel changeTheme];
    [logLabel changeTheme];

    [super changeTheme];
}

@end
