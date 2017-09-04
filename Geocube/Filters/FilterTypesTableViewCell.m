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

@interface FilterTypesTableViewCell ()
{
    NSArray<dbType *> *types;
}

@end

@implementation FilterTypesTableViewCell

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

    types = [dbc Types];
    [types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *img = [imageLibrary get:t.icon];
        CGRect rect = CGRectMake(20, y, img.size.width, img.size.height);
        UIImageView *tv = [[UIImageView alloc] initWithFrame:rect];
        tv.image = img;
        [self.contentView addSubview:tv];

        NSString *c = [self configGet:[NSString stringWithFormat:@"type_%ld", (long)t._id]];
        if (c == nil)
            t.selected = NO;
        else
            t.selected = [c boolValue];

        rect = CGRectMake(img.size.width + 30, y, width - img.size.width - 10, img.size.height + 5);
        GCFilterButton *b = [GCFilterButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [b setTitle:t.type_full forState:UIControlStateNormal];
        [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        [self.contentView addSubview:b];

        y += tv.frame.size.height;
    }];

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

+ (NSString *)configPrefix
{
    return @"types";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [[dbc Types] enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:t.type_full];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[[dbc Types] count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [[dbc Types] enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:t.type_full];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickGroup:(GCFilterButton *)b
{
    dbType *t = [types objectAtIndex:b.index];
    t.selected = !t.selected;
    [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"type_%ld", (long)t._id] value:[NSString stringWithFormat:@"%d", t.selected]];
    [self configUpdate];
}

@end
