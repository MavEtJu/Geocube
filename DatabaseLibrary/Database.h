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

#import <sqlite3.h>

typedef sqlite3_int64 NSId;

#ifndef Geocube_database_h
#define Geocube_database_h

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"
#define KEY_VERSION_DB  @"version"

@interface database : NSObject

@property (nonatomic)sqlite3 *db;

- (instancetype)init;
- (void)checkVersion;
- (NSInteger)getDatabaseSize;
- (void)singleStatement:(NSString *)sql;
- (NSString *)saveCopy;
- (BOOL)restoreFromCopy:(NSString *)source;
- (void)cleanupAfterDelete;
- (void)checkForBackup;

@end

extern database *db;

#endif
