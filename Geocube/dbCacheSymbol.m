/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
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

#import "Geocube-Prefix.pch"

@implementation dbCacheSymbol

@synthesize symbol;

- (id)init:(NSId)__id symbol:(NSString *)_symbol
{
    self = [super init];
    _id = __id;
    symbol = _symbol;
    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];
    dbCacheSymbol *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, symbol from cache_symbols");

        while (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _symbol);
            s = [[dbCacheSymbol alloc] init:_id symbol:_symbol];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

+ (dbObject *)dbGet:(NSId)_id;
{
    dbCacheSymbol *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, symbol from cache_symbols where id = ?");

        SET_VAR_INT(req, 1, _id);

        if (sqlite3_step(req) == SQLITE_ROW) {
            INT_FETCH_AND_ASSIGN(req, 0, _id);
            TEXT_FETCH_AND_ASSIGN(req, 1, _symbol);
            s = [[dbCacheSymbol alloc] init:_id symbol:_symbol];
            return s;
        }
        DB_FINISH;
    }
    return nil;
}

- (NSId)dbCreate
{
    return [dbCacheSymbol dbCreate:symbol];
}

+ (NSId)dbCreate:(NSString *)symbol
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into cache_symbols(symbol) values(?)");

        SET_VAR_TEXT(req, 1, symbol);

        if (sqlite3_step(req) != SQLITE_DONE)
            DB_ASSERT_STEP;
        DB_GET_LAST_ID(__id);
        DB_FINISH;
    }
    return __id;
}

@end
