/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017, 2018 Edwin Groothuis
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

@interface TrackablesTemplateViewController ()

@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation TrackablesTemplateViewController

- NEEDS_OVERLOADING_VOID(remoteAPILoadTrackables:(dbAccount *)a infoItem:(InfoItem *)iid)
- NEEDS_OVERLOADING_VOID(loadTrackables)
- NEEDS_OVERLOADING_VOID(adjustMenus)

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
        if ([self.tbs count] != 0) {
            MAINQUEUE(
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            )
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_TRACKABLETABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_TRACKABLETABLEVIEWCELL];

    [self refreshTrackables:nil];

    [self makeInfoView];

    self.lmi = [[LocalMenuItems alloc] init:trackablesMenuMax];
    [self.lmi addItem:trackablesMenuUpdate label:_(@"trackablestemplateviewcontroller-Update List")];
    [self.lmi addItem:trackablesMenuDrop label:_(@"trackablestemplateviewcontroller-Drop trackable")];
    [self.lmi addItem:trackablesMenuGrab label:_(@"trackablestemplateviewcontroller-Grab trackable")];
    [self.lmi addItem:trackablesMenuDiscover label:_(@"trackablestemplateviewcontroller-Discover trackable")];
    [self adjustMenus];

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
    if (!IS_EMPTY(tb.tbcode) && !IS_EMPTY(tb.pin))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@ / %@"), tb.tbcode, tb.pin];
    if ( IS_EMPTY(tb.tbcode) && !IS_EMPTY(tb.pin))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@"), tb.pin];
    if (!IS_EMPTY(tb.tbcode) &&  IS_EMPTY(tb.pin))
        cell.code.text = [NSString stringWithFormat:_(@"trackablestemplateviewcontroller-Code: %@"), tb.tbcode];
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
    BACKGROUND(menuUpdate_BG, nil)
}

- (void)menuUpdate_BG
{
    [self showInfoView];
    InfoItem *iid = [self.infoView addDownload];
    [iid changeDescription:_(@"trackablestemplateviewcontroller-Download trackables information")];

    [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.remoteAPI.supportsTrackablesRetrieve == YES && a.canDoRemoteStuff == YES) {
            // Get rid of any old data
            [self.tbs enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
                tb.carrier = nil;
                tb.waypoint_name = nil;
                [tb dbUpdate];
            }];
            [self remoteAPILoadTrackables:a infoItem:iid];
            [self refreshTrackables:nil];
            [self reloadDataMainQueue];
            *stop = YES;
        }
    }];

    [iid removeFromInfoViewer];
    [self hideInfoView];
}

- (void)menuDiscover
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"trackablestemplateviewcontroller-Discover A Trackable")
                                message:_(@"trackablestemplateviewcontroller-Enter the code on the trackable")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;

                             __block BOOL tried = NO;
                             __block RemoteAPIResult rv;
                             __block NSString *error = nil;
                             [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
                                 if (a.remoteAPI.supportsTrackablesLog == NO || a.canDoRemoteStuff == NO)
                                     return;
                                 rv = [a.remoteAPI trackableDiscover:value infoItem:nil];
                                 tried = YES;
                                 *stop = YES;
                                 error = a.remoteAPI.lastError;
                             }];
                             if (tried == NO) {
                                 [MyTools messageBox:self header:_(@"Error") text:_(@"trackablestemplateviewcontroller-No capable Remote API has been found to log this trackable.")];
                                 return;
                             }
                             if (rv == REMOTEAPI_OK) {
                                 dbTrackable *t = [dbTrackable dbGetByPin:value];
                                 [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Discover trackable") text:[NSString stringWithFormat:_(@"trackablestemplateviewcontroller-The trackable '%@' has been logged as discovered."), t.name]];
                                 return;
                             }
                             [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Unable to log trackable") text:error];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addTextFieldWithConfigurationHandler:nil];

    [alert addAction:ok];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuGrab
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"trackablestemplateviewcontroller-Grab A Trackable")
                                message:_(@"trackablestemplateviewcontroller-Enter the code on the trackable")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;

                             __block BOOL tried = NO;
                             __block RemoteAPIResult rv;
                             __block NSString *error = nil;
                             [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
                                 if (a.remoteAPI.supportsTrackablesLog == NO || a.canDoRemoteStuff == NO)
                                     return;
                                 rv = [a.remoteAPI trackableGrab:value infoItem:nil];
                                 tried = YES;
                                 *stop = YES;
                                 error = a.remoteAPI.lastError;
                             }];
                             if (tried == NO) {
                                 [MyTools messageBox:self header:_(@"Error") text:_(@"trackablestemplateviewcontroller-No capable Remote API has been found to log this trackable.")];
                                 return;
                             }
                             if (rv == REMOTEAPI_OK) {
                                 dbTrackable *t = [dbTrackable dbGetByPin:value];
                                 [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Grab trackable") text:[NSString stringWithFormat:_(@"trackablestemplateviewcontroller-The trackable '%@' has been logged as grabbed."), t.name]];
                                 [self menuUpdate];
                                 return;
                             }
                             [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Unable to log trackable") text:error];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addTextFieldWithConfigurationHandler:nil];

    [alert addAction:ok];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuDrop
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"trackablestemplateviewcontroller-Discover A Trackable")
                                message:_(@"trackablestemplateviewcontroller-Enter the TBxxx code on the trackable")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *value = tf.text;
                             tf = [alert.textFields objectAtIndex:1];
                             NSString *wptname = tf.text;

                             dbTrackable *tb = [dbTrackable dbGetByTBCode:value];

                             __block BOOL tried = NO;
                             __block RemoteAPIResult rv;
                             __block NSString *error = nil;
                             [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
                                 if (a.remoteAPI.supportsTrackablesLog == NO || a.canDoRemoteStuff == NO)
                                     return;
                                 rv = [a.remoteAPI trackableDrop:tb waypoint:wptname infoItem:0];
                                 tried = YES;
                                 *stop = YES;
                                 error = a.remoteAPI.lastError;
                             }];
                             if (tried == NO) {
                                 [MyTools messageBox:self header:_(@"Error") text:_(@"trackablestemplateviewcontroller-No capable Remote API has been found to log this trackable.")];
                                 return;
                             }
                             if (rv == REMOTEAPI_OK) {
                                 [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Drop trackable") text:[NSString stringWithFormat:_(@"trackablestemplateviewcontroller-The trackable '%@' has been logged as dropped."), tb.name]];
                                 [self menuUpdate];
                                 return;
                             }
                             [MyTools messageBox:self header:_(@"trackablestemplateviewcontroller-Unable to log trackable") text:error];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = @"";
        textField.placeholder = _(@"trackablestemplateviewcontroller-Trackable code");
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = @"";
        textField.placeholder = _(@"trackablestemplateviewcontroller-Waypoint code");
    }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case trackablesMenuUpdate:
            [self menuUpdate];
            return;
        case trackablesMenuDiscover:
            [self menuDiscover];
            return;
        case trackablesMenuGrab:
            [self menuGrab];
            return;
        case trackablesMenuDrop:
            [self menuDrop];
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
