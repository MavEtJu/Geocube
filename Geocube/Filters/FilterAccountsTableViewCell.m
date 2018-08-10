/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic, retain) NSArray<dbAccount *> *accounts;
@property (nonatomic, retain) NSArray<FilterButton *> *buttons;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet FilterButton *firstButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstButtonBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstButtonLeft;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *firstButtonRight;

@end

@implementation FilterAccountsTableViewCell

#define FILTER  @"account"

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.accounts = dbc.accounts;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[self.accounts count]];

    __block NSInteger y = self.firstButton.frame.origin.y + self.firstButton.frame.size.height;

    __block NSObject *lastButton = self.labelHeader;
    __block NSLayoutConstraint *lc;

    [self.contentView removeConstraint:self.firstButtonBottom];
    [self.contentView removeConstraint:self.firstButtonLeft];
    [self.contentView removeConstraint:self.firstButtonRight];

    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"%@_%ld", FILTER, (long)g._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            g.selected = NO;
        else
            g.selected = [c boolValue];

        FilterButton *b;
        if (idx == 0) {
            b = self.firstButton;
        } else {
            b = [FilterButton buttonWithType:UIButtonTypeSystem];
            b.translatesAutoresizingMaskIntoConstraints = NO;
        }

        [b addTarget:self action:@selector(clickAccount:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, 0, 0);
        [b setTitle:s forState:UIControlStateNormal];
        [b sizeToFit];

        if (idx != 0)
            [self.contentView addSubview:b];

        lc = [NSLayoutConstraint
              constraintWithItem:b
              attribute:NSLayoutAttributeTrailing
              relatedBy:NSLayoutRelationEqual
              toItem:self.contentView
              attribute:NSLayoutAttributeTrailingMargin
              multiplier:1.0
              constant:0];
        [self.contentView addConstraint:lc];
        lc = [NSLayoutConstraint
              constraintWithItem:b
              attribute:NSLayoutAttributeLeading
              relatedBy:NSLayoutRelationEqual
              toItem:self.contentView
              attribute:NSLayoutAttributeLeadingMargin
              multiplier:1.0
              constant:0];
        [self.contentView addConstraint:lc];

        lc = [NSLayoutConstraint
              constraintWithItem:b
              attribute:NSLayoutAttributeTop
              relatedBy:NSLayoutRelationEqual
              toItem:lastButton
              attribute:NSLayoutAttributeBottom
              multiplier:1.0
              constant:0];
        [self.contentView addConstraint:lc];

        y += b.frame.size.height;

        [bs addObject:b];
        lastButton = b;
    }];

    lc = [NSLayoutConstraint
          constraintWithItem:lastButton
          attribute:NSLayoutAttributeBottom
          relatedBy:NSLayoutRelationEqual
          toItem:self.contentView
          attribute:NSLayoutAttributeBottomMargin
          multiplier:1.0
          constant:0];
    [self.contentView addConstraint:lc];

    self.buttons = bs;

    [self changeTheme];
    [self.contentView sizeToFit];
}

- (void)changeTheme
{
    [super changeTheme];

    [self.buttons enumerateObjectsUsingBlock:^(FilterButton * _Nonnull fb, NSUInteger idx, BOOL * _Nonnull stop) {
        [fb changeTheme];
    }];

    [self.labelHeader changeTheme];
}

- (void)viewRefresh
{
    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [self.buttons objectAtIndex:idx];
        [b setTitle:a.site forState:UIControlStateNormal];
        [b setTitleColor:(a.selected ? currentStyleTheme.labelTextColor : currentStyleTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b sizeToFit];
    }];

    [self.contentView sizeToFit];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];
    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    [self.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@_%ld", FILTER, (long)g._id];
        g.selected = [[self configGet:key] boolValue];
    }];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
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
        [as addObject:[NSString stringWithFormat:@"%@_%ld", FILTER, (long)a._id]];
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
    dbAccount *a = [self.accounts objectAtIndex:b.index];
    a.selected = !a.selected;
    [b setTitleColor:(a.selected ? currentStyleTheme.labelTextColor : currentStyleTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"%@_%ld", FILTER, (long)a._id] value:[NSString stringWithFormat:@"%d", a.selected]];
    [self configUpdate];
}

@end
