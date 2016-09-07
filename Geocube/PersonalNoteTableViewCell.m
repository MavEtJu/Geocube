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

#define __CLASS__PERSONALNOTETABLEVIEWCELL__
@interface PersonalNoteTableViewCell ()
{
    CGRect rectLog;
    CGRect rectName;
}

@end

@implementation PersonalNoteTableViewCell

@synthesize logLabel, nameLabel, personalNote;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    // Name
    nameLabel = [[GCSmallLabel alloc] initWithFrame:rectName];
    [nameLabel bold:YES];
    [self.contentView addSubview:nameLabel];

    // Log
    logLabel = [[GCTextblock alloc] initWithFrame:rectLog];
    logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [logLabel sizeToFit];
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
     | Name                       |
     +---+------+-----------------|
     | Log                        |
     |                            |
     +----------------------------+
     */
#define BORDER 10

    NSInteger height = myConfig.GCSmallFont.lineHeight;
    rectName = CGRectMake(BORDER, BORDER, width - 2 * BORDER, height);
    rectLog = CGRectMake(BORDER, BORDER + height, width - 2 * BORDER, 30);
}

- (void)calculateCellHeight
{
    personalNote.cellHeight = nameLabel.frame.size.height + logLabel.frame.size.height + 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    nameLabel.frame = rectName;
    logLabel.frame = rectLog;
    [logLabel sizeToFit];
    [self calculateCellHeight];
}

- (void)changeTheme
{
    [nameLabel changeTheme];
    [logLabel changeTheme];

    [super changeTheme];
}

- (void)setLogString:(NSString *)logString
{
    logLabel.frame = rectLog;
    logLabel.text = logString;
    [logLabel sizeToFit];
}

@end
