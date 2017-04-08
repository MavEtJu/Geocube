/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
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

@interface QueriesGCAViewController ()
{
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
    [bezelManager showBezel:self];
    [bezelManager setText:@"Downloading list of queries"];
    [self reloadQueries:PROTOCOL_GCA2];
    [bezelManager removeBezel];
}

- (void)remoteAPI_objectReadyToImport:(InfoViewer *)iv ivi:(InfoItemID)ivi identifier:(NSInteger)identifier object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)a
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    [d setObject:group forKey:@"group"];
    [d setObject:o forKey:@"object"];
    [d setObject:[NSNumber numberWithInteger:ivi] forKey:@"iii"];
    [d setObject:iv forKey:@"infoViewer"];
    [d setObject:a forKey:@"account"];
    [d setObject:[NSNumber numberWithInteger:identifier] forKey:@"identifier"];

    [self performSelectorInBackground:@selector(parseQueryBG:) withObject:d];
}

- (void)parseQueryBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItemID iii = [[dict objectForKey:@"iii"] integerValue];
    InfoViewer *iv = [dict objectForKey:@"infoViewer"];
    dbAccount *a = [dict objectForKey:@"account"];
    NSNumber *identifier = [dict objectForKey:@"identifier"];

    [importManager process:o group:g account:a options:IMPORTOPTION_NONE infoViewer:iv ivi:iii];

    [infoView removeItem:iii];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
}

- (void)remoteAPI_finishedDownloads:(InfoViewer *)iv identifier:(NSInteger)identifier numberOfChunks:(NSInteger)numberOfChunks
{
#warning XXX remoteAPI_finishedDownloadsmissing
}
- (void)remoteAPI_failed:(InfoViewer *)iv identifier:(NSInteger)identifier
{
#warning XXX remoteAPI_failed missing
}

- (BOOL)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    BOOL failure = NO;

    [self showInfoView];
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:[pq objectForKey:@"Name"]];

    RemoteAPIResult rv = [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group infoViewer:infoView ivi:iid callback:self];
    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:@"Error" text:@"Unable to retrieve the JSON data from the query" error:account.remoteAPI.lastError];
        failure = YES;
    }

    [infoView removeItem:iid];
    if ([infoView hasItems] == NO)
        [self hideInfoView];

    return failure;
}

@end
