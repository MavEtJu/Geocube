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

@synthesize site, url, account, password, url_queries, oauth_consumer_private, oauth_consumer_public, protocol;

- (id)init:(NSId)__id site:(NSString *)_site url:(NSString *)_url url_queries:(NSString *)_url_queries account:(NSString *)_account password:(NSString *)_password protocol:(NSInteger)_protocol oauth_public:(NSString *)_oauth_public oauth_private:(NSString *)_oauth_private
{
    self = [super init];

    _id = __id;
    site = _site;
    url = _url;
    url_queries = _url_queries;
    account = _account;
    password = _password;
    protocol = _protocol;
    oauth_consumer_public = _oauth_public;
    oauth_consumer_private = _oauth_private;

    [self finish];
    return self;
}

+ (dbAccount *)dbGet:(NSId)_id
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private from accounts where id = ?");
        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.url_queries);
            TEXT_FETCH(4, a.account);
            TEXT_FETCH(5, a.password);
            INT_FETCH( 6, a.protocol);
            TEXT_FETCH(7, a.oauth_consumer_public);
            TEXT_FETCH(8, a.oauth_consumer_private);
        }
        DB_FINISH;
    }
    return a;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private from accounts");

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.url_queries);
            TEXT_FETCH(4, a.account);
            TEXT_FETCH(5, a.password);
            INT_FETCH( 6, a.protocol);
            TEXT_FETCH(7, a.oauth_consumer_public);
            TEXT_FETCH(8, a.oauth_consumer_private);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

- (void)dbUpdateAccount
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set account = ? where id = ?");

        SET_VAR_TEXT(1, self.account);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateOAuth
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set oauth_consumer_public = ?, oauth_consumer_private = ? where id = ?");

        SET_VAR_TEXT(1, self.oauth_consumer_public);
        SET_VAR_TEXT(2, self.oauth_consumer_private);
        SET_VAR_INT( 3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (dbAccount *)dbGetBySite:(NSString *)site
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private from accounts where site = ?");
        SET_VAR_TEXT(1, site);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.url_queries);
            TEXT_FETCH(4, a.account);
            TEXT_FETCH(5, a.password);
            INT_FETCH( 6, a.protocol);
            TEXT_FETCH(7, a.oauth_consumer_public);
            TEXT_FETCH(8, a.oauth_consumer_private);
        }
        DB_FINISH;
    }
    return a;
}

@end
