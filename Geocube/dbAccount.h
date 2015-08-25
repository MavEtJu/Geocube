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

enum dbAccountProtocol {
    ProtocolNone = 0,
    ProtocolGroundspeak = 1,
    ProtocolOKAPI = 2
};

@interface dbAccount : dbObject {
    NSString *site;
    NSString *url;
    NSString *url_queries;
    NSString *account;
    NSString *password;
    NSInteger protocol;
    NSString *oauth_consumer_public;
    NSString *oauth_consumer_private;
    NSString *oauth_token;
    NSString *oauth_token_secret;
    NSString *oauth_access_url;
    NSString *oauth_authorize_url;
    NSString *oauth_request_url;
}

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *url_queries;
@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) NSInteger protocol;
@property (nonatomic, retain) NSString *oauth_consumer_public;
@property (nonatomic, retain) NSString *oauth_consumer_private;
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) NSString *oauth_access_url;
@property (nonatomic, retain) NSString *oauth_authorize_url;
@property (nonatomic, retain) NSString *oauth_request_url;

+ (dbAccount *)dbGet:(NSId)_id;
- (void)dbUpdateAccount;
- (void)dbUpdateOAuthConsumer;
- (void)dbUpdateOAuthToken;
+ (dbAccount *)dbGetBySite:(NSString *)site;

@end
