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

@interface FilterFlagsTableViewCell ()
{
    UIButton *buttonHighlighted;
    UIButton *buttonMarkedAsFound;
    UIButton *buttonMarkedAsDNF;
    UIButton *buttonIgnored;
    UIButton *buttonInProgress;
    UIButton *buttonLoggedAsFound;
    UIButton *buttonLoggedAsDNF;
    UIButton *buttonOwner;

    FilterFlag valueHighlighted;
    FilterFlag valueMarkedAsFound;
    FilterFlag valueMarkedAsDNF;
    FilterFlag valueIgnored;
    FilterFlag valueInProgress;
    FilterFlag valueLoggedAsFound;
    FilterFlag valueLoggedAsDNF;
    FilterFlag valueOwner;

    NSArray *valuesHighlighted;
    NSArray *valuesMarkedAsFound;
    NSArray *valuesMarkedAsDNF;
    NSArray *valuesIgnored;
    NSArray *valuesInProgress;
    NSArray *valuesLoggedAsFound;
    NSArray *valuesLoggedAsDNF;
    NSArray *valuesOwner;
}

@end

@implementation FilterFlagsTableViewCell

typedef NS_ENUM(NSInteger, FlagType) {
    flagHighlighted,
    flagMarkedAsFound,
    flagMarkedAsDNF,
    flagIgnored,
    flagInProgress,
    flagLoggedAsFound,
    flagLoggedAsDNF,
    flagOwner,
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

    valueHighlighted = FILTER_FLAGS_NOTCHECKED;
    valueMarkedAsFound = FILTER_FLAGS_NOTCHECKED;
    valueMarkedAsDNF = FILTER_FLAGS_NOTCHECKED;
    valueIgnored = FILTER_FLAGS_NOTCHECKED;
    valueInProgress = FILTER_FLAGS_NOTCHECKED;
    valueLoggedAsFound = FILTER_FLAGS_NOTCHECKED;
    valueLoggedAsDNF = FILTER_FLAGS_NOTCHECKED;

    valuesHighlighted = @[@"Highlighted", @"Highlighted", @"Not highlighted"];
    valuesMarkedAsFound = @[@"Marked as Found", @"Marked as Found", @"Not marked as found"];
    valuesMarkedAsDNF = @[@"Marked as DNF", @"Marked as DNF", @"Not marked as DNF"];
    valuesIgnored = @[@"Ignored", @"Ignored", @"Not ignored"];
    valuesInProgress = @[@"In progress", @"In progress", @"Not in progress"];
    valuesLoggedAsFound = @[@"Logged as found", @"Logged as found", @"Not logged as found"];
    valuesLoggedAsDNF = @[@"Logged as DNF", @"Logged as DNF", @"Not logged as DNF"];
    valuesOwner = @[@"Mine", @"Mine", @"Not mine"];

    c = [self configGet:@"highlighted"];
    if (c != nil)
        valueHighlighted = [c integerValue];
    c = [self configGet:@"markedfound"];
    if (c != nil)
        valueMarkedAsFound = [c integerValue];
    c = [self configGet:@"markeddnf"];
    if (c != nil)
        valueMarkedAsDNF = [c integerValue];
    c = [self configGet:@"ignored"];
    if (c != nil)
        valueIgnored = [c integerValue];
    c = [self configGet:@"inprogress"];
    if (c != nil)
        valueInProgress = [c integerValue];
    c = [self configGet:@"loggedasfound"];
    if (c != nil)
        valueLoggedAsFound = [c integerValue];
    c = [self configGet:@"loggedasdnf"];
    if (c != nil)
        valueLoggedAsDNF = [c integerValue];
    c = [self configGet:@"owner"];
    if (c != nil)
        valueOwner = [c integerValue];

    for (FlagType i = 0; i < flagMax; i++) {
        CGRect rect = CGRectMake(20, y, width - 40, 20);
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
            case flagMarkedAsDNF:
                [b setTitle:[valuesMarkedAsDNF objectAtIndex:valueMarkedAsDNF] forState:UIControlStateNormal];
                [b setTitleColor:(valueMarkedAsDNF != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonMarkedAsDNF = b;
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
            case flagLoggedAsFound:
                [b setTitle:[valuesLoggedAsFound objectAtIndex:valueLoggedAsFound] forState:UIControlStateNormal];
                [b setTitleColor:(valueLoggedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonLoggedAsFound = b;
                break;
            case flagLoggedAsDNF:
                [b setTitle:[valuesLoggedAsDNF objectAtIndex:valueLoggedAsDNF] forState:UIControlStateNormal];
                [b setTitleColor:(valueLoggedAsDNF != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonLoggedAsDNF = b;
                break;
            case flagOwner:
                [b setTitle:[valuesOwner objectAtIndex:valueOwner] forState:UIControlStateNormal];
                [b setTitleColor:(valueOwner != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
                buttonOwner = b;
                break;
            default:
                NSAssert1(0, @"Flag %ld not found", (long)i);
        }
        y += 20;
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
        valueMarkedAsFound = (valueMarkedAsFound + 1) % [valuesMarkedAsFound count];
        [b setTitle:[valuesMarkedAsFound objectAtIndex:valueMarkedAsFound] forState:UIControlStateNormal];
        [b setTitleColor:(valueMarkedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"markedfound" value:[NSString stringWithFormat:@"%ld", (long)valueMarkedAsFound]];
        [self configUpdate];
        return;
    }

    if (b == buttonMarkedAsDNF) {
        valueMarkedAsDNF = (valueMarkedAsDNF + 1) % [valuesMarkedAsDNF count];
        [b setTitle:[valuesMarkedAsDNF objectAtIndex:valueMarkedAsDNF] forState:UIControlStateNormal];
        [b setTitleColor:(valueMarkedAsDNF != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"markeddnf" value:[NSString stringWithFormat:@"%ld", (long)valueMarkedAsDNF]];
        [self configUpdate];
        return;
    }

    if (b == buttonIgnored) {
        valueIgnored = (valueIgnored + 1) % [valuesIgnored count];
        [b setTitle:[valuesIgnored objectAtIndex:valueIgnored] forState:UIControlStateNormal];
        [b setTitleColor:(valueIgnored != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"ignored" value:[NSString stringWithFormat:@"%ld", (long)valueIgnored]];
        [self configUpdate];
        return;
    }

    if (b == buttonHighlighted) {
        valueHighlighted = (valueHighlighted + 1) % [valuesHighlighted count];
        [b setTitle:[valuesHighlighted objectAtIndex:valueHighlighted] forState:UIControlStateNormal];
        [b setTitleColor:(valueHighlighted != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"highlighted" value:[NSString stringWithFormat:@"%ld", (long)valueHighlighted]];
        [self configUpdate];
        return;
    }

    if (b == buttonInProgress) {
        valueInProgress = (valueInProgress + 1) % [valuesInProgress count];
        [b setTitle:[valuesInProgress objectAtIndex:valueInProgress] forState:UIControlStateNormal];
        [b setTitleColor:(valueInProgress != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"inprogress" value:[NSString stringWithFormat:@"%ld", (long)valueInProgress]];
        [self configUpdate];
        return;
    }

    if (b == buttonLoggedAsFound) {
        valueLoggedAsFound = (valueLoggedAsFound + 1) % [valuesLoggedAsFound count];
        [b setTitle:[valuesLoggedAsFound objectAtIndex:valueLoggedAsFound] forState:UIControlStateNormal];
        [b setTitleColor:(valueLoggedAsFound != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"loggedasfound" value:[NSString stringWithFormat:@"%ld", (long)valueLoggedAsFound]];
        [self configUpdate];
        return;
    }

    if (b == buttonLoggedAsDNF) {
        valueLoggedAsDNF = (valueLoggedAsDNF + 1) % [valuesLoggedAsDNF count];
        [b setTitle:[valuesLoggedAsDNF objectAtIndex:valueLoggedAsDNF] forState:UIControlStateNormal];
        [b setTitleColor:(valueLoggedAsDNF != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"loggedasdnf" value:[NSString stringWithFormat:@"%ld", (long)valueLoggedAsDNF]];
        [self configUpdate];
        return;
    }

    if (b == buttonOwner) {
        valueOwner = (valueOwner + 1) % [valuesOwner count];
        [b setTitle:[valuesOwner objectAtIndex:valueOwner] forState:UIControlStateNormal];
        [b setTitleColor:(valueOwner != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [self configSet:@"owner" value:[NSString stringWithFormat:@"%ld", (long)valueOwner]];
        [self configUpdate];
        return;
    }

}

@end
