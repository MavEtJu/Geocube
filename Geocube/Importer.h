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

@protocol ImporterDelegate

- (void)importerDelegateUpdate;

@end

@interface Importer : NSObject
{
    id delegate;

    NSInteger run_options;

    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;

    NSInteger newLogsCount;
    NSInteger totalLogsCount;

    NSInteger newTrackablesCount;
    NSInteger totalTrackablesCount;

    NSUInteger percentageRead;
    NSUInteger totalLines;

    NSInteger newImagesCount;

    dbAccount *account;
    dbGroup *group;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSInteger newWaypointsCount;
@property (nonatomic, readonly) NSInteger totalWaypointsCount;
@property (nonatomic, readonly) NSInteger newLogsCount;
@property (nonatomic, readonly) NSInteger totalLogsCount;
@property (nonatomic, readonly) NSInteger newTrackablesCount;
@property (nonatomic, readonly) NSInteger totalTrackablesCount;
@property (nonatomic, readonly) NSUInteger percentageRead;
@property (nonatomic, readonly) NSUInteger totalLines;
@property (nonatomic, readonly) NSInteger newImagesCount;
@property (nonatomic) NSInteger run_options;

@property (nonatomic, retain) dbGroup *group;
@property (nonatomic, retain) dbAccount *account;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;

- (void)updateDelegates;
- (void)parseBefore;
- (void)parseAfter;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseDictionary:(NSDictionary *)dict;

@end
