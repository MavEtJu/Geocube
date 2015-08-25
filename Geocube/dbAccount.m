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

@synthesize site, url, account, password, url_queries, oauth_consumer_private, oauth_consumer_public, protocol, oauth_token_secret, oauth_token, oauth_access_url, oauth_authorize_url, oauth_request_url;

+ (dbAccount *)dbGet:(NSId)_id
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url from accounts where id = ?");
        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH(  0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.account);
            TEXT_FETCH( 5, a.password);
            INT_FETCH(  6, a.protocol);
            TEXT_FETCH( 7, a.oauth_consumer_public);
            TEXT_FETCH( 8, a.oauth_consumer_private);
            TEXT_FETCH( 9, a.oauth_token);
            TEXT_FETCH(10, a.oauth_token_secret);
            TEXT_FETCH(11, a.oauth_request_url);
            TEXT_FETCH(12, a.oauth_authorize_url);
            TEXT_FETCH(13, a.oauth_access_url);
        }
        DB_FINISH;
    }
    return a;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url from accounts");

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH(  0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.account);
            TEXT_FETCH( 5, a.password);
            INT_FETCH(  6, a.protocol);
            TEXT_FETCH( 7, a.oauth_consumer_public);
            TEXT_FETCH( 8, a.oauth_consumer_private);
            TEXT_FETCH( 9, a.oauth_token);
            TEXT_FETCH(10, a.oauth_token_secret);
            TEXT_FETCH(11, a.oauth_request_url);
            TEXT_FETCH(12, a.oauth_authorize_url);
            TEXT_FETCH(13, a.oauth_access_url);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSInteger)dbCount
{
    return [dbAccount dbCount:@"accounts"];
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

- (void)dbUpdateOAuthConsumer
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set oauth_consumer_public = ?, oauth_consumer_private = ?, oauth_request_url = ?, oauth_authorize_url = ?, oauth_access_url = ? where id = ?");

        SET_VAR_TEXT(1, self.oauth_consumer_public);
        SET_VAR_TEXT(2, self.oauth_consumer_private);
        SET_VAR_TEXT(3, self.oauth_request_url);
        SET_VAR_TEXT(4, self.oauth_authorize_url);
        SET_VAR_TEXT(5, self.oauth_access_url);
        SET_VAR_INT( 6, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateOAuthToken
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set oauth_token = ?, oauth_token_secret = ? where id = ?");

        SET_VAR_TEXT(1, self.oauth_token);
        SET_VAR_TEXT(2, self.oauth_token_secret);
        SET_VAR_INT( 3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (dbAccount *)dbGetBySite:(NSString *)site
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, url_queries, account, password, protocol, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url from accounts where site = ?");
        SET_VAR_TEXT(1, site);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH(  0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.account);
            TEXT_FETCH( 5, a.password);
            INT_FETCH(  6, a.protocol);
            TEXT_FETCH( 7, a.oauth_consumer_public);
            TEXT_FETCH( 8, a.oauth_consumer_private);
            TEXT_FETCH( 9, a.oauth_token);
            TEXT_FETCH(10, a.oauth_token_secret);
            TEXT_FETCH(11, a.oauth_request_url);
            TEXT_FETCH(12, a.oauth_authorize_url);
            TEXT_FETCH(13, a.oauth_access_url);
        }
        DB_FINISH;
    }
    return a;
}

@end
