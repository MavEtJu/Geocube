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

typedef NS_ENUM(NSInteger, AccountProtocol) {
    PROTOCOL_NONE = 0,
    PROTOCOL_LIVEAPI = 1,
    PROTOCOL_OKAPI = 2,
    PROTOCOL_GCA = 3,
    PROTOCOL_GCA2 = 4
};

@interface dbAccount : dbObject

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url_site;
@property (nonatomic, retain) NSString *url_queries;
@property (nonatomic, retain) NSString *accountname_string;
@property (nonatomic, retain) dbName *accountname;
@property (nonatomic) NSId accountname_id;
@property (nonatomic) AccountProtocol protocol;
@property (nonatomic) NSInteger geocube_id;
@property (nonatomic) NSInteger revision;
@property (nonatomic) BOOL enabled;

@property (nonatomic, retain) NSString *oauth_consumer_public;
@property (nonatomic, retain) NSString *oauth_consumer_private;
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) NSString *oauth_access_url;
@property (nonatomic, retain) NSString *oauth_authorize_url;
@property (nonatomic, retain) NSString *oauth_request_url;

@property (nonatomic, retain) NSString *authentictation_name;
@property (nonatomic, retain) NSString *authentictation_password;

@property (nonatomic, retain) NSString *gca_cookie_name;
@property (nonatomic, retain) NSString *gca_cookie_value;
@property (nonatomic, retain) NSString *gca_callback_url;
@property (nonatomic, retain) NSString *gca_authenticate_url;

@property (nonatomic) NSInteger distance_minimum;

// Non database originated
@property (nonatomic, readonly) BOOL canDoRemoteStuff;
@property (nonatomic, retain) RemoteAPI *remoteAPI;

+ (dbAccount *)dbGet:(NSId)_id;
- (void)dbUpdateAccount;
- (void)dbUpdateOAuthConsumer;
- (void)dbUpdateOAuthToken;
- (void)dbUpdateCookieValue;
+ (dbAccount *)dbGetBySite:(NSString *)site;
- (void)dbClearAuthentication;
- (void)disableRemoteAccess:(NSString *)reason;
- (void)enableRemoteAccess;

@end
