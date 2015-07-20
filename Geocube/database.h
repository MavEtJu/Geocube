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

#ifndef Geocube_database_h
#define Geocube_database_h

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"


@interface database : NSObject {
    sqlite3 *db;
    id dbaccess;
}

- (id)init;
- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;

- (dbCacheGroup *)CacheGroups_get_byName:(NSString *)name;
- (NSInteger)CacheGroups_count_caches:(NSInteger)wpgid;
- (void)CacheGroups_new:(NSString *)name isUser:(BOOL)isUser;
- (void)CacheGroups_delete:(NSInteger)_id;
- (void)CacheGroups_empty:(NSInteger)_id;
- (void)CacheGroups_rename:(NSInteger)_id newName:(NSString *)newname;
- (void)CacheGroups_add_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid;
- (BOOL)CacheGroups_contains_cache:(NSInteger)wpgid cache_id:(NSInteger)wpid;
- (NSArray *)CacheGroups_all;
- (NSArray *)CacheGroups_all_byCacheId:(NSInteger)wp_id;

- (NSInteger)Cache_get_byname:(NSString *)name;
- (NSInteger)Cache_add:(dbCache *)wp;
- (void)Cache_update:(dbCache *)wp;
- (NSArray *)Caches_all;

- (NSInteger)Log_by_gcid:(NSInteger)gc_id;
- (NSInteger)Logs_add:(dbLog *)log;
- (void)Logs_update:(NSInteger)_id log:(dbLog *)log;
- (void)Logs_update_cache_id:(dbLog *)log cache_id:(NSInteger)wp_id;
- (NSInteger)Logs_count_byCache_id:(NSInteger)wp_id;
- (NSArray *)Logs_all_bycacheid:(NSInteger)wp_id;

@end

#endif
