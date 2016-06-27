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

@interface QueriesGCAViewController ()

@end

@implementation QueriesGCAViewController

enum {
    menuReload,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.queryString = @"Query";
    self.queriesString = @"Queries";

    return self;
}

- (void)reloadQueries
{
    [self reloadQueries:ProtocolGCA];
}

- (BOOL)parseRetrievedQueryGPX:(NSObject *)query group:(dbGroup *)group
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        ImportViewController *newController = [[ImportViewController alloc] init];
        [newController setGroupAccount:group account:account];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        newController.title = @"Import";
        [self.navigationController pushViewController:newController animated:YES];
        newController.run_options = RUN_OPTION_LOGSONLY;
        [newController run:query];
    }];

    [waypointManager needsRefresh];

    return YES;
}


- (BOOL)parseRetrievedQuery:(NSObject *)query group:(dbGroup *)group
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        ImportViewController *newController = [[ImportViewController alloc] init];
        [newController setGroupAccount:group account:account];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        newController.title = @"Import";
        [self.navigationController pushViewController:newController animated:YES];
        [newController run:query];
    }];

    [waypointManager needsRefresh];

    return YES;
}

- (bool)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    __block BOOL failure = NO;
    account.remoteAPI.delegateQueries = self;

    // Download the query. The GPX file is also required since the JSON file doesn't contain the logs.
    NSObject *retjson;
    NSObject *retgpx;
    [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group retObj:retjson];
    [account.remoteAPI retrieveQuery_forcegpx:[pq objectForKey:@"Id"] group:group retObj:retgpx];

    if (retjson == nil && retgpx == nil) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.lastError];
        failure = YES;
        return failure;
    }

    if (retjson == nil) {
        [self parseRetrievedQuery:retgpx group:group];
    } else {
        [self parseRetrievedQuery:retjson group:group];
        [self parseRetrievedQueryGPX:retgpx group:group];
    }

    return failure;
}

@end
