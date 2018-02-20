/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@property (nonatomic        ) FilterFlag valueHighlighted;
@property (nonatomic        ) FilterFlag valueMarkedAsFound;
@property (nonatomic        ) FilterFlag valueMarkedAsDNF;
@property (nonatomic        ) FilterFlag valueIgnored;
@property (nonatomic        ) FilterFlag valueInProgress;
@property (nonatomic        ) FilterFlag valueLoggedAsFound;
@property (nonatomic        ) FilterFlag valueLoggedAsDNF;
@property (nonatomic        ) FilterFlag valueOwner;
@property (nonatomic        ) FilterFlag valueEnabled;
@property (nonatomic        ) FilterFlag valueArchived;

@property (nonatomic, retain) NSArray<NSString *> *valuesHighlighted;
@property (nonatomic, retain) NSArray<NSString *> *valuesMarkedAsFound;
@property (nonatomic, retain) NSArray<NSString *> *valuesMarkedAsDNF;
@property (nonatomic, retain) NSArray<NSString *> *valuesIgnored;
@property (nonatomic, retain) NSArray<NSString *> *valuesInProgress;
@property (nonatomic, retain) NSArray<NSString *> *valuesLoggedAsFound;
@property (nonatomic, retain) NSArray<NSString *> *valuesLoggedAsDNF;
@property (nonatomic, retain) NSArray<NSString *> *valuesOwner;
@property (nonatomic, retain) NSArray<NSString *> *valuesEnabled;
@property (nonatomic, retain) NSArray<NSString *> *valuesArchived;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;

@property (nonatomic, weak) IBOutlet FilterButton *buttonHighlighted;
@property (nonatomic, weak) IBOutlet FilterButton *buttonMarkedAsFound;
@property (nonatomic, weak) IBOutlet FilterButton *buttonMarkedAsDNF;
@property (nonatomic, weak) IBOutlet FilterButton *buttonIgnored;
@property (nonatomic, weak) IBOutlet FilterButton *buttonInProgress;
@property (nonatomic, weak) IBOutlet FilterButton *buttonLoggedAsFound;
@property (nonatomic, weak) IBOutlet FilterButton *buttonLoggedAsDNF;
@property (nonatomic, weak) IBOutlet FilterButton *buttonOwner;
@property (nonatomic, weak) IBOutlet FilterButton *buttonEnabled;
@property (nonatomic, weak) IBOutlet FilterButton *buttonArchived;

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.valueHighlighted = FILTER_FLAGS_NOTCHECKED;
    self.valueMarkedAsFound = FILTER_FLAGS_NOTCHECKED;
    self.valueMarkedAsDNF = FILTER_FLAGS_NOTCHECKED;
    self.valueIgnored = FILTER_FLAGS_NOTCHECKED;
    self.valueInProgress = FILTER_FLAGS_NOTCHECKED;
    self.valueLoggedAsFound = FILTER_FLAGS_NOTCHECKED;
    self.valueLoggedAsDNF = FILTER_FLAGS_NOTCHECKED;
    self.valueEnabled = FILTER_FLAGS_NOTCHECKED;
    self.valueArchived = FILTER_FLAGS_NOTCHECKED;

    self.valuesHighlighted = @[
        _(@"filterflagstableviewcell-Highlighted"),
        _(@"filterflagstableviewcell-Highlighted"),
        _(@"filterflagstableviewcell-Not highlighted")];
    self.valuesMarkedAsFound = @[
        _(@"filterflagstableviewcell-Marked as Found"),
        _(@"filterflagstableviewcell-Marked as Found"),
        _(@"filterflagstableviewcell-Not marked as Found")];
    self.valuesMarkedAsDNF = @[
        _(@"filterflagstableviewcell-Marked as DNF"),
        _(@"filterflagstableviewcell-Marked as DNF"),
        _(@"filterflagstableviewcell-Not marked as DNF")];
    self.valuesIgnored = @[
        _(@"filterflagstableviewcell-Ignored"),
        _(@"filterflagstableviewcell-Ignored"),
        _(@"filterflagstableviewcell-Not ignored")];
    self.valuesInProgress = @[
        _(@"filterflagstableviewcell-In progress"),
        _(@"filterflagstableviewcell-In progress"),
        _(@"filterflagstableviewcell-Not in progress")];
    self.valuesLoggedAsFound = @[
        _(@"filterflagstableviewcell-Logged as Found"),
        _(@"filterflagstableviewcell-Logged as Found"),
        _(@"filterflagstableviewcell-Not logged as Found")];
    self.valuesLoggedAsDNF = @[
        _(@"filterflagstableviewcell-Logged as DNF"),
        _(@"filterflagstableviewcell-Logged as DNF"),
        _(@"filterflagstableviewcell-Not logged as DNF")];
    self.valuesOwner = @[
        _(@"filterflagstableviewcell-Mine"),
        _(@"filterflagstableviewcell-Mine"),
        _(@"filterflagstableviewcell-Not mine")];
    self.valuesEnabled = @[
        _(@"filterflagstableviewcell-Enabled"),
        _(@"filterflagstableviewcell-Enabled"),
        _(@"filterflagstableviewcell-Not enabled")];
    self.valuesArchived = @[
        _(@"filterflagstableviewcell-Archived"),
        _(@"filterflagstableviewcell-Archived"),
        _(@"filterflagstableviewcell-Not archived")];

    NSString *c;

#define CHECK(__type__, __config__) \
    [self.button ## __type__ addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown]; \
    c = [self configGet:__config__]; \
    if (c != nil) \
        self.value ## __type__ = [c integerValue];

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

    [self viewRefresh];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelHeader changeTheme];
}

- (void)viewRefresh
{
#define VIEW(__type__, __config__) \
    [self.button ## __type__ setTitle:[self.values ## __type__ objectAtIndex:self.value ## __type__] forState:UIControlStateNormal]; \
    [self.button ## __type__ setTitleColor:(self.value ## __type__ != 0 ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];

    VIEW(MarkedAsFound, @"markedfound");
    VIEW(MarkedAsDNF, @"markeddnf");
    VIEW(Ignored, @"ignored");
    VIEW(Highlighted, @"highlighted");
    VIEW(InProgress, @"inprogress");
    VIEW(LoggedAsFound, @"loggedasfound");
    VIEW(LoggedAsDNF, @"loggedasdnf");
    VIEW(Owner, @"owner");
    VIEW(Enabled, @"isenabled");
    VIEW(Archived, @"isarchived");
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
    [self viewRefresh];
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
    return @{@"enabled": @"0",
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
    if (b == self.button ## __type__) { \
        self.value ## __type__ = (self.value ## __type__ + 1) % [self.values ## __type__ count]; \
        [self configSet:__config__ value:[NSString stringWithFormat:@"%ld", (long)self.value ## __type__]]; \
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
