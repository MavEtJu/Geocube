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

@interface FilterDatesTableViewCell ()

@property (nonatomic        ) FilterDate comparePlaced, compareLastLog;
@property (nonatomic, retain) ActionSheetDatePicker *asdp;
@property (nonatomic        ) NSInteger epochPlaced, epochLastLog;

@property (nonatomic, weak) IBOutlet FilterButton *buttonComparePlaced;
@property (nonatomic, weak) IBOutlet FilterButton *buttonCompareLastLog;
@property (nonatomic, weak) IBOutlet FilterButton *buttonDatePlaced;
@property (nonatomic, weak) IBOutlet FilterButton *buttonDateLastLog;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelPlaced;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelLastLog;

@end

@implementation FilterDatesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.labelPlaced.text = [NSString stringWithFormat:@"%@: ", _(@"filterdatetableviewcell-Placed on")];
    self.labelLastLog.text = [NSString stringWithFormat:@"%@: ", _(@"filterdatetableviewcell-Last log")];

    [self.buttonComparePlaced addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.buttonCompareLastLog addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDatePlaced addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDateLastLog addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelHeader changeTheme];
    [self.labelPlaced changeTheme];
    [self.labelLastLog changeTheme];
    [self.buttonDatePlaced changeTheme];
    [self.buttonDateLastLog changeTheme];
    [self.buttonComparePlaced changeTheme];
    [self.buttonCompareLastLog changeTheme];
}

- (void)viewRefresh
{
    switch (self.compareLastLog) {
    case FILTER_DATE_BEFORE:
        [self.buttonCompareLastLog setTitle:_(@"filterdatetableviewcell-Before") forState:UIControlStateNormal];
        break;
    case FILTER_DATE_AFTER:
        [self.buttonCompareLastLog setTitle:_(@"filterdatetableviewcell-After") forState:UIControlStateNormal];
        break;
    case FILTER_DATE_ON:
        [self.buttonCompareLastLog setTitle:_(@"filterdatetableviewcell-On") forState:UIControlStateNormal];
        break;
    }

    switch (self.comparePlaced) {
    case FILTER_DATE_BEFORE:
        [self.buttonComparePlaced setTitle:_(@"filterdatetableviewcell-Before") forState:UIControlStateNormal];
        break;
    case FILTER_DATE_AFTER:
        [self.buttonComparePlaced setTitle:_(@"filterdatetableviewcell-After") forState:UIControlStateNormal];
        break;
    case FILTER_DATE_ON:
        [self.buttonComparePlaced setTitle:_(@"filterdatetableviewcell-On") forState:UIControlStateNormal];
        break;
    }

    NSString *s = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.epochLastLog] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    [self.buttonDateLastLog setTitle:s forState:UIControlStateNormal];

    s = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:self.epochPlaced] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    [self.buttonDatePlaced setTitle:s forState:UIControlStateNormal];
}

#pragma mark -- configuration

#define JAN1_2000   946684800

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    NSString *s;
    s = [self configGet:@"placed_epoch"];
    self.epochPlaced = [s integerValue];
    s = [self configGet:@"lastlog_epoch"];
    self.epochLastLog = [s integerValue];
    s = [self configGet:@"placed_compare"];
    self.comparePlaced = [s integerValue];
    s = [self configGet:@"lastlog_compare"];
    self.compareLastLog = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"placed_epoch" value:[NSString stringWithFormat:@"%ld", (long)self.epochPlaced]];
    [self configSet:@"lastlog_epoch" value:[NSString stringWithFormat:@"%ld", (long)self.epochLastLog]];
    [self configSet:@"placed_compare" value:[NSString stringWithFormat:@"%ld", (long)self.comparePlaced]];
    [self configSet:@"lastlog_compare" value:[NSString stringWithFormat:@"%ld", (long)self.compareLastLog]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"dates";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"placed_epoch", @"lastlog_epoch", @"placed_compare", @"lastlog_compare", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"placed_epoch": [@JAN1_2000 stringValue],
             @"lastlog_epoch": [@JAN1_2000 stringValue],
             @"placed_compare": [NSString stringWithFormat:@"%ld", (long)FILTER_DATE_AFTER],
             @"lastlog_compare": [NSString stringWithFormat:@"%ld", (long)FILTER_DATE_AFTER],
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)clickCompare:(FilterButton *)b
{
    FilterDate compare = -1;
    if (b == self.buttonCompareLastLog)
        compare = self.compareLastLog = (self.compareLastLog + 1) % 3;
    if (b == self.buttonComparePlaced)
        compare = self.comparePlaced = (self.comparePlaced + 1) % 3;
    [self configUpdate];
    [self viewRefresh];
}

- (void)clickDate:(FilterButton *)b
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:2000];
    [minimumDateComponents setMonth:1];
    [minimumDateComponents setDay:1];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];

    NSDate *d;
    if (b == self.buttonDateLastLog)
        d = [NSDate dateWithTimeIntervalSince1970:self.epochLastLog];
    if (b == self.buttonDatePlaced)
        d = [NSDate dateWithTimeIntervalSince1970:self.epochPlaced];

    self.asdp =
        [[ActionSheetDatePicker alloc]
         initWithTitle:_(@"filterdatetableviewcell-Date") datePickerMode:UIDatePickerModeDate
         selectedDate:d //self.selectedDate
         minimumDate:minDate
         maximumDate:maxDate
         target:self
         action:@selector(dateWasSelected:element:)
         origin:b];

    [self.asdp showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)date element:(FilterButton *)b
{
    if (b == self.buttonDateLastLog)
        self.epochLastLog = [date timeIntervalSince1970];
    if (b == self.buttonDatePlaced)
        self.epochPlaced = [date timeIntervalSince1970];
    [self configUpdate];
    [self viewRefresh];
}

@end
