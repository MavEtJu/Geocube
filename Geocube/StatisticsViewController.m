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

@interface StatisticsViewController ()
{
    UIScrollView *contentView;
    NSMutableArray *accountViews;
    NSMutableArray *accountDictionaries;
    GCView *totalView;
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
        GCView *v = [[GCView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:v];
        [accountViews addObject:v];

        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setObject:@"Not yet polled" forKey:@"status"];
        [accountDictionaries addObject:d];

        if (a.enabled == NO)
            [d setObject:@"No remote API available" forKey:@"status"];
    }];

    totalView = [[GCView alloc] initWithFrame:CGRectZero];
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
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;

    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_found"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_notfound"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"waypoints_hidden"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_given"];
    [totalDictionary setObject:[NSNumber numberWithInteger:0] forKey:@"recommendations_received"];

    __block NSInteger y = 0;
    [[dbc Accounts] enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        GCView *v = [accountViews objectAtIndex:idx];
        NSDictionary *d = [accountDictionaries objectAtIndex:idx];

        if (a.accountname == nil) {
            v.frame = CGRectZero;
        } else {
            [self showAccount:a.site view:v dict:d];
            v.frame = CGRectMake(0, y, width, v.frame.size.height);
            y += v.frame.size.height;
        }

    }];

    y += 10;
    [self showAccount:@"Totals" view:totalView dict:totalDictionary];
    totalView.frame = CGRectMake(0, y, width, totalView.frame.size.height);
    y += totalView.frame.size.height;

    contentView.contentSize = CGSizeMake(width, y);
}

- (void)showAccount:(NSString *)site view:(GCView *)v dict:(NSDictionary *)d
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    NSInteger width = bounds.size.width;
    NSInteger y = 0;

    [v.subviews enumerateObjectsUsingBlock:^(UIView *cv, NSUInteger idx, BOOL * _Nonnull stop) {
        [cv removeFromSuperview];
    }];

#define MARGIN  5
#define INDENT  10

#define LABEL_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN, y, width - 2 * MARGIN, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;
#define INDENT_RESIZE(__s__) \
    __s__.frame = CGRectMake(MARGIN + INDENT, y, width - 2 * MARGIN - INDENT, __s__.font.lineHeight); \
    y += __s__.font.lineHeight;

    GCLabel *l = [[GCLabel alloc] initWithFrame:CGRectZero];
    l.text = site;
    LABEL_RESIZE(l);
    [v addSubview:l];
    NSInteger yh = l.font.lineHeight;

    NSObject *o = [d objectForKey:@"status"];
    if ([o isKindOfClass:[NSString class]] == YES) {
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        l.text = [NSString stringWithFormat:@"%@", o];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    o = [d valueForKey:@"waypoints_found"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_found" with:o];
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        [l setText:[NSString stringWithFormat:@"Found: %@", o]];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    o = [d valueForKey:@"waypoints_notfound"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_notfound" with:o];
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        [l setText:[NSString stringWithFormat:@"Not found: %@", o]];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    o = [d valueForKey:@"waypoints_hidden"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_hidden" with:o];
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        [l setText:[NSString stringWithFormat:@"Hidden: %@", o]];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    o = [d valueForKey:@"recommendations_given"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_given" with:o];
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        [l setText:[NSString stringWithFormat:@"Recommendations given: %@", o]];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    o = [d valueForKey:@"recommendations_received"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_received" with:o];
        l = [[GCSmallLabel alloc] initWithFrame:CGRectZero];
        [l setText:[NSString stringWithFormat:@"Recommendations received: %@", o]];
        INDENT_RESIZE(l);
        [v addSubview:l];
    }

    y += yh / 2;
    v.frame = CGRectMake(0, 0, width, y);
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
    InfoItemDowload *iid = [infoView addDownload];
    [iid setDescription:a.site];

    NSDictionary *d = nil;
    NSInteger retValue = [a.remoteAPI UserStatistics:&d downloadInfoItem:iid];

    if (retValue != REMOTEAPI_OK)
        return;

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
