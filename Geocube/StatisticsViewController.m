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
    NSMutableArray<StatisticsSingleView *> *accountViews;
    NSMutableArray<NSMutableDictionary *> *accountDictionaries;
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

    accountViews = nil;
    hasbeenstarted = NO;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    self.view = contentView;

    [self createViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (hasbeenstarted == NO) {
        hasbeenstarted = YES;
        [self loadStatistics];
    }
}

- (void)createViews
{
    accountDictionaries = [NSMutableArray arrayWithCapacity:[[dbc Accounts] count]];
    accountViews = [NSMutableArray arrayWithCapacity:[[dbc Accounts] count]];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:@"Not yet polled" forKey:@"status"];
        [d setObject:a.site forKey:@"site"];
        [d setObject:a forKey:@"account"];
        [accountDictionaries addObject:d];

        if (a.enabled == NO)
            [d setObject:@"No remote API available" forKey:@"status"];

        StatisticsSingleView *sv = [[StatisticsSingleView alloc] initWithFrame:CGRectZero];
        sv.site.text = a.site;
        [self.view addSubview:sv];
        [accountViews addObject:sv];
        [d setObject:sv forKey:@"view"];
    }];

    totalDictionary = [NSMutableDictionary dictionary];
    [totalDictionary setObject:@"Total" forKey:@"site"];
    [totalDictionary setObject:@"Not yet computed" forKey:@"status"];
    [self clearTotal];
    [accountDictionaries addObject:totalDictionary];

    StatisticsSingleView *sv = [[StatisticsSingleView alloc] initWithFrame:CGRectZero];
    [totalDictionary setObject:sv forKey:@"view"];
    [self.view addSubview:sv];

    [self makeInfoView];

    [self showViews];
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

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([a.remoteAPI supportsUserStatistics] == NO)
            return;
        if ([a canDoRemoteStuff] == NO)
            return;

        NSMutableDictionary *d = [accountDictionaries objectAtIndex:idx];
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

    [self showViews];
}

- (void)resizeViews
{
    __block NSInteger y = 0;
    [accountDictionaries enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
        StatisticsSingleView *sv = [ad objectForKey:@"view"];
        sv.frame = CGRectMake(0, y, sv.frame.size.width, sv.frame.size.height);
        y += sv.frame.size.height;
    }];

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    contentView.contentSize = CGSizeMake(width, y);
}

- (void)showViews
{
    [self clearTotal];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [accountDictionaries enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull ad, NSUInteger idx, BOOL * _Nonnull stop) {
            [self showView:ad];
            if (ad != totalDictionary)
                [self updateTotals:ad];
        }];
        [self resizeViews];
    }];
}

- (void)showView:(NSMutableDictionary *)ad
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    NSInteger y = 0;

    StatisticsSingleView *sv = [ad objectForKey:@"view"];
    dbAccount *a = [ad objectForKey:@"account"];

    if (a != nil && a.accountname == nil) {
        sv.frame = CGRectZero;
        return;
    }

#define ADD(__key__, __field__, __prefix__) \
    o = [ad objectForKey:__key__]; \
    if (o != nil) { \
        sv.__field__.text = [NSString stringWithFormat:@"%@%@", __prefix__, o]; \
        [sv.__field__ sizeToFit]; \
        y += sv.__field__.frame.size.height; \
    } else \
        sv.__field__.text = @"";

    NSObject *o;

    ADD(@"site", site, @"");
    ADD(@"status", status, @"");
    ADD(@"waypoints_found", wpsFound, @"Waypoints found: ");
    ADD(@"waypoints_notfound", wpsDNF, @"Waypoints not found: ");
    ADD(@"waypoints_hidden", wpsHidden, @"Waypoints hidden: ");
    ADD(@"recommendations_given", recommendationsGiven, @"Recommendations given: ");
    ADD(@"recommendations_received", recommendationsReceived, @"Recommendations received: ");

    sv.frame = CGRectMake(0, 0, width, y);
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

    [infoView removeItem:iid];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
    [self showViews];
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
