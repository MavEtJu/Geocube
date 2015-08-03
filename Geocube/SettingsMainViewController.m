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
    return 2;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)   // Distance section
        return 1;

    if (section == 1)   // Theme section
        return 1;

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    /* Metric section */
    switch (section) {
        case 0:
            return @"Distances";
        case 1:
            return @"Theme";
    }

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
                case 0: {   // Metric
                    cell.textLabel.text = @"Metric";
                    cell.textLabel.backgroundColor = [UIColor clearColor];

                    distanceMetric = [[UISwitch alloc] initWithFrame:CGRectZero];
                    distanceMetric.on = myConfig.distanceMetric;
                    [distanceMetric addTarget:self action:@selector(updateDistanceMetric:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = distanceMetric;

                    CAGradientLayer *gradient = [CAGradientLayer layer];
                    gradient.frame = cell.bounds;
                    gradient.colors = [NSArray arrayWithObjects:
                        (id)[[UIColor colorWithRed:232/255.0 green:223/255.0 blue:175/255.0 alpha:1] CGColor],
                        (id)[[UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1] CGColor],
                        nil];
                    [cell.layer insertSublayer:gradient atIndex:0];
                    
                    return cell;
                }
            }
            break;
        }
        case 1: {   // Theme
            switch (indexPath.row) {
                case 0: {   // Geosphere theme
                    cell.textLabel.text = @"Geosphere";
                    cell.textLabel.backgroundColor = [UIColor clearColor];

                    themeGeosphere = [[UISwitch alloc] initWithFrame:CGRectZero];
                    themeGeosphere.on = myConfig.themeGeosphere;
                    [themeGeosphere addTarget:self action:@selector(updateThemeGeosphere:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = themeGeosphere;

                    CAGradientLayer *gradient = [CAGradientLayer layer];
                    gradient.frame = cell.bounds;
                    gradient.colors = [NSArray arrayWithObjects:
                        (id)[[UIColor colorWithRed:232/255.0 green:223/255.0 blue:175/255.0 alpha:1] CGColor],
                        (id)[[UIColor colorWithRed:245/255.0 green:240/255.0 blue:218/255.0 alpha:1] CGColor],
                        nil];
                    [cell.layer insertSublayer:gradient atIndex:0];
                    
                    return cell;
                }
            }
            break;
        }
    }

    return nil;
}

- (void)updateDistanceMetric:(UISwitch *)s
{
    [myConfig distanceMetricUpdate:s.on];
}

- (void)updateThemeGeosphere:(UISwitch *)s
{
    [myConfig themeGeosphereUpdate:s.on];
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
