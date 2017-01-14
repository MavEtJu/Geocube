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

@protocol GCOAuthBlackboxDelegate

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret;
- (void)oauthtripped:(NSString *)reason error:(NSError *)error;

@end

/*
 * myConsumerKey = @"S2g[...]";
 * myConsumerSecret = @"mvD[...]";
 *
 * requestURL = @"http://www.opencaching.nl/okapi/services/oauth/request_token";
 * accessURL = @"http://www.opencaching.nl/okapi/services/oauth/authorize";
 * authorizeURL = @"http://www.opencaching.nl/okapi/services/oauth/access_token";
 *
 * [oabb server:@"http://www.opencaching.nl"];
 * [oabb URLRequestToken:requestURL];
 * [oabb URLAuthorize:authorizeURL];
 * [oabb URLAccessToken:accessURL];
 * [oabb consumerKey:myConsumerKey];
 * [oabb consumerSecret:myConsumerSecret];
 * [oabb nonce:[NSString stringWithFormat:@"%ld", time(NULL)]];
 * [oabb timestamp:[NSString stringWithFormat:@"%ld", time(NULL)]];
 *
 * [oabb obtainRequestToken];
 */


@interface GCOAuthBlackbox : NSObject <UIWebViewDelegate>

@property (nonatomic, retain, readonly) NSString *token;
@property (nonatomic, retain, readonly) NSString *callback;
@property (nonatomic) id<GCOAuthBlackboxDelegate> delegate;

- (void)URLRequestToken:(NSString *)s;
- (void)URLAuthorize:(NSString *)s;
- (void)URLAccessToken:(NSString *)s;
- (void)consumerKey:(NSString *)s;
- (void)consumerSecret:(NSString *)s;
- (void)nonce:(NSString *)s;
- (void)timestamp:(NSString *)s;
- (void)body:(NSString *)s;
- (void)token:(NSString *)s;
- (void)tokenSecret:(NSString *)s;
- (void)verifier:(NSString *)s;
- (void)server:(NSString *)s;

- (void)obtainRequestToken;
- (void)obtainAccessToken;

- (NSString *)oauth_header:(GCMutableURLRequest *)urlRequest;
- (void)webview:(BrowserBrowserViewController *)bbvc url:(NSString *)url;

@end
