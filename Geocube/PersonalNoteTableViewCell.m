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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
#define BORDER 10

    NSInteger height = myConfig.GCSmallFont.lineHeight;
    CGRect rectName = CGRectMake(BORDER, BORDER, width - 2 * BORDER, height);
           rectLog = CGRectMake(BORDER, BORDER + height, width - 2 * BORDER, 30);

    // Name
    name = [[GCSmallLabel alloc] initWithFrame:rectName];
    [name bold:YES];
    [self.contentView addSubview:name];

    // Log
    log = [[GCTextblock alloc] initWithFrame:rectLog];
    [log sizeToFit];

    self.contentView.backgroundColor = currentTheme.tableViewCellBackgroundColor;

    [self.contentView sizeToFit];
    [self.contentView addSubview:log];

    return self;
}

- (void)changeTheme
{
    [themeManager changeThemeView:name];
    [themeManager changeThemeView:log];
    [super changeTheme];
}

- (void)setLogString:(NSString *)logString
{
    log.lineBreakMode = NSLineBreakByWordWrapping;
    log.frame = rectLog;
    log.text = logString;
    [log sizeToFit];
}

@end
