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

@implementation FilterTypesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    /* Get some standard values */
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UIFont *f1 = cell.textLabel.font;
    UIFont *f2 = cell.detailTextLabel.font;
    NSInteger cellHeight = cell.frame.size.height;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;

    CGRect rect;
    NSInteger y = 0;

    rect = CGRectMake(20, 2, width - 20, cellHeight);
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.font = f1;
    l.text = @"Any Cache Type";
    l.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:l];
    y += cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        height = y;
        return self;
    }

    NSArray *types = [dbc Types];
    NSEnumerator *e = [types objectEnumerator];
    dbType *t;
    while ((t = [e nextObject]) != nil) {
        UIImage *img = [imageLibrary get:t.icon];
        rect = CGRectMake(0, y, img.size.width, img.size.height);
        UIImageView *tv = [[UIImageView alloc] initWithFrame:rect];
        tv.image = img;
        [self.contentView addSubview:tv];

        rect = CGRectMake(img.size.width + 10, y, width - img.size.width - 10, img.size.height);
        l = [[UILabel alloc] initWithFrame:rect];
        l.text = t.type;
        l.font = f2;
        [self.contentView addSubview:l];

        y += tv.frame.size.height;
    }

    [self.contentView sizeToFit];
    height = y;

    return self;
}

- (NSInteger)cellHeight
{
    return height;
}

@end
