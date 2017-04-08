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

@protocol ImportDelegate

- (void)Import_WaypointProcessed:(dbWaypoint *)wp;

@end

@interface ImportTemplate : NSObject
{
    NSInteger newWaypointsCount;
    NSInteger totalWaypointsCount;

    NSInteger newLogsCount;
    NSInteger totalLogsCount;

    NSInteger newTrackablesCount;
    NSInteger totalTrackablesCount;

    NSInteger newImagesCount;

    dbAccount *account;
    dbGroup *group;

    InfoViewer *infoViewer;
    InfoItemID ivi;
};

// Needs to be defined here instead of in ImportManager.
typedef NS_ENUM(NSInteger, ImportOptions) {
    IMPORTOPTION_NONE = 0,
    IMPORTOPTION_LOGSONLY = 1,
    IMPORTOPTION_NOPOST = 2,
    IMPORTOPTION_NOPRE = 4,
    IMPORTOPTION_NOPARSE = 8,
};

@property (nonatomic) ImportOptions run_options;
@property (nonatomic, retain) id<ImportDelegate> delegate;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;

- (void)parseBefore;
- (void)parseAfter;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseGPX:(GCStringGPX *)gpx;
- (void)parseDictionary:(GCDictionary *)dict;
- (void)parseFile:(NSString *)filename infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (void)parseData:(NSData *)data infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (void)parseString:(NSString *)data infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;
- (void)parseDictionary:(GCDictionary *)dict infoViewer:(InfoViewer *)iv ivi:(InfoItemID)ivi;

@end
