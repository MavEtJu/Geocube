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

@interface SettingsColoursViewController ()
{
    NSMutableArray *types;
}

@end

@implementation SettingsColoursViewController

#define THISCELL @"SettingsColoursViewControllerCell"

enum {
    menuReset,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];

    LocalMenuItems *lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuReset label:@"Reset"];
    menuItems = [lmi makeMenu];

    types = [NSMutableArray arrayWithArray:[dbc Types]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [types count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    dbType *t = [types objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", t.type_major, t.type_minor];
    cell.imageView.image = [imageLibrary get:t.pin];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbType *t = [types objectAtIndex:indexPath.row];

    UIViewController *newController = [[SettingsColourViewController alloc] init:t];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    switch (index) {
        case menuReset: // Reset
            [self resetPinColours];
            return;
    }

    [super didSelectedMenu:menu atIndex:index];
}

- (void)resetPinColours
{
    [[dbc Types] enumerateObjectsUsingBlock:^(dbType *t, NSUInteger idx, BOOL * _Nonnull stop) {
        t.pin_rgb = @"";
        [t dbUpdatePin];
        [t finish];

        float r, g, b;
        [ImageLibrary RGBtoFloat:t.pin_rgb_default r:&r g:&g b:&b];
        UIColor *pinColour = [UIColor colorWithRed:r green:g blue:b alpha:1];

        [imageLibrary recreatePin:t.pin color:pinColour];
    }];
    [self.tableView reloadData];
}


@end
