/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface dbAccount ()

@property (nonatomic, readwrite) BOOL canDoRemoteStuff;

@end

@implementation dbAccount

- (void)finish
{
    [super finish];

    if (self.protocol_string != nil) {
        self.protocol = [dbProtocol dbGetByName:self.protocol_string];
        self.protocol_id = self.protocol._id;
    } else {
        self.protocol = [dbProtocol dbGet:self.protocol_id];
        self.protocol_string = self.protocol.name;
    }

    self.remoteAPI = nil;
    switch ((ProtocolId)self.protocol._id) {
        case PROTOCOL_GCA:
            self.remoteAPI = [[RemoteAPIGCA alloc] init:self];
            break;
        case PROTOCOL_GCA2:
            self.remoteAPI = [[RemoteAPIGCA2 alloc] init:self];
            break;
        case PROTOCOL_GGCW:
            self.remoteAPI = [[RemoteAPIGGCW alloc] init:self];
            break;
        case PROTOCOL_LIVEAPI:
            self.remoteAPI = [[RemoteAPILiveAPI alloc] init:self];
            break;
        case PROTOCOL_OKAPI:
            self.remoteAPI = [[RemoteAPIOKAPI alloc] init:self];
            break;
        case PROTOCOL_NONE:
            self.remoteAPI = nil;
            break;
    }
    self.canDoRemoteStuff = NO;

    /* Even if it is nil.... */
    dbName *n = [dbName dbGetByName:self.accountname_string account:self];
    self.accountname = n;
    self.accountname_id = n._id;

    [self checkRemoteAccess];
}

- (void)checkRemoteAccess
{
    if (self.enabled == NO) {
        [self disableRemoteAccess:@"This account is not enabled"];
        return;
    }

    ProtocolId pid = self.protocol._id;
    switch (pid) {
        case PROTOCOL_OKAPI:
        case PROTOCOL_LIVEAPI:
            if (self.oauth_token == nil || [self.oauth_token isEqualToString:@""] == YES ||
                self.oauth_token_secret == nil || [self.oauth_token_secret isEqualToString:@""] == YES)
                [self disableRemoteAccess:@"This account is currenlty not authenticated"];
            else
                [self enableRemoteAccess];
            break;

        case PROTOCOL_GGCW:
        case PROTOCOL_GCA:
        case PROTOCOL_GCA2:
            if (self.gca_cookie_value == nil || [self.gca_cookie_value isEqualToString:@""] == YES)
                [self disableRemoteAccess:@"This account is currently not authenticated"];
            else
                [self enableRemoteAccess];
            break;

        case PROTOCOL_NONE:
            [self disableRemoteAccess:@"Unkown Protocol"];
            break;
    }
}

- (void)disableRemoteAccess:(NSString *)reason
{
    self.canDoRemoteStuff = NO;
    self.remoteAccessFailureReason = reason;
}

- (void)enableRemoteAccess
{
    self.canDoRemoteStuff = YES;
    self.remoteAccessFailureReason = nil;
}

- (void)dbClearAuthentication
{
    self.oauth_token = nil;
    self.oauth_token_secret = nil;
    self.gca_cookie_value = nil;
    [self dbUpdateCookieValue];
    [self dbUpdateOAuthToken];
}

