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

@implementation dbName

@synthesize name, code;

- (id)init:(NSId)__id name:(NSString *)_name code:(NSString *)_code
{
    self = [super init];

    _id = __id;
    name = _name;
    code = _code;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code from names");

        DB_WHILE_STEP {
            dbName *s = [[dbName alloc] init];
            INT_FETCH( 0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
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
        DB_PREPARE(@"select id, name, code from names where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH(0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByNameCode:(NSString *)name code:(NSString *)code
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code from names where name = ? and code = ?");

        SET_VAR_TEXT(1, name);
        SET_VAR_TEXT(2, code);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH(0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByCode:(NSString *)code
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code from names where code = ?");

        SET_VAR_TEXT(1, code);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH(0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
        }
        DB_FINISH;
    }
    return s;
}

+ (dbName *)dbGetByName:(NSString *)name
{
    dbName *s = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code from names where name = ?");

        SET_VAR_TEXT(1, name);

        DB_IF_STEP {
            s = [[dbName alloc] init];
            INT_FETCH(0, s._id);
            TEXT_FETCH(1, s.name);
            TEXT_FETCH(2, s.code);
        }
        DB_FINISH;
    }
    return s;
}

+ (NSId)dbCreate:(NSString *)name code:(NSString *)code
{
    NSId _id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into names(name, code) values(?, ?)");

        SET_VAR_TEXT(1, name);
        SET_VAR_TEXT(2, code);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(_id);
    }

    return _id;
}

- (void)dbUpdateName
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update names set name = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_INT(2, self._id);

        DB_CHECK_OKAY;
    }
}

+ (void)makeNameExist:(NSString *)_name code:(NSString *)_code
{
    dbName *name;
    if (_code != nil && [_code compare:@""] != NSOrderedSame) {
        name = [dbName dbGetByCode:_code];
        if (name == nil) {
            [dbName dbCreate:_name code:_code];
            return;
        }
        if ([name.name compare:_name] == NSOrderedSame)
            return;
        name.name = _name;
        [name dbUpdateName];
        return;
    }

    if ([dbName dbGetByName:_name] == nil) {
        [dbName dbCreate:_name code:nil];
    }
}

@end
