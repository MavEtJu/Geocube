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
    ProtocolLiveAPI = 1,
    ProtocolOKAPI = 2,
    ProtocolGCA = 3
};

@interface dbAccount : dbObject {
    NSString *site;
    NSString *url_site;
    NSString *url_queries;
    NSString *accountname;
    NSInteger protocol;
    NSInteger geocube_id;
    NSInteger revision;

    NSString *gca_cookie_name;
    NSString *gca_cookie_value;
    NSString *gca_callback_url;
    NSString *gca_autenticate_url;

    NSString *oauth_consumer_public;
    NSString *oauth_consumer_private;
    NSString *oauth_token;
    NSString *oauth_token_secret;
    NSString *oauth_access_url;
    NSString *oauth_authorize_url;
    NSString *oauth_request_url;

    // Not read from the database
    BOOL canDoRemoteStuff;
    RemoteAPI *remoteAPI;
    NSInteger idx;
}

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url_site;
@property (nonatomic, retain) NSString *url_queries;
@property (nonatomic, retain) NSString *accountname;
@property (nonatomic) NSInteger protocol;
@property (nonatomic) NSInteger geocube_id;
@property (nonatomic) NSInteger revision;

@property (nonatomic, retain) NSString *oauth_consumer_public;
@property (nonatomic, retain) NSString *oauth_consumer_private;
@property (nonatomic, retain) NSString *oauth_token;
@property (nonatomic, retain) NSString *oauth_token_secret;
@property (nonatomic, retain) NSString *oauth_access_url;
@property (nonatomic, retain) NSString *oauth_authorize_url;
@property (nonatomic, retain) NSString *oauth_request_url;

@property (nonatomic, retain) NSString *gca_cookie_name;
@property (nonatomic, retain) NSString *gca_cookie_value;
@property (nonatomic, retain) NSString *gca_callback_url;
@property (nonatomic, retain) NSString *gca_authenticate_url;

@property (nonatomic) BOOL canDoRemoteStuff;
@property (nonatomic, retain) RemoteAPI *remoteAPI;
@property (nonatomic) NSInteger idx;

+ (dbAccount *)dbGet:(NSId)_id;
- (void)dbUpdateAccount;
- (void)dbUpdateOAuthConsumer;
- (void)dbUpdateOAuthToken;
- (void)dbUpdateCookieValue;
+ (dbAccount *)dbGetBySite:(NSString *)site;
- (void)dbClearAuthentication;

@end
