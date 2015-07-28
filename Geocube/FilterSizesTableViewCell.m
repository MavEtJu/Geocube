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

@implementation FilterSizesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self header:fo];

    CGRect rect;
    NSInteger y = 0;

    rect = CGRectMake(20, 2, width - 40, cellHeight);
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.font = f1;
    l.text = fo.name;
    l.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:l];
    y += cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = height = y;
        return self;
    }

    NSArray *containers = [dbc Containers];
    NSEnumerator *e = [containers objectEnumerator];
    dbContainer *c;
    while ((c = [e nextObject]) != nil) {
        UIImage *img = [imageLibrary get:c.icon];
        rect = CGRectMake(20, y, img.size.width, img.size.height);
        UIImageView *cv = [[UIImageView alloc] initWithFrame:rect];
        cv.image = img;
        [self.contentView addSubview:cv];

        rect = CGRectMake(img.size.width + 30, y, width - img.size.width - 10, img.size.height);
        l = [[UILabel alloc] initWithFrame:rect];
        l.text = c.size;
        l.font = f2;
        [self.contentView addSubview:l];

        y += cv.frame.size.height;
    }

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;
    
    return self;
}

@end
