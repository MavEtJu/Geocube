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

@interface UserProfileViewController ()
{
    UIScrollView *contentView;
    NSMutableArray *accountViews;
    NSMutableArray *accountDictionaries;
    GCView *totalView;
    NSMutableDictionary *totalDictionary;

    BOOL hasbeenstarted;
}

@end

@implementation UserProfileViewController

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

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    contentView = [[GCScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
    NSInteger labelHeight = myConfig.GCLabelFont.lineHeight;

    [v.subviews enumerateObjectsUsingBlock:^(UIView *cv, NSUInteger idx, BOOL * _Nonnull stop) {
        [cv removeFromSuperview];
    }];

    GCLabel *l = [[GCLabel alloc] initWithFrame:CGRectMake(10, y, width - 20, labelHeight)];
    l.text = site;
    [v addSubview:l];
    y += l.frame.size.height;

    NSObject *o = [d objectForKey:@"status"];
    if ([o isKindOfClass:[NSString class]] == YES) {
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        l.text = [NSString stringWithFormat:@"%@", o];
        [v addSubview:l];
        y += l.frame.size.height;
    }

    o = [d valueForKey:@"waypoints_found"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_found" with:o];
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        [l setText:[NSString stringWithFormat:@"Found: %@", o]];
        [v addSubview:l];
        y += l.frame.size.height;
    }

    o = [d valueForKey:@"waypoints_notfound"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_notfound" with:o];
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        [l setText:[NSString stringWithFormat:@"Not found: %@", o]];
        [v addSubview:l];
        y += l.frame.size.height;
    }

    o = [d valueForKey:@"waypoints_hidden"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"waypoints_hidden" with:o];
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        [l setText:[NSString stringWithFormat:@"Hidden: %@", o]];
        [v addSubview:l];
        y += l.frame.size.height;
    }

    o = [d valueForKey:@"recommendations_given"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_given" with:o];
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        [l setText:[NSString stringWithFormat:@"Recommendations given: %@", o]];
        [v addSubview:l];
        y += l.frame.size.height;
    }

    o = [d valueForKey:@"recommendations_received"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        [self updateTotal:@"recommendations_received" with:o];
        l = [[GCLabel alloc] initWithFrame:CGRectMake(width / 8, y, 7 * width / 8, labelHeight)];
        [l setText:[NSString stringWithFormat:@"Recommendations received: %@", o]];
        [v addSubview:l];
        y += l.frame.size.height;
    }

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

    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *d = [accountDictionaries objectAtIndex:idx];

        // If there is nothing, do not show.
        if (a.accountname == nil)
            return;

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
    [self showAccounts];
}

- (void)runStatistics:(dbAccount *)a
{
    NSDictionary *d = [a.remoteAPI UserStatistics];

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

    [self showAccounts];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuReload:
            [self loadStatistics];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

@end
