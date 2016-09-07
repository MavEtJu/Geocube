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

@interface FilterDifficultyTableViewCell ()
{
    RangeSlider *slider;
    GCLabel *sliderLabel;
    float config_min, config_max;
}

@end

@implementation FilterDifficultyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    CGRect rect;
    NSInteger y = cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = cellHeight = y;
        return self;
    }

    rect = CGRectMake(20, y, width - 40, 15);
    sliderLabel = [[GCLabel alloc] initWithFrame:rect];
    sliderLabel.text = @"Difficulty: 1 - 5";
    sliderLabel.font = f2;
    sliderLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:sliderLabel];
    y += 25;

    rect = CGRectMake(20, y, width - 40, 15);
    slider = [[RangeSlider alloc] initWithFrame:rect];
    slider.minimumRangeLength = .00;
    [slider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [slider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [slider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    UIImage *image = [UIImage imageNamed:@"fillrange.png"];
    [slider addTarget:self action:@selector(reportSlider:) forControlEvents:UIControlEventValueChanged];
    [slider setInRangeTrackImage:image];

    slider.min = (config_min - 1) / 4.0;
    slider.max = (config_max - 1) / 4.0;

    [self.contentView addSubview:slider];
    [self reportSlider:nil];
    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

#pragma mark -- configuration

- (void)configInit
{
    [self configPrefix:@"difficulty"];

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    s = [self configGet:@"min"];
    if (s == nil)
        config_min = 1;
    else
        config_min = [s floatValue];
    s = [self configGet:@"max"];
    if (s == nil)
        config_max = 5;
    else
        config_max = [s floatValue];
}

- (void)configUpdate
{
    [self configSet:@"min" value:[NSString stringWithFormat:@"%0.1f", config_min]];
    [self configSet:@"max" value:[NSString stringWithFormat:@"%0.1f", config_max]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)reportSlider:(RangeSlider *)s
{
    config_min = (2 + (int)(4 * slider.min * 2)) / 2.0;
    config_max = (2 + (int)(4 * slider.max * 2)) / 2.0;
    [self configUpdate];

    NSString *minString = [NSString stringWithFormat:((int)config_min == config_min) ? @"%1.0f" : @"%0.1f", config_min];
    NSString *maxString = [NSString stringWithFormat:((int)config_max == config_max) ? @"%1.0f" : @"%0.1f", config_max];

    sliderLabel.text = [NSString stringWithFormat:@"Difficulty: %@ - %@", minString, maxString];
}

@end
