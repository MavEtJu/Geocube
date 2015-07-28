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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    [self header:fo];

    CGRect rect;
    NSInteger y = 0;
    UILabel *l;

    rect = CGRectMake(20, 2, width - 40, cellHeight);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f1;
    l.text = fo.name;
    l.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:l];
    y += cellHeight;

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

    rect = CGRectMake(80, y, 20, 15);
    buttonComparePlaced = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonComparePlaced.frame = rect;
    [buttonComparePlaced addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonComparePlaced];
    comparePlaced = 0;
    [self clickCompare:buttonComparePlaced];

    rect = CGRectMake(100, y, width - 120, 15);
    buttonDatePlaced = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDatePlaced.frame = rect;
    [buttonDatePlaced addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonDatePlaced];
    [self clickCompare:buttonDatePlaced];

    y += 35;

    rect = CGRectMake(20, y, width - 40, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f2;
    l.textAlignment = NSTextAlignmentLeft;
    l.text = @"Last log: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(80, y, 20, 15);
    buttonCompareLastLog = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonCompareLastLog.frame = rect;
    [buttonCompareLastLog addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonCompareLastLog];
    compareLastLog = 0;
    [self clickCompare:buttonCompareLastLog];

    rect = CGRectMake(100, y, width - 120, 15);
    buttonDateLastLog = [UIButton buttonWithType:UIButtonTypeSystem];
    buttonDateLastLog.frame = rect;
    [buttonDateLastLog addTarget:self action:@selector(clickDate:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:buttonDateLastLog];
    [self clickCompare:buttonDateLastLog];
    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

- (void)clickCompare:(UIButton *)b
{
    NSInteger compare = -1;
    if (b == buttonCompareLastLog)
        compare = compareLastLog = (compareLastLog + 1) % 3;
    if (b == buttonComparePlaced)
        compare = comparePlaced = (comparePlaced + 1) % 3;

    switch (compare) {
    case 0:
        [b setTitle:@"=<" forState:UIControlStateNormal];
        [b setTitle:@"=<" forState:UIControlStateSelected];
        break;
    case 1:
        [b setTitle:@">=" forState:UIControlStateNormal];
        [b setTitle:@">=" forState:UIControlStateSelected];
        break;
    case 2:
        [b setTitle:@"=" forState:UIControlStateNormal];
        [b setTitle:@"=" forState:UIControlStateSelected];
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

    NSDate *d = [NSDate dateWithTimeIntervalSince1970:12345678];

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
    [b setTitle:dateFromString forState:UIControlStateSelected];
}

@end
