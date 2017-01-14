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

@interface dbQueryImport ()

@end

@implementation dbQueryImport

- (void)finish
{
    [super finish];
    if (self.account == nil)
        self.account = [dbAccount dbGet:self.account_id];
}

+ (NSId)dbCreate:(dbQueryImport *)qi
{
    NSId _id = 0;

    @synchronized(db) {
        DB_PREPARE(@"insert into query_imports(account_id, name, filesize, last_import_epoch) values(?, ?, ?, ?)");

        SET_VAR_INT (1, qi.account_id);
        SET_VAR_TEXT(2, qi.name);
        SET_VAR_INT (3, qi.filesize);
        SET_VAR_INT (4, qi.lastimport);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    qi._id = _id;
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update query_imports set account_id = ?, name = ?, filesize = ?, last_import_epoch = ? where id = ?");

        SET_VAR_INT (1, self.account_id);
        SET_VAR_TEXT(2, self.name);
        SET_VAR_INT (3, self.filesize);
        SET_VAR_INT (4, self.lastimport);
        SET_VAR_INT (5, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray *)dbAll
{
    NSMutableArray *qis = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, account_id, name, filesize, last_import_epoch from query_imports");

        DB_WHILE_STEP {
            dbQueryImport *qi = [[dbQueryImport alloc] init];
            INT_FETCH (0, qi._id);
            INT_FETCH (1, qi.account_id);
            TEXT_FETCH(2, qi.name);
            INT_FETCH (3, qi.filesize);
            INT_FETCH (4, qi.lastimport);
            [qi finish];
            [qis addObject:qi];
        }
        DB_FINISH;
    }
    return qis;
}

+ (NSInteger)dbCount
{
    return [dbImage dbCount:@"query_imports"];
}

@end
