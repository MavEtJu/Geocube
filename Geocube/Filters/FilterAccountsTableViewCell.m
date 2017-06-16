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
}

@end

@implementation FilterAccountsTableViewCell

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

    accounts = [dbc Accounts];

    [accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        NSString *s = [NSString stringWithFormat:@"account_%ld", (long)a._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            a.selected = NO;
        else
            a.selected = [c boolValue];

        CGRect rect = CGRectMake(20, y, width - 40, 15);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        [b setTitle:a.site forState:UIControlStateNormal];
        [b setTitleColor:(a.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickAccount:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        y += 15;
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
    return @"accounts";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:a.site];
    }];
    return as;
}

+ (NSDictionary *)configDefaults
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[[dbc Accounts] count] + 1];
    [dict setObject:@"0" forKey:@"enabled"];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [dict setObject:@"0" forKey:a.site];
    }];
    return dict;
}

#pragma mark -- callback functions

- (void)clickAccount:(UIButton *)b
{
    [accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        if ([a.site isEqualToString:[b titleForState:UIControlStateNormal]] == YES) {
            a.selected = !a.selected;
            [b setTitleColor:(a.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
            [self configSet:[NSString stringWithFormat:@"account_%ld", (long)a._id] value:[NSString stringWithFormat:@"%d", a.selected]];
            [self configUpdate];
            *stop = YES;
        }
    }];
}

@end
