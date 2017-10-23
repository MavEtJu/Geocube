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

@property (nonatomic      ) NSInteger config_min, config_max;

@property (nonatomic, weak) IBOutlet RangeSlider *slider;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelSlider;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;

@end

@implementation FilterFavouritesTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.slider.minimumRangeLength = .00;
    [self.slider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [self.slider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [self.slider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    UIImage *image = [UIImage imageNamed:@"fillrange.png"];
    [self.slider addTarget:self action:@selector(reportSlider:) forControlEvents:UIControlEventValueChanged];
    [self.slider setInRangeTrackImage:image];
    self.slider.min = self.config_min / 100.0;
    self.slider.max = self.config_max / 100.0;
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelSlider changeTheme];
    [self.labelHeader changeTheme];
}

- (void)viewRefresh
{
    /* Do not update self.slider.min/max here */

    NSString *minString = [NSString stringWithFormat:@"%ld", (long)self.config_min];
    NSString *maxString = [NSString stringWithFormat:@"%ld", (long)self.config_max];

    if (self.config_min == 0 && self.config_max == 100)
        self.labelSlider.text = _(@"filterfavouritestableviewcell-Favourites: Anything");
    else if (self.config_min == self.config_max)
        self.labelSlider.text = [NSString stringWithFormat:_(@"filterfavouritestableviewcell-Favourites: %@"), minString];
    else if (self.config_max == 100)
        self.labelSlider.text = [NSString stringWithFormat:_(@"filterfavouritestableviewcell-Favourites: At least %@"), minString];
    else if (self.config_min == 0)
        self.labelSlider.text = [NSString stringWithFormat:_(@"filterfavouritestableviewcell-Favourites: At most %@"), maxString];
    else
        self.labelSlider.text = [NSString stringWithFormat:_(@"filterfavouritestableviewcell-Favourites: Between %@ and %@"), minString, maxString];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), self.fo.name];

    NSString *s;
    s = [self configGet:@"min"];
    self.config_min = [s integerValue];
    s = [self configGet:@"max"];
    self.config_max = [s integerValue];
}

- (void)configUpdate
{
    [self configSet:@"min" value:[NSString stringWithFormat:@"%ld", (long)self.config_min]];
    [self configSet:@"max" value:[NSString stringWithFormat:@"%ld", (long)self.config_max]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%ld", (long)self.fo.expanded]];
    [self viewRefresh];
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
    self.config_min = (int)(100 * s.min);
    self.config_max = (int)(100 * s.max);
    [self configUpdate];
}

@end
