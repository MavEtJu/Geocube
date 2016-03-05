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

@interface dbFilter ()
{
    NSString *key;
    NSString *value;
}

@end

@implementation dbFilter

@synthesize key, value;

- (instancetype)init:(NSId)__id key:(NSString *)_key value:(NSString *)_value
{
    self = [super init];
    _id = __id;
    key = _key;
    value = _value;
    [self finish];
    return self;
}

+ (dbFilter *)dbGetByKey:(NSString *)_key
{
    dbFilter *c;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, key, value from filters where key = ?");

        SET_VAR_TEXT(1, _key);

        DB_IF_STEP {
            c = [[dbFilter alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.key);
            TEXT_FETCH(2, c.value);
        }
        DB_FINISH;
    }
    return c;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update filters set value = ? where key = ?");

        SET_VAR_TEXT(1, value);
        SET_VAR_TEXT(2, key);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into filters(key, value) values(?, ?)");

        SET_VAR_TEXT(1, key);
        SET_VAR_TEXT(2, value);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id)
        DB_FINISH;
    }

    return __id;
}

+ (void)dbUpdateOrInsert:(NSString *)key value:(NSString *)value
{
    dbFilter *c = [dbFilter dbGetByKey:key];
    if (c != nil) {
        c.value = value;
        [c dbUpdate];
        return;
    }
    c = [[dbFilter alloc] init];
    c.key = key;
    c.value = value;
    [c dbCreate];
}

+ (void)dbAllClear
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"delete from filters");
        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSInteger)dbCount
{
    return [dbFilter dbCount:@"filters"];
}

@end
