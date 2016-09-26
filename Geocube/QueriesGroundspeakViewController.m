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
    [bezelManager showBezel:self];
    [bezelManager setText:@"Downloading list of pocket queries"];
    [self reloadQueries:PROTOCOL_LIVEAPI];
    [bezelManager removeBezel];
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

    GCDictionaryLiveAPI *d = [[GCDictionaryLiveAPI alloc] initWithDictionary:o];
    [importManager process:d group:g account:a options:RUN_OPTION_NONE infoItemImport:iii];

    [infoView removeItem:iii];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
}

- (bool)runRetrieveQuery:(NSDictionary *)pq group:(dbGroup *)group
{
    __block BOOL failure = NO;

    // Download the query
    NSObject *ret;

    [self showInfoView];
    InfoItemDowload *iid = [infoView addDownload];
    [iid setDescription:[pq objectForKey:@"Name"]];

    [account.remoteAPI retrieveQuery:[pq objectForKey:@"Id"] group:group retObj:&ret downloadInfoItem:iid infoViewer:infoView callback:self];

    [infoView removeItem:iid];
    if ([infoView hasItems] == NO)
        [self hideInfoView];

    if (ret == nil) {
        failure = YES;
        [MyTools messageBox:self header:account.site text:@"Unable to retrieve the query" error:account.lastError];
    }

    return failure;
}

@end
