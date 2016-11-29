/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

- (instancetype)init:(NSId)_id name:(NSString *)name url:(NSString *)url import_id:(NSInteger)import_id
{
    self = [super init];

    self._id = _id;
    self.name = name;
    self.url = url;
    self.import_id = import_id;

    [self finish];
    return self;
}

+ (dbBookmark *)dbGet:(NSId)_id
{
    dbBookmark *a = nil;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, url, import_id from bookmarks where id = ?");
        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            a = [[dbBookmark alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.name);
            TEXT_FETCH(2, a.url);
            INT_FETCH (3, a.import_id);
        }
        DB_FINISH;
    }
    return a;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name, url, import_id from bookmarks");

        DB_WHILE_STEP {
            dbBookmark *a = [[dbBookmark alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.name);
            TEXT_FETCH(2, a.url);
            INT_FETCH (3, a.import_id);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSInteger)dbCount
{
    return [dbBookmark dbCount:@"bookmarks"];
}

+ (NSId)dbCreate:(dbBookmark *)bm;
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into bookmarks(name, url, import_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, bm.name);
        SET_VAR_TEXT(2, bm.url);
        SET_VAR_INT (3, bm.import_id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }
    return _id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update bookmarks set name = ?, url = ?, import_id = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.url);
        SET_VAR_INT (3, self.import_id);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbDelete
{
    @synchronized(db) {
        DB_PREPARE(@"delete from bookmarks where id = ?");

        SET_VAR_INT(1, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (dbBookmark *)dbGetByImport:(NSInteger)import_id
{
    dbBookmark *a = nil;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, url, import_id from bookmarks where import_id = ?");
        SET_VAR_INT(1, import_id);

        DB_IF_STEP {
            a = [[dbBookmark alloc] init];
            INT_FETCH (0, a._id);
            TEXT_FETCH(1, a.name);
            TEXT_FETCH(2, a.url);
            INT_FETCH (3, a.import_id);
        }
        DB_FINISH;
    }
    return a;
}


@end
