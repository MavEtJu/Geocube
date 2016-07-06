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

@interface ListViewController ()

@end

@implementation ListViewController

enum {
    menuClearFlags,
    menuReloadWaypoints,
    menuExportGPX,
    menuMax
};

#define THISCELL @"CacheTableViewCell"

NEEDS_OVERLOADING(clearFlags)

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuClearFlags label:@"Clear list"];
    [lmi addItem:menuReloadWaypoints label:@"Reload Waypoints"];
    [lmi addItem:menuExportGPX label:@"Export GPX"];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[WaypointTableViewCell class] forCellReuseIdentifier:THISCELL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    waypoints = [dbWaypoint dbAllByFlag:flag];
    [self.tableView reloadData];

    if ([waypoints count] == 0)
        [lmi disableItem:menuExportGPX];
    else
        [lmi enableItem:menuExportGPX];
}

#pragma mark - TableViewController related functions

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (waypoints == nil)
        return @"";
    NSInteger c = [waypoints count];
    return [NSString stringWithFormat:@"%ld waypoint%@", (unsigned long)c, c == 1 ? @"" : @"s"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [waypoints count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WaypointTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    cell.description.text = wp.wpt_urlname;
    cell.name.text = wp.wpt_name;
    cell.icon.image = [imageLibrary getType:wp];
    if (wp.flag_highlight == YES)
        cell.description.backgroundColor = [UIColor yellowColor];
    else
        cell.description.backgroundColor = [UIColor clearColor];

    [cell setRatings:wp.gs_favourites terrain:wp.gs_rating_terrain difficulty:wp.gs_rating_difficulty size:wp.gs_container.icon];

    NSInteger bearing = [Coordinates coordinates2bearing:LM.coords to:wp.coordinates];
    cell.bearing.text = [NSString stringWithFormat:@"%ld°", (long)bearing];
    cell.compass.text = [Coordinates bearing2compass:bearing];
    cell.distance.text = [MyTools niceDistance:[Coordinates coordinates2distance:LM.coords to:wp.coordinates]];

    NSMutableString *s = [NSMutableString stringWithFormat:@""];
    if (wp.gs_state != nil) {
        [s appendFormat:@"%@", myConfig.showStateAsAbbrevation == YES ? wp.gs_state.code : wp.gs_state.name];
    }
    if (wp.gs_country != nil) {
        if ([s isEqualToString:@""] == NO)
            [s appendFormat:@", "];
        [s appendFormat:@"%@", myConfig.showCountryAsAbbrevation == YES ? wp.gs_country.code : wp.gs_country.name];
    }
    cell.stateCountry.text = s;

    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [WaypointTableViewCell cellHeight];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbWaypoint *wp = [waypoints objectAtIndex:indexPath.row];
    NSString *newTitle = wp.description;

    WaypointViewController *newController = [[WaypointViewController alloc] initWithStyle:UITableViewStyleGrouped canBeClosed:YES];
    [newController showWaypoint:wp];
    newController.edgesForExtendedLayout = UIRectEdgeNone;
    newController.title = newTitle;
    [self.navigationController pushViewController:newController animated:YES];
}

#pragma mark - Local menu related functions

- (void)menuClearFlags
{
    [self clearFlags];
    waypoints = @[];
    [self.tableView reloadData];
    [waypointManager needsRefresh];
}

- (void)menuReloadWaypoints
{
    [self performSelectorInBackground:@selector(runReloadWaypoints) withObject:nil];
}

- (void)runReloadWaypoints
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView activityViewForView:self.view withLabel:[NSString stringWithFormat:@"Reloading waypoints\n0 / %ld", (unsigned long)[waypoints count]]];
    }];

    __block BOOL failure = NO;
    [waypoints enumerateObjectsUsingBlock:^(dbWaypoint *wp, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [DejalBezelActivityView currentActivityView].activityLabel.text = [NSString stringWithFormat:@"Reloading waypoints\n%ld / %ld", (long)(idx + 1), (long)[waypoints count]];
        }];
        if ([wp.account.remoteAPI loadWaypoint:wp] == NO) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MyTools messageBox:self header:@"Reload waypoints" text:@"Update failed" error:wp.account.lastError];
                failure = YES;
            }];
            *stop = YES;
        }
    }];

    waypoints = [dbWaypoint dbAllByFlag:flag];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [DejalBezelActivityView removeViewAnimated:NO];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [waypointManager needsRefresh];

    if (failure == NO)
        [MyTools playSound:playSoundImportComplete];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuClearFlags:
            [self menuClearFlags];
            return;
        case menuReloadWaypoints:
            [self menuReloadWaypoints];
            return;
        case menuExportGPX:
            [ExportGPX exports:waypoints];
            [MyTools messageBox:self header:@"Export successful" text:@"The exported file can be found in the Files section"];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
