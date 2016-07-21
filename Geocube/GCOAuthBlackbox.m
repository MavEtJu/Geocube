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

@interface GCOAuthBlackbox ()
{
    NSString *nonce;
    NSString *timestamp;
    NSString *consumerKey;
    NSString *consumerSecret;
    NSString *signatureMethod;
    NSString *version;
    NSString *callback;
    NSString *signature;
    NSString *tokenSecret;
    NSString *verifier;

    NSString *URLRequestToken;
    NSString *URLAuthorize;
    NSString *URLAccessToken;

    NSString *body;

    NSURL *RequestTokenURL;
    NSURL *AuthorizeURL;
    NSURL *AccessTokenURL;

    NSString *server;
}

@end

@implementation GCOAuthBlackbox

@synthesize token, delegate, callback;

- (instancetype)init
{
    self = [super init];

    nonce = nil;
    consumerKey = nil;
    consumerSecret = nil;
    timestamp = nonce;
    signatureMethod = @"HMAC-SHA1";
    version = @"1.0";
    callback = @"http://geocube/authentication";
    signature = nil;
    body = nil;
    token = nil;
    tokenSecret = nil;
    verifier = nil;

    URLRequestToken = nil;
    URLAuthorize = nil;
    URLAccessToken = nil;

    delegate = nil;
    server = nil;

    return self;
}

- (void)server:(NSString *)s
{
    server = s;
}

- (void)URLRequestToken:(NSString *)s
{
    URLRequestToken = s;
    RequestTokenURL = [NSURL URLWithString:s];
}

- (void)URLAuthorize:(NSString *)s
{
    URLAuthorize = s;
    AuthorizeURL = [NSURL URLWithString:s];
}

- (void)URLAccessToken:(NSString *)s
{
    URLAccessToken = s;
    AccessTokenURL = [NSURL URLWithString:s];
}

- (void)consumerKey:(NSString *)s
{
    consumerKey = s;
}

- (void)consumerSecret:(NSString *)s
{
    consumerSecret = s;
}

- (void)URLCallback:(NSString *)s
{
    callback = s;
}

- (void)token:(NSString *)s
{
    token = s;
}

- (void)tokenSecret:(NSString *)s
{
    tokenSecret = s;
}

- (void)nonce:(NSString *)s
{
    nonce = s;
}

- (void)timestamp:(NSString *)s
{
    timestamp = s;
}

- (void)verifier:(NSString *)s
{
    verifier = s;
}

- (void)body:(NSString *)s
{
    body = s;
}

- (NSString *)oauth_header:(GCMutableURLRequest *)urlRequest
{
    NSMutableString *oauth = [NSMutableString stringWithFormat:@"OAuth "];

    struct timeval tp;
    gettimeofday(&tp, NULL);
    nonce = [[NSString stringWithFormat:@"%ld%06d", tp.tv_sec, tp.tv_usec] substringToIndex:13];
    timestamp = [NSString stringWithFormat:@"%ld", (long)time(NULL)];

    timestamp = [NSString stringWithFormat:@"%ld", (long)time(NULL)];

    [oauth appendFormat:@"oauth_consumer_key=\"%@\"", [ MyTools urlEncode:consumerKey]];
    [oauth appendFormat:@", oauth_nonce=\"%@\"", [MyTools urlEncode:nonce]];
    [oauth appendFormat:@", oauth_timestamp=\"%@\"", timestamp];
    [oauth appendFormat:@", oauth_signature_method=\"%@\"", signatureMethod];
    [oauth appendFormat:@", oauth_version=\"%@\"", [MyTools urlEncode:version]];
    if (callback != nil)
        [oauth appendFormat:@", oauth_callback=\"%@\"", [MyTools urlEncode:callback]];
    if (token != nil)
        [oauth appendFormat:@", oauth_token=\"%@\"", [MyTools urlEncode:token]];
    if (verifier != nil)
        [oauth appendFormat:@", oauth_verifier=\"%@\"", [MyTools urlEncode:verifier]];

    [self calculateSignature:urlRequest];
    [oauth appendFormat:@", oauth_signature=\"%@\"", [MyTools urlEncode:signature]];

    return oauth;
}

