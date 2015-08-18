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
}

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *url_queries;
@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) NSInteger protocol;
@property (nonatomic, retain) NSString *oauth_consumer_public;
@property (nonatomic, retain) NSString *oauth_consumer_private;

+ (dbAccount *)dbGet:(NSId)_id;
- (id)init:(NSId)__id site:(NSString *)_site url:(NSString *)_url url_queries:(NSString *)_url_queries account:(NSString *)_account password:(NSString *)_password protocol:(NSInteger)_protocol oauth_public:(NSString *)oauth_public oauth_private:(NSString *)oauth_private;
- (void)dbUpdateAccount;
- (void)dbUpdateOAuth;
+ (dbAccount *)dbGetBySite:(NSString *)site;

@end
