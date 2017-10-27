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

@property (nonatomic, retain) UIScrollView *contentView;
@property (nonatomic, retain) NSMutableArray<NSMutableDictionary *> *accounts;
@property (nonatomic, retain) NSMutableDictionary *totalDictionary;

@property (nonatomic        ) BOOL hasbeenstarted;

@end

@implementation StatisticsViewController

enum {
    menuReload,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuReload label:_(@"statisticsviewcontroller-Reload")];

    self.accounts = [NSMutableArray arrayWithCapacity:[dbc.accounts count]];
    self.hasbeenstarted = NO;

    [self makeInfoView2];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_STATISTICSTABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_STATISTICSTABLEVIEWCELL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.hasbeenstarted == NO) {
        self.hasbeenstarted = YES;
        [self createStatistics];
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
        return _(@"statistics-Accounts");
    else
        return _(@"statistics-Total");
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return 1;
    else
        return [self.accounts count];
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
        CELL(site, nil, self.totalDictionary, @"site")
        CELL(status, @"Status", self.totalDictionary, @"status")
        CELL(wpsFound, @"Waypoints found", self.totalDictionary, @"waypoints_found")
        CELL(wpsHidden, @"Waypoints hidden", self.totalDictionary, @"waypoints_hidden")
        CELL(wpsDNF, @"Waypoints DNF", self.totalDictionary, @"waypoints_notfound")
        CELL(recommendationsGiven, @"Recommendations given", self.totalDictionary, @"recommendations_given")
        CELL(recommendationsReceived, @"Recommendations received", self.totalDictionary, @"recommendations_received")
    }

    if (indexPath.section == 0) {
        NSDictionary *d = [self.accounts objectAtIndex:indexPath.row];
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
    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {

        if (IS_EMPTY(a.accountname.name) == YES)
            return;

        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:10];
        [d setObject:_(@"statistics-Not yet polled") forKey:@"status"];
        [d setObject:a.site forKey:@"site"];
        [d setObject:a forKey:@"account"];
        [self.accounts addObject:d];

        if (a.remoteAPI.supportsUserStatistics == NO)
            [d setObject:_(@"statistics-Remote API doesn't support user statistics") forKey:@"status"];
        else if (a.enabled == NO)
            [d setObject:_(@"statistics-No remote API available") forKey:@"status"];
    }];

    self.totalDictionary = [NSMutableDictionary dictionary];
    [self.totalDictionary setObject:@"" forKey:@"site"];
    [self.totalDictionary setObject:_(@"statistics-Not yet computed") forKey:@"status"];
    [self clearTotal];
}

- (void)clearTotal
{
    [self.totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_hidden"];
    [self.totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_notfound"];
    [self.totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_found"];
    [self.totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_given"];
    [self.totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_received"];
}

- (void)loadStatistics
{
    [self showInfoView2];
    [self clearTotal];

    [self.accounts enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull d, NSUInteger idx, BOOL * _Nonnull stop) {
        dbAccount *a = [d objectForKey:@"account"];

        [d removeObjectForKey:@"waypoints_found"];
        [d removeObjectForKey:@"waypoints_notfound"];
        [d removeObjectForKey:@"waypoints_hidden"];
        [d removeObjectForKey:@"recommendations_given"];
        [d removeObjectForKey:@"recommendations_received"];

        if (a.enabled == NO) {
            [d setObject:_(@"statistics-Remote API is not enabled") forKey:@"status"];
            return;
        }

        if (a.canDoRemoteStuff == NO) {
            [d setObject:_(@"statistics-Remote API is not available") forKey:@"status"];
            return;
        }

        BACKGROUND(runStatistics:, d);
        [d setObject:_(@"statistics-Polling...") forKey:@"status"];
    }];

    [self reloadDataMainQueue];
}

- (void)updateTotals:(NSDictionary *)ad
{
    [self.totalDictionary removeObjectForKey:@"status"];
    [self updateTotal:@"waypoints_found" with:[ad valueForKey:@"waypoints_found"]];
    [self updateTotal:@"waypoints_notfound" with:[ad valueForKey:@"waypoints_notfound"]];
    [self updateTotal:@"waypoints_hidden" with:[ad valueForKey:@"waypoints_hidden"]];
    [self updateTotal:@"recommendations_given" with:[ad valueForKey:@"recommendations_given"]];
    [self updateTotal:@"recommendations_received" with:[ad valueForKey:@"recommendations_received"]];
}

- (void)updateTotal:(NSString *)key with:(NSObject *)value
{
    if (value == nil)
        return;
    if ([value isKindOfClass:[NSNumber class]] == NO)
        return;
    NSNumber *nvalue = (NSNumber *)value;
    NSNumber *n = [self.totalDictionary objectForKey:key];
    NSAssert1(n != nil, @"updateTotal: key %@ does not exist", key);

    NSInteger i = [n integerValue];
    i += [nvalue integerValue];

    [self.totalDictionary setObject:[NSNumber numberWithInteger:i] forKey:key];
}

- (void)runStatistics:(NSMutableDictionary *)ad
{
    InfoItem2 *iid = [self.infoView2 addDownload];
    [iid changeDescription:[ad objectForKey:@"site"]];

    dbAccount *a = [ad objectForKey:@"account"];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:5];
    NSInteger retValue = [a.remoteAPI UserStatistics:&d infoItem:iid];

    if (retValue != REMOTEAPI_OK) {
        [self.infoView2 removeDownload:iid];
        if ([self.infoView2 hasItems] == NO)
            [self hideInfoView2];

        NSString *header = [NSString stringWithFormat:_(@"statistics-Unable to load statistics for %@"), a.site];
        NSString *text = [NSString stringWithFormat:_(@"statistics-Returned error: %@"), a.remoteAPI.lastError];
        [MyTools messageBox:self header:header text:text];
        return;
    }

    [d enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]] == YES)
            [ad setObject:obj forKey:key];
    }];

    [ad removeObjectForKey:@"status"];
    [self updateTotals:ad];

    [self.infoView2 removeDownload:iid];
    if ([self.infoView2 hasItems] == NO)
        [self hideInfoView2];
    [self reloadDataMainQueue];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuReload:
            if ([self.accounts count] == 0)
                [self createStatistics];
            [self loadStatistics];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
