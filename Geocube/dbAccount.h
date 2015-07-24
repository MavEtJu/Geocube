//
//  dbAccount.h
//  Geocube
//
//  Created by Edwin Groothuis on 24/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

@interface dbAccount : dbObject {
    NSString *site;
    NSString *url;
    NSString *account;
    NSString *password;
}

@property (nonatomic, retain) NSString *site;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *account;
@property (nonatomic, retain) NSString *password;

@end
