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

@interface QueriesGroundspeakViewController ()

@end

@implementation QueriesGroundspeakViewController

- (instancetype)init
{
    self = [super init];

    self.queryString = @"Pocket Query";
    self.queriesString = @"Pocket Queries";

    return self;
}

- (void)reloadQueries
{
    [downloadManager setBezelViewController:self];
    [downloadManager setBezelViewText:@"Downloading list of pocket queries"];
    [self reloadQueries:PROTOCOL_LIVEAPI];
    [downloadManager setBezelViewController:nil];
}

- (BOOL)parseRetrievedQuery:(NSObject *)query group:(dbGroup *)group
{
    GCDictionaryLiveAPI *d = [[GCDictionaryLiveAPI alloc] initWithDictionary:query];
    [importManager run:d group:group account:account options:RUN_OPTION_NONE];

    return YES;
}

- (bool)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    __block BOOL failure = NO;
    account.remoteAPI.delegateQueries = self;

    // Download the query
    NSObject *ret;

    [downloadsImportsViewController showDownloadManager];
    [downloadManager resetForegroundDownload];
    [downloadManager setDescription:[NSString stringWithFormat:@"Pocket query %@", [pq objectForKey:@"Name"]]];

    [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group retObj:&ret];

    if (ret == nil) {
        failure = YES;
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.lastError];
    } else
        [self parseRetrievedQuery:ret group:group];

    return failure;
}

@end
