//
//  CacheDescriptionViewController.h
//  Geocube
//
//  Created by Edwin Groothuis on 10/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface CacheHintViewController : GCViewController<UIScrollViewDelegate, UIWebViewDelegate> {
    dbCache *wp;
    UIWebView *webview;
}

- (id)init:(dbCache *)wp;

@end
