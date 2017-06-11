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
}

@end

@implementation WaypointDescriptionViewController

- (instancetype)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    hasCloseButton = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [webview loadHTMLString:[self makeHTMLString] baseURL:nil];
    [webview sizeToFit];
    self.view = webview;

    [self prepareCloseButton:webview];
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

@end
