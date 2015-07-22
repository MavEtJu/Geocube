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

@interface ImportGPXViewController : GCViewController {
    NSString *filename;
    dbGroup *group;

    UILabel *newWaypointsLabel;
    UILabel *totalWaypointsLabel;
    UILabel *newLogsLabel;
    UILabel *totalLogsLabel;
    UILabel *newTravelbugsLabel;
    UILabel *totalTravelbugsLabel;
    UILabel *progressLabel;

    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;
    NSInteger newLogsCount;
    NSInteger totalLogsCount;
    NSInteger newTravelbugsCount;
    NSInteger totalTravelbugsCount;

    NSUInteger percentageRead;

    Import_GPX *imp;
    BOOL importDone;
}

- (id)init:(NSString *)filename group:(dbGroup *)group;

@end