- (void)obtainAccessToken
{
    NSLog(@"obtainAccessToken");

    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:AccessTokenURL];

    callback = nil;
    NSString *oauth = [self oauth_header:urlRequest];
    [urlRequest addValue:oauth forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"none" forHTTPHeaderField:@"Accept-Encoding"];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"retbody: %@", retbody);

    if (error != nil || response.statusCode != 200) {
        NSLog(@"%@ - token is nil after obtainAccessToken, not further authenticating", [self class]);
        if (delegate != nil)
            [delegate oauthtripped:@"Unable to obtain access token."  error:error];
        tokenSecret = nil;
        token = nil;
        return;
    }

    // Expected:
    // oauth_token=q3rHbDurHspVhzuV36Wp&
    // oauth_token_secret=8gpVwNwNwgGK9WjasCsZUEL456QX2CbZKqM638Jq

    [[retbody componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *keyvalue, NSUInteger idx, BOOL *stop) {
        NSArray *ss = [keyvalue componentsSeparatedByString:@"="];
        NSString *key = [ss objectAtIndex:0];
        NSString *value = [ss objectAtIndex:1];

        if ([key isEqualToString:@"oauth_token"] == YES)
            token = [MyTools urlDecode:value];
        if ([key isEqualToString:@"oauth_token_secret"] == YES)
            tokenSecret = [MyTools urlDecode:value];
    }];
    if (delegate != nil)
        [delegate oauthdanced:token secret:tokenSecret];
}

- (void)obtainRequestToken
{
    NSLog(@"obtainRequestToken");

    GCMutableURLRequest *urlRequest = [GCMutableURLRequest requestWithURL:RequestTokenURL];

    NSString *oauth = [self oauth_header:urlRequest];
    [urlRequest addValue:oauth forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"none" forHTTPHeaderField:@"Accept-Encoding"];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error];
    NSString *retbody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"error: %@", [error description]);
    NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    if (error != nil || response.statusCode != 200) {
        NSLog(@"%@ - Unable to obtain request token, aborting", [self class]);
        token = nil;
        tokenSecret = nil;
        if (delegate != nil)
            [delegate oauthtripped:@"Unable to obtain request token, aborting" error:error];
        return;
    }

    // Expected:
    // oauth_token=b3vbGSxCEB2xNRjHfmj6&
    // oauth_token_secret=w7EXnvDKw5fyXBzvjVXNpPb2wkACxJyTF3GTpbuJ&
    // oauth_callback_confirmed=true

    [[retbody componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *keyvalue, NSUInteger idx, BOOL *stop) {
        NSArray *ss = [keyvalue componentsSeparatedByString:@"="];
        NSString *key = [ss objectAtIndex:0];
        NSString *value = [ss objectAtIndex:1];

        if ([key isEqualToString:@"oauth_token"] == YES)
            token = [MyTools urlDecode:value];
        if ([key isEqualToString:@"oauth_token_secret"] == YES)
            tokenSecret = [MyTools urlDecode:value];
    }];

    NSLog(@"token: %@", token);
    NSLog(@"token_secret: %@", tokenSecret);
}

- (void)webview:(BrowserBrowserViewController *)bbvc url:(NSString *)url
{
    [bbvc loadURL:url];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView:shouldStartLoadWithRequest: %@", request);

    NSString *url = [request.URL absoluteString];
    NSString *query = [request.URL query];
    url = [url substringToIndex:(url.length - [query length] - 1)];

    if ([[url substringToIndex:[callback length]] isEqualToString:callback] == YES) {
        // In body: oauth_token=MyEhWdraaVDuUyvqRwxr&oauth_verifier=56536006
        [[query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *keyvalue, NSUInteger idx, BOOL *stop) {
            NSArray *ss = [keyvalue componentsSeparatedByString:@"="];
            NSString *key = [ss objectAtIndex:0];
            NSString *value = [ss objectAtIndex:1];

            if ([key isEqualToString:@"oauth_token"] == YES)
                token = [MyTools urlDecode:value];
            if ([key isEqualToString:@"oauth_verifier"] == YES)
                verifier = [MyTools urlDecode:value];
        }];

        NSLog(@"token: %@", token);
        NSLog(@"verifier: %@", verifier);

        [self obtainAccessToken];
        return NO;
    }

    return YES;
}

