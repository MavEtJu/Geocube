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

@implementation dbAccount

@synthesize site, url, account, password, url_queries;

- (id)init:(NSId)__id site:(NSString *)_site url:(NSString *)_url url_queries:(NSString *)_url_queries account:(NSString *)_account password:(NSString *)_password
{
    self = [super init];

    _id = __id;
    site = _site;
    url = _url;
    url_queries = _url_queries;
    account = _account;
    password = _password;

    [self finish];
    return self;
}

+ (dbAccount *)dbGet:(NSId)_id
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password from accounts where id = ?");
        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.url_queries);
            TEXT_FETCH(4, a.account);
            TEXT_FETCH(5, a.password);
        }
        DB_FINISH;
    }
    return a;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password from accounts");

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.url_queries);
            TEXT_FETCH(4, a.account);
            TEXT_FETCH(5, a.password);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set account = ?, password = ? where id = ?");

        SET_VAR_TEXT(1, self.account);
        SET_VAR_TEXT(2, self.password);
        SET_VAR_INT(3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

@end
