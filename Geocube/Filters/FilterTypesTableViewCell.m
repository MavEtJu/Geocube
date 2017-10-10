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
    NSArray<FilterButton *> *buttons;
    NSInteger viewWidth;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCView *accountsView;

@end

@implementation FilterTypesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    types = dbc.types;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[types count]];

    __block NSInteger y = 0;

    viewWidth = self.accountsView.frame.size.width;

    [types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"type_%ld", (long)t._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            t.selected = NO;
        else
            t.selected = [c boolValue];

        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b addTarget:self action:@selector(clickType:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, width, 1);
        [b.titleLabel sizeToFit];
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, viewWidth, b.frame.size.height);
        [self.accountsView addSubview:b];

        y += b.frame.size.height;

        [bs addObject:b];
    }];

    buttons = bs;

    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:self.accountsView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:0
                                  toItem:nil
                                  attribute:NSLayoutAttributeHeight
                                  multiplier:1.0
                                  constant:y];
    [self.accountsView addConstraint:height];

    [self changeTheme];

    [self.accountsView sizeToFit];
    [self.contentView sizeToFit];
}

- (void)changeTheme
{
    [super changeTheme];

    [buttons enumerateObjectsUsingBlock:^(FilterButton * _Nonnull fs, NSUInteger idx, BOOL * _Nonnull stop) {
        [fs changeTheme];
    }];

    [self.labelHeader changeTheme];
    [self.accountsView changeTheme];
}

- (void)viewRefresh
{
    viewWidth = self.accountsView.frame.size.width;
    [types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [buttons objectAtIndex:idx];
        [b setTitle:t.type_full forState:UIControlStateNormal];
        [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b.titleLabel sizeToFit];
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, viewWidth, b.frame.size.height);
    }];
    [self.accountsView sizeToFit];
    [self.contentView sizeToFit];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];
    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), fo.name];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"types";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:t.type_full];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[dbc.types count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:t.type_full];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickType:(FilterButton *)b
{
    dbType *t = [types objectAtIndex:b.index];
    t.selected = !t.selected;
    [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"type_%ld", (long)t._id] value:[NSString stringWithFormat:@"%d", t.selected]];
    [self configUpdate];
}

@end