+ (dbAccount *)dbGet:(NSId)_id
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url_site, url_queries, accountname, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, name_id, enabled, distance_minimum, authentication_name, authentication_password from accounts where id = ?");
        SET_VAR_INT(1, _id);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH ( 0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url_site);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.accountname_string);
            INT_FETCH ( 5, a.protocol_id);
            TEXT_FETCH( 6, a.oauth_consumer_public);
            TEXT_FETCH( 7, a.oauth_consumer_private);
            TEXT_FETCH( 8, a.oauth_token);
            TEXT_FETCH( 9, a.oauth_token_secret);
            TEXT_FETCH(10, a.oauth_request_url);
            TEXT_FETCH(11, a.oauth_authorize_url);
            TEXT_FETCH(12, a.oauth_access_url);
            TEXT_FETCH(13, a.gca_cookie_name);
            TEXT_FETCH(14, a.gca_authenticate_url);
            TEXT_FETCH(15, a.gca_callback_url);
            INT_FETCH (16, a.geocube_id);
            INT_FETCH (17, a.revision);
            TEXT_FETCH(18, a.gca_cookie_value);
            INT_FETCH (19, a.accountname_id);
            BOOL_FETCH(20, a.enabled);
            INT_FETCH (21, a.distance_minimum);
            TEXT_FETCH(22, a.authentictation_name);
            TEXT_FETCH(23, a.authentictation_password);
            [a finish];
        }
        DB_FINISH;
    }
    return a;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url_site, url_queries, accountname, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, name_id, enabled, distance_minimum, authentication_name, authentication_password from accounts");

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH ( 0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url_site);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.accountname_string);
            INT_FETCH ( 5, a.protocol_id);
            TEXT_FETCH( 6, a.oauth_consumer_public);
            TEXT_FETCH( 7, a.oauth_consumer_private);
            TEXT_FETCH( 8, a.oauth_token);
            TEXT_FETCH( 9, a.oauth_token_secret);
            TEXT_FETCH(10, a.oauth_request_url);
            TEXT_FETCH(11, a.oauth_authorize_url);
            TEXT_FETCH(12, a.oauth_access_url);
            TEXT_FETCH(13, a.gca_cookie_name);
            TEXT_FETCH(14, a.gca_authenticate_url);
            TEXT_FETCH(15, a.gca_callback_url);
            INT_FETCH (16, a.geocube_id);
            INT_FETCH (17, a.revision);
            TEXT_FETCH(18, a.gca_cookie_value);
            INT_FETCH (19, a.accountname_id);
            BOOL_FETCH(20, a.enabled);
            INT_FETCH (21, a.distance_minimum);
            TEXT_FETCH(22, a.authentictation_name);
            TEXT_FETCH(23, a.authentictation_password);
            [a finish];
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

