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

@interface SettingsColoursViewController ()
{
    NSMutableArray<dbPin *> *pins;
}

@end

@implementation SettingsColoursViewController

enum {
    menuReset,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuReset label:_(@"settingscoloursviewcontroller-Reset")];

    pins = [NSMutableArray arrayWithArray:dbc.pins];
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
    return [pins count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];

    dbPin *p = [pins objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"pin-%@", p.desc];
    cell.textLabel.text = _(cell.textLabel.text);
    cell.imageView.image = p.img;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbPin *p = [pins objectAtIndex:indexPath.row];

    UIViewController *newController = [[SettingsColourViewController alloc] init:p];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:newController animated:YES];
    return;
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuReset: // Reset
            [self resetPinColours];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)resetPinColours
{
    [dbc.pins enumerateObjectsUsingBlock:^(dbPin * _Nonnull p, NSUInteger idx, BOOL * _Nonnull stop) {
        p.rgb = @"";
        [p dbUpdateRGB];
        [p finish];
    }];
    [self.tableView reloadData];
}

@end
