/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

TABLENAME(@"config")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into config(key, value) values(?, ?)");

        SET_VAR_TEXT(1, self.key);
        SET_VAR_TEXT(2, self.value);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id)
        DB_FINISH;
    }

    return self._id;
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

+ (NSArray<dbConfig *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *>*)values
{
    NSMutableArray<dbConfig *> *ss = [NSMutableArray arrayWithCapacity:10];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, key, value from config "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

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

+ (NSArray<dbConfig *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbConfig *)dbGetByKey:(NSString *)key
{
    return [[self dbAllXXX:@"where key = ?" keys:@"s" values:@[key]] firstObject];
}

/* Other methods */

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

@end