- (NSId)dbCreate
{
    NSId __id;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"insert into accounts(site, url_site, url_queries, accountname, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, name_id, enabled, distance_minimum, authentication_name, authentication_password) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, self.site);
        SET_VAR_TEXT( 2, self.url_site);
        SET_VAR_TEXT( 3, self.url_queries);
        SET_VAR_TEXT( 4, self.accountname_string);
        SET_VAR_INT ( 5, self.protocol_id);
        SET_VAR_TEXT( 6, self.oauth_consumer_public);
        SET_VAR_TEXT( 7, self.oauth_consumer_private);
        SET_VAR_TEXT( 8, self.oauth_token);
        SET_VAR_TEXT( 9, self.oauth_token_secret);
        SET_VAR_TEXT(10, self.oauth_request_url);
        SET_VAR_TEXT(11, self.oauth_authorize_url);
        SET_VAR_TEXT(12, self.oauth_access_url);
        SET_VAR_TEXT(13, self.gca_cookie_name);
        SET_VAR_TEXT(14, self.gca_authenticate_url);
        SET_VAR_TEXT(15, self.gca_callback_url);
        SET_VAR_INT (16, self.geocube_id);
        SET_VAR_INT (17, self.revision);
        SET_VAR_TEXT(18, self.gca_cookie_value);
        SET_VAR_INT (19, self.accountname_id);
        SET_VAR_BOOL(20, self.enabled);
        SET_VAR_INT (21, self.distance_minimum);
        SET_VAR_TEXT(22, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT(22, self.authentictation_name);
        SET_VAR_TEXT(23, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT(23, self.authentictation_password);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(__id);

        DB_FINISH;
    }
    return __id;
}

- (void)dbUpdate
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set site = ?, url_site = ?, url_queries = ?, accountname = ?, protocol_id = ?, oauth_consumer_public = ?, oauth_consumer_private = ?, oauth_token = ?, oauth_token_secret = ?, oauth_request_url = ?, oauth_authorize_url = ?, oauth_access_url = ?, gca_cookie_name = ?, gca_authenticate_url = ?, gca_callback_url = ?, geocube_id = ?, revision = ?, gca_cookie_value = ?, name_id = ?, enabled = ?, distance_minimum = ?, authentication_name = ?, authentication_password = ? where id = ?");

        SET_VAR_TEXT( 1, self.site);
        SET_VAR_TEXT( 2, self.url_site);
        SET_VAR_TEXT( 3, self.url_queries);
        SET_VAR_TEXT( 4, self.accountname_string);
        SET_VAR_INT ( 5, self.protocol_id);
        SET_VAR_TEXT( 6, self.oauth_consumer_public);
        SET_VAR_TEXT( 7, self.oauth_consumer_private);
        SET_VAR_TEXT( 8, self.oauth_token);
        SET_VAR_TEXT( 9, self.oauth_token_secret);
        SET_VAR_TEXT(10, self.oauth_request_url);
        SET_VAR_TEXT(11, self.oauth_authorize_url);
        SET_VAR_TEXT(12, self.oauth_access_url);
        SET_VAR_TEXT(13, self.gca_cookie_name);
        SET_VAR_TEXT(14, self.gca_authenticate_url);
        SET_VAR_TEXT(15, self.gca_callback_url);
        SET_VAR_INT (16, self.geocube_id);
        SET_VAR_INT (17, self.revision);
        SET_VAR_TEXT(18, self.gca_cookie_value);
        SET_VAR_INT (19, self.accountname_id);
        SET_VAR_BOOL(20, self.enabled);
        SET_VAR_INT (21, self.distance_minimum);
        SET_VAR_TEXT(22, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT(22, self.authentictation_name);
        SET_VAR_TEXT(23, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT(23, self.authentictation_password);
        SET_VAR_INT (24, self._id);

        DB_CHECK_OKAY;

        DB_FINISH;
    }
}


- (void)dbUpdateAccount
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set accountname = ?, name_id = ?, authentication_name = ?, authentication_password = ? where id = ?");

        SET_VAR_TEXT( 1, self.accountname_string);
        SET_VAR_INT ( 2, self.accountname_id);
        SET_VAR_TEXT( 3, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT( 3, self.authentictation_name);
        SET_VAR_TEXT( 4, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT( 4, self.authentictation_password);
        SET_VAR_INT ( 5, self._id);

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
        SET_VAR_INT (6, self._id);

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
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [self checkRemoteAccess];
}

- (void)dbUpdateCookieValue
{
    @synchronized(db.dbaccess) {
        DB_PREPARE(@"update accounts set gca_cookie_value = ? where id = ?");

        SET_VAR_TEXT(1, self.gca_cookie_value);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [self checkRemoteAccess];
}

+ (dbAccount *)dbGetBySite:(NSString *)site
{
    dbAccount *a = nil;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url_site, url_queries, accountname, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, name_id, enabled, distance_minimum, authentication_name, authentication_password from accounts where site = ?");
        SET_VAR_TEXT(1, site);

        DB_IF_STEP {
            a = [[dbAccount alloc] init];
            INT_FETCH ( 0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url_site);
            TEXT_FETCH( 3, a.url_queries);
            TEXT_FETCH( 4, a.accountname_string);
            INT_FETCH ( 5, a.protocol_id);
            TEXT_FETCH( 6, a.oauth_consumer_public);
            TEXT_FETCH( 7, a.oauth_consumer_private);
            TEXT_FETCH( 8, a.oauth_token);
            TEXT_FETCH( 9, a.oauth_token_secret);
            TEXT_FETCH(10, a.oauth_request_url);
            TEXT_FETCH(11, a.oauth_authorize_url);
            TEXT_FETCH(12, a.oauth_access_url);
            TEXT_FETCH(13, a.gca_cookie_name);
            TEXT_FETCH(14, a.gca_authenticate_url);
            TEXT_FETCH(15, a.gca_callback_url);
            INT_FETCH (16, a.geocube_id);
            INT_FETCH (17, a.revision);
            TEXT_FETCH(18, a.gca_cookie_value);
            INT_FETCH (19, a.accountname_id);
            BOOL_FETCH(20, a.enabled);
            INT_FETCH (21, a.distance_minimum);
            TEXT_FETCH(22, a.authentictation_name);
            TEXT_FETCH(23, a.authentictation_password);
            [a finish];
        }
        DB_FINISH;
    }
    return a;
}

@end
