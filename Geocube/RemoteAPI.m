//
//  RemoteAPI.m
//  Geocube
//
//  Created by Edwin Groothuis on 26/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation RemoteAPI

@synthesize account, oabb;
@synthesize stats_found, stats_notfound;

- (id)init:(dbAccount *)_account;
{
    self = [super init];

    account = _account;

    oabb = [[GCOAuthBlackbox alloc] init];
    [oabb token:account.oauth_token];
    [oabb tokenSecret:account.oauth_token_secret];
    [oabb consumerKey:account.oauth_consumer_public];
    [oabb consumerSecret:account.oauth_consumer_private];

    gs = nil;
    okapi = nil;
    switch (account.protocol) {
        case ProtocolGroundspeak:
            gs = [[LiveAPI alloc] init:self];
            break;
        case ProtocolOKAPI:
            okapi = [[OKAPI alloc] init:self];
            break;
    }
    return self;
}

- (BOOL)Authenticate
{
    if (account.protocol == ProtocolOKAPI || account.protocol == ProtocolGroundspeak) {
        // Reset it
        oabb = [[GCOAuthBlackbox alloc] init];

        [oabb URLRequestToken:account.oauth_request_url];
        [oabb URLAuthorize:account.oauth_authorize_url];
        [oabb URLAccessToken:account.oauth_access_url];
        [oabb consumerKey:account.oauth_consumer_public];
        [oabb consumerSecret:account.oauth_consumer_private];

        [oabb obtainRequestToken];
        oabb.delegate = self;
        NSString *url = [NSString stringWithFormat:@"%@?oauth_token=%@", account.oauth_authorize_url, [oabb urlencode:oabb.token]];

        BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BOOKMARKS];
        UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BOOKMARKS_BROWSER];
        BookmarksBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];

        [_AppDelegate switchController:RC_BOOKMARKS];

        [btc makeTabViewCurrent:VC_BOOKMARKS_BROWSER];
        [bbvc prepare_oauth:oabb];
        [bbvc loadURL:url];
    }
    
    return NO;
}

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret
{
    account.oauth_token = token;
    account.oauth_token_secret = secret;
    [account dbUpdateOAuthToken];
    account = nil;
    oabb = nil;

    [_AppDelegate switchController:RC_SETTINGS];
}

- (NSDictionary *)UserStatistics
{
    return [self UserStatistics:account.account];
}

- (NSDictionary *)UserStatistics:(NSString *)username
/* Returns:
 * waypoints_found
 * waypoints_dnf
 */
{
    if (account.protocol == ProtocolOKAPI) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        NSDictionary *dict = [okapi services_users_byUsername:username];
        [ret setValue:[dict valueForKey:@"caches_found"] forKey:@"waypoints_found"];
        [ret setValue:[dict valueForKey:@"caches_notfound"] forKey:@"waypoints_notfound"];
        return ret;
    }

    if (account.protocol == ProtocolGroundspeak) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        NSDictionary *dict = [gs GetYourUserProfile];

        NSDictionary *d = [dict objectForKey:@"Profile"];
        d = [d objectForKey:@"User"];
        [ret setValue:[d valueForKey:@"FindCount"] forKey:@"waypoints_found"];

        [ret setValue:@"" forKey:@"waypoints_notfound"];
        return ret;

    }
    return nil;
}

@end
