/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface LogTableViewCell ()
{
    CGRect rectLogtype;
    CGRect rectDatetime;
    CGRect rectLogger;
    CGRect rectLog;
}

@end

@implementation LogTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    // Image
    self.logtypeImage = [[UIImageView alloc] initWithFrame:rectLogtype];
    self.logtypeImage.image = [imageLibrary get:ImageTypes_TraditionalCache];
    //icon.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:self.logtypeImage];

    // Date
    self.datetimeLabel = [[GCSmallLabel alloc] initWithFrame:rectDatetime];
    [self.datetimeLabel bold:YES];
    [self.contentView addSubview:self.datetimeLabel];

    // Logger
    self.loggerLabel = [[GCSmallLabel alloc] initWithFrame:rectLogger];
    [self.loggerLabel bold:YES];
    self.loggerLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.loggerLabel];

    // Log
    self.logLabel = [[GCTextblock alloc] initWithFrame:rectLog];
    self.logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.logLabel];

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

    NSInteger height_name = configManager.GCSmallFont.lineHeight;

    rectLogtype = CGRectMake(BORDER, BORDER, IMAGE_WIDTH, height_name);
    rectDatetime = CGRectMake(BORDER + IMAGE_WIDTH + BORDER, BORDER, DATE_WIDTH, height_name);
    rectLogger = CGRectMake(BORDER + IMAGE_WIDTH + DATE_WIDTH, BORDER, width - 2 * BORDER - DATE_WIDTH - height_name, height_name);
    rectLog = CGRectMake(BORDER, BORDER + height_name, width - 2 * BORDER, 30);
}

- (void)setLogString:(NSString *)logString
{
    self.logLabel.frame = rectLog;
    self.logLabel.text = logString;
    [self.logLabel sizeToFit];
}

- (void)calculateCellHeight
{
    self.log.cellHeight = self.logLabel.frame.size.height + self.loggerLabel.frame.size.height + 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    self.logtypeImage.frame = rectLogtype;
    self.datetimeLabel.frame = rectDatetime;
    self.loggerLabel.frame = rectLogger;
    self.logLabel.frame = rectLog;
    [self.logLabel sizeToFit];
    [self calculateCellHeight];
}

- (void)changeTheme
{
    [self.datetimeLabel changeTheme];
    [self.loggerLabel changeTheme];
    [self.logLabel changeTheme];

    [super changeTheme];
}

@end
