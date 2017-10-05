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

@interface FilterAccountsTableViewCell ()
{
    NSArray<dbAccount *> *accounts;
    NSArray<FilterButton *> *buttons;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCView *accountsView;

@end

@implementation FilterAccountsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    accounts = dbc.accounts;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[accounts count]];

    __block NSInteger y = 0;

    [accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"account_%ld", (long)a._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            a.selected = NO;
        else
            a.selected = [c boolValue];

        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b addTarget:self action:@selector(clickAccount:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, width, 1);
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, width, b.frame.size.height);
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
}

- (void)changeTheme
{
    [super changeTheme];

    [self.labelHeader changeTheme];
    [self.accountsView changeTheme];
}

- (void)viewRefresh
{
    [accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [buttons objectAtIndex:idx];
        [b setTitle:a.site forState:UIControlStateNormal];
        [b setTitleColor:(a.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b sizeToFit];
        b.frame = CGRectMake(b.frame.origin.x, b.frame.origin.y, width, b.frame.size.height);
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
    return @"accounts";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:a.site];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[dbc.accounts count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:a.site];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickAccount:(FilterButton *)b
{
    dbAccount *a = [accounts objectAtIndex:b.index];
    a.selected = !a.selected;
    [b setTitleColor:(a.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"account_%ld", (long)a._id] value:[NSString stringWithFormat:@"%d", a.selected]];
    [self configUpdate];
}

@end
