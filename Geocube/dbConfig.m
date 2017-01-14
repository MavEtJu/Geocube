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

@interface dbConfig ()

@end

@implementation dbConfig

- (instancetype)init:(NSId)_id key:(NSString *)key value:(NSString *)value
{
    self = [super init];
    self._id = _id;
    self.key = key;
    self.value = value;
    [self finish];
    return self;
}

+ (dbConfig *)dbGetByKey:(NSString *)_key
{
    dbConfig *c;

    @synchronized(db) {
        DB_PREPARE(@"select id, key, value from config where key = ?");

        SET_VAR_TEXT(1, _key);

        DB_IF_STEP {
            c = [[dbConfig alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.key);
            TEXT_FETCH(2, c.value);
        }
        DB_FINISH;
    }
    return c;
}


+ (NSArray *)dbAll
{
    NSMutableArray *ss = [NSMutableArray arrayWithCapacity:10];

    @synchronized(db) {
        DB_PREPARE(@"select id, key, value from config");

        DB_WHILE_STEP {
            dbConfig *c = [[dbConfig alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.key);
            TEXT_FETCH(2, c.value);

            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update config set value = ? where key = ?");

        SET_VAR_TEXT(1, self.value);
        SET_VAR_TEXT(2, self.key);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db) {
        DB_PREPARE(@"insert into config(key, value) values(?, ?)");

        SET_VAR_TEXT(1, self.key);
        SET_VAR_TEXT(2, self.value);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id)
        DB_FINISH;
    }

    return __id;
}

+ (void)dbUpdateOrInsert:(NSString *)key value:(NSString *)value
{
    dbConfig *c = [dbConfig dbGetByKey:key];
    if (c != nil) {
        c.value = value;
        [c dbUpdate];
        return;
    }
    c = [[dbConfig alloc] init];
    c.key = key;
    c.value = value;
    [c dbCreate];
}

+ (NSInteger)dbCount
{
    return [dbConfig dbCount:@"config"];
}

@end
