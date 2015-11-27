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

@interface BrowserBrowserViewController ()
{
    UIWebView *webView;

    NSMutableData *receivedData;
    //NSURLConnection *urlConnection;
    NSString *suggestedFilename;
    NSMutableURLRequest *req;
    NSString *urlHome;

    GCOAuthBlackbox *oabb;
    GeocachingAustralia *gca;
    NSInteger networkActivityIndicator;
}

@end

@implementation BrowserBrowserViewController

enum {
    menuGoHome,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuGoHome label:@"Go home"];

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
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     CGRect frame = [[UIScreen mainScreen] applicationFrame];
                                     webView.frame = frame;
                                 }
     ];
}

- (void)loadURL:(NSString *)urlString
{
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

    if (oabb == nil && gca == nil) {
        [self showActivity:YES];
        NSString *urlString = [[newRequest URL] absoluteString];
        if ([urlString containsString:@"geocaching.com/"] == YES &&
            [urlString containsString:@"/pocket/downloadpq.ashx"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }
        if ([urlString containsString:@"geocaching.com.au/my/query/gpx/"] == YES ||
            [urlString containsString:@"geocaching.com.au/my/query/zip/"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }
        if ([urlString containsString:@"opencaching"] == YES &&
            [urlString containsString:@"search.php"] == YES &&
            [urlString containsString:@"output=gpxgc"] == YES) {
            urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
            return NO;
        }
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

    [self showActivity:YES];
    return YES;
}

- (void)prepare_oauth:(GCOAuthBlackbox *)_oabb
{
    oabb = _oabb;
}

- (void)prepare_gca:(GeocachingAustralia *)_gca
{
    gca = _gca;
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
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Loading data for %@", suggestedFilename]];
            }];
            *stop = YES;
        }
    }];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    NSLog(@"Error for WEBVIEW: %@", [error description]);

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Failed to download"
                               message:[error description]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:nil];

    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
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
  //  NSLog(@"Size: %ld", (long)[data length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (receivedData == nil)
        return;

    NSInteger length = [receivedData length];
    NSLog(@"Received %ld bytes", (long)length);
    [receivedData writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], suggestedFilename] atomically:NO];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Download complete"
                                   message:[NSString stringWithFormat:@"Downloaded %@. You can find them in the Files menu.", [MyTools niceFileSize:length]]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];

        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];

    receivedData = nil;
    //urlConnection = nil;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuGoHome:
            [self loadURL:urlHome];
            return;
    }
}

@end
