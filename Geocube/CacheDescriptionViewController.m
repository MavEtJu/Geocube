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

- (id)init:(dbCache *)_wp
{
    self = [super self];

    wp = _wp;

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
    NSString *short_desc = wp.gc_short_desc;
    if (wp.gc_short_desc_html == NO)
        short_desc = [MyTools simpleHTML:short_desc];
    NSString *long_desc = wp.gc_long_desc;
    if (wp.gc_long_desc_html == NO)
        long_desc = [MyTools simpleHTML:long_desc];

    return [NSString stringWithFormat:@"%@<hr>%@", short_desc, long_desc];
}

@end
