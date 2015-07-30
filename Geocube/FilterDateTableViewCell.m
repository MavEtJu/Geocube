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

@implementation FilterDateTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;
    UILabel *l;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = height = y;
        return self;
    }

    rect = CGRectMake(20, y, width - 40, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f2;
    l.textAlignment = NSTextAlignmentLeft;
    l.text = @"Placed on: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(80, y, 50, 15);
    buttonComparePlaced = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonComparePlaced.frame = rect;
    [buttonComparePlaced addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonComparePlaced];
    comparePlaced--;
    [self clickCompare:buttonComparePlaced];

    rect = CGRectMake(130, y, width - 150, 15);
    buttonDatePlaced = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDatePlaced.frame = rect;
    [buttonDatePlaced addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonDatePlaced];
    [self dateWasSelected:[NSDate dateWithTimeIntervalSince1970:epochPlaced ] element:buttonDatePlaced];

    y += 20;

    rect = CGRectMake(20, y, width - 40, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f2;
    l.textAlignment = NSTextAlignmentLeft;
    l.text = @"Last log: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(80, y, 50, 15);
    buttonCompareLastLog = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonCompareLastLog.frame = rect;
    [buttonCompareLastLog addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonCompareLastLog];
    compareLastLog--;
    [self clickCompare:buttonCompareLastLog];

    rect = CGRectMake(130, y, width - 150, 15);
    buttonDateLastLog = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDateLastLog.frame = rect;
    [buttonDateLastLog addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonDateLastLog];
    [self dateWasSelected:[NSDate dateWithTimeIntervalSince1970:epochLastLog ] element:buttonDateLastLog];
    
    y += 20;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    configPrefix = @"dates";
    
    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    s = [self configGet:@"placed_epoch"];
    if (s == nil)
        epochPlaced = 946684800;
    else
        epochPlaced = [s integerValue];

    s = [self configGet:@"lastlog_epoch"];
    if (s == nil)
        epochLastLog = 946684800;
    else
        epochLastLog = [s integerValue];

    s = [self configGet:@"placed_compare"];
    if (s == nil)
        comparePlaced= 1;
    else
        comparePlaced = [s integerValue];

    s = [self configGet:@"lastlog_compare"];
    if (s == nil)
        compareLastLog = 1;
    else
        compareLastLog = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"placed_epoch" value:[NSString stringWithFormat:@"%ld", (long)epochPlaced]];
    [self configSet:@"lastlog_epoch" value:[NSString stringWithFormat:@"%ld", (long)epochLastLog]];
    [self configSet:@"placed_compare" value:[NSString stringWithFormat:@"%ld", (long)comparePlaced]];
    [self configSet:@"lastlog_compare" value:[NSString stringWithFormat:@"%ld", (long)compareLastLog]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickCompare:(UIButton *)b
{
    NSInteger compare = -1;
    if (b == buttonCompareLastLog)
        compare = compareLastLog = (compareLastLog + 1) % 3;
    if (b == buttonComparePlaced)
        compare = comparePlaced = (comparePlaced + 1) % 3;
    [self configUpdate];

    switch (compare) {
    case 0:
        [b setTitle:@"before" forState:UIControlStateNormal];
        break;
    case 1:
        [b setTitle:@"after" forState:UIControlStateNormal];
        break;
    case 2:
        [b setTitle:@"on" forState:UIControlStateNormal];
        break;
    }
}

- (void)clickDate:(UIButton *)b
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *minimumDateComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    [minimumDateComponents setYear:2000];
    [minimumDateComponents setMonth:1];
    [minimumDateComponents setDay:1];
    NSDate *minDate = [calendar dateFromComponents:minimumDateComponents];
    NSDate *maxDate = [NSDate date];

    NSDate *d;
    if (b == buttonDateLastLog)
        d = [NSDate dateWithTimeIntervalSince1970:epochLastLog];
    if (b == buttonDatePlaced)
        d = [NSDate dateWithTimeIntervalSince1970:epochPlaced];

    asdp =
        [[ActionSheetDatePicker alloc]
         initWithTitle:@"Date" datePickerMode:UIDatePickerModeDate
         selectedDate:d //self.selectedDate
         minimumDate:minDate
         maximumDate:maxDate
         target:self
         action:@selector(dateWasSelected:element:)
         origin:b];

    [asdp showActionSheetPicker];
}

- (void)dateWasSelected:(NSDate *)date element:(UIButton *)b
{
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateFromString = [dateFormatter stringFromDate:date];

    [b setTitle:dateFromString forState:UIControlStateNormal];

    if (b == buttonDateLastLog)
        epochLastLog = [date timeIntervalSince1970];
    if (b == buttonDatePlaced)
        epochPlaced = [date timeIntervalSince1970];
    [self configUpdate];
}

@end
