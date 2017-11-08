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

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) UIWebView *webview;
@property (nonatomic, retain) GCScrollView *scrollview;
@property (nonatomic, retain) GCTextblock *block;
@property (nonatomic        ) BOOL useWebview;

@end

@implementation WaypointDescriptionViewController

enum {
    menuShowAsText,
    menuScanForWaypoints,
    menuMax,
};

- (instancetype)init:(dbWaypoint *)wp webview:(BOOL)yesno
{
    self = [super init];

    self.waypoint = wp;
    self.useWebview = yesno;

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    if (yesno == YES)
        [self.lmi addItem:menuShowAsText label:_(@"waypointdescriptionviewcontroller-Show as text")];
    else
        [self.lmi addItem:menuShowAsText label:_(@"waypointdescriptionviewcontroller-Show as HTML")];
    [self.lmi addItem:menuScanForWaypoints label:_(@"waypointdescriptionviewcontroller-Scan for waypoints")];

    return self;
}

- (void)loadView
{
    self.hasCloseButton = YES;
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    /* webview */
    if (self.useWebview == YES) {
        self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self.webview loadHTMLString:[self makeHTMLString] baseURL:nil];
        [self.webview sizeToFit];
        self.view = self.webview;
        [self prepareCloseButton:self.webview];
    } else {
        /* scrollview */
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        self.scrollview = [[GCScrollView alloc] initWithFrame:applicationFrame];

        self.block = [[GCTextblock alloc] initWithFrame:CGRectMake(0, 0, applicationFrame.size.width, 0)];
        self.block.text = [self makeTextString];
        [self.block sizeToFit];

        CGRect frame = self.block.frame;
        frame.size.width = applicationFrame.size.width;
        self.block.frame = frame;

        [self.scrollview addSubview:self.block];

        self.scrollview.contentSize = self.block.frame.size;
        [self.scrollview sizeToFit];
        self.view = self.scrollview;
        [self prepareCloseButton:self.scrollview];
    }
}

- (void)calculateRects
{
    [super calculateRects];
    if (self.useWebview == NO) {
        CGRect applicationFrame = [[UIScreen mainScreen] bounds];
        NSInteger width = applicationFrame.size.width;

        self.block.frame = CGRectMake(0, 0, width, 0);
        [self.block sizeToFit];
    }
}

- (NSString *)makeHTMLString
{
    NSMutableString *ret = [NSMutableString stringWithString:self.waypoint.description];

    if ([self.waypoint.gs_short_desc isEqualToString:@""] == NO) {
        NSString *s = self.waypoint.gs_short_desc;
        if (self.waypoint.gs_short_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    if ([self.waypoint.gs_long_desc isEqualToString:@""] == NO) {
        NSString *s = self.waypoint.gs_long_desc;
        if (self.waypoint.gs_long_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    return ret;
}

- (NSString *)makeTextString
{
    NSMutableString *ret = [NSMutableString stringWithString:self.waypoint.description];

    if ([self.waypoint.gs_short_desc isEqualToString:@""] == NO) {
        NSString *s = self.waypoint.gs_short_desc;
        if (self.waypoint.gs_short_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"\n-----------------\n%@", s];
    }

    if ([self.waypoint.gs_long_desc isEqualToString:@""] == NO) {
        NSString *s = self.waypoint.gs_long_desc;
        if (self.waypoint.gs_long_desc_html == NO)
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
        case menuScanForWaypoints:
            [self scanForWaypoints];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)scanForWaypoints
{
    NSArray<NSString *> *lines = @[[self makeHTMLString]];
    [Coordinates scanForWaypoints:lines waypoint:self.waypoint view:self];
}

- (void)showAsText
{
    [self.navigationController popViewControllerAnimated:YES];
    WaypointViewController *cvc = (WaypointViewController *)self.navigationController.topViewController;
    UIViewController *newController = [[WaypointDescriptionViewController alloc] init:self.waypoint webview:!self.useWebview];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [cvc.navigationController pushViewController:newController animated:YES];
}

@end
