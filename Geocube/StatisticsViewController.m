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
    StatisticsSingleView *totalView;
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
    totalView = nil;

    hasbeenstarted = NO;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] bounds];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = currentTheme.viewBackgroundColor;
    self.view = contentView;

    accountDictionaries = [NSMutableArray arrayWithCapacity:[[dbc Accounts] count]];
    accountViews = [NSMutableArray arrayWithCapacity:[[dbc Accounts] count]];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        StatisticsSingleView *sv = [[StatisticsSingleView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:sv];
        [accountViews addObject:sv];

        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:@"Not yet polled" forKey:@"status"];
        [accountDictionaries addObject:d];

        if (a.enabled == NO)
            [d setObject:@"No remote API available" forKey:@"status"];
    }];

    totalView = [[StatisticsSingleView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:totalView];

    totalDictionary = [NSMutableDictionary dictionary];

    [self makeInfoView];

    [self showAccounts];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (hasbeenstarted == NO) {
        hasbeenstarted = YES;
        [self loadStatistics];
    }
}

- (void)showAccounts
{
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_found"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_notfound"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_hidden"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_given"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_received"];

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        StatisticsSingleView *sv = [accountViews objectAtIndex:idx];
        NSDictionary *d = [accountDictionaries objectAtIndex:idx];

        sv.site.text = a.site;

        if (a.accountname == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                sv.frame = CGRectZero;
                [self resizeAccounts:sv];
            }];
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showAccount:a.site view:sv dict:d];
        }];
    }];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self showAccount:@"Totals" view:totalView dict:totalDictionary];
    }];
}

- (void)resizeAccounts:(StatisticsSingleView *)sv
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    __block NSInteger y = 0;
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        StatisticsSingleView *sv = [accountViews objectAtIndex:idx];

        sv.frame = CGRectMake(0, y, sv.frame.size.width, sv.frame.size.height);
        y += sv.frame.size.height;
    }];
    totalView.frame = CGRectMake(0, y, totalView.frame.size.width, totalView.frame.size.height);
    y += totalView.frame.size.height;

    contentView.contentSize = CGSizeMake(width, y);
}

- (void)showAccount:(NSString *)site view:(StatisticsSingleView *)sv dict:(NSDictionary *)d
{
    NSInteger y = 0;

    sv.site.text = site;
    y += sv.site.frame.size.height;

    NSObject *o = [d objectForKey:@"status"];
    if ([o isKindOfClass:[NSString class]] == YES) {
        sv.status.text = [NSString stringWithFormat:@"%@", o];
        y += sv.status.frame.size.height;
    } else
        sv.status.text = @"";

    o = [d valueForKey:@"waypoints_found"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_found" with:o];
        sv.wpsFound.text = [NSString stringWithFormat:@"Found: %@", o];
        y += sv.wpsFound.frame.size.height;
    } else
        sv.wpsFound.text = @"";

    o = [d valueForKey:@"waypoints_notfound"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_notfound" with:o];
        sv.wpsDNF.text = [NSString stringWithFormat:@"Not found: %@", o];
        y += sv.wpsDNF.frame.size.height;
    } else
        sv.wpsDNF.text = @"";

    o = [d valueForKey:@"waypoints_hidden"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_hidden" with:o];
        sv.wpsHidden.text = [NSString stringWithFormat:@"Hidden: %@", o];
        y += sv.wpsHidden.frame.size.height;
    } else
        sv.wpsHidden.text = @"";

    o = [d valueForKey:@"recommendations_given"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_given" with:o];
        sv.recommendationsGiven.text = [NSString stringWithFormat:@"Recommendations given: %@", o];
        y += sv.recommendationsGiven.frame.size.height;
    } else
        sv.recommendationsGiven.text = @"";

    o = [d valueForKey:@"recommendations_received"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_received" with:o];
        sv.recommendationsReceived.text = [NSString stringWithFormat:@"Recommendations received: %@", o];
        y += sv.recommendationsReceived.frame.size.height;
    } else
        sv.recommendationsReceived.text = @"";

    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    [sv setNeedsLayout];  [sv layoutIfNeeded];
    NSLog(@"%@ %d %f %f", sv.site.text, y, sv.frame.size.height, sv.bounds.size.height);
    sv.frame = CGRectMake(0, 0, width, y);

    [self resizeAccounts:sv];
}

- (void)updateTotal:(NSString *)key with:(NSObject *)_value
{
    if ([_value isKindOfClass:[NSNumber class]] == NO)
        return;
    NSNumber *value = (NSNumber *)_value;
    NSNumber *n = [totalDictionary objectForKey:key];
    NSAssert1(n != nil, @"updateTotal: key %@ does not exist", key);

    NSInteger i = [n integerValue];
    i += [value integerValue];

    [totalDictionary setObject:[NSNumber numberWithInteger:i] forKey:key];
}

- (void)loadStatistics
{
    __block NSInteger count = 0;

    [self showInfoView];

    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        // If there is nothing, do not show.
        if ([a canDoRemoteStuff] == NO)
            return;

        NSMutableDictionary *d = [accountDictionaries objectAtIndex:idx];
        [d removeAllObjects];
        count++;

        if (a.enabled == NO) {
            [d setObject:@"Remote API is not enabled" forKey:@"status"];
            return;
        }

        if (a.canDoRemoteStuff == NO) {
            [d setObject:@"Remote API is not available" forKey:@"status"];
            return;
        }

        [self performSelectorInBackground:@selector(runStatistics:) withObject:a];
        [d setObject:@"Polling..." forKey:@"status"];
    }];

    if (count == 0) {
        [self hideInfoView];
        [MyTools messageBox:self header:@"No statistics loaded" text:@"No accounts with remote capabilities could be found. Please go to the Accounts tab in the Settings menu to define an account."];
        return;
    }

    [self showAccounts];
}

- (void)runStatistics:(dbAccount *)a
{
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:a.site];

    NSDictionary *d = nil;
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

    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *aa, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a == aa) {

            NSMutableDictionary *dd = [accountDictionaries objectAtIndex:idx];
            [d enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *obj, BOOL *stop) {
                [dd setObject:obj forKey:key];
            }];
            [dd removeObjectForKey:@"status"];
            *stop = YES;
        }
    }];

    [infoView removeItem:iid];
    if ([infoView hasItems] == NO)
        [self hideInfoView];
    [self showAccounts];
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
