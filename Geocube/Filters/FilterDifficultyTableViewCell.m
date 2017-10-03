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

@interface FilterDifficultyTableViewCell ()
{
    float config_min, config_max;
}

@property (nonatomic, weak) IBOutlet RangeSlider *slider;
@property (nonatomic, weak) IBOutlet GCLabelSmallText *labelSlider;
@property (nonatomic, weak) IBOutlet GCLabelNormalText *labelHeader;

@end

@implementation FilterDifficultyTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];

    self.labelSlider.text = [NSString stringWithFormat:@"%@: 1 - 5", _(@"filterdifficultytableviewcell-Difficulty")];
    self.slider.minimumRangeLength = .00;
    [self.slider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [self.slider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    [self.slider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    UIImage *image = [UIImage imageNamed:@"fillrange.png"];
    [self.slider addTarget:self action:@selector(reportSlider:) forControlEvents:UIControlEventValueChanged];
    [self.slider setInRangeTrackImage:image];
    self.slider.min = (config_min - 1) / 4.0;
    self.slider.max = (config_max - 1) / 4.0;

    [self reportSlider:nil];
}

- (void)changeTheme
{
    [self.labelSlider changeTheme];
    [self.labelHeader changeTheme];
}

#pragma mark -- configuration

- (void)configInit
{
    [super configInit];

    self.labelHeader.text = [NSString stringWithFormat:_(@"filtertableviewcell-Selected %@"), fo.name];

    NSString *s;
    s = [self configGet:@"min"];
    config_min = [s floatValue];
    s = [self configGet:@"max"];
    config_max = [s floatValue];
}

- (void)configUpdate
{
    [self configSet:@"min" value:[NSString stringWithFormat:@"%0.1f", config_min]];
    [self configSet:@"max" value:[NSString stringWithFormat:@"%0.1f", config_max]];
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

+ (NSString *)configPrefix
{
    return @"difficulty";
}

+ (NSArray<NSString *> *)configFields
{
    return @[@"min", @"max", @"enabled"];
}

+ (NSDictionary *)configDefaults
{
    return @{@"min": @"1",
             @"max": @"5",
             @"enabled": @"0",
             };
}

#pragma mark -- callback functions

- (void)reportSlider:(RangeSlider *)s
{
    if (s != nil) {
        config_min = (2 + (int)(4 * s.min * 2)) / 2.0;
        config_max = (2 + (int)(4 * s.max * 2)) / 2.0;
        [self configUpdate];
    }

    NSString *minString = [NSString stringWithFormat:((int)config_min == config_min) ? @"%1.0f" : @"%0.1f", config_min];
    NSString *maxString = [NSString stringWithFormat:((int)config_max == config_max) ? @"%1.0f" : @"%0.1f", config_max];

    self.labelSlider.text = [NSString stringWithFormat:@"%@: %@ - %@", _(@"filterdifficultytableviewcell-Difficulty"), minString, maxString];
}

@end
