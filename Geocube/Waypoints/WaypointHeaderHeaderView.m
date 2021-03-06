/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@interface WaypointHeaderHeaderView ()

@property (weak, nonatomic) IBOutlet GCLabelNormalText *labelName;
@property (weak, nonatomic) IBOutlet GCLabelSmallText *labelWhoWhen;
@property (weak, nonatomic) IBOutlet GCLabelSmallText *labelCode;
@property (weak, nonatomic) IBOutlet GCLabelSmallText *labelLastImport;

@end

@implementation WaypointHeaderHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelName changeTheme];
    [self.labelWhoWhen changeTheme];
    [self.labelCode changeTheme];
    [self.labelLastImport changeTheme];
}

- (void)setWaypoint:(dbWaypoint *)waypoint
{
    UIColor *bgColor = [UIColor clearColor];
    if (waypoint.flag_highlight == YES)
        bgColor = currentStyleTheme.labelHighlightBackgroundColor;

    self.labelName.text = waypoint.wpt_urlname;
    self.labelName.backgroundColor = bgColor;

    NSMutableString *s = [NSMutableString stringWithString:@""];
    if (IS_EMPTY(waypoint.gs_owner.name) == NO)
        [s appendFormat:_(@"waypointheaderheaderview-by %@"), waypoint.gs_owner.name];
    if (waypoint.wpt_date_placed_epoch != 0)
        [s appendFormat:_(@"waypointheaderheaderview- on %@"), [MyTools dateTimeString_YYYY_MM_DD:waypoint.wpt_date_placed_epoch]];
    self.labelWhoWhen.text = s;
    self.labelWhoWhen.backgroundColor = bgColor;

    self.labelCode.text = [NSString stringWithFormat:@"%@ (%@)", waypoint.wpt_name, waypoint.account.site];
    self.labelCode.backgroundColor = bgColor;

    self.labelLastImport.text = [NSString stringWithFormat:_(@"waypointheaderheaderview-Last imported on %@"), [MyTools dateTimeString_YYYY_MM_DD:waypoint.date_lastimport_epoch]];
    self.labelLastImport.backgroundColor = bgColor;
}

@end
