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

    NSMutableURLRequest *req;
    NSString *urlHome;

    GCOAuthBlackbox *oabb;
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
    [lmi addItem:menuGoHome label:_(@"browserbrowserviewcontroll-gohome")];
    [lmi addItem:menuEnterURL label:_(@"browserbrowserviewcontroll-enterurl")];
    [lmi addItem:menuOpenInSafari label:_(@"browserbrowserviewcontroll-openinsafari")];

    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;

    webView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:webView];

    networkActivityIndicator = 0;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeInfoView];
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
    req = [NSMutableURLRequest requestWithURL:[newRequest URL]];

    if (oabb == nil && ggcw == nil) {
        [self showActivity:YES];
        NSString *urlString = [[newRequest URL] absoluteString];
        NSLog(@"urlString: -%@-", urlString);

        // Download Pocket Queries from geocaching.com
        if ([urlString containsString:@"geocaching.com/"] == YES &&
            [urlString containsString:@"/pocket/downloadpq.ashx"] == YES) {
            [self performSelectorInBackground:@selector(downloadBG:) withObject:urlString];
            return NO;
        }

        // Download queries from Geocaching Australia
        if ([urlString containsString:@"geocaching.com.au/my/query/gpx/"] == YES ||
            [urlString containsString:@"geocaching.com.au/my/query/zip/"] == YES) {
            [self performSelectorInBackground:@selector(downloadBG:) withObject:urlString];
            return NO;
        }

        // Download caches from OpenCaching websites
        if ([urlString containsString:@"opencaching"] == YES &&
            [urlString containsString:@"search.php"] == YES &&
            [urlString containsString:@"output=gpxgc"] == YES) {
            [self performSelectorInBackground:@selector(downloadBG:) withObject:urlString];
            return NO;
        }

        // Download a single GPX file from geocaching.com
        if ([urlString containsString:@"geocaching.com/geocache"] == YES &&
            [[newRequest HTTPMethod] isEqualToString:@"POST"] == YES) {
            [self performSelectorInBackground:@selector(downloadBG:) withObject:urlString];
            return NO;
        }

        // Download .zip, .xml or .gpx files.
        if ([[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".zip"] == YES ||
            [[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".xml"] == YES ||
            [[urlString substringFromIndex:[urlString length] - 4] isEqualToString:@".gpx"] == YES) {
            [self performSelectorInBackground:@selector(downloadBG:) withObject:urlString];
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
            NSArray<NSString *> *ss = [keyvalue componentsSeparatedByString:@"="];
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

    // Geocaching.com Authentication related stuff
    if (ggcw != nil &&
        [url length] >= [ggcw.callback length] &&
        [[url substringToIndex:[ggcw.callback length]] isEqualToString:ggcw.callback] == YES) {
        NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray<NSHTTPCookie *> *cookies = [cookiemgr cookiesForURL:req.URL];

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

- (void)downloadBG:(NSString *)urlString
{
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;

    [self showInfoView];
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:@"Downloading query"];

    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoViewer:infoView iiDownload:iid];
    [self showActivity:NO];
    [self saveDataToFile:data response:response error:error];

    [infoView removeItem:iid];
    [self hideInfoView];
}

- (void)saveDataToFile:data response:(NSURLResponse *)response error:(NSError *)error
{
    if (data == nil)
        return;

    NSInteger length = [data length];
    NSLog(@"Received %ld bytes", (long)length);
    [data writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], response.suggestedFilename] atomically:NO];

    [MyTools messageBox:self header:@"Download complete" text:[NSString stringWithFormat:@"Downloaded %@ for %@. You can find it in the Files menu.", [MyTools niceFileSize:length], response.suggestedFilename]];
}

- (void)prepare_oauth:(GCOAuthBlackbox *)_oabb
{
    oabb = _oabb;
}

- (void)prepare_ggcw:(ProtocolGGCW *)_ggcw
{
    ggcw = _ggcw;

    NSHTTPCookieStorage *cookiemgr = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = cookiemgr.cookies;

    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        if ([cookie.name isEqualToString:@"gspkauth"] == NO)
            return;

        [cookiemgr deleteCookie:cookie];
        *stop = YES;
    }];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorCancelled)
        return;

    NSLog(@"Error for WEBVIEW: %@", [error description]);

    // Ignore "Frame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"])
        return;

    [MyTools messageBox:self header:@"Failed to download" text:[error description]];
    [self showActivity:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showActivity:-1];
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
    UIAlertController *alert = [UIAlertController
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
    [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
}

@end