- (void)calculateSignature:(GCMutableURLRequest *)url
{
    // Step described at https://dev.twitter.com/oauth/overview/creating-signatures
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableString *params = [NSMutableString stringWithString:@""];

    // Collecting the request method and URL
    NSString *method = @"GET";
    NSString *BaseURL = [url.URL absoluteString];

    if ([url.URL query] != nil)
        BaseURL = [BaseURL substringToIndex:[BaseURL length] - 1 - [[url.URL query] length]];
    NSLog(@"BaseURL: %@", BaseURL);

    // Collecting parameters


    // - From the URL query string
    {
        NSString *query = [url.URL query];
        NSLog(@"query: %@", query);

        NSArray *queries = [query componentsSeparatedByString:@"&"];
        [queries enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL *stop) {
            NSArray *ss = [s componentsSeparatedByString:@"="];
            [paramDict setValue:[MyTools urlDecode:[ss objectAtIndex:1]] forKey:[ss objectAtIndex:0]];
        }];
    }

    // - From the HTTP body
    {
        NSArray *queries = [body componentsSeparatedByString:@"&"];
        [queries enumerateObjectsUsingBlock:^(NSString *s, NSUInteger idx, BOOL *stop) {
            NSArray *ss = [s componentsSeparatedByString:@"="];
            [paramDict setValue:[MyTools urlDecode:[ss objectAtIndex:1]] forKey:[ss objectAtIndex:0]];
        }];
    }

    // - From the OAuth data
    [paramDict setValue:consumerKey forKey:@"oauth_consumer_key"];
    [paramDict setValue:nonce forKey:@"oauth_nonce"];
    [paramDict setValue:signatureMethod forKey:@"oauth_signature_method"];
    [paramDict setValue:timestamp forKey:@"oauth_timestamp"];
    [paramDict setValue:version forKey:@"oauth_version"];

    if (callback != nil)
        [paramDict setValue:callback forKey:@"oauth_callback"];
    if (verifier != nil)
        [paramDict setValue:verifier forKey:@"oauth_verifier"];
    if (token != nil)
        [paramDict setValue:token forKey:@"oauth_token"];

    NSArray *order = [[paramDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [a compare:b];
    }];

    [order enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([params compare:@""] != NSOrderedSame)
            [params appendString:@"&"];
        [params appendFormat:@"%@=%@", [MyTools urlEncode:key], [MyTools urlEncode:[paramDict objectForKey:key]]];
    }];

    /*
    NSString *expected = @"include_entities=true&oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318622958&oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&oauth_version=1.0&status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21";

    for (NSInteger i = 0; i < [expected length]; i++) {
        if ([expected compare:[params substringToIndex:i] options:0 range:NSMakeRange(0, i)] != NSOrderedSame) {
            NSLog(@"%ld", i);
            NSLog(@"Wrong at: %@", [params substringToIndex:i]);
            break;
        }
    }
     */

    NSLog(@"params: %@", params);

    // Creating the signature base string

    NSMutableString *pre = [NSMutableString stringWithString:method];
    [pre appendString:@"&"];
    [pre appendString:[MyTools urlEncode:BaseURL]];
    [pre appendString:@"&"];
    [pre appendString:[MyTools urlEncode:params ]];

    /*
    expected = @"POST&https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521";

    for (NSInteger i = 0; i < [expected length]; i++) {
        if ([expected compare:[pre substringToIndex:i] options:0 range:NSMakeRange(0, i)] != NSOrderedSame) {
            NSLog(@"%ld", i);
            NSLog(@"Wrong at: %@", [pre substringToIndex:i]);
            break;
        }
    }
     */

    NSLog(@"pre: %@", pre);

    // Getting a signing key

    NSMutableString *sk = [NSMutableString stringWithString:@""];
    [sk appendString:[MyTools urlEncode:consumerSecret]];
    [sk appendString:@"&"];
    if (tokenSecret != nil)
        [sk appendString:[MyTools urlEncode:tokenSecret]];

    /*
    expected = @"kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTt5jkRh4J50vUPVVHtR2YPi5kE";
    for (NSInteger i = 0; i < [expected length]; i++) {
        if ([expected compare:[sk substringToIndex:i] options:0 range:NSMakeRange(0, i)] != NSOrderedSame) {
            NSLog(@"%ld", i);
            NSLog(@"Wrong at: %@", [sk substringToIndex:i]);
            break;
        }
    }
     */

    NSLog(@"sk: %@", sk);

    // Calculating the signature
    // From http://stackoverflow.com/questions/756492/objective-c-sample-code-for-hmac-sha1

    NSString *key = sk;
    NSString *data = pre;

    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];

    char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    signature = [HMAC base64EncodedStringWithOptions:0];
    NSLog(@"Signature: %@", signature);
}

@end
