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

@interface NoticeTableViewCell ()
{
    CGRect rectNote;
    CGRect rectSender;
    CGRect rectDate;
}

@end

@implementation NoticeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self calculateRects];

    // Sender
    self.senderLabel = [[GCSmallLabel alloc] initWithFrame:rectSender];
    [self.senderLabel bold:YES];
    [self.contentView addSubview:self.senderLabel];

    // Date
    self.dateLabel = [[GCSmallLabel alloc] initWithFrame:rectDate];
    [self.dateLabel bold:YES];
    [self.contentView addSubview:self.dateLabel];

    // Note
    self.noteLabel = [[GCTextblock alloc] initWithFrame:rectNote];
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:self.noteLabel];

    self.userInteractionEnabled = YES;

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

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

    NSInteger height_name = configManager.GCSmallFont.lineHeight;
    rectSender = CGRectMake(BORDER, BORDER, width - 2 * BORDER - WIDTH_DATE, height_name);
    rectDate = CGRectMake(width - WIDTH_DATE - BORDER, BORDER, WIDTH_DATE, height_name);
    rectNote = CGRectMake(BORDER, BORDER + height_name, width - 2 * BORDER, 0);
}

- (void)calculateCellHeight
{
    self.notice.cellHeight = self.noteLabel.frame.size.height + self.senderLabel.frame.size.height + 10;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    self.dateLabel.frame = rectDate;
    self.senderLabel.frame = rectSender;
    self.noteLabel.frame = rectNote;
    [self.noteLabel sizeToFit];
    [self calculateCellHeight];
}

- (void)setNote:(NSString *)noteString
{
    self.noteLabel.frame = rectNote;
    self.noteLabel.text = noteString;
    [self.noteLabel sizeToFit];
}

- (void)setURL:(NSString *)urlString
{
    self.noteLabel.frame = rectNote;
    NSMutableString *s = [NSMutableString stringWithString:self.noteLabel.text];
    [s appendFormat:@"\n\n--> Press to open link <--"];
    self.noteLabel.text = s;
    [self.noteLabel sizeToFit];
}

- (void)changeTheme
{
    [self.senderLabel changeTheme];
    [self.dateLabel changeTheme];
    [self.noteLabel changeTheme];

    [themeManager changeThemeArray:[self.contentView subviews]];
    [super changeTheme];
}

@end
