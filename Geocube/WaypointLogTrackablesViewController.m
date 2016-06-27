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

@interface WaypointLogTrackablesViewController ()
{
    dbWaypoint *waypoint;
    NSMutableArray *tbs;
    NSMutableArray *logtypes;
}

@end

@implementation WaypointLogTrackablesViewController

#define THISCELL @"WaypointLogTrackablesCell"

enum {
    menuPickup,
    menuDiscover,
    menuMax
};

- (instancetype)init:(dbWaypoint *)wp trackables:(NSMutableArray *)_tbs
{
    self = [super init];

    waypoint = wp;
    tbs = _tbs;
    logtypes = [NSMutableArray arrayWithCapacity:[tbs count]];

    [tbs enumerateObjectsUsingBlock:^(dbTrackable *tb, NSUInteger idx, BOOL * _Nonnull stop) {
        [logtypes addObject:[NSNumber numberWithInteger:tb.logtype]];
    }];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuPickup label:@"Pick up"];
    [lmi addItem:menuDiscover label:@"Discover"];

    hasCloseButton = YES;
    _delegate = nil;

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)willClosePage
{
    [logtypes enumerateObjectsUsingBlock:^(NSNumber *logtype, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger lt = [logtype integerValue];
        dbTrackable *tb = [tbs objectAtIndex:idx];
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

    [_delegate refreshTable];

    [super willClosePage];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [tbs count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellWithSubtitle *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];

    dbTrackable *tb = [tbs objectAtIndex:indexPath.row];
    NSInteger logtype = [[logtypes objectAtIndex:indexPath.row] integerValue];

    cell.textLabel.text = tb.name;
    cell.userInteractionEnabled = YES;
    cell.detailTextLabel.text = @"";
    switch (logtype) {
        case TRACKABLE_LOG_NONE:
            if (tb.logtype == TRACKABLE_LOG_NONE)
                cell.detailTextLabel.text = @"No action (automatic)";
            else
                cell.detailTextLabel.text = @"No action";
            break;
        case TRACKABLE_LOG_VISIT:
            if (tb.logtype == TRACKABLE_LOG_NONE)
                cell.detailTextLabel.text = @"Visited";
            else
                cell.detailTextLabel.text = @"Visited (automatic)";
            break;
        case TRACKABLE_LOG_DROPOFF:
            cell.detailTextLabel.text = @"Dropped off";
            break;
        case TRACKABLE_LOG_PICKUP:
            cell.detailTextLabel.text = @"Picked up";
            break;
        case TRACKABLE_LOG_DISCOVER:
            cell.detailTextLabel.text = @"Discovered";
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Trackable action"
                               message:@""
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noaction = [UIAlertAction
                               actionWithTitle:@"No action"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_NONE] atIndexedSubscript:indexPath.row];
                                   [self.tableView reloadData];
                               }];

    UIAlertAction *dropoff = [UIAlertAction
                              actionWithTitle:@"Dropped off"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_DROPOFF] atIndexedSubscript:indexPath.row];
                                  [self.tableView reloadData];
                              }];

    UIAlertAction *visited = [UIAlertAction
                              actionWithTitle:@"Visited"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *action) {
                                  [logtypes setObject:[NSNumber numberWithInteger:TRACKABLE_LOG_VISIT] atIndexedSubscript:indexPath.row];
                                  [self.tableView reloadData];
                              }];

    [alert addAction:noaction];
    [alert addAction:dropoff];
    [alert addAction:visited];

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
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Pick up a trackable"
                               message:@"Enter the code as found on the trackable"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Pick up"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             NSString *code = [alert.textFields objectAtIndex:0].text;
                             __block dbTrackable *tb = [dbTrackable dbGetByCode:code];
                             if (tb == nil) {
                                 [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
                                     if (a.protocol == ProtocolLiveAPI) {
                                         tb = [a.remoteAPI trackableFind:code];
                                         *stop = YES;
                                     }
                                 }];
                             }

                             if (tb == nil) {
                                 [MyTools messageBox:self header:@"Trackable not found" text:[NSString stringWithFormat:@"There was no travelbug found with the code '%@'", code]];
                                 return;
                             }

                             [tbs addObject:tb];
                             tb.logtype = TRACKABLE_LOG_PICKUP;
                             [logtypes addObject:[NSNumber numberWithInteger:TRACKABLE_LOG_PICKUP]];
                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Code";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)menuDiscover
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Discover a trackable"
                               message:@"Enter the code as found on the trackable"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Discover"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             NSString *code = [alert.textFields objectAtIndex:0].text;
                             __block dbTrackable *tb = [dbTrackable dbGetByCode:code];
                             if (tb == nil) {
                                 [dbc.Accounts enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
                                     if (a.protocol == ProtocolLiveAPI) {
                                         tb = [a.remoteAPI trackableFind:code];
                                         *stop = YES;
                                     }
                                 }];
                             }

                             if (tb == nil) {
                                 [MyTools messageBox:self header:@"Trackable not found" text:[NSString stringWithFormat:@"There was no travelbug found with the code '%@'", code]];
                                 return;
                             }

                             [tbs addObject:tb];
                             tb.logtype = TRACKABLE_LOG_DISCOVER;
                             [logtypes addObject:[NSNumber numberWithInteger:TRACKABLE_LOG_DISCOVER]];
                             [self.tableView reloadData];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Code";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

@end
