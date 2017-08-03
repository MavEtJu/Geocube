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

@interface dbSymbol ()

@end

@implementation dbSymbol

TABLENAME(@"symbols")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into symbols(symbol) values(?)");

        SET_VAR_TEXT(1, self.symbol);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

+ (NSArray<dbSymbol *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbSymbol *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, symbol from symbols "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbSymbol *s = [[dbSymbol alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.symbol);
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbSymbol *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbObject *)dbGet:(NSId)_id;
{
    return [[self dbAllXXX:@"Where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

@end
