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

@interface FilterSizesTableViewCell ()
{
    NSArray *containers;
}

@end

@implementation FilterSizesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    __block NSInteger y = cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = cellHeight = y;
        return self;
    }

    UIImage *img = [imageLibrary get:dbc.Container_Unknown.icon];
    CGSize imgSize = img.size;

    containers = [dbc Containers];
    [containers enumerateObjectsUsingBlock:^(dbContainer *c, NSUInteger idx, BOOL *stop) {
        UIImage *img = [imageLibrary get:c.icon];
        if (img != nil) {
            CGRect rect = CGRectMake(20, y, imgSize.width, imgSize.height);
            UIImageView *cv = [[UIImageView alloc] initWithFrame:rect];
            cv.image = img;
            [self.contentView addSubview:cv];
        }

        NSString *cfg = [self configGet:[NSString stringWithFormat:@"container_%ld", (long)c._id]];
        if (cfg == nil)
            c.selected = NO;
        else
            c.selected = [cfg boolValue];

        CGRect rect = CGRectMake(imgSize.width + 30, y, width - imgSize.width - 10, imgSize.height);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [b setTitle:c.size forState:UIControlStateNormal];
        [b setTitleColor:(c.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        y += rect.size.height;
    }];

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    [self configPrefix:@"sizes"];

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
    [containers enumerateObjectsUsingBlock:^(dbContainer *c, NSUInteger idx, BOOL *stop) {
        if ([c.size isEqualToString:[b titleForState:UIControlStateNormal]] == YES) {
            c.selected = !c.selected;
            [b setTitleColor:(c.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
            [self configSet:[NSString stringWithFormat:@"container_%ld", (long)c._id] value:[NSString stringWithFormat:@"%d", c.selected]];
            [self configUpdate];
            *stop = YES;
        }
    }];
}

@end
