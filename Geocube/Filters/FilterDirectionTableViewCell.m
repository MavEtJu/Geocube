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

@interface FilterDirectionTableViewCell ()

@property (nonatomic, retain) NSArray<NSString *> *directions;
@property (nonatomic        ) FilterDirection direction;
@property (nonatomic, retain) NSString *directionString;

@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelDirection;
@property (nonatomic, weak) IBOutlet FilterButton *buttonDirection;
@property (nonatomic, weak) IBOutlet GCView *viewWindow;

@end

@implementation FilterDirectionTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.directions = @[
                   _(@"compass-north"),
                   _(@"compass-northeast"),
                   _(@"compass-east"),
                   _(@"compass-southeast"),
                   _(@"compass-south"),
                   _(@"compass-southwest"),
                   _(@"compass-west"),
                   _(@"compass-northwest"),
                   ];

    self.labelDirection.text = _(@"filterdirectiontableviewcell-Direction");
    [self.buttonDirection addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelHeader changeTheme];
    [self.labelDirection changeTheme];
    [self.buttonDirection changeTheme];
    [self.viewWindow changeTheme];
}

- (void)viewRefresh
{
    [self.buttonDirection setTitle:[self.directions objectAtIndex:self.direction] forState:UIControlStateNormal];
    [self.buttonDirection setTitle:[self.directions objectAtIndex:self.direction] forState:UIControlStateSelected];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    self.direction = [[self configGet:@"direction"] integerValue];
    self.directionString = [self.directions objectAtIndex:self.direction];
}

- (void)configUpdate
{
    [self configSet:@"direction" value:[NSString stringWithFormat:@"%ld", (long)self.direction]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", self.fo.expanded]];
    [self viewRefresh];
}

+ (NSString *)configPrefix
{
    return @"direction";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"direction", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"direction": @"0",
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)clickDirection:(FilterButton *)s
{
    [ActionSheetStringPicker
        showPickerWithTitle:_(@"filterdirectiontableviewcell-Select a direction")
        rows:self.directions
        initialSelection:self.direction
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.direction = selectedIndex;
            self.directionString = [self.directions objectAtIndex:self.direction];
            [self configUpdate];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
        }
        origin:self
    ];
}

@end
