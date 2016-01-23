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
    UIButton *buttonLogStatus;

    NSInteger valueHighlighted;
    NSInteger valueMarkedAsFound;
    NSInteger valueIgnored;
    NSInteger valueInProgress;
    NSInteger valueLogStatus;

    NSArray *valuesHighlighted;
    NSArray *valuesMarkedAsFound;
    NSArray *valuesIgnored;
    NSArray *valuesInProgress;
    NSArray *valuesLogStatus;
}

@end

@implementation FilterFlagsTableViewCell

enum {
    flagHighlighted,
    flagMarkedAsFound,
    flagIgnored,
    flagInProgress,
    flagLogStatus,
    flagMax
};

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
    valueLogStatus = 0;

    valuesHighlighted = @[@"Highlighted", @"Highlighted", @"Not highlighted"];
    valuesMarkedAsFound = @[@"Marked as Found", @"Marked as Found", @"Not marked as found"];
    valuesIgnored = @[@"Ignored", @"Ignored", @"Not ignored"];
    valuesInProgress = @[@"In progress", @"In progress", @"Not in progress"];
    valuesLogStatus = @[@"Not logged", @"Not logged", @"Did Not Find", @"Found"];

    c = [self configGet:@"highlighted"];
    if (c != nil)
        valueHighlighted = [c integerValue];
    c = [self configGet:@"markedfound"];
    if (c != nil)
        valueMarkedAsFound = [c integerValue];
    c = [self configGet:@"ignored"];
    if (c != nil)
        valueIgnored = [c integerValue];
    c = [self configGet:@"inprogress"];
    if (c != nil)
        valueInProgress = [c integerValue];
    c = [self configGet:@"logstatus"];
    if (c != nil)
        valueLogStatus = [c integerValue];

    for (NSInteger i = 0; i < flagMax; i++) {
        CGRect rect = CGRectMake(20, y, width - 40, 15);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        switch (i) {
            case flagHighlighted:
                [b setTitle:[valuesHighlighted objectAtIndex:valueHighlighted] forState:UIControlStateNormal];
                [b setTitleColor:(valueHighlighted != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonHighlighted = b;
                break;
            case flagMarkedAsFound:
                [b setTitle:[valuesMarkedAsFound objectAtIndex:valueMarkedAsFound] forState:UIControlStateNormal];
                [b setTitleColor:(valueMarkedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonMarkedAsFound = b;
                break;
            case flagIgnored:
                [b setTitle:[valuesIgnored objectAtIndex:valueIgnored] forState:UIControlStateNormal];
                [b setTitleColor:(valueIgnored != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonIgnored = b;
                break;
            case flagInProgress:
                [b setTitle:[valuesInProgress objectAtIndex:valueInProgress] forState:UIControlStateNormal];
                [b setTitleColor:(valueInProgress != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonInProgress = b;
                break;
            case flagLogStatus:
                [b setTitle:[valuesLogStatus objectAtIndex:valueLogStatus] forState:UIControlStateNormal];
                [b setTitleColor:(valueLogStatus != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonLogStatus = b;
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
        [self configSet:@"markedfound" value:[NSString stringWithFormat:@"%ld", (long)valueMarkedAsFound]];
        [self configUpdate];
        return;
    }

    if (b == buttonIgnored) {
        valueIgnored = (valueIgnored + 1) % 3;
        [b setTitle:[valuesIgnored objectAtIndex:valueIgnored] forState:UIControlStateNormal];
        [b setTitleColor:(valueIgnored != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"ignored" value:[NSString stringWithFormat:@"%ld", (long)valueIgnored]];
        [self configUpdate];
        return;
    }

    if (b == buttonHighlighted) {
        valueHighlighted = (valueHighlighted + 1) % 3;
        [b setTitle:[valuesHighlighted objectAtIndex:valueHighlighted] forState:UIControlStateNormal];
        [b setTitleColor:(valueHighlighted != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"highlighted" value:[NSString stringWithFormat:@"%ld", (long)valueHighlighted]];
        [self configUpdate];
        return;
    }

    if (b == buttonInProgress) {
        valueInProgress = (valueInProgress + 1) % 3;
        [b setTitle:[valuesInProgress objectAtIndex:valueInProgress] forState:UIControlStateNormal];
        [b setTitleColor:(valueInProgress != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"inprogress" value:[NSString stringWithFormat:@"%ld", (long)valueInProgress]];
        [self configUpdate];
        return;
    }

    if (b == buttonLogStatus) {
        valueLogStatus = (valueLogStatus + 1) % 4;
        [b setTitle:[valuesLogStatus objectAtIndex:valueLogStatus] forState:UIControlStateNormal];
        [b setTitleColor:(valueLogStatus != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"logstatus" value:[NSString stringWithFormat:@"%ld", (long)valueLogStatus]];
        [self configUpdate];
        return;
    }

}

@end
