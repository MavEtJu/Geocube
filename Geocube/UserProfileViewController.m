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

@implementation UserProfileViewController

- (id)init
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"Reload"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    contentView = [[UIScrollView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    [self loadStatistics];
}

- (void)loadStatistics
{
    for (UIView *subview in contentView.subviews) {
        [subview removeFromSuperview];
    }

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    __block NSInteger y = 10;

    totalFound = 0;
    totalDNF = 0;
    totalHidden = 0;
    totalRecommendationsGiven = 0;
    totalRecommendationsReceived = 0;

    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {

        if (a.accountname == nil || [a.accountname length] == 0)
            return;

        UILabel *l;

        /* Site name */
        l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 15)];
        [l setText:a.site];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        y += 15;

        if (a.canDoRemoteStuff == NO) {
            l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 0)];
            [l setText:@"Remote API is not available for this account, please check the settings."];
            l.font = [UIFont systemFontOfSize:14];
            l.numberOfLines = 0;
            [l sizeToFit];
            [contentView addSubview:l];
            y += l.frame.size.height;
            return;
        }

        NSDictionary *d = [a.remoteAPI UserStatistics];
        [self showStatistics:d y:&y width:width];
    }];

    /* Total */
    y += 10;
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 15)];
    [l setText:@"Total"];
    l.font = [UIFont systemFontOfSize:14];
    [contentView addSubview:l];
    y += 15;

    NSDictionary *totals = [NSDictionary dictionaryWithObjects:@[
         [NSNumber numberWithInteger:totalFound],
         [NSNumber numberWithInteger:totalDNF],
         [NSNumber numberWithInteger:totalHidden],
         [NSNumber numberWithInteger:totalRecommendationsGiven],
         [NSNumber numberWithInteger:totalRecommendationsReceived]
        ] forKeys:@[
          @"waypoints_found",
          @"waypoints_notfound",
          @"waypoints_hidden",
          @"recommendations_given",
          @"recommendations_received"
        ]
    ];

    [self showStatistics:totals y:&y width:width];
    [contentView setContentSize:CGSizeMake(width, y)];
}

- (void)showStatistics:(NSDictionary *)d y:(NSInteger *)y width:(NSInteger)width
{
    NSObject *o;
    NSNumber *n;
    UILabel *l;

    o = [d valueForKey:@"waypoints_found"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        n = (NSNumber *)o; totalFound += [n integerValue];
        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4, *y, 3 * width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"Found: %@", o]];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        *y += 15;
    }

    o = [d valueForKey:@"waypoints_notfound"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        n = (NSNumber *)o; totalDNF += [n integerValue];
        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4, *y, 3 * width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"Not found: %@", o]];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        *y += 15;
    }

    o = [d valueForKey:@"waypoints_hidden"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        n = (NSNumber *)o; totalHidden += [n integerValue];
        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4, *y, 3 * width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"Hidden: %@", o]];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        *y += 15;
    }

    o = [d valueForKey:@"recommendations_given"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        n = (NSNumber *)o; totalRecommendationsGiven += [n integerValue];
        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4, *y, 3 * width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"Recommendations given: %@", o]];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        *y += 15;
    }

    o = [d valueForKey:@"recommendations_received"];
    if ([o isKindOfClass:[NSNumber class]] == YES) {
        n = (NSNumber *)o; totalRecommendationsReceived += [n integerValue];
        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4, *y, 3 * width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"Recommendations received: %@", o]];
        l.font = [UIFont systemFontOfSize:14];
        [contentView addSubview:l];
        *y += 15;
    }

}


#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    if (index == 0) {      // Reload
        [self loadStatistics];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}


@end
