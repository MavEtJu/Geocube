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

@interface FilterTypeIcon ()

@property (nonatomic) BOOL selected;
@property (nonatomic) NSInteger icon;
@property (nonatomic, retain) NSString *desc;

@end

@implementation FilterTypeIcon
@end

@interface FilterTypeIconsTableViewCell ()

@property (nonatomic, retain) NSMutableArray<FilterTypeIcon *> *icons;
@property (nonatomic, retain) NSArray<FilterButton *> *buttons;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet FilterButton *firstButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtonRight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtomBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtonLeft;

@end

@implementation FilterTypeIconsTableViewCell

#define FILTER  @"icon"

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSMutableArray<NSNumber *> *icons = [NSMutableArray arrayWithCapacity:20];
    [dbc.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *n = [NSNumber numberWithInteger:t.icon];
        if ([icons containsObject:n] == NO)
            [icons addObject:n];
    }];
    self.icons = [NSMutableArray arrayWithCapacity:[icons count]];
    [icons enumerateObjectsUsingBlock:^(NSNumber * _Nonnull n, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterTypeIcon *ft = [[FilterTypeIcon alloc] init];
        ft.icon = [n integerValue];
        ft.selected = NO;
        ft.desc = [NSString stringWithFormat:@"Icon %ld", (long)ft.icon];
        [self.icons addObject:ft];
    }];

    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[self.icons count]];

    __block NSInteger y = self.firstButton.frame.origin.y + self.firstButton.frame.size.height;

    __block NSObject *lastButton = self.labelHeader;
    __block NSLayoutConstraint *lc;

    [self.contentView removeConstraint:self.constraintButtonTop];
    [self.contentView removeConstraint:self.constraintButtomBottom];
    [self.contentView removeConstraint:self.constraintButtonRight];
    [self.contentView removeConstraint:self.constraintButtonLeft];

    [self.icons enumerateObjectsUsingBlock:^(FilterTypeIcon * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"%@_%ld", FILTER, (long)g.icon];
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

        [b addTarget:self action:@selector(clickContainer:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, 0, 0);
        [b setImage:[imageManager get:g.icon] forState:UIControlStateNormal];
        [b sizeToFit];

        if (idx != 0)
            [self.contentView addSubview:b];

        // button to right margin
        lc = [NSLayoutConstraint
              constraintWithItem:b
              attribute:NSLayoutAttributeTrailing
              relatedBy:NSLayoutRelationEqual
              toItem:self.contentView
              attribute:NSLayoutAttributeTrailingMargin
              multiplier:1.0
              constant:-30];
        [self.contentView addConstraint:lc];
        // image to left margin
        lc = [NSLayoutConstraint
              constraintWithItem:b
              attribute:NSLayoutAttributeLeading
              relatedBy:NSLayoutRelationEqual
              toItem:self.contentView
              attribute:NSLayoutAttributeLeadingMargin
              multiplier:1.0
              constant:35];
        [self.contentView addConstraint:lc];

        // button to top
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

    [self.buttons enumerateObjectsUsingBlock:^(FilterButton * _Nonnull fs, NSUInteger idx, BOOL * _Nonnull stop) {
        [fs changeTheme];
    }];

    [self.labelHeader changeTheme];
}

- (void)viewRefresh
{
    [self.icons enumerateObjectsUsingBlock:^(FilterTypeIcon * _Nonnull typeicon, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [self.buttons objectAtIndex:idx];
        [b setTitle:typeicon.desc forState:UIControlStateNormal];
        [b setTitleColor:(typeicon.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b sizeToFit];
    }];
    [self.contentView sizeToFit];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];
    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    [self.icons enumerateObjectsUsingBlock:^(FilterTypeIcon * _Nonnull typeicon, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"%@_%ld", FILTER, (long)typeicon.icon];
        typeicon.selected = [[self configGet:key] boolValue];
    }];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"typeicons";
}

+ (NSArray<NSString *> *)configFields
{
    NSMutableArray<NSString *> *as = [NSMutableArray arrayWithArray:@[@"enabled"]];
    [dbc.containers enumerateObjectsUsingBlock:^(dbContainer * _Nonnull c, NSUInteger idx, BOOL * _Nonnull stop) {
        [as addObject:[NSString stringWithFormat:@"%@_%ld", FILTER, (long)c._id]];
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
    FilterTypeIcon *c = [self.icons objectAtIndex:b.index];
    c.selected = !c.selected;
    [b setTitleColor:(c.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"%@_%ld", FILTER, (long)c.icon] value:[NSString stringWithFormat:@"%d", c.selected]];
    [self configUpdate];
}

@end
