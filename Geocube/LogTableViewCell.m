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

#import "LogTableViewCell.h"

#import "BaseObjectsLibrary/GCLabel.h"
#import "ToolsLibrary/MyTools.h"
#import "ToolsLibrary/Coordinates.h"
#import "DatabaseLibrary/dbLog.h"

@interface LogTableViewCell ()

@property (nonatomic, retain) IBOutlet UIImageView *ivLogType;
@property (nonatomic, retain) IBOutlet GCLabelSmallText *labelDateTime;
@property (nonatomic, retain) IBOutlet GCLabelSmallText *labelLogger;
@property (nonatomic, retain) IBOutlet GCLabelNormalText *labelLog;
@property (nonatomic, retain) IBOutlet GCLabelSmallText *labelLocalLog;
@property (nonatomic, retain) IBOutlet GCLabelSmallText *labelNotSubmitted;
@property (nonatomic, retain) IBOutlet GCLabelSmallText *labelCoordinates;

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
    [self.labelLocalLog changeTheme];
    [self.labelNotSubmitted changeTheme];
    [self.labelCoordinates changeTheme];
}

- (void)setLog:(dbLog *)log
{
    self.labelDateTime.text = [MyTools dateTimeString_YYYY_MM_DD_hh_mm_ss:log.datetime_epoch];
    self.labelLogger.text = log.logger.name;
    self.ivLogType.image = [imageLibrary get:log.logstring.icon];
    self.labelLog.text = log.log;
    self.labelLocalLog.hidden = (log.localLog == NO);
    self.labelNotSubmitted.hidden = (log.needstobelogged == NO);
    if (log.latitude != 0 && log.longitude != 0)
        self.labelCoordinates.text = [Coordinates niceCoordinates:log.latitude longitude:log.longitude];
    else
        self.labelCoordinates.text = @"";
}

@end
