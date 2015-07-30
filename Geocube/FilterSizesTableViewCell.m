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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = height = y;
        return self;
    }

    containers = [dbc Containers];
    NSEnumerator *e = [containers objectEnumerator];
    dbContainer *c;
    while ((c = [e nextObject]) != nil) {
        UIImage *img = [imageLibrary get:c.icon];
        rect = CGRectMake(20, y, img.size.width, img.size.height);
        UIImageView *cv = [[UIImageView alloc] initWithFrame:rect];
        cv.image = img;
        [self.contentView addSubview:cv];

        NSString *cfg = [self configGet:[NSString stringWithFormat:@"container_%ld", (long)c._id]];
        if (cfg == nil)
            c.selected = NO;
        else
            c.selected = [cfg boolValue];

        rect = CGRectMake(img.size.width + 30, y, width - img.size.width - 10, img.size.height);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [b setTitle:c.size forState:UIControlStateNormal];
        [b setTitleColor:c.selected ? [UIColor darkTextColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        y += cv.frame.size.height;
    }

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;
    
    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    configPrefix = @"sizes";

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickGroup:(UIButton *)b
{
    NSEnumerator *e = [containers objectEnumerator];
    dbContainer *c;
    while ((c = [e nextObject]) != nil) {
        if ([c.size compare:[b titleForState:UIControlStateNormal]] == NSOrderedSame) {
            c.selected = !c.selected;
            [b setTitleColor:c.selected ? [UIColor darkTextColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
            [self configSet:[NSString stringWithFormat:@"container_%ld", (long)c._id] value:[NSString stringWithFormat:@"%d", c.selected]];
            [self configUpdate];
            return;
        }
    }
}

@end
