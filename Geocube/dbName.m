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

@interface dbName ()
{
    NSString *name;
    NSString *code;
    NSId account_id;
    dbAccount *account;
}

@end

@implementation dbName

@synthesize name, code, account_id, account;

- (instancetype)init:(NSId)__id name:(NSString *)_name code:(NSString *)_code account:(dbAccount *)_account
{
    self = [super init];

    _id = __id;
    name = _name;
    code = _code;
    account = _account;

    [self finish];
    return self;
}

- (void)finish
{
    if (account == nil)
        account = [dbc Account_get:account_id];
    if (account_id == 0)
        account_id = account._id;
    [super finish];
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code, account_id from names");

        DB_WHILE_STEP {
            dbName *s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH (3, s.account_id);
            [s finish];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

+ (dbName *)dbGet:(NSId)_id
{
    dbName *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code, account_id from names where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH (3, s.account_id);
            [s finish];
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByNameCode:(NSString *)name code:(NSString *)code account:(dbAccount *)account
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code, account_id from names where name = ? and code = ? and account_id = ?");

        SET_VAR_TEXT(1, name);
        SET_VAR_TEXT(2, code);
        SET_VAR_INT (3, account._id);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH( 3, s.account_id);
            [s finish];
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByCode:(NSString *)code account:(dbAccount *)account
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code, account_id from names where code = ? and account_id = ?");

        SET_VAR_TEXT(1, code);
        SET_VAR_INT( 2, account._id);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH (3, s.account_id);
            [s finish];
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByName:(NSString *)name account:(dbAccount *)account
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code, account_id from names where name = ? and account_id = ?");

        SET_VAR_TEXT(1, name);
        SET_VAR_INT( 2, account._id);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH (0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
            INT_FETCH (3, s.account_id);
            [s finish];
        }
        DB_FINISH;
    }
    return s;
}

+ (NSId)dbCreate:(NSString *)name code:(NSString *)code account:(dbAccount *)account
{
    NSId _id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into names(name, code, account_id) values(?, ?, ?)");

        SET_VAR_TEXT(1, name);
        SET_VAR_TEXT(2, code);
        SET_VAR_INT (3, account._id);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
        DB_FINISH;
    }

    // Keep a copy in the cache
    dbName *n = [[dbName alloc] init:_id name:name code:code account:account];
    [dbc Name_add:n];

    return _id;
}

- (NSId)dbCreate
{
    NSId i = [dbName dbCreate:name code:code account:account];
    _id = i;
    return i;
}

- (void)dbUpdateName
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update names set name = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT (2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (void)makeNameExist:(NSString *)_name code:(NSString *)_code account:(dbAccount *)account
{
    dbName *name;
    if (_code != nil && [_code isEqualToString:@""] == NO) {
        name = [dbName dbGetByCode:_code account:account];
        if (name == nil) {
            [dbName dbCreate:_name code:_code account:account];
            return;
        }
        if ([name.name isEqualToString:_name] == YES)
            return;
        name.name = _name;
        [name dbUpdateName];
        return;
    }

    if ([dbName dbGetByName:_name account:account] == nil) {
        [dbName dbCreate:_name code:nil account:account];
    }
}

+ (NSInteger)dbCount
{
    return [dbName dbCount:@"names"];
}

@end
