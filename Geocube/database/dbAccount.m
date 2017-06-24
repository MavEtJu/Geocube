/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

TABLENAME(@"accounts")

- (void)finish
{
    [super finish];

    if (self.oauth_consumer_private_sharedsecret != nil && [self.oauth_consumer_private_sharedsecret isEqualToString:@""] == NO)
        self.oauth_consumer_private = [keyManager decrypt:self.oauth_consumer_private_sharedsecret data:self.oauth_consumer_private];
    if (self.oauth_consumer_public_sharedsecret != nil && [self.oauth_consumer_public_sharedsecret isEqualToString:@""] == NO)
        self.oauth_consumer_public = [keyManager decrypt:self.oauth_consumer_public_sharedsecret data:self.oauth_consumer_public];

    self.remoteAPI = nil;
    switch ((ProtocolId)self.protocol._id) {
        case PROTOCOL_GCA:
            NSAssert(FALSE, @"Obsolete protocol: PROTOCOL_GCA");
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
//    self.accountname = [dbName dbGetByName:self.accountname.name account:self];

    [self checkRemoteAccess];
}

- (NSId)dbCreate
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"insert into accounts(site, url_site, url_queries, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, accountname_id, enabled, distance_minimum, authentication_name, authentication_password, oauth_consumer_public_sharedsecret, oauth_consumer_private_sharedsecret) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

        SET_VAR_TEXT( 1, self.site);
        SET_VAR_TEXT( 2, self.url_site);
        SET_VAR_TEXT( 3, self.url_queries);
        SET_VAR_INT ( 4, self.protocol._id);
        SET_VAR_TEXT( 5, self.oauth_consumer_public);
        SET_VAR_TEXT( 6, self.oauth_consumer_private);
        SET_VAR_TEXT( 7, self.oauth_token);
        SET_VAR_TEXT( 8, self.oauth_token_secret);
        SET_VAR_TEXT( 9, self.oauth_request_url);
        SET_VAR_TEXT(10, self.oauth_authorize_url);
        SET_VAR_TEXT(11, self.oauth_access_url);
        SET_VAR_TEXT(12, self.gca_cookie_name);
        SET_VAR_TEXT(13, self.gca_authenticate_url);
        SET_VAR_TEXT(14, self.gca_callback_url);
        SET_VAR_INT (15, self.geocube_id);
        SET_VAR_INT (16, self.revision);
        SET_VAR_TEXT(17, self.gca_cookie_value);
        SET_VAR_INT (18, self.accountname._id);
        SET_VAR_BOOL(19, self.enabled);
        SET_VAR_INT (20, self.distance_minimum);
        SET_VAR_TEXT(21, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT(21, self.authentictation_name);
        SET_VAR_TEXT(22, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT(22, self.authentictation_password);
        SET_VAR_TEXT(23, self.oauth_consumer_public_sharedsecret);
        SET_VAR_TEXT(24, self.oauth_consumer_private_sharedsecret);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }
    return self._id;
}

- (void)dbUpdate
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"update accounts set site = ?, url_site = ?, url_queries = ?, protocol_id = ?, oauth_consumer_public = ?, oauth_consumer_private = ?, oauth_token = ?, oauth_token_secret = ?, oauth_request_url = ?, oauth_authorize_url = ?, oauth_access_url = ?, gca_cookie_name = ?, gca_authenticate_url = ?, gca_callback_url = ?, geocube_id = ?, revision = ?, gca_cookie_value = ?, accountname_id = ?, enabled = ?, distance_minimum = ?, authentication_name = ?, authentication_password = ?, oauth_consumer_public_sharedsecret = ?, oauth_consumer_private_sharedsecret = ? where id = ?");

        SET_VAR_TEXT( 1, self.site);
        SET_VAR_TEXT( 2, self.url_site);
        SET_VAR_TEXT( 3, self.url_queries);
        SET_VAR_INT ( 4, self.protocol._id);
        SET_VAR_TEXT( 5, self.oauth_consumer_public);
        SET_VAR_TEXT( 6, self.oauth_consumer_private);
        SET_VAR_TEXT( 7, self.oauth_token);
        SET_VAR_TEXT( 8, self.oauth_token_secret);
        SET_VAR_TEXT( 9, self.oauth_request_url);
        SET_VAR_TEXT(10, self.oauth_authorize_url);
        SET_VAR_TEXT(11, self.oauth_access_url);
        SET_VAR_TEXT(12, self.gca_cookie_name);
        SET_VAR_TEXT(13, self.gca_authenticate_url);
        SET_VAR_TEXT(14, self.gca_callback_url);
        SET_VAR_INT (15, self.geocube_id);
        SET_VAR_INT (16, self.revision);
        SET_VAR_TEXT(17, self.gca_cookie_value);
        SET_VAR_INT (18, self.accountname._id);
        SET_VAR_BOOL(19, self.enabled);
        SET_VAR_INT (20, self.distance_minimum);
        SET_VAR_TEXT(21, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT(21, self.authentictation_name);
        SET_VAR_TEXT(22, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT(22, self.authentictation_password);
        SET_VAR_TEXT(23, self.oauth_consumer_public_sharedsecret);
        SET_VAR_TEXT(24, self.oauth_consumer_private_sharedsecret);
        SET_VAR_INT (25, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateAccount
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"update accounts set accountname_id = ?, authentication_name = ?, authentication_password = ? where id = ?");

        SET_VAR_INT ( 1, self.accountname._id);
        SET_VAR_TEXT( 2, @"");
        if (configManager.accountsSaveAuthenticationName == YES)
            SET_VAR_TEXT( 2, self.authentictation_name);
        SET_VAR_TEXT( 3, @"");
        if (configManager.accountsSaveAuthenticationPassword == YES)
            SET_VAR_TEXT( 3, self.authentictation_password);
        SET_VAR_INT ( 4, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateOAuthConsumer
{
    NSAssert(finished == YES, @"Finish method not called");
    @synchronized(db) {
        DB_PREPARE(@"update accounts set oauth_consumer_public = ?, oauth_consumer_private = ?, oauth_request_url = ?, oauth_authorize_url = ?, oauth_access_url = ?, oauth_consumer_public_sharedsecret = ?, oauth_consumer_private_sharedsecret = ? where id = ?");

        SET_VAR_TEXT(1, self.oauth_consumer_public);
        SET_VAR_TEXT(2, self.oauth_consumer_private);
        SET_VAR_TEXT(3, self.oauth_request_url);
        SET_VAR_TEXT(4, self.oauth_authorize_url);
        SET_VAR_TEXT(5, self.oauth_access_url);
        SET_VAR_TEXT(6, self.oauth_consumer_public_sharedsecret);
        SET_VAR_TEXT(7, self.oauth_consumer_private_sharedsecret);
        SET_VAR_INT (8, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

- (void)dbUpdateOAuthToken
{
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
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
    NSAssert(finished == YES, @"Not finished");
    @synchronized(db) {
        DB_PREPARE(@"update accounts set gca_cookie_value = ? where id = ?");

        SET_VAR_TEXT(1, self.gca_cookie_value);
        SET_VAR_INT( 2, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
    [self checkRemoteAccess];
}

+ (NSArray<dbAccount *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbAccount *> *ss = [[NSMutableArray alloc] initWithCapacity:20];
    NSId i;

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, site, url_site, url_queries, protocol_id, oauth_consumer_public, oauth_consumer_private, oauth_token, oauth_token_secret, oauth_request_url, oauth_authorize_url, oauth_access_url, gca_cookie_name, gca_authenticate_url, gca_callback_url, geocube_id, revision, gca_cookie_value, accountname_id, enabled, distance_minimum, authentication_name, authentication_password, oauth_consumer_public_sharedsecret, oauth_consumer_private_sharedsecret from accounts "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values)

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH ( 0, a._id);
            TEXT_FETCH( 1, a.site);
            TEXT_FETCH( 2, a.url_site);
            TEXT_FETCH( 3, a.url_queries);
            INT_FETCH ( 4, i);
            a.protocol = [dbc Protocol_get:i];
            TEXT_FETCH( 5, a.oauth_consumer_public);
            TEXT_FETCH( 6, a.oauth_consumer_private);
            TEXT_FETCH( 7, a.oauth_token);
            TEXT_FETCH( 8, a.oauth_token_secret);
            TEXT_FETCH( 9, a.oauth_request_url);
            TEXT_FETCH(10, a.oauth_authorize_url);
            TEXT_FETCH(11, a.oauth_access_url);
            TEXT_FETCH(12, a.gca_cookie_name);
            TEXT_FETCH(13, a.gca_authenticate_url);
            TEXT_FETCH(14, a.gca_callback_url);
            INT_FETCH (15, a.geocube_id);
            INT_FETCH (16, a.revision);
            TEXT_FETCH(17, a.gca_cookie_value);
            INT_FETCH (18, i);
            a.accountname = [dbName dbGet:i];    // Do not use the cached version for this
            BOOL_FETCH(19, a.enabled);
            INT_FETCH (20, a.distance_minimum);
            TEXT_FETCH(21, a.authentictation_name);
            TEXT_FETCH(22, a.authentictation_password);
            TEXT_FETCH(23, a.oauth_consumer_public_sharedsecret);
            TEXT_FETCH(24, a.oauth_consumer_private_sharedsecret);
            [a finish];
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbAccount *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbAccount *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbAccount *)dbGetBySite:(NSString *)site
{
    return [[self dbAllXXX:@"where site = ?" keys:@"s" values:@[site]] firstObject];
}

/* Other methods */

- (void)checkRemoteAccess
{
    NSAssert(finished == YES, @"Not finished");
    if (self.enabled == NO) {
        [self disableRemoteAccess:@"This account is not enabled"];
        return;
    }

    ProtocolId pid = (ProtocolId)self.protocol._id;
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
    NSAssert(finished == YES, @"Not finished");
    self.canDoRemoteStuff = NO;
    self.remoteAccessFailureReason = reason;
}

- (void)enableRemoteAccess
{
    NSAssert(finished == YES, @"Not finished");
    self.canDoRemoteStuff = YES;
    self.remoteAccessFailureReason = nil;
}

- (void)dbClearAuthentication
{
    NSAssert(finished == YES, @"Not finished");
    self.oauth_token = nil;
    self.oauth_token_secret = nil;
    self.gca_cookie_value = nil;
    [self dbUpdateCookieValue];
    [self dbUpdateOAuthToken];
}

@end
