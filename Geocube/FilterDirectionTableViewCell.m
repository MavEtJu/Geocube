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

@interface FilterDirectionTableViewCell ()
{
    NSArray<NSString *> *directions;
    FilterDirection direction;
    NSString *directionString;
    UIButton *directionButton;
}

@end

@implementation FilterDirectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    directions = @[@"North", @"North East", @"East", @"South East", @"South", @"South West", @"West", @"North West"];

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;
    GCLabel *l;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = cellHeight = y;
        return self;
    }

    rect = CGRectMake(20, y, 100, 15);
    l = [[GCLabel alloc] initWithFrame:rect];
    l.text = @"Direction is:";
    l.font = f2;
    l.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:l];

    rect = CGRectMake(120, y, width - 140, 15);
    directionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    directionButton.frame = rect;
    [directionButton addTarget:self action:@selector(clickDirection:) forControlEvents:UIControlEventTouchDown];
    [self.contentView addSubview:directionButton];
    [self clickDirection:nil];
    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    [self configPrefix:@"direction"];

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    direction = [[self configGet:@"direction"] integerValue];
    directionString = [directions objectAtIndex:direction];
}

- (void)configUpdate
{
    [self configSet:@"direction" value:[NSString stringWithFormat:@"%ld", (long)direction]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickDirection:(UIButton *)s
{
    if (s == nil) {
        [directionButton setTitle:[directions objectAtIndex:direction] forState:UIControlStateNormal];
        [directionButton setTitle:[directions objectAtIndex:direction] forState:UIControlStateSelected];
        return;
    }

    [ActionSheetStringPicker
        showPickerWithTitle:@"Select a Direction"
        rows:directions
        initialSelection:direction
        doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            direction = selectedIndex;
            directionString = [directions objectAtIndex:direction];
            [self clickDirection:nil];
            [self configUpdate];
        }
        cancelBlock:^(ActionSheetStringPicker *picker) {
        }
        origin:self
    ];
}

@end
