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
    dbAccount *s;

    @synchronized(db.dbaccess) {
        DB_PREPARE(@"select id, site, url, account, password from accounts");

        DB_WHILE_STEP {
            INT_FETCH_AND_ASSIGN( 0, _id);
            TEXT_FETCH_AND_ASSIGN(1, site);
            TEXT_FETCH_AND_ASSIGN(2, url);
            TEXT_FETCH_AND_ASSIGN(3, account);
            TEXT_FETCH_AND_ASSIGN(4, password);
            s = [[dbAccount alloc] init:_id site:site url:url account:account password:password];
            [ss addObject:s];
        }
        DB_FINISH;
    }
    return ss;
}

@end
