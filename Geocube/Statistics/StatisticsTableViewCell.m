/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2017 Edwin Groothuis
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

@interface StatisticsTableViewCell ()

@end

@implementation StatisticsTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeTheme];
}

- (void)changeTheme
{
    [super changeTheme];
    [self.site changeTheme];
    [self.status changeTheme];
    [self.wpsFound changeTheme];
    [self.wpsHidden changeTheme];
    [self.wpsDNF changeTheme];
    [self.recommendationsGiven changeTheme];
    [self.recommendationsReceived changeTheme];

    self.site.font = [UIFont systemFontOfSize:configManager.fontNormalTextSize];
    self.status.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
    self.wpsFound.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
    self.wpsHidden.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
    self.wpsDNF.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
    self.recommendationsGiven.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
    self.recommendationsReceived.font = [UIFont systemFontOfSize:configManager.fontSmallTextSize];
}

@end
