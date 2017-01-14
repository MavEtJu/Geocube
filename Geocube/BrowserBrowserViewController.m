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

@interface BrowserBrowserViewController ()
{
    UIWebView *webView;

    NSMutableData *receivedData;
    //NSURLConnection *urlConnection;
    NSString *suggestedFilename;
    NSMutableURLRequest *req;
    NSString *urlHome;

    GCOAuthBlackbox *oabb;
    ProtocolGCA *gca;
    ProtocolGGCW *ggcw;
    NSInteger networkActivityIndicator;
}

@end

@implementation BrowserBrowserViewController

enum {
    menuGoHome,
    menuEnterURL,
    menuOpenInSafari,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuGoHome label:@"Go home"];
    [lmi addItem:menuEnterURL label:@"Enter URL"];
    [lmi addItem:menuOpenInSafari label:@"Open in Safari"];

    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;

    webView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:webView];

    networkActivityIndicator = 0;

    return self;
}

- (void)showBrowser
{
    [_AppDelegate switchController:RC_BROWSER];
    [browserTabController setSelectedIndex:VC_BROWSER_BROWSER animated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                                CGRect frame = [[UIScreen mainScreen] bounds];
                                                webView.frame = frame;
                                                [self calculateRects];
                                                [self viewWilltransitionToSize];
                                            }
                                 completion:nil
     ];
}

- (void)clearScreen
{
    [webView loadHTMLString:@"" baseURL:nil];
}

