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

@interface FilterTableViewCell ()

@property (nonatomic, retain) NSString *configPrefix;
@property (nonatomic        ) CGRect rectHeader;
@property (nonatomic, retain) GCLabelNormalText *labelHeader;

@end

@implementation FilterTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.fo = fo;

    [self configInit];
    [self.contentView sizeToFit];
    self.fo.cellHeight = self.cellHeight;

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    self.width = applicationFrame.size.width;

    [self changeTheme];
    [self configInit];
}

- (void)initFO:(FilterObject *)fo
{
    self.fo = fo;
    [self configInit];
}

- (void)header
{
    /// XXX
}

#pragma mark -- configuration

- NEEDS_OVERLOADING_VOID(configUpdate)
- NEEDS_OVERLOADING_VOID(viewRefresh)
+ NEEDS_OVERLOADING_NSSTRING(configPrefix)
+ NEEDS_OVERLOADING_NSARRAY_NSSTRING(configFields)
+ NEEDS_OVERLOADING_NSDICTIONARY(configDefaults)

- (void)configInit
{
    [self configPrefix:[[self class] configPrefix]];

    NSString *s = [self configGet:@"enabled"];
    self.fo.expanded = [s boolValue];
}

- (void)configPrefix:(NSString *)prefix
{
    self.configPrefix = prefix;
}

- (NSString *)configGet:(NSString *)name
{
    NSString *retvalue = [waypointManager configGet:[NSString stringWithFormat:@"%@_%@", self.configPrefix, name]];
    if (retvalue != nil)
        return retvalue;

    NSDictionary *defs = [[self class] configDefaults];
    return [defs objectForKey:name];
}

- (void)configSet:(NSString *)name value:(NSString *)value
{
    [waypointManager configSet:[NSString stringWithFormat:@"%@_%@", self.configPrefix, name] value:value];
}

@end
