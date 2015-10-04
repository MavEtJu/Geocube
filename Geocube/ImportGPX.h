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

#ifndef Geocube_Import_GPX_h
#define Geocube_Import_GPX_h

@protocol ImportGPXDelegate

- (void)updateData:(NSInteger)percentageRead newWaypointsCount:(NSInteger)newWaypointsCount totalWaypointsCount:(NSInteger)totalWaypointsCount newLogsCount:(NSInteger)newLogsCount totalLogsCount:(NSInteger)totalLogsCount newTrackablesCount:(NSInteger)newTrackablesCount totalTrackablesCount:(NSInteger)totalTrackablesCount newImagesCount:(NSInteger)newImagesCount;

@end

@interface ImportGPX : NSObject <NSXMLParserDelegate> {
    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;
    NSInteger newLogsCount;
    NSInteger totalLogsCount;
    NSInteger newTrackablesCount;
    NSInteger totalTrackablesCount;
    NSUInteger percentageRead;
    NSUInteger totalLines;
    NSInteger newImagesCount;

    NSArray *files;
    dbGroup *group;
    dbAccount *account;

    NSMutableDictionary *logIdGCId;
    NSMutableArray *attributesYES, *attributesNO;
    NSMutableArray *logs;
    NSMutableArray *trackables;
    NSInteger index;
    NSInteger inItem, inLog, inTrackable, inGroundspeak;
    NSMutableString *currentText;
    NSString *currentElement;
    NSString *gsOwnerNameId, *logFinderNameId;
    dbWaypoint *currentWP;
    dbGroundspeak *currentGS;
    dbLog *currentLog;
    dbTrackable *currentTB;

    id delegate;
}

@property (nonatomic)id delegate;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;
- (void)parseBefore;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseAfter;

@end

#endif
