//
//  SettingMainViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 3/08/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL @"SettingsMainViewControllerCell"

@implementation SettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
    menuItems = [NSMutableArray arrayWithArray:@[@"XReset to default"]];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    /* Metric section */
    if (section == 0)
        return 1;

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Metric section */
    if (section == 0)
        return @"Distances";

    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    switch (indexPath.section) {
        case 0: {   // Distance
            switch (indexPath.row) {
                case 0: { // Metric
                    cell.textLabel.text = @"Metric";
                    distanceMetric = [[UISwitch alloc] initWithFrame:CGRectZero];
                    distanceMetric.on = myConfig.distanceMetric;
                    [distanceMetric addTarget:self action:@selector(updateDistanceMetric:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = distanceMetric;
                    break;
                }
            }
            break;
        }
    }

    return cell;
}

- (void)updateDistanceMetric:(UISwitch *)s
{
    [myConfig metricUpdate:s.on];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    if (index == 0) {
        [self resetValues];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)resetValues
{
}

@end
