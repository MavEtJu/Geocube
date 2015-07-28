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

@implementation FilterFavouritesTableViewCell

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
    sliderLabel = [[UILabel alloc] initWithFrame:rect];
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

    [self.contentView addSubview:slider];
    y += 35;

    [self.contentView sizeToFit];
    fo.cellHeight = height = y;

    return self;
}

- (void)reportSlider:(RangeSlider *)s
{
    float min = (int)(100 * slider.min);
    float max = (int)(100 * slider.max);

    NSString *minString = [NSString stringWithFormat:((int)min == min) ? @"%1.0f" : @"%0.1f", min];
    NSString *maxString = [NSString stringWithFormat:((int)max == max) ? @"%1.0f" : @"%0.1f", max];

    if (min == 0 && max == 100)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: anything"];
    else if (min == max)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: %@", minString];
    else if (max == 100)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: at least %@", minString];
    else if (min == 0)
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: at most %@", maxString];
    else
        sliderLabel.text = [NSString stringWithFormat:@"Favourites: between %@ and %@", minString, maxString];
}

@end
