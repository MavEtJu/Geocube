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

    menuItems = [NSMutableArray arrayWithArray:@[@"XNothing"]];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    NSInteger width = applicationFrame.size.width;
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;
    __block NSInteger y = 10;

    [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL *stop) {

        if (a.account == nil || [a.account length] == 0)
            return;

        UILabel *l;

        l = [[UILabel alloc] initWithFrame:CGRectMake(10, y, width - 20, 15)];
        [l setText:a.site];
        l.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:l];

        NSDictionary *d = [a.remoteAPI UserStatistics];

        l = [[UILabel alloc] initWithFrame:CGRectMake(width / 4 * 3, y, width / 4, 15)];
        [l setText:[NSString stringWithFormat:@"%@ %@", [d valueForKey:@"waypoints_found"], [d valueForKey:@"waypoints_notfound"]]];
        l.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:l];

        y += 15;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
