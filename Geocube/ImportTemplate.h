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

@protocol ImportDelegate

- (void)Import_setTotalWaypoints:(NSInteger)v;
- (void)Import_setNewWaypoints:(NSInteger)v;
- (void)Import_setTotalLogs:(NSInteger)v;
- (void)Import_setNewLogs:(NSInteger)v;
- (void)Import_setTotalTrackables:(NSInteger)v;
- (void)Import_setNewTrackables:(NSInteger)v;
- (void)Import_setProgress:(NSInteger)l total:(NSInteger)t;

@end

@interface ImportTemplate : NSObject
{
    id<ImportDelegate> delegate;

    NSInteger run_options;

    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;

    NSInteger newLogsCount;
    NSInteger totalLogsCount;

    NSInteger newTrackablesCount;
    NSInteger totalTrackablesCount;

    NSInteger newImagesCount;

    dbAccount *account;
    dbGroup *group;
}

enum {
    RUN_OPTION_NONE = 0,
    RUN_OPTION_LOGSONLY = 1,
};

@property (nonatomic, retain) id<ImportDelegate> delegate;
@property (nonatomic) NSInteger run_options;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;

- (void)parseBefore;
- (void)parseAfter;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseDictionary:(NSDictionary *)dict;

@end
