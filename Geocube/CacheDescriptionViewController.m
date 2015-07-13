//
//  CacheDescriptionViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 10/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

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