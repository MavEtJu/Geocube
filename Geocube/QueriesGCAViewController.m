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

@interface QueriesGCAViewController ()
{
    BOOL seenJSON;
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
    [self reloadQueries:PROTOCOL_GCA];
    [bezelManager removeBezel];
}

- (BOOL)parseRetrievedQueryGPX:(NSObject *)query group:(dbGroup *)group
{
    [importManager addToQueue:query group:group account:account options:RUN_OPTION_LOGSONLY];
    return YES;
}


- (BOOL)parseRetrievedQuery:(NSObject *)query group:(dbGroup *)group
{
    [importManager addToQueue:query group:group account:account options:RUN_OPTION_NONE];
    return YES;
}

- (void)remoteAPI_objectReadyToImport:(InfoItemImport *)iii object:(NSObject *)o group:(dbGroup *)group account:(dbAccount *)a
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    [d setObject:group forKey:@"group"];
    [d setObject:o forKey:@"object"];
    [d setObject:iii forKey:@"iii"];
    [d setObject:a forKey:@"account"];

    [self performSelectorInBackground:@selector(parseQueryBG:) withObject:d];
}

- (void)parseQueryBG:(NSDictionary *)dict
{
    dbGroup *g = [dict objectForKey:@"group"];
    NSObject *o = [dict objectForKey:@"object"];
    InfoItemImport *iii = [dict objectForKey:@"iii"];
    dbAccount *a = [dict objectForKey:@"account"];

    if ([o isKindOfClass:[GCStringGPX class]] == YES) {
        if (seenJSON == YES)
            [importManager process:o group:g account:a options:RUN_OPTION_LOGSONLY infoItemImport:iii];
        else
            [importManager process:o group:g account:a options:RUN_OPTION_NONE infoItemImport:iii];
    } else {
        [importManager process:o group:g account:a options:RUN_OPTION_NONE infoItemImport:iii];
        seenJSON = YES;
    }

    [infoView removeItem:iii];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
}

- (BOOL)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    __block BOOL failure = NO;

    // Download the query. The GPX file is also required since the JSON file doesn't contain the logs.
    NSObject *retjson;
    NSObject *retgpx;

    seenJSON = NO;

    [self showInfoView];
    InfoItemDowload *iid = [infoView addDownload];
    [iid setDescription:[pq objectForKey:@"Name"]];

    [infoView setHeaderSuffix:@"1/2"];

    RemoteAPIResult rv = [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group retObj:&retjson downloadInfoItem:iid infoViewer:infoView callback:self];
    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:@"Error" text:@"Unable to retrieve the JSON data from the query" error:account.remoteAPI.lastError];
        [infoView removeItem:iid];
        if ([infoView hasItems] == NO)
            [self hideInfoView];
        return YES;
    }

    [iid resetBytesChunks];
    [infoView setHeaderSuffix:@"2/2"];

    rv = [account.remoteAPI retrieveQuery_forcegpx:[pq objectForKey:@"Id"] group:group retObj:&retgpx downloadInfoItem:iid infoViewer:infoView callback:self];
    if (rv != REMOTEAPI_OK) {
        [MyTools messageBox:self header:@"Error" text:@"Unable to retrieve the GPX data from the query" error:account.remoteAPI.lastError];
        [infoView removeItem:iid];
        if ([infoView hasItems] == NO)
            [self hideInfoView];
        return YES;
    }

    [infoView removeItem:iid];

    if (retjson == nil && retgpx == nil) {
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve any data from the query" error:account.remoteAPI.lastError];
        if ([infoView hasItems] == NO)
            [self hideInfoView];
        failure = YES;
    }

    return failure;
}

@end
