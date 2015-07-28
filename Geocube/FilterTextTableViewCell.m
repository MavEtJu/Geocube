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

@implementation FilterTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self header:fo];

    CGRect rect;
    NSInteger y = 0;
    UILabel *l;

    rect = CGRectMake(20, 2, width - 40, cellHeight);
    l = [[UILabel alloc] initWithFrame:rect];
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

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Cache name:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    cacheName = [[UITextField alloc] initWithFrame:rect];
    cacheName.frame = rect;
    cacheName.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:cacheName];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Owner:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    owner = [[UITextField alloc] initWithFrame:rect];
    owner.frame = rect;
    owner.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:owner];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"State:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    state = [[UITextField alloc] initWithFrame:rect];
    state.frame = rect;
    state.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:state];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Country:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    country = [[UITextField alloc] initWithFrame:rect];
    country.frame = rect;
    country.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:country];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Description:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    description = [[UITextField alloc] initWithFrame:rect];
    description.frame = rect;
    description.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:description];
    y += 20;

    rect = CGRectMake(20, y, 100, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.text = @"Logs:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    logs = [[UITextField alloc] initWithFrame:rect];
    logs.frame = rect;
    logs.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:logs];
    y += 20;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

@end
