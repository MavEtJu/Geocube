//
//  GCOAuthBlackbox-delegate.h
//  Geocube
//
//  Created by Edwin Groothuis on 17/9/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCOAuthBlackboxDelegate

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret;
- (void)oauthtripped:(NSString *)reason error:(NSError *)error;

@end
