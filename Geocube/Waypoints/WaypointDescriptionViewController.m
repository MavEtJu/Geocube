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

@interface WaypointDescriptionViewController ()
{
    dbWaypoint *waypoint;
    UIWebView *webview;
    GCScrollView *scrollview;
    BOOL useWebview;
}

@end

@implementation WaypointDescriptionViewController

enum {
    menuShowAsText,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)_wp webview:(BOOL)yesno
{
    self = [super init];

    waypoint = _wp;
    useWebview = yesno;

    lmi = [[LocalMenuItems alloc] init:menuMax];
    if (yesno == YES)
        [lmi addItem:menuShowAsText label:_(@"waypointdescriptionviewcontroller-Show as text")];
    else
        [lmi addItem:menuShowAsText label:_(@"waypointdescriptionviewcontroller-Show as HTML")];

    return self;
}

- (void)loadView
{
    hasCloseButton = YES;
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    /* webview */
    if (useWebview == YES) {
        webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [webview loadHTMLString:[self makeHTMLString] baseURL:nil];
        [webview sizeToFit];
        self.view = webview;
        [self prepareCloseButton:webview];
    } else {
        /* scrollview */
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        scrollview = [[GCScrollView alloc] initWithFrame:applicationFrame];

        GCTextblock *l = [[GCTextblock alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 0)];
        l.text = [self makeTextString];
        [l sizeToFit];
        l.userInteractionEnabled = YES;

        CGRect frame = l.frame;
        frame.size.width = applicationFrame.size.width;
        l.frame = frame;

        [scrollview addSubview:l];

        scrollview.contentSize = l.frame.size;
        [scrollview sizeToFit];
        self.view = scrollview;
        [self prepareCloseButton:scrollview];
    }
}

- (NSString *)makeHTMLString
{
    NSMutableString *ret = [NSMutableString stringWithString:waypoint.description];

    if ([waypoint.gs_short_desc isEqualToString:@""] == NO) {
        NSString *s = waypoint.gs_short_desc;
        if (waypoint.gs_short_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    if ([waypoint.gs_long_desc isEqualToString:@""] == NO) {
        NSString *s = waypoint.gs_long_desc;
        if (waypoint.gs_long_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    return ret;
}

- (NSString *)makeTextString
{
    NSMutableString *ret = [NSMutableString stringWithString:waypoint.description];

    if ([waypoint.gs_short_desc isEqualToString:@""] == NO) {
        NSString *s = waypoint.gs_short_desc;
        if (waypoint.gs_short_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"\n-----------------\n%@", s];
    }

    if ([waypoint.gs_long_desc isEqualToString:@""] == NO) {
        NSString *s = waypoint.gs_long_desc;
        if (waypoint.gs_long_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"\n-----------------\n%@", s];
    }

#define REPLACE(_a_, _b_) \
    [ret replaceOccurrencesOfString:_a_ withString:_b_ options:NSCaseInsensitiveSearch|NSRegularExpressionSearch range:NSMakeRange(0, [ret length])];
    REPLACE(@"<br[^>]*>", @"\n");
    REPLACE(@"</?p>", @"\n");
    REPLACE(@"&nbsp;", @" ");
    REPLACE(@"&quot;", @"\"");
    REPLACE(@"&amp;", @"&");
    REPLACE(@"&#39;", @"'");
    REPLACE(@"</?span[^>]*>", @" ");
    REPLACE(@"</?i[^>]*>", @"/");
    REPLACE(@"</?em[^>]*>", @"/");
    REPLACE(@"</?b[^>]*>", @"*");
    REPLACE(@"</?strong[^>]*>", @"*");
    REPLACE(@"</?[Hh][1-5]>", @"==");
    REPLACE(@"<img[^>]*>", @"[PICTURE]");
    REPLACE(@"<a[^>]*>", @"[ANCHOR]");
    REPLACE(@"</a>", @"[/ANCHOR]");
    REPLACE(@"</?p>", @"\n");
    REPLACE(@"</?ul>", @"\n");
    REPLACE(@"</?ol>", @"\n");
    REPLACE(@"</?li>", @"\n* ");
    REPLACE(@"\r", @"\n");
    REPLACE(@"\n+", @"\n");

    return ret;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Import a photo
    switch (index) {
        case menuShowAsText:
            [self showAsText];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)showAsText
{
    [self.navigationController popViewControllerAnimated:YES];
    WaypointViewController *cvc = (WaypointViewController *)self.navigationController.topViewController;
    UIViewController *newController = [[WaypointDescriptionViewController alloc] init:waypoint webview:!useWebview];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [cvc.navigationController pushViewController:newController animated:YES];
}

@end
