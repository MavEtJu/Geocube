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

@interface ImportTemplate : NSObject
{
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

    InfoItemImport *infoItemImport;
}

enum {
    RUN_OPTION_NONE = 0,
    RUN_OPTION_LOGSONLY = 1,
};

@property (nonatomic) NSInteger run_options;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;

- (void)parseBefore;
- (void)parseAfter;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseDictionary:(NSDictionary *)dict;
- (void)parseFile:(NSString *)filename infoItemImport:(InfoItemImport *)iii;
- (void)parseData:(NSData *)data infoItemImport:(InfoItemImport *)iii;
- (void)parseString:(NSString *)data infoItemImport:(InfoItemImport *)iii;
- (void)parseDictionary:(NSDictionary *)dict infoItemImport:(InfoItemImport *)iii;

@end
