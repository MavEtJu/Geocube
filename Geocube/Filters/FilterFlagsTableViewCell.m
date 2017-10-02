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
    FilterButton *buttonHighlighted;
    FilterButton *buttonMarkedAsFound;
    FilterButton *buttonMarkedAsDNF;
    FilterButton *buttonIgnored;
    FilterButton *buttonInProgress;
    FilterButton *buttonLoggedAsFound;
    FilterButton *buttonLoggedAsDNF;
    FilterButton *buttonOwner;
    FilterButton *buttonEnabled;
    FilterButton *buttonArchived;

    FilterFlag valueHighlighted;
    FilterFlag valueMarkedAsFound;
    FilterFlag valueMarkedAsDNF;
    FilterFlag valueIgnored;
    FilterFlag valueInProgress;
    FilterFlag valueLoggedAsFound;
    FilterFlag valueLoggedAsDNF;
    FilterFlag valueOwner;
    FilterFlag valueEnabled;
    FilterFlag valueArchived;

    NSArray<NSString *> *valuesHighlighted;
    NSArray<NSString *> *valuesMarkedAsFound;
    NSArray<NSString *> *valuesMarkedAsDNF;
    NSArray<NSString *> *valuesIgnored;
    NSArray<NSString *> *valuesInProgress;
    NSArray<NSString *> *valuesLoggedAsFound;
    NSArray<NSString *> *valuesLoggedAsDNF;
    NSArray<NSString *> *valuesOwner;
    NSArray<NSString *> *valuesEnabled;
    NSArray<NSString *> *valuesArchived;
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
    flagEnabled,
    flagArchived,
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
    valueEnabled = FILTER_FLAGS_NOTCHECKED;
    valueArchived = FILTER_FLAGS_NOTCHECKED;

    valuesHighlighted = @[_(@"filterflagstableviewcell-Highlighted"), _(@"filterflagstableviewcell-Highlighted"), _(@"filterflagstableviewcell-Not highlighted")];
    valuesMarkedAsFound = @[_(@"filterflagstableviewcell-Marked as Found"), _(@"filterflagstableviewcell-Marked as Found"), _(@"filterflagstableviewcell-Not marked as Found")];
    valuesMarkedAsDNF = @[_(@"filterflagstableviewcell-Marked as DNF"), _(@"filterflagstableviewcell-Marked as DNF"), _(@"filterflagstableviewcell-Not marked as DNF")];
    valuesIgnored = @[_(@"filterflagstableviewcell-Ignored"), _(@"filterflagstableviewcell-Ignored"), _(@"filterflagstableviewcell-Not ignored")];
    valuesInProgress = @[_(@"filterflagstableviewcell-In progress"), _(@"filterflagstableviewcell-In progress"), _(@"filterflagstableviewcell-Not in progress")];
    valuesLoggedAsFound = @[_(@"filterflagstableviewcell-Logged as Found"), _(@"filterflagstableviewcell-Logged as Found"), _(@"filterflagstableviewcell-Not logged as Found")];
    valuesLoggedAsDNF = @[_(@"filterflagstableviewcell-Logged as DNF"), _(@"filterflagstableviewcell-Logged as DNF"), _(@"filterflagstableviewcell-Not logged as DNF")];
    valuesOwner = @[_(@"filterflagstableviewcell-Mine"), _(@"filterflagstableviewcell-Mine"), _(@"filterflagstableviewcell-Not mine")];
    valuesEnabled = @[_(@"filterflagstableviewcell-Enabled"), _(@"filterflagstableviewcell-Enabled"), _(@"filterflagstableviewcell-Not enabled")];
    valuesArchived = @[_(@"filterflagstableviewcell-Archived"), _(@"filterflagstableviewcell-Archived"), _(@"filterflagstableviewcell-Not archived")];

#define CHECK(__type__, __config__) \
    c = [self configGet:__config__]; \
    if (c != nil) \
        value ## __type__ = [c integerValue];

    CHECK(MarkedAsFound, @"markedfound");
    CHECK(MarkedAsDNF, @"markeddnf");
    CHECK(Ignored, @"ignored");
    CHECK(Highlighted, @"highlighted");
    CHECK(InProgress, @"inprogress");
    CHECK(LoggedAsFound, @"loggedasfound");
    CHECK(LoggedAsDNF, @"loggedasdnf");
    CHECK(Owner, @"owner");
    CHECK(Enabled, @"isenabled");
    CHECK(Archived, @"isarchived");

    for (FlagType i = 0; i < flagMax; i++) {
        FilterButton *b = [FilterButton buttonWithType:UIButtonTypeSystem];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        CGRect rect = CGRectMake(20, y, width - 40, b.titleLabel.font.lineHeight);
        b.frame = rect;
        [self.contentView addSubview:b];

#define CASE(__type__) \
        case flag ## __type__: \
            [b setTitle:[values ## __type__ objectAtIndex:value ## __type__] forState:UIControlStateNormal]; \
            [b setTitleColor:(value ## __type__ != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal]; \
            button ## __type__ = b; \
            break;

        switch (i) {
            CASE(Highlighted);
            CASE(MarkedAsFound);
            CASE(MarkedAsDNF);
            CASE(Ignored);
            CASE(InProgress);
            CASE(LoggedAsFound);
            CASE(LoggedAsDNF);
            CASE(Owner);
            CASE(Enabled);
            CASE(Archived);
            default:
                NSAssert1(0, @"Flag %ld not found", (long)i);
        }
        y += b.frame.size.height;
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
    [super configInit];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

+ (NSString *)configPrefix
{
    return @"flags";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"enabled", @"markedfound", @"markeddnf", @"ignored", @"highlighted", @"inprogress", @"loggedasfound", @"loggedasdnf", @"owner", @"isenabled", @"isarchived"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"enabled": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"markedfound": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"markeddnf": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"ignored": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"highlighted": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"inprogress": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"loggedasfound": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"loggedasdnf": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"owner": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"isenabled": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             @"isarchived": [NSString stringWithFormat:@"%ld", (long)FILTER_FLAGS_NOTCHECKED],
             };
}

#pragma mark -- callback functions

- (void)clickGroup:(FilterButton *)b
{
#define PROCESS(__type__, __config__) \
    if (b == button ## __type__) { \
        value ## __type__ = (value ## __type__ + 1) % [values ## __type__ count]; \
        [b setTitle:[values ## __type__ objectAtIndex:value ## __type__] forState:UIControlStateNormal]; \
        [b setTitleColor:(value ## __type__ != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal]; \
        [self configSet:__config__ value:[NSString stringWithFormat:@"%ld", (long)value ## __type__]]; \
        [self configUpdate]; \
        return; \
    }

    PROCESS(MarkedAsFound, @"markedfound");
    PROCESS(MarkedAsDNF, @"markeddnf");
    PROCESS(Ignored, @"ignored");
    PROCESS(Highlighted, @"highlighted");
    PROCESS(InProgress, @"inprogress");
    PROCESS(LoggedAsFound, @"loggedasfound");
    PROCESS(LoggedAsDNF, @"loggedasdnf");
    PROCESS(Owner, @"owner");
    PROCESS(Enabled, @"isenabled");
    PROCESS(Archived, @"isarchived");
}

@end
