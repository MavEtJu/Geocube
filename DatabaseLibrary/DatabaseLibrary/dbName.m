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

#import "dbName.h"

#import "Geocube-defines.h"
#import "database-cache.h"
#import "dbAccount.h"

@interface dbName ()

@end

@implementation dbName

TABLENAME(@"names")

- (NSId)dbCreate
{
    ASSERT_SELF_FIELD_EXISTS(account);
    @synchronized(db) {
        DB_PREPARE(@"insert into names(name, code, account_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);
        SET_VAR_INT (3, self.account._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    // Keep a copy in the cache
    [dbc nameAdd:self];

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update names set name = ?, code = ?, account_id = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);
        SET_VAR_INT (3, self.account._id);
        SET_VAR_INT (4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbName *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbName *> *ss = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, code, account_id from names "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbName *s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH (3, i);
            s.account = [dbc accountGet:i];
            [s finish];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbName *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbName *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithId:_id]]] firstObject];
}

+ (dbName *)dbGetByNameCode:(NSString *)name code:(NSString *)code account:(dbAccount *)account
{
    return [[self dbAllXXX:@"where name = ? and code = ? and account_id = ?" keys:@"ssi" values:@[name, code, [NSNumber numberWithId:account._id]]] firstObject];
}

+ (dbName *)dbGetByCode:(NSString *)code account:(dbAccount *)account
{
    return [[self dbAllXXX:@"where code = ? and account_id = ?" keys:@"si" values:@[code, [NSNumber numberWithId:account._id]]] firstObject];
}

+ (dbName *)dbGetByName:(NSString *)name account:(dbAccount *)account
{
    return [[self dbAllXXX:@"where name = ? and account_id = ?" keys:@"si" values:@[name, [NSNumber numberWithId:account._id]]] firstObject];
}

/* Other methods */

+ (void)makeNameExist:(NSString *)_name code:(NSString *)_code account:(dbAccount *)account
{
    /*
     * First check if the code exists.
     * - If so, get the dbName and update the name if needed.
     * If the code doesn't exist, check if the name exist.
     * - If so, update the code.
     * - If not, create the name with the code.
     */

    dbName *name;
    if (IS_EMPTY(_code) == NO) {
        name = [dbName dbGetByCode:_code account:account];
        if (name != nil) {
            if ([name.name isEqualToString:_name] == YES)
                return;
            name.name = _name;
            [name dbUpdate];
            return;
        }
    }

    name = [dbName dbGetByName:_name account:account];
    if (name != nil) {
        if (_code != nil && [_code isEqualToString:name.code] == NO) {
            name.code = _code;
            [name dbUpdate];
            return;
        }
        return;
    }

    name = [[dbName alloc] init];
    name.name = _name;
    name.code = _code;
    name.account = account;
    [name dbCreate];
}

@end
