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
    NSArray<FilterButton *> *buttons;
    NSInteger viewWidth;
    NSLayoutConstraint *heightConstraint;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCView *accountsView;

@end

@implementation FilterGroupsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    groups = dbc.groups;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[groups count]];

    __block NSInteger y = 0;

    viewWidth = self.accountsView.frame.size.width;

    [groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"group_%ld", (long)g._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            g.selected = NO;
        else
            g.selected = [c boolValue];

        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, viewWidth, 1);
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, viewWidth - 2 * b.frame.origin.x, b.frame.size.height);
        [self.accountsView addSubview:b];

        y += b.frame.size.height;

        [bs addObject:b];
    }];

    buttons = bs;

    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];

    [buttons enumerateObjectsUsingBlock:^(FilterButton * _Nonnull fb, NSUInteger idx, BOOL * _Nonnull stop) {
        [fb changeTheme];
    }];

    [self.labelHeader changeTheme];
    [self.accountsView changeTheme];
}

- (void)viewRefresh
{
    __block NSInteger y = 0;

    [groups enumerateObjectsUsingBlock:^(dbGroup * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [buttons objectAtIndex:idx];
        [b setTitle:g.name forState:UIControlStateNormal];
        [b setTitleColor:(g.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, y, viewWidth, b.frame.size.height);
        y += b.frame.size.height;
    }];
    [self.accountsView removeConstraint:heightConstraint];
    heightConstraint = [NSLayoutConstraint
                        constraintWithItem:self.accountsView
                        attribute:NSLayoutAttributeHeight
                        relatedBy:0
                        toItem:nil
                        attribute:NSLayoutAttributeHeight
                        multiplier:1.0
                        constant:y];
    [self.accountsView addConstraint:heightConstraint];

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
