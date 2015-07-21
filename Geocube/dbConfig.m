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

#import "Geocube-Prefix.pch"

@implementation dbConfig

@synthesize key, value;

- (id)init:(NSId)__id key:(NSString *)_key value:(NSString *)_value
{
    self = [super init];
    _id = __id;
    key = _key;
    value = _value;
    [self finish];
    return self;
}

+ (dbConfig *)dbGetByKey:(NSString *)_key
{
    NSString *sql = @"select id, key, value from config where key = ?";
    sqlite3_stmt *req;

    dbConfig *c;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;
        SET_VAR_TEXT(req, 1, _key);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, __id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _key);
            TEXT_FETCH_AND_ASSIGN(req, 2, _value);
            c = [[dbConfig alloc] init:__id key:_key value:_value];
        }
        DB_FINISH;
    }
    return c;
}

- (void)config_update
{
    NSString *sql = @"update config set value = ? where key = ?";
    sqlite3_stmt *req;

    @synchronized(db.dbaccess) {
        if (sqlite3_prepare_v2(db.db, [sql cStringUsingEncoding:NSUTF8StringEncoding], -1, &req, NULL) != SQLITE_OK)
            DB_ASSERT_PREPARE;

        SET_VAR_TEXT(req, 1, value);
        SET_VAR_TEXT(req, 2, key);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        DB_FINISH;
    }
}

@end
