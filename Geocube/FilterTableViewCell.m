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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    f1 = cell.textLabel.font;
    f2 = cell.detailTextLabel.font;
    cellHeight = cell.frame.size.height;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    width = applicationFrame.size.width;
    CGRect rect;
    UILabel *l;

    rect = CGRectMake(20, 2, width - 40, cellHeight);
    l = [[UILabel alloc] initWithFrame:rect];
    l.font = f1;
    if (fo.expanded == YES)
        l.text = [NSString stringWithFormat:@"Selected %@", fo.name];
    else
        l.text = [NSString stringWithFormat:@"Any %@", fo.name];
    l.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:l];
}

- (NSInteger)cellHeight
{
    return height;
}

#pragma mark -- configuration

- (NSString *)configGet:(NSString *)_name
{
    dbConfig *c = [dbConfig dbGetByKey:[NSString stringWithFormat:@"config_%@_%@", configPrefix, _name]];
    if (c == nil)
        return nil;
    return c.value;
}

- (void)configInit
{
}

- (void)configSet:(NSString *)_name value:(NSString *)_value
{
    [dbConfig dbUpdateOrInsert:[NSString stringWithFormat:@"config_%@_%@", configPrefix, _name] value:_value];
}

- (void)configUpdate
{
    NSAssert(0, @"%@ should be overriden", [self class]);
}

@end
