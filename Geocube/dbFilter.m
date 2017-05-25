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

@interface dbFilter ()

@end

@implementation dbFilter

- (instancetype)init:(NSId)_id key:(NSString *)key value:(NSString *)value
{
    self = [super init];
    self._id = _id;
    self.key = _key;
    self.value = _value;
    [self finish];
    return self;
}

+ (dbFilter *)dbGetByKey:(NSString *)_key
{
    dbFilter *c;

    @synchronized(db) {
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
    @synchronized(db) {
        DB_PREPARE(@"update filters set value = ? where key = ?");

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
        DB_PREPARE(@"insert into filters(key, value) values(?, ?)");

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

+ (void)dbAllClear:(NSString *)prefix
{
    if (prefix == nil) {
        @synchronized(db) {
            DB_PREPARE(@"delete from filters where not key like '%||%'");
            DB_CHECK_OKAY;
            DB_FINISH;
        }
    } else {
        @synchronized(db) {
            DB_PREPARE(@"delete from filters where key like '?'");
            NSString *s = [NSString stringWithFormat:@"%@||%%", prefix];
            SET_VAR_TEXT(1, s);
            DB_CHECK_OKAY;
            DB_FINISH;
        }
    }
}

+ (NSInteger)dbCount
{
    return [dbFilter dbCount:@"filters"];
}

+ (NSArray<NSString *> *)findFilterNames
{
    NSMutableArray<NSString *> *fs = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select key from filters");

        DB_WHILE_STEP {
            TEXT_FETCH_AND_ASSIGN(0, s);
            if ([s containsString:@"||"] == NO)
                continue;

            NSArray<NSString *> *ws = [s componentsSeparatedByString:@"||"];
            s = [ws objectAtIndex:0];

            __block BOOL found = NO;
            [fs enumerateObjectsUsingBlock:^(NSString * _Nonnull f, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([f isEqualToString:s] == YES) {
                    found = YES;
                    *stop = YES;
                }
            }];
            if (found == NO)
                [fs addObject:s];
        }
        DB_FINISH;
    }
    return fs;
}

@end
