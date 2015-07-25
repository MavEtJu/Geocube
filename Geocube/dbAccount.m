//
//  dbAccount.m
//  Geocube
//
//  Created by Edwin Groothuis on 24/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

@implementation dbAccount

@synthesize site, url, account, password;

- (id)init:(NSId)__id site:(NSString *)_site url:(NSString *)_url account:(NSString *)_account password:(NSString *)_password
{
    self = [super init];

    _id = __id;
    site = _site;
    url = _url;
    account = _account;
    password = _password;

    [self finish];
    return self;
}

+ (NSArray *)dbAll
{
    NSMutableArray *ss = [[NSMutableArray alloc] initWithCapacity:20];

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, account, password from accounts");

        DB_WHILE_STEP {
            dbAccount *a = [[dbAccount alloc] init];
            INT_FETCH( 0, a._id);
            TEXT_FETCH(1, a.site);
            TEXT_FETCH(2, a.url);
            TEXT_FETCH(3, a.account);
            TEXT_FETCH(4, a.password);
            [ss addObject:a];
        }
        DB_FINISH;
    }
    return ss;
}

@end
