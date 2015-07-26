/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

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
