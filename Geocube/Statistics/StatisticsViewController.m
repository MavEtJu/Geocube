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

@interface StatisticsViewController ()
{
    UIScrollView *contentView;
    NSMutableArray<NSMutableDictionary *> *accounts;
    NSMutableDictionary *totalDictionary;

    BOOL hasbeenstarted;
}

@end

@implementation StatisticsViewController

enum {
    menuReload,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuReload label:@"Reload"];

    accounts = [NSMutableArray arrayWithCapacity:[dbc.Accounts count]];
    hasbeenstarted = NO;

    [self makeInfoView];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_STATISTICSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_STATISTICSTABLEVIEWCELL];

    [self createStatistics];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (hasbeenstarted == NO) {
        hasbeenstarted = YES;
        [self loadStatistics];
    }
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Accounts";
    else
        return @"Total";
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 1;
    else
        return [accounts count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatisticsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_STATISTICSTABLEVIEWCELL forIndexPath:indexPath];

#define CELL(__field__, __prefix__, __dict__, __key__) { \
        NSObject *o = [__dict__ objectForKey:__key__]; \
        if (o != nil) { \
            if (__prefix__ == nil) \
                cell.__field__.text = [NSString stringWithFormat:@"%@", o]; \
            else \
                cell.__field__.text = [NSString stringWithFormat:@"%@: %@", __prefix__, o]; \
        } else \
            cell.__field__.text = @""; \
    }

    if (indexPath.section == 1) {
        CELL(site, nil, totalDictionary, @"site")
        CELL(status, @"Status", totalDictionary, @"status")
        CELL(wpsFound, @"Waypoints found", totalDictionary, @"waypoints_found")
        CELL(wpsHidden, @"Waypoints hidden", totalDictionary, @"waypoints_hidden")
        CELL(wpsDNF, @"Waypoints DNF", totalDictionary, @"waypoints_notfound")
        CELL(recommendationsGiven, @"Recommendations given", totalDictionary, @"recommendations_given")
        CELL(recommendationsReceived, @"Recommendations received", totalDictionary, @"recommendations_received")
    }

    if (indexPath.section == 0) {
        NSDictionary *d = [accounts objectAtIndex:indexPath.row];
        CELL(site, nil, d, @"site")
        CELL(status, @"Status", d, @"status")
        CELL(wpsFound, @"Waypoints found", d, @"waypoints_found")
        CELL(wpsHidden, @"Waypoints hidden", d, @"waypoints_hidden")
        CELL(wpsDNF, @"Waypoints DNF", d, @"waypoints_notfound")
        CELL(recommendationsGiven, @"Recommendations given", d, @"recommendations_given")
        CELL(recommendationsReceived, @"Recommendations received", d, @"recommendations_received")
    }

    [cell setUserInteractionEnabled:NO];

    return cell;
}

///////////////

- (void)createStatistics
{
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {

        if (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES)
            return;

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        [d setObject:@"Not yet polled" forKey:@"status"];
        [d setObject:a.site forKey:@"site"];
        [d setObject:a forKey:@"account"];
        [accounts addObject:d];

        if (a.remoteAPI.supportsUserStatistics == NO)
            [d setObject:@"Remote API doesn't support user statistics" forKey:@"status"];
        else if (a.enabled == NO)
            [d setObject:@"No remote API available" forKey:@"status"];
    }];

    totalDictionary = [NSMutableDictionary dictionary];
    [totalDictionary setObject:@"Total" forKey:@"site"];
    [totalDictionary setObject:@"Not yet computed" forKey:@"status"];
    [self clearTotal];
}

- (void)clearTotal
{
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_hidden"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_notfound"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_found"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_given"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_received"];
}

- (void)loadStatistics
{
    [self showInfoView];
    [self clearTotal];

    [accounts enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        dbAccount *a = [d objectForKey:@"account"];

        [d removeObjectForKey:@"waypoints_found"];
        [d removeObjectForKey:@"waypoints_notfound"];
        [d removeObjectForKey:@"waypoints_hidden"];
        [d removeObjectForKey:@"recommendations_given"];
        [d removeObjectForKey:@"recommendations_received"];

        if (a.enabled == NO) {
            [d setObject:@"Remote API is not enabled" forKey:@"status"];
            return;
        }

        if (a.canDoRemoteStuff == NO) {
            [d setObject:@"Remote API is not available" forKey:@"status"];
            return;
        }

        [self performSelectorInBackground:@selector(runStatistics:) withObject:d];
        [d setObject:@"Polling..." forKey:@"status"];
    }];

    [self reloadDataMainQueue];
}

- (void)updateTotals:(NSDictionary *)ad
{
    [totalDictionary removeObjectForKey:@"status"];
    [self updateTotal:@"waypoints_found" with:[ad valueForKey:@"waypoints_found"]];
    [self updateTotal:@"waypoints_notfound" with:[ad valueForKey:@"waypoints_notfound"]];
    [self updateTotal:@"waypoints_hidden" with:[ad valueForKey:@"waypoints_hidden"]];
    [self updateTotal:@"recommendations_given" with:[ad valueForKey:@"recommendations_given"]];
    [self updateTotal:@"recommendations_received" with:[ad valueForKey:@"recommendations_received"]];
}

- (void)updateTotal:(NSString *)key with:(NSObject *)_value
{
    if (_value == nil)
        return;
    if ([_value isKindOfClass:[NSNumber class]] == NO)
        return;
    NSNumber *value = (NSNumber *)_value;
    NSNumber *n = [totalDictionary objectForKey:key];
    NSAssert1(n != nil, @"updateTotal: key %@ does not exist", key);

    NSInteger i = [n integerValue];
    i += [value integerValue];

    [totalDictionary setObject:[NSNumber numberWithInteger:i] forKey:key];
}

- (void)runStatistics:(NSMutableDictionary *)ad
{
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:[ad objectForKey:@"site"]];

    dbAccount *a = [ad objectForKey:@"account"];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    NSInteger retValue = [a.remoteAPI UserStatistics:&d infoViewer:infoView iiDownload:iid];

    if (retValue != REMOTEAPI_OK) {
        [infoView removeItem:iid];
        if ([infoView hasItems] == NO)
            [self hideInfoView];

        NSString *header = [NSString stringWithFormat:@"Unable to load statistics for %@", a.site];
        NSString *text = [NSString stringWithFormat:@"Returned error: %@", a.remoteAPI.lastError];
        [MyTools messageBox:self header:header text:text];
        return;
    }

    [d enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]] == YES)
            [ad setObject:obj forKey:key];
    }];

    [ad removeObjectForKey:@"status"];
    [self updateTotals:ad];

    [infoView removeItem:iid];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
    [self reloadDataMainQueue];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self loadStatistics];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
