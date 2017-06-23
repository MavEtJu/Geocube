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

TABLENAME(@"countries")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into countries(name, code) values(?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
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

+ (NSArray<dbCountry *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbCountry *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, code from countries "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

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

+ (NSArray<dbCountry *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbCountry *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

/* Other methods */

+ (void)makeNameExist:(NSString *)name
{
    if ([dbc Country_get_byNameCode:name] == nil) {
        dbCountry *c = [[dbCountry alloc] init];
        c.name = name;
        c.code = name;
        [c dbCreate];
        [dbc Country_add:c];
    }
}

@end
