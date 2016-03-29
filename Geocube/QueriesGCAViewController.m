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
{
    NSArray *pqs;
    dbAccount *account;
}

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

- (BOOL)parseRetrievedQuery:(NSObject *)query group:(dbGroup *)group
{
    NSStringGPX *d = (NSStringGPX *)query;

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        ImportViewController *newController = [[ImportViewController alloc] init];
        [newController setGroupAccount:group account:account];
        newController.edgesForExtendedLayout = UIRectEdgeNone;
        newController.title = @"Import";
        [self.navigationController pushViewController:newController animated:YES];
        [newController run:d];
    }];

    [waypointManager needsRefresh];

    return YES;
}

@end
