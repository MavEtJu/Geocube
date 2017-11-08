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

@interface ImportTemplate : NSObject

@property (nonatomic        ) NSInteger newWaypointsCount;
@property (nonatomic        ) NSInteger totalWaypointsCount;

@property (nonatomic        ) NSInteger newLogsCount;
@property (nonatomic        ) NSInteger totalLogsCount;

@property (nonatomic        ) NSInteger newTrackablesCount;
@property (nonatomic        ) NSInteger totalTrackablesCount;

@property (nonatomic        ) NSInteger newImagesCount;

@property (nonatomic, retain) dbAccount *account;
@property (nonatomic, retain) dbGroup *group;

@property (nonatomic, retain) InfoItem *iiImport;

@property (nonatomic        ) ImportOptions run_options;
@property (nonatomic, retain) id<ImportDelegate> delegate;

- (instancetype)init:(dbGroup *)group account:(dbAccount *)account;

- (void)parseBefore;
- (void)parseAfter;
- (void)parseFile:(NSString *)filename;
- (void)parseData:(NSData *)data;
- (void)parseString:(NSString *)data;
- (void)parseGPX:(GCStringGPX *)gpx;
- (void)parseDictionary:(GCDictionary *)dict;
- (void)parseFile:(NSString *)filename infoItem:(InfoItem *)iii;
- (void)parseData:(NSData *)data infoItem:(InfoItem *)iii;
- (void)parseString:(NSString *)data infoItem:(InfoItem *)iii;
- (void)parseDictionary:(GCDictionary *)dict infoItem:(InfoItem *)iii;

@end
