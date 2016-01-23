/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@interface FilterFlagsTableViewCell ()
{
    UIButton *buttonHighlighted;
    UIButton *buttonMarkedAsFound;
    UIButton *buttonIgnored;
    UIButton *buttonInProgress;

    NSInteger valueHighlighted;
    NSInteger valueMarkedAsFound;
    NSInteger valueIgnored;
    NSInteger valueInProgress;

    NSArray *valuesHighlighted;
    NSArray *valuesMarkedAsFound;
    NSArray *valuesIgnored;
    NSArray *valuesInProgress;
}

@end

@implementation FilterFlagsTableViewCell

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

    NSString *c;

    valueHighlighted = 0;
    valueMarkedAsFound = 0;
    valueIgnored = 0;
    valueInProgress = 0;

    valuesHighlighted = @[@"Highlighted", @"Highlighted", @"Not highlighted"];
    valuesMarkedAsFound = @[@"Marked as Found", @"Marked as Found", @"Not marked as found"];
    valuesIgnored = @[@"Ignored", @"Ignored", @"Not ignored"];
    valuesInProgress = @[@"In progress", @"In progress", @"Not in progress"];

    c = [self configGet:@"flags_highlighted"];
    if (c != nil)
        valueHighlighted = [c integerValue];
    c = [self configGet:@"flags_markedfound"];
    if (c != nil)
        valueMarkedAsFound = [c integerValue];
    c = [self configGet:@"flags_ignored"];
    if (c != nil)
        valueIgnored = [c integerValue];
    c = [self configGet:@"flags_inprogress"];
    if (c != nil)
        valueInProgress = [c integerValue];

    for (NSInteger i = 0; i < 4; i++) {
        CGRect rect = CGRectMake(20, y, width - 40, 15);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        switch (i) {
            case 0:
                [b setTitle:[valuesHighlighted objectAtIndex:valueHighlighted] forState:UIControlStateNormal];
                [b setTitleColor:(valueHighlighted != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonHighlighted = b;
                break;
            case 1:
                [b setTitle:[valuesMarkedAsFound objectAtIndex:valueMarkedAsFound] forState:UIControlStateNormal];
                [b setTitleColor:(valueMarkedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonMarkedAsFound = b;
                break;
            case 2:
                [b setTitle:[valuesIgnored objectAtIndex:valueIgnored] forState:UIControlStateNormal];
                [b setTitleColor:(valueIgnored != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonIgnored = b;
                break;
            case 3:
                [b setTitle:[valuesInProgress objectAtIndex:valueInProgress] forState:UIControlStateNormal];
                [b setTitleColor:(valueInProgress != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonInProgress = b;
                break;
        }
        y += 15;
    };

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
    [self configPrefix:@"flags"];

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickGroup:(UIButton *)b
{

    if (b == buttonMarkedAsFound) {
        valueMarkedAsFound = (valueMarkedAsFound + 1) % 3;
        [b setTitle:[valuesMarkedAsFound objectAtIndex:valueMarkedAsFound] forState:UIControlStateNormal];
        [b setTitleColor:(valueMarkedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"flags_markedfound" value:[NSString stringWithFormat:@"%ld", (long)valueMarkedAsFound]];
        [self configUpdate];
        return;
    }

    if (b == buttonIgnored) {
        valueIgnored = (valueIgnored + 1) % 3;
        [b setTitle:[valuesIgnored objectAtIndex:valueIgnored] forState:UIControlStateNormal];
        [b setTitleColor:(valueIgnored != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"flags_ignored" value:[NSString stringWithFormat:@"%ld", (long)valueIgnored]];
        [self configUpdate];
        return;
    }

    if (b == buttonHighlighted) {
        valueHighlighted = (valueHighlighted + 1) % 3;
        [b setTitle:[valuesHighlighted objectAtIndex:valueHighlighted] forState:UIControlStateNormal];
        [b setTitleColor:(valueHighlighted != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"flags_highlighted" value:[NSString stringWithFormat:@"%ld", (long)valueHighlighted]];
        [self configUpdate];
        return;
    }

    if (b == buttonInProgress) {
        valueInProgress = (valueInProgress + 1) % 3;
        [b setTitle:[valuesInProgress objectAtIndex:valueInProgress] forState:UIControlStateNormal];
        [b setTitleColor:(valueInProgress != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"flags_inprogress" value:[NSString stringWithFormat:@"%ld", (long)valueInProgress]];
        [self configUpdate];
        return;
    }

}

@end
