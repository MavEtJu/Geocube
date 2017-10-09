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

#import "FilterSizesTableViewCell.h"

#import "ThemesLibrary/ThemeManager.h"
#import "ManagersLibrary/LocalizationManager.h"

@interface FilterSizesTableViewCell ()
{
    NSArray<dbContainer *> *containers;
    NSArray<FilterButton *> *buttons;
    NSInteger viewWidth;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCView *accountsView;

@end

@implementation FilterSizesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    containers = dbc.containers;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[containers count]];

    __block NSInteger y = 0;

    viewWidth = self.accountsView.frame.size.width;

    [containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull con, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"type_%ld", (long)con._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            con.selected = NO;
        else
            con.selected = [c boolValue];

        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b addTarget:self action:@selector(clickContainer:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, width, 1);
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
    [containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull con, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [buttons objectAtIndex:idx];
        [b setTitle:con.size forState:UIControlStateNormal];
        [b setTitleColor:(con.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
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
    return @"sizes";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [dbc.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:c.size];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[dbc.containers count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [dbc.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:c.size];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickContainer:(FilterButton *)b
{
    dbContainer *c = [containers objectAtIndex:b.index];
    c.selected = !c.selected;
    [b setTitleColor:(c.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"container_%ld", (long)c._id] value:[NSString stringWithFormat:@"%d", c.selected]];
    [self configUpdate];
}

@end