- (void)loadURL:(NSString *)urlString
{
    // Clear
    [self clearScreen];

    urlHome = urlString;
    NSURL *url = [NSURL URLWithString:urlHome];
    GCURLRequest *request = [GCURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)showActivity:(NSInteger)enable
{
    @synchronized(self) {
        NSLog(@"showActivity - %ld %ld", (long)networkActivityIndicator, (long)enable);
        if (enable == YES)
            networkActivityIndicator++;
        else if (enable == NO) {
            if (networkActivityIndicator > 0)
                networkActivityIndicator--;
        } else if (enable == -1)
            networkActivityIndicator = 0;
        if (networkActivityIndicator > 0)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        else
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)loadURLRequest:(GCURLRequest *)_req
{
    [webView loadRequest:_req];
}

// https://www.geocaching.com/pocket/downloadpq.ashx?g=9bf11fd9-abcd-49b2-b182-74e494e5a1fe&src=web
// http://geocaching.com.au/my/query/gpx/7250
// http://geocaching.com.au/my/query/zip/7250
// http://www.opencaching.us/search.php?queryid=2361431&output=gpxgc&count=max&zip=1

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)newRequest navigationType:(UIWebViewNavigationType)navigationType
{
    receivedData = nil;
    req = [NSMutableURLRequest requestWithURL:[newRequest URL]];
    NSURLConnection *urlConnection;

    if (oabb == nil && gca == nil && ggcw == nil) {
        [self showActivity:YES];
        NSString *urlString = [[newRequest URL] absoluteString];
        NSLog(@"urlString: -%@-", urlString);

        // Download Pocket Queries from geocaching.com
        if ([urlString containsString:@"geocaching.com/"] == YES &&
            [urlString containsString:@"/pocket/downloadpq.ashx"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }

        // Download queries from Geocaching Australia
        if ([urlString containsString:@"geocaching.com.au/my/query/gpx/"] == YES ||
            [urlString containsString:@"geocaching.com.au/my/query/zip/"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }

        // Download caches from OpenCaching websites
        if ([urlString containsString:@"opencaching"] == YES &&
            [urlString containsString:@"search.php"] == YES &&
            [urlString containsString:@"output=gpxgc"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }

        // Download a single GPX file from geocaching.com
        if ([urlString containsString:@"geocaching.com/geocache"] == YES &&
            [[newRequest HTTPMethod] isEqualToString:@"POST"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }

        // Download .zip, .xml or .gpx files.
        if ([[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".zip"] == YES ||
            [[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".xml"] == YES ||
            [[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".gpx"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }

        return YES;
    }

    // OAuth related stuff
    NSLog(@"W: %@", req);

    NSString *url = [req.URL absoluteString];
    NSString *query = [req.URL query];
    if ([query length] != 0)
        url = [url substringToIndex:(url.length - [query length] - 1)];

    // OAuth related stuff
    if (oabb != nil &&
        [url length] >= [oabb.callback length] &&
        [[url substringToIndex:[oabb.callback length]] isEqualToString:oabb.callback] == YES) {
        // In body: oauth_token=MyEhWdraaVDuUyvqRwxr&oauth_verifier=56536006
        [[query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString *keyvalue, NSUInteger idx, BOOL *stop) {
            NSArray *ss = [keyvalue componentsSeparatedByString:@"="];
            NSString *key = [ss objectAtIndex:0];
            NSString *value = [ss objectAtIndex:1];

            if ([key isEqualToString:@"oauth_token"] == YES)
                [oabb token:[MyTools urlDecode:value]];
            if ([key isEqualToString:@"oauth_verifier"] == YES)
                [oabb verifier:[MyTools urlDecode:value]];
        }];

//        NSLog(@"token: %@", oauth_token);
//        NSLog(@"verifier: %@", oauth_verifier);

        [self showActivity:-1];
        [oabb obtainAccessToken];
        return NO;
    }

    // Geocaching Australia Authentication related stuff
    if (gca != nil &&
        [url length] >= [gca.callback length] &&
        [[url substringToIndex:[gca.callback length]] isEqualToString:gca.callback] == YES) {
        NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookiemgr cookiesForURL:req.URL];

        [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
            if ([cookie.name isEqualToString:@"phpbb3mysql_data"] == NO)
                return;

            [gca storeCookie:cookie];
            *stop = YES;
        }];

        [self showActivity:-1];
        return NO;
    }

    // Geocaching.com Authentication related stuff
    if (ggcw != nil &&
        [url length] >= [ggcw.callback length] &&
        [[url substringToIndex:[ggcw.callback length]] isEqualToString:ggcw.callback] == YES) {
        NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookiemgr cookiesForURL:req.URL];

        [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
            if ([cookie.name isEqualToString:@"gspkauth"] == NO)
                return;

            [ggcw storeCookie:cookie];
            *stop = YES;
        }];

        [self showActivity:-1];
        return NO;
    }

    [self showActivity:YES];
    return YES;
}

- (void)prepare_oauth:(GCOAuthBlackbox *)_oabb
{
    oabb = _oabb;
}

- (void)prepare_gca:(ProtocolGCA *)_gca
{
    gca = _gca;

    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
#warning XXX - crashes after importing clean configuration
    NSArray *cookies = [cookiemgr cookiesForURL:req.URL];

    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if ([cookie.name isEqualToString:@"phpbb3mysql_data"] == NO)
            return;

        [cookiemgr deleteCookie:cookie];
        *stop = YES;
    }];
}

- (void)prepare_ggcw:(ProtocolGGCW *)_ggcw
{
    ggcw = _ggcw;

    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = cookiemgr.cookies;

    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if ([cookie.name isEqualToString:@"gspkauth"] == NO)
            return;

        [cookiemgr deleteCookie:cookie];
        *stop = YES;
    }];
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *mime = [response MIMEType];

    NSArray *mimeTypes = @[@"application/gpx", @"application/gpx+xml", @"application/zip", @"text/xml"];
    NSLog(@"Found mime type: %@", mime);

    [self showActivity:NO];

    [mimeTypes enumerateObjectsUsingBlock:^(NSString *mimeType, NSUInteger idx, BOOL *stop) {
        if ([mime isEqualToString:mimeType] == YES) {
            NSLog(@"Found mime type: %@", mime);
            receivedData = [NSMutableData dataWithCapacity:0];
            suggestedFilename = response.suggestedFilename;
            [webView stopLoading];
            [bezelManager showBezel:self];
            [bezelManager setText:[NSString stringWithFormat:@"Loading data for %@", suggestedFilename]];
            *stop = YES;
        }
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorCancelled)
        return;

    NSLog(@"Error for WEBVIEW: %@", [error description]);

    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
        return;

    [MyTools messageBox:self header:@"Failed to download" text:[error description]];
    [self showActivity:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showActivity:-1];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    if (receivedData == nil)
        return;
    [receivedData appendData:_data];
    NSLog(@"Size: %ld - %ld", (long)[receivedData length], (long)[_data length]);
    [bezelManager setText:[NSString stringWithFormat:@"Loading %@ for %@", [MyTools niceFileSize:[receivedData length]], suggestedFilename]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (receivedData == nil)
        return;

    NSInteger length = [receivedData length];
    NSLog(@"Received %ld bytes", (long)length);
    [receivedData writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], suggestedFilename] atomically:NO];

    [bezelManager removeBezel];
    [MyTools messageBox:self header:@"Download complete" text:[NSString stringWithFormat:@"Downloaded %@ for %@. You can find it in the Files menu.", [MyTools niceFileSize:length], suggestedFilename]];

    receivedData = nil;
    //urlConnection = nil;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuGoHome:
            [self loadURL:urlHome];
            return;
        case menuEnterURL:
            [self menuEnterURL];
            return;
        case menuOpenInSafari:
            [self menuOpenInSafari];
            return;
    }
    [super performLocalMenuAction:index];
}

- (void)menuEnterURL
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Enter URL"
                               message:nil
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;

                             [self loadURL:value];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = @"";
        textField.placeholder = @"URL";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuOpenInSafari
{
    NSURL *url = [NSURL URLWithString:urlHome];
    [[UIApplication sharedApplication] openURL:url];
}

@end
