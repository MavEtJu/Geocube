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

@interface FilesViewCell ()
{
    CGRect rectFileName;
    CGRect rectFileSize;
    CGRect rectFileDateTime;
    CGRect rectLastImport;
}

@end

@implementation FilesViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.accessoryType = UITableViewCellAccessoryNone;

    // Name
    self.labelFileName = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.labelFileName.font = [UIFont boldSystemFontOfSize:14.0];
    [self.contentView addSubview:self.labelFileName];

    // Size
    self.labelFileSize = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.labelFileSize.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:self.labelFileSize];

    // Date Time
    self.labelFileDateTime = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.labelFileDateTime.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:self.labelFileDateTime];

    // Last import
    self.labelLastImport = [[GCLabel alloc] initWithFrame:CGRectZero];
    self.labelLastImport.font = [UIFont systemFontOfSize:10.0];
    [self.contentView addSubview:self.labelLastImport];

    [self viewWillTransitionToSize];
    [self changeTheme];

    return self;
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    NSInteger offset = 16;
    NSInteger labelWidth = width - 2 * offset;

    NSInteger y = 0;
    rectFileName = CGRectMake(offset, y, labelWidth, self.labelFileName.font.lineHeight);
    y += self.labelFileName.font.lineHeight + 1;
    rectFileSize = CGRectMake(offset, y, labelWidth, self.labelFileSize.font.lineHeight);
    y += self.labelFileSize.font.lineHeight + 1;
    rectFileDateTime = CGRectMake(offset, y, labelWidth, self.labelFileDateTime.font.lineHeight);
    y += self.labelFileDateTime.font.lineHeight + 1;
    rectLastImport = CGRectMake(offset, y, labelWidth, self.labelLastImport.font.lineHeight);
    y += self.labelLastImport.font.lineHeight + 1;
}

- (void)viewWillTransitionToSize
{
    [self calculateRects];
    self.labelFileName.frame = rectFileName;
    self.labelFileSize.frame = rectFileSize;
    self.labelFileDateTime.frame = rectFileDateTime;
    self.labelLastImport.frame = rectLastImport;
}

- (void)changeTheme
{
    [self.labelFileName changeTheme];
    [self.labelFileSize changeTheme];
    [self.labelFileDateTime changeTheme];
    [self.labelLastImport changeTheme];

    [super changeTheme];
}

- (NSInteger)cellHeight
{
    return self.labelLastImport.frame.size.height + self.labelLastImport.frame.origin.y + 2;
}

@end
