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

@interface dbBookmark ()

@end

@implementation dbBookmark

TABLENAME(@"bookmarks")

- (NSId)dbCreate
{
    // ASSERT_SELF_FIELD_EXISTS(import);        -- Not filled in until the first import
    @synchronized(db) {
        DB_PREPARE(@"insert into bookmarks(name, url, import_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.url);
        SET_VAR_INT (3, self.import._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update bookmarks set name = ?, url = ?, import_id = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.url);
        SET_VAR_INT (3, self.import._id);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbBookmark *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbBookmark *> *ss = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, url, import_id from bookmarks "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbBookmark *a = [[dbBookmark alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.name);
            TEXT_FETCH(2, a.url);
            INT_FETCH (3, i);
            a.import = [dbFileImport dbGet:i];
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbBookmark *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbBookmark *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

+ (dbBookmark *)dbGetByImport:(NSInteger)import_id
{
    return [[self dbAllXXX:@"where import_id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:import_id]]] firstObject];
}

@end
