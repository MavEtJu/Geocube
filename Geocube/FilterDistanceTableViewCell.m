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
    l.text = @"Distance: ";
    [self.contentView addSubview:l];

    rect = CGRectMake(80, y, 20, 15);
    compareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    compareButton.frame = rect;
    [compareButton addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:compareButton];
    compareSmaller = NO;
    [self clickCompare:compareButton];

    distanceM = 500;
    distanceKm = 2;
    rect = CGRectMake(100, y, width - 20 - 120, 15);
    distanceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    distanceButton.frame = rect;
    [distanceButton addTarget:self action:@selector(clickDistance:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:distanceButton];
    [self measurementWasSelectedWithBigUnit:[NSNumber numberWithLong:distanceKm ] smallUnit:[NSNumber numberWithLong:distanceM] element:nil];

    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

- (void)clickCompare:(UIButton *)b
{
    compareSmaller = !compareSmaller;
    if (compareSmaller == YES) {
        [compareButton setTitle:@"=<" forState:UIControlStateNormal];
        [compareButton setTitle:@"=<" forState:UIControlStateSelected];
    } else {
        [compareButton setTitle:@">=" forState:UIControlStateNormal];
        [compareButton setTitle:@">=" forState:UIControlStateSelected];
    }
}

- (void)clickDistance:(UIButton *)b
{
    [ActionSheetDistancePicker showPickerWithTitle:@"Select distance" bigUnitString:@"km" bigUnitMax:999 selectedBigUnit:distanceKm smallUnitString:@"m" smallUnitMax:999 selectedSmallUnit:distanceM target:self action:@selector(measurementWasSelectedWithBigUnit:smallUnit:element:) origin:b];
}

- (void)measurementWasSelectedWithBigUnit:(NSNumber *)bu smallUnit:(NSNumber *)su element:(NSString *)e
{
    distanceM = su.integerValue;
    distanceKm = bu.integerValue;
    [distanceButton setTitle:[MyTools NiceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateNormal];
    [distanceButton setTitle:[MyTools NiceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateSelected];
}

@end
