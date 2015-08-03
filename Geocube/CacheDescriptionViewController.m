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

@implementation CacheDescriptionViewController

- (id)init:(dbWaypoint *)_wp
{
    self = [super init];

    waypoint = _wp;
    groundspeak = [dbGroundspeak dbGet:_wp.groundspeak_id];

    hasCloseButton = YES;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];

    [webview loadHTMLString:[self makeHTMLString] baseURL:nil];
    [webview sizeToFit];
    self.view = webview;
}

- (NSString *)makeHTMLString
{
    NSMutableString *ret = [NSMutableString stringWithString:waypoint.description];

    if ([groundspeak.short_desc compare:@""] != NSOrderedSame) {
        NSString *s = groundspeak.short_desc;
        if (groundspeak.short_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    if ([groundspeak.long_desc compare:@""] != NSOrderedSame) {
        NSString *s = groundspeak.long_desc;
        if (groundspeak.long_desc_html == NO)
            s = [MyTools simpleHTML:s];
        [ret appendFormat:@"<hr>%@", s];
    }

    return ret;
}

@end
