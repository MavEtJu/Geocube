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

@interface FilterTableViewCell ()
{
    UIFont *f1;

    NSString *configPrefix;

    CGRect rectHeader;
    GCLabel *labelHeader;
}

@end

@implementation FilterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight;

    return self;
}

- (void)header
{
    /* Get some standard values */
    UITableViewCell *cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    f1 = cell.textLabel.font;
    f2 = cell.detailTextLabel.font;

    [self calculateRects];

    labelHeader = [[GCLabel alloc] initWithFrame:rectHeader];
    labelHeader.font = f1;
    if (fo.expanded == YES)
        labelHeader.text = [NSString stringWithFormat:@"Selected %@", fo.name];
    else
        labelHeader.text = [NSString stringWithFormat:@"Any %@", fo.name];
    labelHeader.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:labelHeader];
}

- (void)viewWillTransitionToSize
{
    [self calculateCellHeights];
    [self calculateRects];
    labelHeader.frame = rectHeader;
    [self calculateCellHeights];
}

- (void)calculateRects
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    width = bounds.size.width;
    [self calculateCellHeights];

    rectHeader = CGRectMake(20, 2, width - 40, cellHeight);
}

- (void)calculateCellHeights
{
    UITableViewCell *cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cellHeight = cell.frame.size.height;
}

- (NSInteger)cellHeight
{
    return cellHeight;
}

#pragma mark -- configuration

NEEDS_OVERLOADING(configUpdate)
NEEDS_OVERLOADING(configInit)

- (void)configPrefix:(NSString *)prefix
{
    configPrefix = prefix;
}

- (NSString *)configGet:(NSString *)_name
{
    return [waypointManager configGet:[NSString stringWithFormat:@"%@_%@", configPrefix, _name]];
}

- (void)configSet:(NSString *)_name value:(NSString *)_value
{
    [waypointManager configSet:[NSString stringWithFormat:@"%@_%@", configPrefix, _name] value:_value];
}

@end
