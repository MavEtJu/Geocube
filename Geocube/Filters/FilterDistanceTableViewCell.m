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

#import "FilterDistanceTableViewCell.h"

#import "BaseObjectsLibrary/GCLabelNormalText.h"
#import "ManagersLibrary/LocalizationManager.h"

#import "FilterButton.h"

@interface FilterDistanceTableViewCell ()
{
    FilterDistance compareDistance;

    NSInteger distanceKm, distanceM;
    NSInteger variationKm, variationM;
}

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelDistance;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelVariation;
@property (nonatomic, weak) IBOutlet FilterButton *buttonCompareDistance;
@property (nonatomic, weak) IBOutlet FilterButton *buttonDistance;
@property (nonatomic, weak) IBOutlet FilterButton *buttonVariation;

@end

@implementation FilterDistanceTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.labelDistance.text = [NSString stringWithFormat:@"%@: ", _(@"filterdistancetableviewcell-Distance")];
    self.labelVariation.text = [NSString stringWithFormat:@"%@: ", _(@"filterdistancetableviewcell-Variation")];

    [self.buttonCompareDistance addTarget:self action:@selector(clickCompare:) forControlEvents:UIControlEventTouchDown];
    [self.buttonDistance addTarget:self action:@selector(clickDistance:) forControlEvents:UIControlEventTouchDown];
    [self.buttonVariation addTarget:self action:@selector(clickDistance:) forControlEvents:UIControlEventTouchDown];
}

- (void)changeTheme
{
    [super changeTheme];

    [self.labelHeader changeTheme];
    [self.labelDistance changeTheme];
    [self.labelVariation changeTheme];
    [self.buttonDistance changeTheme];
    [self.buttonVariation changeTheme];
    [self.buttonCompareDistance changeTheme];
}

- (void)viewRefresh
{
    switch (compareDistance) {
        case FILTER_DISTANCE_LESSTHAN:
            [self.buttonCompareDistance setTitle:_(@"=<") forState:UIControlStateNormal];
            [self.buttonCompareDistance setTitle:_(@"=<") forState:UIControlStateSelected];
            break;
        case FILTER_DISTANCE_MORETHAN:
            [self.buttonCompareDistance setTitle:_(@">=") forState:UIControlStateNormal];
            [self.buttonCompareDistance setTitle:_(@">=") forState:UIControlStateSelected];
            break;
        case FILTER_DISTANCE_INBETWEEN:
            [self.buttonCompareDistance setTitle:_(@"=") forState:UIControlStateNormal];
            [self.buttonCompareDistance setTitle:_(@"=") forState:UIControlStateSelected];
            break;
        default:
            break;
    }

    [self.buttonDistance setTitle:[MyTools niceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateNormal];
    [self.buttonDistance setTitle:[MyTools niceDistance:(distanceKm * 1000 + distanceM)] forState:UIControlStateSelected];
    [self.buttonVariation setTitle:[MyTools niceDistance:(variationKm * 1000 + variationM)] forState:UIControlStateNormal];
    [self.buttonVariation setTitle:[MyTools niceDistance:(variationKm * 1000 + variationM)] forState:UIControlStateSelected];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), fo.name];

    NSString *s;
    s = [self configGet:@"distanceKm"];
    distanceKm = [s integerValue];
    s = [self configGet:@"distanceM"];
    distanceM = [s integerValue];
    s = [self configGet:@"variationKm"];
    variationKm = [s integerValue];
    s = [self configGet:@"variationM"];
    variationM = [s integerValue];
    s = [self configGet:@"compareDistance"];
    compareDistance = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"compareDistance" value:[NSString stringWithFormat:@"%ld", (long)compareDistance]];
    [self configSet:@"distanceM" value:[NSString stringWithFormat:@"%ld", (long)distanceM]];
    [self configSet:@"distanceKm" value:[NSString stringWithFormat:@"%ld", (long)distanceKm]];
    [self configSet:@"variationM" value:[NSString stringWithFormat:@"%ld", (long)variationM]];
    [self configSet:@"variationKm" value:[NSString stringWithFormat:@"%ld", (long)variationKm]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%ld", (long)fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"distance";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"compareDistance", @"distanceM", @"distanceKm", @"variationM", @"variationKm", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"compareDistance": [NSString stringWithFormat:@"%ld", (long)FILTER_DISTANCE_LESSTHAN],
             @"distanceM": @"0",
             @"distanceKm": @"10",
             @"variationM": @"500",
             @"variationKm": @"2",
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)clickCompare:(FilterButton *)b
{
    compareDistance = (compareDistance + 1) % FILTER_DISTANCE_MAX;
    [self configUpdate];
}

- (void)clickDistance:(FilterButton *)b
{
    if (b == self.buttonDistance) {
        [ActionSheetDistancePicker showPickerWithTitle:_(@"filterdistancetableviewcell-Select distance") bigUnitString:@"km" bigUnitMax:999 selectedBigUnit:distanceKm smallUnitString:@"m" smallUnitMax:999 selectedSmallUnit:distanceM target:self action:@selector(measurementWasSelectedWithBigUnit:smallUnit:element:) origin:b];
        return;
    }
    if (b == self.buttonVariation) {
        [ActionSheetDistancePicker showPickerWithTitle:_(@"filterdistancetableviewcell-Select variation") bigUnitString:@"km" bigUnitMax:99 selectedBigUnit:variationKm smallUnitString:@"m" smallUnitMax:999 selectedSmallUnit:variationM target:self action:@selector(measurementWasSelectedWithBigUnit:smallUnit:element:) origin:b];
        return;
    }
}

- (void)measurementWasSelectedWithBigUnit:(NSNumber *)bu smallUnit:(NSNumber *)su element:(FilterButton *)e
{
    if (e == self.buttonDistance) {
        distanceM = su.integerValue;
        distanceKm = bu.integerValue;
        [self configUpdate];
        return;
    }
    if (e == self.buttonVariation) {
        variationM = su.integerValue;
        variationKm = bu.integerValue;
        [self configUpdate];
        return;
    }
}

@end
