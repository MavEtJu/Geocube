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

@interface PersonalNoteTableViewCell ()

@property (nonatomic, weak) IBOutlet GCLabel *labelNote;
@property (nonatomic, weak) IBOutlet GCLabel *labelCode;

@end

@implementation PersonalNoteTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelCode changeTheme];
    [self.labelNote changeTheme];
}

- (void)setNote:(dbPersonalNote *)pn
{
    dbWaypoint *wp = [dbWaypoint dbGetByName:pn.wp_name];
    self.labelCode.text = [NSString stringWithFormat:@"%@ - %@", wp.wpt_name, wp.wpt_urlname];
    self.labelNote.text = pn.note;
}

@end
