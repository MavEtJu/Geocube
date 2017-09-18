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

#import "TrackablesTemplateViewController.h"

#import "NetworkLibrary/RemoteAPITemplate.h"

@interface TrackablesTemplateViewController ()

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation TrackablesTemplateViewController

enum {
    menuUpdate = 0,
    menuMax,
};

- NEEDS_OVERLOADING_VOID(remoteAPILoadTrackables:(dbAccount *)a infoView:(InfoViewer *)iv infoItemID:(InfoItemID)iid)
- NEEDS_OVERLOADING_VOID(loadTrackables)

- (void)refreshTrackables:(NSString *)searchString
{
    [self loadTrackables];
    if (searchString != nil) {
        searchString = [searchString lowercaseString];
        NSMutableArray<dbTrackable *> *tbs = [NSMutableArray arrayWithCapacity:[self.tbs count]];
        [self.tbs enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull t, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[t.name lowercaseString] containsString:searchString] == NO)
                return;
            [tbs addObject:t];
        }];
        self.tbs = tbs;
    } else {
        // Hide the search window by default
        MAINQUEUE(
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        )
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_TRACKABLETABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_TRACKABLETABLEVIEWCELL];

    [self refreshTrackables:nil];

    [self makeInfoView];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUpdate label:_(@"trackablestemplateviewcontroller-Update")];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;

    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.edgesForExtendedLayout = UIRectEdgeNone;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
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

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tbs count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackableTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_TRACKABLETABLEVIEWCELL forIndexPath:indexPath];

    dbTrackable *tb = [self.tbs objectAtIndex:indexPath.row];

    cell.name.text = nil;
    cell.code.text = nil;
    cell.carrier.text = nil;
    cell.waypoint.text = nil;
    cell.owner.text = nil;

    cell.name.text = tb.name;
    if (!IS_EMPTY(tb.ref) && !IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@ / %@"), tb.ref, tb.code];
    if ( IS_EMPTY(tb.ref) && !IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@"), tb.code];
    if (!IS_EMPTY(tb.ref) &&  IS_EMPTY(tb.code))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@"), tb.ref];
    if (tb.carrier != nil)
        cell.carrier.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Carried by %@"), tb.carrier.name];
    if (!IS_EMPTY(tb.waypoint_name))
        cell.waypoint.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Stored in %@"), tb.waypoint_name];
    if (tb.owner != nil)
        cell.owner.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Owned by %@"), tb.owner.name];

    cell.userInteractionEnabled = NO;

    return cell;
}

#pragma mark - Local menu related functions

- (void)menuUpdate
{
    [self showInfoView];
    InfoItemID iid = [infoView addDownload];
    [infoView setDescription:iid description:_(@"trackablestemplateviewcontroller-Download trackables information")];

    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.remoteAPI.supportsTrackables == YES && a.canDoRemoteStuff == YES) {
            // Get rid of any old data
            [self.tbs enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
                tb.carrier = nil;
                tb.waypoint_name = nil;
                [tb dbUpdate];
            }];
            [self remoteAPILoadTrackables:a infoView:infoView infoItemID:iid];
            [self refreshTrackables:nil];
            [self reloadDataMainQueue];
            *stop = YES;
        }
    }];

    [infoView removeItem:iid];
    [self hideInfoView];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuUpdate:
            BACKGROUND(menuUpdate, nil);
            return;
    }

    [super performLocalMenuAction:index];
}

#pragma mark - SearchBar related functions

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if ([searchString isEqualToString:@""] == YES)
        searchString = nil;
    [self refreshTrackables:searchString];
    //    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

@end
