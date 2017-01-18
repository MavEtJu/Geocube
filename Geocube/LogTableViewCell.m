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

@interface LogTableViewCell ()

@property (nonatomic, retain) IBOutlet UIImageView *ivLogType;
@property (nonatomic, retain) IBOutlet GCLabel *labelDateTime;
@property (nonatomic, retain) IBOutlet GCLabel *labelLogger;
@property (nonatomic, retain) IBOutlet GCLabel *labelLog;

@end

@implementation LogTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.labelLog changeTheme];
    [self.labelLogger changeTheme];
    [self.labelDateTime changeTheme];
}

- (void)setLog:(dbLog *)log
{
    self.labelDateTime.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:log.datetime_epoch];
    self.labelLogger.text = log.logger.name;
    self.ivLogType.image = [imageLibrary get:log.logstring.icon];
    self.labelLog.text = log.log;
}

@end
