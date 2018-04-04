/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2016, 2017, 2018 Edwin Groothuis
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

@interface WaypointLogTrackablesViewController ()

@property (nonatomic, retain) dbWaypoint *waypoint;
@property (nonatomic, retain) NSMutableArray<dbTrackable *> *tbs;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *logtypes;

@end

@implementation WaypointLogTrackablesViewController

enum {
    menuPickup,
    menuDiscover,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp trackables:(NSMutableArray<dbTrackable *> *)tbs
{
    self = [super init];

    self.waypoint = wp;
    self.tbs = tbs;
    self.logtypes = [NSMutableArray arrayWithCapacity:[self.tbs count]];

    [self.tbs enumerateObjectsUsingBlock:^(dbTrackable * _Nonnull tb, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.logtypes addObject:[NSNumber numberWithInteger:tb.logtype]];
    }];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuPickup label:_(@"waypointlogtrackablesviewcontroller-Pickup")];
    [self.lmi addItem:menuDiscover label:_(@"waypointlogtrackablesviewcontroller-Discover")];

    self.hasCloseButton = YES;
    _delegate = nil;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    return self;
}

- (void)willClosePage
{
    [self.logtypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull logtype, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger lt = [logtype integerValue];
        dbTrackable *tb = [self.tbs objectAtIndex:idx];
        if (lt == TRACKABLE_LOG_VISIT && tb.logtype != TRACKABLE_LOG_VISIT) {
            tb.logtype = lt;
            [tb dbUpdate];
            return;
        }
        if (lt == TRACKABLE_LOG_NONE && tb.logtype != TRACKABLE_LOG_NONE) {
            tb.logtype = lt;
            [tb dbUpdate];
            return;
        }
        tb.logtype = lt;
    }];

    [_delegate waypointLogTrackablesRefreshTable];

    [super willClosePage];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tbs count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    dbTrackable *tb = [self.tbs objectAtIndex:indexPath.row];
    NSInteger logtype = [[self.logtypes objectAtIndex:indexPath.row] integerValue];

    cell.textLabel.text = tb.name;
    cell.userInteractionEnabled = YES;
    cell.detailTextLabel.text = @"";
    switch (logtype) {
        case TRACKABLE_LOG_NONE:
            if (tb.logtype == TRACKABLE_LOG_NONE)
                cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-No action (automatic)");
            else
                cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-No action");
            break;
        case TRACKABLE_LOG_VISIT:
            if (tb.logtype == TRACKABLE_LOG_NONE)
                cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-Visited");
            else
                cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-Visited (automatic)");
            break;
        case TRACKABLE_LOG_DROPOFF:
            cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-Dropped off");
            break;
        case TRACKABLE_LOG_PICKUP:
            cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-Picked up");
            break;
        case TRACKABLE_LOG_DISCOVER:
            cell.detailTextLabel.text = _(@"waypointlogtrackablesviewcontroller-Discovered");
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbTrackable *tb = [self.tbs objectAtIndex:indexPath.row];

    if (tb.logtype == TRACKABLE_LOG_PICKUP) {
        [self trackableContainerAction:tb indexPath:indexPath];
    } else if (tb.logtype == TRACKABLE_LOG_DISCOVER) {
        [self trackableContainerAction:tb indexPath:indexPath];
    } else {
        [self trackableCarrierAction:tb indexPath:indexPath];
    }
}

