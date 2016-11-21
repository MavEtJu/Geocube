/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface PersonalNoteTableViewCell ()
{
    CGRect rectLog;
    CGRect rectName;
}

@end

@implementation PersonalNoteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    // Name
    self.nameLabel = [[GCSmallLabel alloc] initWithFrame:rectName];
    [self.nameLabel bold:YES];
    [self.contentView addSubview:self.nameLabel];

    // Log
    self.logLabel = [[GCTextblock alloc] initWithFrame:rectLog];
    self.logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.logLabel sizeToFit];
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
     | Name                       |
     +---+------+-----------------|
     | Log                        |
     |                            |
     +----------------------------+
     */
#define BORDER 10

    NSInteger height = configManager.GCSmallFont.lineHeight;
    rectName = CGRectMake(BORDER, BORDER, width - 2 * BORDER, height);
    rectLog = CGRectMake(BORDER, BORDER + height, width - 2 * BORDER, 30);
}

- (void)calculateCellHeight
{
    self.personalNote.cellHeight = self.nameLabel.frame.size.height + self.logLabel.frame.size.height + 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    self.nameLabel.frame = rectName;
    self.logLabel.frame = rectLog;
    [self.logLabel sizeToFit];
    [self calculateCellHeight];
}

- (void)changeTheme
{
    [self.nameLabel changeTheme];
    [self.logLabel changeTheme];

    [super changeTheme];
}

- (void)setLogString:(NSString *)logString
{
    self.logLabel.frame = rectLog;
    self.logLabel.text = logString;
    [self.logLabel sizeToFit];
}

@end
