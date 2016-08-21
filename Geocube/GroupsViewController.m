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

@interface GroupsViewController ()
{
    NSInteger cgCount;
    NSArray *cgs;
    BOOL showUsers;
}

@end

#define THISCELL @"GroupsViewControllerCell"

@implementation GroupsViewController

enum {
    menuEmptyGroups = 0,
    menuAddAGroup,
    menuMax
};

- (instancetype)init:(BOOL)_showUsers
{
    self = [super init];
    showUsers = _showUsers;

    [self refreshGroupData];

    // Local menu
    if (showUsers == YES) {
        lmi = [[LocalMenuItems alloc] init:menuMax];
        [lmi addItem:menuEmptyGroups label:@"Empty groups"];
        [lmi addItem:menuAddAGroup label:@"Add a group"];
    } else
        lmi = nil;

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)refreshGroupData
{
    NSMutableArray *ws = [[NSMutableArray alloc] initWithCapacity:20];

    [dbc.Groups enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        if (cg.usergroup == showUsers)
            [ws addObject:cg];
    }];
    cgs = ws;
    cgCount = [cgs count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return cgCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbGroup *cg = [cgs objectAtIndex:indexPath.row];
    cell.textLabel.text = cg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld waypoints", (long)[cg dbCountWaypoints]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbGroup *cg = [cgs objectAtIndex:indexPath.row];
    return cg.deletable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbGroup *cg = [cgs objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete && cg.deletable == YES) {
        [self groupDelete:cg];
        [self refreshGroupData];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showUsers == NO) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    dbGroup *cg = [cgs objectAtIndex:indexPath.row];

    UIAlertController *view=   [UIAlertController
                                alertControllerWithTitle:cg.name
                                message:@"Select you choice"
                                preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *empty = [UIAlertAction
                            actionWithTitle:@"Empty"
                            style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction * action)
                            {
                                //Do some thing here
                                [self groupEmpty:cg reload:YES];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];

    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:@"Rename"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupRename:cg];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupDelete:cg];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    // Set close to the text beginning
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    CGRect rectToUse = cell.bounds;
    rectToUse.origin.x = rectToUse.size.width - 200;
    rectToUse.origin.x = 100;
    rectToUse.size.width -= rectToUse.origin.x;
    rectToUse.size.width = 100;

    UIPopoverPresentationController *popPresenter = [view popoverPresentationController];
    popPresenter.sourceView = [aTableView cellForRowAtIndexPath:indexPath];
    popPresenter.sourceRect = rectToUse;

    [view addAction:empty];
    if (cg.deletable == YES) {
        [view addAction:rename];
        [view addAction:delete];
    }
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)emptyGroups
{
    [cgs enumerateObjectsUsingBlock:^(dbGroup *cg, NSUInteger idx, BOOL *stop) {
        [self groupEmpty:cg reload:NO];
    }];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)groupEmpty:(dbGroup *)cg reload:(BOOL)reload
{
    [cg dbEmpty];
    [db cleanupAfterDelete];
    [waypointManager needsRefresh];
    if (reload == YES) {
        [self refreshGroupData];
        [self.tableView reloadData];
    }
}

- (void)groupDelete:(dbGroup *)cg
{
    [cg dbDelete];
    [db cleanupAfterDelete];
    [waypointManager needsRefresh];
    [dbc Group_delete:cg];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)groupRename:(dbGroup *)cg
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Rename group"
                               message:[NSString stringWithFormat:@"Rename %@ to", cg.name]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;

                             NSLog(@"Renaming group '%ld' to '%@'", (long)cg._id, tf.text);
                             [cg dbUpdateName:tf.text];
                             cg.name = tf.text;
                             [self refreshGroupData];
                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = cg.name;
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    // Add a group
    if (showUsers == YES) {
        switch (index) {
            case menuEmptyGroups:
                [self emptyGroups];
                return;
            case menuAddAGroup:
                [self newGroup];
                return;
        }
    } else {
        if (index == 0) {
            [self emptyGroups];
            return;
        }
    }

    [super performLocalMenuAction:index];
}

- (void)newGroup
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Add a group"
                               message:@"Name of the new group"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *newgroup = tf.text;

                             NSLog(@"Creating new group '%@'", newgroup);
                             NSId gid = [dbGroup dbCreate:newgroup isUser:YES];
                             dbGroup *group = [dbGroup dbGet:gid];
                             [dbc Group_add:group];
                             [self refreshGroupData];
                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name of the new group";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

@end
