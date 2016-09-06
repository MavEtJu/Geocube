//
//  BezelManager.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/09/2016.
//  Copyright © 2016 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@interface BezelManager ()
{
    UIViewController *bezelViewController;
    NSString *bezelText;
}

@end

@implementation BezelManager

- (void)showBezel:(UIViewController *)vc
{
    bezelViewController = vc;
    bezelText = @"Doing stuff";

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if (bezelViewController == nil) {
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD showWithStatus:bezelText];
        }
    }];
}

- (void)setText:(NSString *)text
{
    bezelText = text;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD showWithStatus:text];
    }];
}

- (void)removeBezel
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [SVProgressHUD dismiss];
    }];
}

@end
