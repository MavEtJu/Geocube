//
//  BezelManager.h
//  Geocube
//
//  Created by Edwin Groothuis on 7/09/2016.
//  Copyright © 2016 Edwin Groothuis. All rights reserved.
//

@interface BezelManager : NSObject

- (void)showBezel:(UIViewController *)vc;
- (void)removeBezel;
- (void)setText:(NSString *)text;

@end
