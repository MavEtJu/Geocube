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

+ (NSArray<dbLocale *> *)dbAll
{
    NSMutableArray<dbLocale *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name from locales");

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

+ (void)makeNameExist:(NSString *)name
{
    if ([dbc Locale_get_byName:name] == nil) {
        NSId _id = [dbLocale dbCreate:name];
        dbLocale *c = [self dbGet:_id];
        [dbc Locale_add:c];
    }
}

+ (NSInteger)dbCount
{
    return [dbLocale dbCount:@"locales"];
}

+ (dbLocale *)dbGet:(NSId)_id
{
    dbLocale *l;

    @synchronized(db) {
        DB_PREPARE(@"select id, name from locales where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            l = [[dbLocale alloc] init];
            INT_FETCH (0, l._id);
            TEXT_FETCH(1, l.name);
        }
        DB_FINISH;
    }
    return l;
}

+ (NSId)dbCreate:(NSString *)name
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into locales(name) values(?)");

        SET_VAR_TEXT(1, name);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    return _id;
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

@end