- (void)trackableContainerAction:(dbTrackable *)tb indexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointlogtrackablesviewcontroller-Trackable action")
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ignore = [UIAlertAction
                               actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Ignore")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_NONE] atIndexedSubscript:indexPath.row];
                                   [self.tableView reloadData];
                               }];

    UIAlertAction *pickup = [UIAlertAction
                             actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Pick up")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_PICKUP] atIndexedSubscript:indexPath.row];
                                 [self.tableView reloadData];
                             }];

    UIAlertAction *discovered = [UIAlertAction
                                 actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Discovered")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *action) {
                                     [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_DISCOVER] atIndexedSubscript:indexPath.row];
                                     [self.tableView reloadData];
                                 }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) {
                                 [self.tableView reloadData];
                             }];

    [alert addAction:pickup];
    [alert addAction:discovered];
    [alert addAction:ignore];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)trackableCarrierAction:(dbTrackable *)tb indexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointlogtrackablesviewcontroller-Trackable action")
                                message:@""
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noaction = [UIAlertAction
                               actionWithTitle:_(@"waypointlogtrackablesviewcontroller-No action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_NONE] atIndexedSubscript:indexPath.row];
                                   [self.tableView reloadData];
                               }];

    UIAlertAction *dropoff = [UIAlertAction
                              actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Dropped off")
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_DROPOFF] atIndexedSubscript:indexPath.row];
                                  [self.tableView reloadData];
                              }];

    UIAlertAction *visited = [UIAlertAction
                              actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Visited")
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [self.logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_VISIT] atIndexedSubscript:indexPath.row];
                                  [self.tableView reloadData];
                              }];

    UIAlertAction *cancel = [UIAlertAction
                              actionWithTitle:_(@"Cancel")
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction *action) {
                                  [self.tableView reloadData];
                              }];

    [alert addAction:dropoff];
    [alert addAction:visited];
    [alert addAction:noaction];
    [alert addAction:cancel];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuPickup:
            [self menuPickup];
            return;
        case menuDiscover:
            [self menuDiscover];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)menuPickup
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointlogtrackablesviewcontroller-Pick up a trackable")
                                message:_(@"waypointlogtrackablesviewcontroller-Enter the code as found on the trackable")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Pick up")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             NSString *pin = [alert.textFields objectAtIndex:0].text;
                             __block dbTrackable *tb = [dbTrackable dbGetByPin:pin];
                             if (tb == nil) {
                                 [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
                                     if (a.remoteAPI.supportsTrackablesRetrieve == YES) {
                                         [a.remoteAPI trackableFind:pin trackable:&tb infoItem:nil];
                                         *stop = YES;
                                     }
                                 }];
                             }

                             if (tb == nil) {
                                 [MyTools messageBox:self header:_(@"waypointlogtrackablesviewcontroller-Trackable not found") text:[NSString stringWithFormat:_(@"waypointlogtrackablesviewcontroller-There was no trackable found with the pin '%@'"), pin]];
                                 return;
                             }

                             [self.tbs addObject:tb];
                             tb.logtype = TRACKABLE_LOG_PICKUP;
                             [self.logtypes addObject:[NSNumber numberWithInteger:TRACKABLE_LOG_PICKUP]];
                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointlogtrackablesviewcontroller-Code");
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuDiscover
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"waypointlogtrackablesviewcontroller-Discover a trackable")
                                message:_(@"waypointlogtrackablesviewcontroller-Enter the code as found on the trackable")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"waypointlogtrackablesviewcontroller-Discover")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             NSString *pin = [alert.textFields objectAtIndex:0].text;
                             __block dbTrackable *tb = [dbTrackable dbGetByPin:pin];
                             if (tb == nil) {
                                 [dbc.accounts enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
                                     if (a.remoteAPI.supportsTrackablesRetrieve == YES && a.canDoRemoteStuff == YES) {
                                         [a.remoteAPI trackableFind:pin trackable:&tb infoItem:nil];
                                         *stop = YES;
                                     }
                                 }];
                             }

                             if (tb == nil) {
                                 [MyTools messageBox:self header:_(@"waypointlogtrackablesviewcontroller-Trackable not found") text:[NSString stringWithFormat:_(@"waypointlogtrackablesviewcontroller-There was no trackable found with the pin '%@'"), pin]];
                                 return;
                             }

                             [self.tbs addObject:tb];
                             tb.logtype = TRACKABLE_LOG_DISCOVER;
                             [self.logtypes addObject:[NSNumber numberWithInteger:TRACKABLE_LOG_DISCOVER]];
                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"waypointlogtrackablesviewcontroller-Code");
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

@end
