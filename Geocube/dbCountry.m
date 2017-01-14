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

@interface dbCountry ()

@end

@implementation dbCountry

- (instancetype)init:(NSId)_id name:(NSString *)name code:(NSString *)code
{
    self = [super init];

    self._id = _id;
    self.name = name;
    self.code = code;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db) {
        DB_PREPARE(@"select id, name, code from countries");

        DB_WHILE_STEP {
            dbCountry *c = [[dbCountry alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.name);
            TEXT_FETCH(2, c.code);
            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSInteger)dbCount
{
    return [dbCountry dbCount:@"countries"];
}

+ (dbCountry *)dbGet:(NSId)_id
{
    dbCountry *c;

    @synchronized(db) {
        DB_PREPARE(@"select id, name, code from countries where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            c = [[dbCountry alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.name);
            TEXT_FETCH(2, c.code);
        }
        DB_FINISH;
    }
    return c;
}

+ (NSId)dbCreate:(NSString *)name code:(NSString *)code
{
    NSId _id;

    @synchronized(db) {
        DB_PREPARE(@"insert into countries(name, code) values(?, ?)");

        SET_VAR_TEXT(1, name);
        SET_VAR_TEXT(2, code);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    return _id;
}

+ (void)makeNameExist:(NSString *)name
{
    if ([dbc Country_get_byNameCode:name] == nil) {
        NSId _id = [dbCountry dbCreate:name code:name];
        dbCountry *c = [self dbGet:_id];
        [dbc Country_add:c];
    }
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update countries set name = ?, code = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
