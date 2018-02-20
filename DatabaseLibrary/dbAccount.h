/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface dbAccount : dbObject

typedef NS_ENUM(NSInteger, AccountType) {
    ACCOUNT_GCA2_GCA = 1,
    ACCOUNT_LIVEAPI_GS = 2,
    ACCOUNT_OKAPI_OCNL = 3,
    ACCOUNT_OKAPI_OCNA = 4,
    ACCOUNT_OKAPI_OCDE = 5,
    ACCOUNT_OKAPI_OCCZ = 6,
    ACCOUNT_OKAPI_OCPL = 7,
    ACCOUNT_OKAPI_OCIT = 8,
    ACCOUNT_OKAPI_OCUK = 9,
    ACCOUNT_OKAPI_OCRO = 10,
    ACCOUNT_OKAPI_OCES = 11,
    ACCOUNT_GCSU = 12,
    ACCOUNT_TPUK = 13,
    ACCOUNT_WEB_GCCOM = 14,
    ACCOUNT_PRIVATE = 15,
};

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url_site;
@property (nonatomic, retain) NSString *url_queries;
@property (nonatomic, retain) dbName *accountname;
@property (nonatomic, retain) dbProtocol *protocol;
@property (nonatomic) NSInteger geocube_id;
@property (nonatomic) NSInteger revision;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL hidden;

@property (nonatomic, retain) NSString *oauth_consumer_public;
@property (nonatomic, retain) NSString *oauth_consumer_public_sharedsecret;
@property (nonatomic, retain) NSString *oauth_consumer_private;
@property (nonatomic, retain) NSString *oauth_consumer_private_sharedsecret;
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

@property (nonatomic, retain) NSString *ggcw_token;
@property (nonatomic) NSInteger ggcw_tokenexpires;
@property (nonatomic, retain) NSString *ggcw_tokentype;
@property (nonatomic, retain) NSString *ggcw_username;
@property (nonatomic, retain) NSString *ggcw_sessiontoken;

@property (nonatomic) NSInteger distance_minimum;

// Non database originated
@property (nonatomic, readonly) BOOL canDoRemoteStuff;
@property (nonatomic, retain) RemoteAPITemplate *remoteAPI;
@property (nonatomic, retain) NSString *remoteAccessFailureReason;
@property (nonatomic) BOOL selected;

+ (NSArray<dbAccount *> *)dbAll;
+ (NSArray<dbAccount *> *)dbAllNoHidden;
- (void)dbUpdateAccount;
- (void)dbUpdateOAuthConsumer;
- (void)dbUpdateOAuthToken;
- (void)dbUpdateCookieValue;
+ (dbAccount *)dbGetByGeocubeID:(NSInteger)geocube_id;
- (void)dbClearAuthentication;
- (void)disableRemoteAccess:(NSString *)reason;
- (void)enableRemoteAccess;

@end
