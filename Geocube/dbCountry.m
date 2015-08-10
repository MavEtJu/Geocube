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

@implementation dbCountry

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
        DB_PREPARE(@"select id, name, code from countries");

        DB_WHILE_STEP {
            dbCountry *c = [[dbCountry alloc] init];;
            INT_FETCH( 0, c._id);
            TEXT_FETCH(1, c.name);
            TEXT_FETCH(2, c.code);
            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (dbCountry *)dbGet:(NSId)_id
{
    dbCountry *c;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, name, code from countries where id = ?");

        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            c = [[dbCountry alloc] init];
            INT_FETCH(0, c._id);
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

    @synchronized(db.dbaccess) {
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
    if ([dbc Country_get_byName:name] == nil) {
        NSId _id = [dbCountry dbCreate:name code:name];
        dbCountry *c = [self dbGet:_id];
        [dbc Country_add:c];
    }
}

@end