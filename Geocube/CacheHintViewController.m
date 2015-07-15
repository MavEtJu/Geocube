//
//  CacheDescriptionViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 10/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation CacheHintViewController

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
    return [MyTools simpleHTML:wp.gc_hint];
}

@end