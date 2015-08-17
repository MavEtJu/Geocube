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

@implementation BookmarksBrowserViewController

- (id)init
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"Go home"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;

    webView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:webView];
}

- (void)loadURL:(NSString *)urlString
{
    urlHome = urlString;
    NSURL *url = [NSURL URLWithString:urlHome];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

// https://www.geocaching.com/pocket/downloadpq.ashx?g=9bf11fd9-abcd-49b2-b182-74e494e5a1fe&src=web
// http://geocaching.com.au/my/query/gpx/7250
// http://geocaching.com.au/my/query/zip/7250
// http://www.opencaching.us/search.php?queryid=2361431&output=gpxgc&count=max&zip=1

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)newRequest navigationType:(UIWebViewNavigationType)navigationType
{
    receivedData = nil;
    req = [NSMutableURLRequest requestWithURL:[newRequest URL]];

    // Spoof iOS Safari headers for sites that sniff the User Agent
    urlConnection = [NSURLConnection connectionWithRequest:newRequest delegate:self];

    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *mime = [response MIMEType];

    NSArray *mimeTypes = @[@"application/gpx", @"application/zip", @"text/xml"];

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

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data
{
    if (receivedData == nil)
        return;
    [receivedData appendData:_data];
  //  NSLog(@"Size: %ld", (long)[data length]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (receivedData == nil)
        return;

    NSInteger length = [receivedData length];
    NSLog(@"Received %ld bytes", length);
    [receivedData writeToFile:[NSString stringWithFormat:@"%@/%@", [MyTools FilesDir], suggestedFilename] atomically:NO];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Download complete"
                                   message:[NSString stringWithFormat:@"Downloaded %@", [MyTools niceFileSize:length]]
                                   preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];

        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];

    receivedData = nil;
    urlConnection = nil;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    // Go back home
    if (index == 0) {
        [self loadURL:urlHome];
        return;
    }
}

@end