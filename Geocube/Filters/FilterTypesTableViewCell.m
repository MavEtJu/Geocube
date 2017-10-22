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

@property (nonatomic, retain) NSArray<dbType *> *types;
@property (nonatomic, retain) NSArray<FilterButton *> *buttons;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet FilterButton *firstButton;
@property (nonatomic, weak) IBOutlet GCImageView *firstImage;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtonTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtonRight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintImageButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintButtomBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintImageLeft;

@end

@implementation FilterTypesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.types = dbc.types;
    NSMutableArray<FilterButton *> *bs = [NSMutableArray arrayWithCapacity:[self.types count]];

    __block NSInteger y = self.firstButton.frame.origin.y + self.firstButton.frame.size.height;

    __block NSObject *lastButton = self.labelHeader;
    __block NSLayoutConstraint *lc;

    [self.contentView removeConstraint:self.constraintImageLeft];
    [self.contentView removeConstraint:self.constraintImageButton];
    [self.contentView removeConstraint:self.constraintButtonRight];
    [self.contentView removeConstraint:self.constraintButtomBottom];
    [self.contentView removeConstraint:self.constraintButtonTop];

    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull g, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = [NSString stringWithFormat:@"group_%ld", (long)g._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            g.selected = NO;
        else
            g.selected = [c boolValue];

        GCImageView *iv;
        FilterButton *b;
        if (idx == 0) {
            b = self.firstButton;
            iv = self.firstImage;
        } else {
            b = [FilterButton buttonWithType:UIButtonTypeSystem];
            b.translatesAutoresizingMaskIntoConstraints = NO;
            iv = [[GCImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            iv.translatesAutoresizingMaskIntoConstraints = NO;
        }
        iv.image = [imageManager get:g.icon];

        [b addTarget:self action:@selector(clickType:) forControlEvents:UIControlEventTouchDown];
        b.index = idx;
        b.frame = CGRectMake(0, y, 0, 0);
        [b setTitle:s forState:UIControlStateNormal];
        [b sizeToFit];

        if (idx != 0) {
            [self.contentView addSubview:b];
            [self.contentView addSubview:iv];
        }
        // height and width 30px
        lc = [NSLayoutConstraint
              constraintWithItem:iv
              attribute:NSLayoutAttributeWidth
              relatedBy:NSLayoutRelationEqual
              toItem:nil
              attribute:0
              multiplier:1.0
              constant:30];
        [iv addConstraint:lc];
        lc = [NSLayoutConstraint
              constraintWithItem:iv
              attribute:NSLayoutAttributeHeight
              relatedBy:NSLayoutRelationEqual
              toItem:nil
              attribute:0
              multiplier:1.0
              constant:30];
        [iv addConstraint:lc];

        // image to button alignment
        lc = [NSLayoutConstraint
              constraintWithItem:iv
              attribute:NSLayoutAttributeCenterY
              relatedBy:NSLayoutRelationEqual
              toItem:b
              attribute:NSLayoutAttributeCenterY
              multiplier:1.0
              constant:0];
        [self.contentView addConstraint:lc];

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
              constraintWithItem:iv
              attribute:NSLayoutAttributeLeading
              relatedBy:NSLayoutRelationEqual
              toItem:self.contentView
              attribute:NSLayoutAttributeLeadingMargin
              multiplier:1.0
              constant:0];
        [self.contentView addConstraint:lc];
        // image to button
        lc = [NSLayoutConstraint
              constraintWithItem:iv
              attribute:NSLayoutAttributeTrailing
              relatedBy:NSLayoutRelationEqual
              toItem:b
              attribute:NSLayoutAttributeLeading
              multiplier:1.0
              constant:0];
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

    // last button to bottom margin
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
    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        FilterButton *b = [self.buttons objectAtIndex:idx];
        [b setTitle:t.type_full forState:UIControlStateNormal];
        [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b sizeToFit];
    }];
    [self.contentView sizeToFit];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];
    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    [self.types enumerateObjectsUsingBlock:^(dbType * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [NSString stringWithFormat:@"type_%ld", (long)t._id];
        t.selected = [[self configGet:key] boolValue];
    }];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
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
        [as addObject:[NSString stringWithFormat:@"type_%ld", (long)t._id]];
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
    dbType *t = [self.types objectAtIndex:b.index];
    t.selected = !t.selected;
    [b setTitleColor:(t.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
    [self configSet:[NSString stringWithFormat:@"type_%ld", (long)t._id] value:[NSString stringWithFormat:@"%d", t.selected]];
    [self configUpdate];
}

@end
