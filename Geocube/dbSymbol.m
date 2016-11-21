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

@interface dbSymbol ()

@end

@implementation dbSymbol

- (instancetype)init:(NSId)_id symbol:(NSString *)symbol
{
    self = [super init];
    self._id = _id;
    self.symbol = symbol;
    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, symbol from symbols");

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

+ (NSInteger)dbCount
{
    return [dbSymbol dbCount:@"symbols"];
}

+ (dbObject *)dbGet:(NSId)_id;
{
    dbSymbol *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, symbol from symbols where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            s = [[dbSymbol alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.symbol);
        }
        DB_FINISH;
    }
    return s;
}

- (NSId)dbCreate
{
    return [dbSymbol dbCreate:self.symbol];
}

+ (NSId)dbCreate:(NSString *)symbol
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into symbols(symbol) values(?)");

        SET_VAR_TEXT(1, symbol);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

@end
