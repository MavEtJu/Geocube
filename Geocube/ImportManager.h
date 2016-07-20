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

@protocol ImportManagerDelegate

- (void)importManager_setDescription:(NSString *)description;
- (void)ImportManager_setTotalWaypoints:(NSInteger)v;
- (void)ImportManager_setNewWaypoints:(NSInteger)v;
- (void)ImportManager_setNewLogs:(NSInteger)v;
- (void)ImportManager_setTotalLogs:(NSInteger)v;
- (void)ImportManager_setNewTrackables:(NSInteger)v;
- (void)ImportManager_setTotalTrackables:(NSInteger)v;
- (void)ImportManager_setTotalImages:(NSInteger)v;
- (void)ImportManager_setQueuedImages:(NSInteger)v;

@end

@interface ImportManager : NSObject <SSZipArchiveDelegate>

enum {
    RUN_OPTION_NONE = 0,
    RUN_OPTION_LOGSONLY = 1,
};

@property (nonatomic, retain) id downloadsImportsDelegate;

- (void)run:(NSObject *)data group:(dbGroup *)group account:(dbAccount *)account options:(NSInteger)runoptions;

- (void)resetImports;

@end
