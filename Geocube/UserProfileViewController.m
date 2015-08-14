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
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = contentView;

    /*
    NSURL *baseURL = [NSURL URLWithString:@"https://staging.geocaching.com/"];
    NSString *OAUTH_CONSUMER_KEY = @"9C7552E1-3C04-4D04-A395-230D8931E494";
    NSString *OAUTH_CONSUMER_SECRET = @"DA7CC147-7B5B-4423-BCB4-D0C03E2BF685";
     */

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, 100, 40)];
    [label setText:@"Label created in ScrollerController.loadView"];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
