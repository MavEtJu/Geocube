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

@interface FilterFavouritesTableViewCell ()
{
    RangeSlider *slider;
    GCLabel *sliderLabel;
    NSInteger config_min, config_max;
}

@end

@implementation FilterFavouritesTableViewCell

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
    sliderLabel.text = @"Favourites: at least 0";
    sliderLabel.font = f2;
    sliderLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:sliderLabel];
    y += 25;

    rect = CGRectMake(20, y, width - 40, 15);
    slider = [[RangeSlider alloc] initWithFrame:rect];
    slider.minimumRangeLength = 0.00;
    [slider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [slider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [slider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    UIImage *image = [UIImage imageNamed:@"fillrange.png"];
    [slider addTarget:self action:@selector(reportSlider:) forControlEvents:UIControlEventValueChanged];
    [slider setInRangeTrackImage:image];
    slider.min = config_min / 100.0;
    slider.max = config_max / 100.0;
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
    [super configInit];

    NSString *s;
    s = [self configGet:@"min"];
    config_min = [s integerValue];
    s = [self configGet:@"max"];
    config_max = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"min" value:[NSString stringWithFormat:@"%ld", (long)config_min]];
    [self configSet:@"max" value:[NSString stringWithFormat:@"%ld", (long)config_max]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%ld", (long)fo.expanded]];
}

+ (NSString *)configPrefix
{
    return @"favourites";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"min", @"max", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"min": @"0",
             @"max": @"100",
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)reportSlider:(RangeSlider *)s
{
    config_min = (int)(100 * slider.min);
    config_max = (int)(100 * slider.max);
    [self configUpdate];

    NSString *minString = [NSString stringWithFormat:@"%ld", (long)config_min];
    NSString *maxString = [NSString stringWithFormat:@"%ld", (long)config_max];

    if (config_min == 0 && config_max == 100)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: anything"];
    else if (config_min == config_max)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: %@", minString];
    else if (config_max == 100)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: at least %@", minString];
    else if (config_min == 0)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: at most %@", maxString];
    else
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: between %@ and %@", minString, maxString];
}

@end
