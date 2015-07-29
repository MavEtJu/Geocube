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

@implementation FilterDistanceTableViewCell

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
    l.text = @"Distance: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(80, y, 20, 15);
    compareDistanceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    compareDistanceButton.frame = rect;
    [compareDistanceButton addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:compareDistanceButton];
    compareDistance--;
    [self clickCompare:compareDistanceButton];

    rect = CGRectMake(100, y, width - 20 - 120, 15);
    distanceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    distanceButton.frame = rect;
    [distanceButton addTarget:self action:@selector(clickDistance:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:distanceButton];
    [self measurementWasSelectedWithBigUnit:[NSNumber numberWithLong:distanceKm] smallUnit:[NSNumber numberWithLong:distanceM] element:distanceButton];

    y += 35;

    rect = CGRectMake(20, y, width - 40, 15);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f2;
    l.textAlignment = NSTextAlignmentLeft;
    l.text = @"Variation: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(100, y, width - 20 - 120, 15);
    variationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    variationButton.frame = rect;
    [variationButton addTarget:self action:@selector(clickDistance:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:variationButton];
    [self measurementWasSelectedWithBigUnit:[NSNumber numberWithLong:variationKm] smallUnit:[NSNumber numberWithLong:variationM] element:variationButton];

    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    configPrefix = @"distance";
    
    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    s = [self configGet:@"distanceKm"];
    if (s == nil)
        distanceKm = 10;
    else
        distanceKm = [s integerValue];

    s = [self configGet:@"distanceM"];
    if (s == nil)
        distanceM = 0;
    else
        distanceM = [s integerValue];

    s = [self configGet:@"variationKm"];
    if (s == nil)
        variationKm = 2;
    else
        variationKm = [s integerValue];

    s = [self configGet:@"variationM"];
    if (s == nil)
        variationM = 500;
    else
        variationM = [s integerValue];

    s = [self configGet:@"compareDistance"];
    if (s == nil)
        compareDistance = 0;
    else
        compareDistance = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"compareDistance" value:[NSString stringWithFormat:@"%ld", compareDistance]];
    [self configSet:@"distanceM" value:[NSString stringWithFormat:@"%ld", distanceM]];
    [self configSet:@"distanceKm" value:[NSString stringWithFormat:@"%ld", distanceKm]];
    [self configSet:@"variationM" value:[NSString stringWithFormat:@"%ld", variationM]];
    [self configSet:@"variationKm" value:[NSString stringWithFormat:@"%ld", variationKm]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickCompare:(UIButton *)b
{
    compareDistance = (compareDistance + 1) % 3;
    [self configUpdate];

    switch (compareDistance) {
        case 0:
            [compareDistanceButton setTitle:@"=<" forState:UIControlStateNormal];
            [compareDistanceButton setTitle:@"=<" forState:UIControlStateSelected];
            break;
        case 1:
            [compareDistanceButton setTitle:@">=" forState:UIControlStateNormal];
            [compareDistanceButton setTitle:@">=" forState:UIControlStateSelected];
            break;
        case 2:
            [compareDistanceButton setTitle:@"=" forState:UIControlStateNormal];
            [compareDistanceButton setTitle:@"=" forState:UIControlStateSelected];
            break;
    }
}

- (void)clickDistance:(UIButton *)b
{
    if (b == distanceButton) {
        [ActionSheetDistancePicker showPickerWithTitle:@"Select distance" bigUnitString:@"km" bigUnitMax:999 selectedBigUnit:distanceKm smallUnitString:@"m" smallUnitMax:999 selectedSmallUnit:distanceM target:self action:@selector(measurementWasSelectedWithBigUnit:smallUnit:element:) origin:b];
        return;
    }
    if (b == variationButton) {
        [ActionSheetDistancePicker showPickerWithTitle:@"Select variation" bigUnitString:@"km" bigUnitMax:99 selectedBigUnit:variationKm smallUnitString:@"m" smallUnitMax:999 selectedSmallUnit:variationM target:self action:@selector(measurementWasSelectedWithBigUnit:smallUnit:element:) origin:b];
        return;
    }
}

- (void)measurementWasSelectedWithBigUnit:(NSNumber *)bu smallUnit:(NSNumber *)su element:(UIButton *)e
{
    if (e == distanceButton) {
        distanceM = su.integerValue;
        distanceKm = bu.integerValue;
        [distanceButton setTitle:[MyTools NiceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateNormal];
        [distanceButton setTitle:[MyTools NiceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateSelected];
        [self configUpdate];
        return;
    }
    if (e == variationButton) {
        variationM = su.integerValue;
        variationKm = bu.integerValue;
        [variationButton setTitle:[MyTools NiceDistance:(variationKm * 1000 + variationM)] forState:UIControlStateNormal];
        [variationButton setTitle:[MyTools NiceDistance:(variationKm * 1000 + variationM)] forState:UIControlStateSelected];
        [self configUpdate];
        return;
    }
}

@end
