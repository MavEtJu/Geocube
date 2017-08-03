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

@interface dbLocale ()

@end

@implementation dbLocale

TABLENAME(@"locales")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into locales(name) values(?)");

        SET_VAR_TEXT(1, self.name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update locales set name = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbLocale *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbLocale *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name from locales "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbLocale *l = [[dbLocale alloc] init];
            INT_FETCH (0, l._id);
            TEXT_FETCH(1, l.name);
            [ss addObject:l];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbLocale *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbLocale *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

/* Other methods */

+ (void)makeNameExist:(NSString *)name
{
    if ([dbc Locale_get_byName:name] == nil) {
        dbLocale *l = [[dbLocale alloc] init];
        l.name = name;
        [l dbCreate];
        [dbc Locale_add:l];
    }
}

@end
