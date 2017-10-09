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

@interface dbFileImport ()

@end

@implementation dbFileImport

TABLENAME(@"file_imports")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into file_imports(filename, filesize, last_import_epoch) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.filename);
        SET_VAR_INT (2, self.filesize);
        SET_VAR_INT (3, self.lastimport);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update file_imports set filename = ?, filesize = ?, last_import_epoch = ? where id = ?");

        SET_VAR_TEXT(1, self.filename);
        SET_VAR_INT (2, self.filesize);
        SET_VAR_INT (3, self.lastimport);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbFileImport *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbFileImport *> *is = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, filename, filesize, last_import_epoch from file_imports "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbFileImport *i = [[dbFileImport alloc] init];
            INT_FETCH (0, i._id);
            TEXT_FETCH(1, i.filename);
            INT_FETCH (2, i.filesize);
            INT_FETCH (3, i.lastimport);
            [i finish];
            [is addObject:i];
        }
        DB_FINISH;
    }
    return is;
}

+ (NSArray<dbFileImport *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbFileImport *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

@end
