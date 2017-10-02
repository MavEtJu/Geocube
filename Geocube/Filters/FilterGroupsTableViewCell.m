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

@interface FilterGroupsTableViewCell ()
{
    NSArray<dbGroup *> *groups;
}

@end

@implementation FilterGroupsTableViewCell

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

    groups = dbc.groups;

    [groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"group_%ld", (long)g._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            g.selected = NO;
        else
            g.selected = [c boolValue];

        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b setTitle:g.name forState:UIControlStateNormal];
        [b setTitleColor:(g.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(20, y, width - 40, b.titleLabel.font.lineHeight);
        [self.contentView addSubview:b];

        y += b.frame.size.height;
    }];

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

- (void)viewWillTransitionToSize
{
    [super viewWillTransitionToSize];
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
    return @"groups";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:g.name];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[dbc.groups count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [dbc.groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:g.name];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickGroup:(FilterButton *)b
{
    dbGroup *g = [groups objectAtIndex:b.index];
    g.selected = !g.selected;
    [b setTitleColor:(g.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"group_%ld", (long)g._id] value:[NSString stringWithFormat:@"%d", g.selected]];
    [self configUpdate];
}

@end
