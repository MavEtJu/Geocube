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

@interface FilterGroupsTableViewCell ()
{
    NSArray *groups;
}

@end

@implementation FilterGroupsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier filterObject:(FilterObject *)_fo
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    fo = _fo;

    [self configInit];
    [self header];

    __block NSInteger y = cellHeight;

    if (fo.expanded == NO) {
        [self.contentView sizeToFit];
        fo.cellHeight = cellHeight = y;
        return self;
    }

    groups = [dbc Groups];

    [groups enumerateObjectsUsingBlock:^(dbGroup *g, NSUInteger idx, BOOL *stop) {
        NSString *s = [NSString stringWithFormat:@"group_%ld", (long)g._id];
        NSString *c = [self configGet:s];
        if (c == nil)
            g.selected = NO;
        else
            g.selected = [c boolValue];

        CGRect rect = CGRectMake(20, y, width - 40, 15);
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = rect;
        [b setTitle:g.name forState:UIControlStateNormal];
        [b setTitleColor:(g.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickGroup:) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:b];

        y += 15;
    }];

    [self.contentView sizeToFit];
    fo.cellHeight = cellHeight = y;

    return self;
}

- (void)viewWillTransitionToSize
{
    [super viewWillTransitionToSize];
}

#pragma mark -- configuration

- (void)configInit
{
    [self configPrefix:@"groups"];

    NSString *s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];

    s = [self configGet:@"enabled"];
    if (s != nil)
        fo.expanded = [s boolValue];
}

- (void)configUpdate
{
    [self configSet:@"enabled" value:[NSString stringWithFormat:@"%d", fo.expanded]];
}

#pragma mark -- callback functions

- (void)clickGroup:(UIButton *)b
{
    [groups enumerateObjectsUsingBlock:^(dbGroup *g, NSUInteger idx, BOOL *stop) {
        if ([g.name isEqualToString:[b titleForState:UIControlStateNormal]] == YES) {
            g.selected = !g.selected;
            [b setTitleColor:(g.selected ? currentTheme.labelTextColor : currentTheme.labelTextColorDisabled) forState:UIControlStateNormal];
            [self configSet:[NSString stringWithFormat:@"group_%ld", (long)g._id] value:[NSString stringWithFormat:@"%d", g.selected]];
            [self configUpdate];
            *stop = YES;
        }
    }];
}

@end
