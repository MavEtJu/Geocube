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

#ifndef Geocube_database_h
#define Geocube_database_h

#define	DB_EMPTY		@"empty.db"
#define	DB_NAME         @"database.db"
#define KEY_VERSION_DB  @"version"


@interface database : NSObject

@property (nonatomic)sqlite3 *db;

- (instancetype)init;
- (void)checkVersion;
//- (void)checkAndCreateDatabase:(NSString *)dbname empty:(NSString *)dbempty;
- (NSInteger)getDatabaseSize;
- (void)singleStatement:(NSString *)sql;
- (NSString *)saveCopy;
- (BOOL)restoreFromCopy:(NSString *)source;
- (void)cleanupAfterDelete;

@end

#define TEXT_FETCH_AND_ASSIGN(col, string) \
    NSString *string = nil; \
    { \
        char *__s = (char *)sqlite3_column_text(req, col); \
        if (__s == NULL) \
            string = nil; \
        else \
            string = [[NSString alloc] initWithUTF8String:__s]; \
    }
#define BOOL_FETCH_AND_ASSIGN(col, string) \
    BOOL string = sqlite3_column_int(req, col);
#define INT_FETCH_AND_ASSIGN(col, string) \
    NSInteger string = sqlite3_column_int(req, col);
#define DOUBLE_FETCH_AND_ASSIGN(col, string) \
    double string = sqlite3_column_double(req, col);

#define TEXT_FETCH(col, string) \
    { \
        char *__s = (char *)sqlite3_column_text(req, col); \
        if (__s == NULL) \
            string = nil; \
        else \
            string = [[NSString alloc] initWithUTF8String:__s]; \
    }
#define BOOL_FETCH(col, string) \
    string = sqlite3_column_int(req, col);
#define INT_FETCH(col, string) \
    string = sqlite3_column_int(req, col);
#define DOUBLE_FETCH(col, string) \
    string = sqlite3_column_double(req, col);

#define SET_VAR_BOOL(col, string) \
    if (sqlite3_bind_int(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_BOOL: %s", sqlite3_errmsg(db.db));
#define SET_VAR_INT(col, string) \
    if (sqlite3_bind_int64(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_INT: %s", sqlite3_errmsg(db.db));

#define SET_VAR_TEXT(col, string) \
    if (sqlite3_bind_text(req, col, [string cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_TEXT: %s", sqlite3_errmsg(db.db));
#define SET_VAR_DOUBLE(col, string) \
    if (sqlite3_bind_double(req, col, string) != SQLITE_OK) \
        NSAssert1(0, @"SET_VAR_DOUBLE: %s", sqlite3_errmsg(db.db));


#define DB_ASSERT(__s__) \
    NSAssert3(0, @"%s/%@: %s", __FUNCTION__, __s__, sqlite3_errmsg(db.db))
#define DB_ASSERT_STEP      DB_ASSERT(@"step")
#define DB_ASSERT_PREPARE   DB_ASSERT(@"prepare")

#define DB_PREPARE(__s__) \
    sqlite3_stmt *req; \
    if (sqlite3_prepare_v2(db.db, [__s__ cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK) \
        DB_ASSERT_PREPARE;
#define DB_FINISH \
    sqlite3_finalize(req);
#define DB_GET_LAST_ID(__id__) \
    __id__ = sqlite3_last_insert_rowid(db.db);
#define DB_IF_STEP \
    if (sqlite3_step(req) == SQLITE_ROW)
#define DB_WHILE_STEP \
    while (sqlite3_step(req) == SQLITE_ROW)
#define DB_CHECK_OKAY \
    if (sqlite3_step(req) != SQLITE_DONE) \
        DB_ASSERT_STEP

// + (NSArray *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray *)values
#define DB_PREPARE_KEYSVALUES(__sql__, __keys__, __values__) \
    DB_PREPARE(sql); \
    if (__keys__ != nil) { \
        if ([__keys__ length] != [__values__ count]) \
            NSAssert2(NO, @"Keys length is not equal to values count: %ld - %ld", (long)[__keys__ length], (long)[__values__ count]); \
        [__values__ enumerateObjectsUsingBlock:^(NSObject *v, NSUInteger idx, BOOL * _Nonnull stop) { \
            NSNumber *n = (NSNumber *)v; \
            NSString *s = (NSString *)v; \
            int i = (int)idx + 1; \
            switch ([__keys__ characterAtIndex:idx]) { \
                case 'i': \
                    SET_VAR_INT(i, [n longValue]); \
                    break; \
                case 'f': \
                    SET_VAR_DOUBLE(i, [n floatValue]); \
                    break; \
                case 's': \
                    SET_VAR_TEXT(i, s); \
                    break; \
                case 'b': \
                    SET_VAR_BOOL(i, [n boolValue]); \
                    break; \
                default: \
                    NSAssert2(NO, @"Invalid key: %@ at index %ld", __keys__, (unsigned long)idx); \
            } \
        }]; \
    } \

#endif
