//
//  BezelManager.m
//  Geocube
//
//  Created by Edwin Groothuis on 7/09/2016.
//  Copyright © 2016 Edwin Groothuis. All rights reserved.
//

@interface BezelManager ()

@end

@implementation BezelManager

- (void)showBezel:(UIViewController *)vc
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [SVProgressHUD setDefaultStyle:currentTheme.svProgressHUDStyle];
        [SVProgressHUD showWithStatus:@"Doing stuff"];
    }];
}

- (void)setText:(NSString *)text
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [SVProgressHUD setDefaultStyle:currentTheme.svProgressHUDStyle];
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
