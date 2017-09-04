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

@interface GroupsTemplateViewController ()

@end

@implementation GroupsTemplateViewController

- (instancetype)init
{
    self = [super init];

    [self refreshGroupData];
    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- NEEDS_OVERLOADING_VOID(refreshGroupData)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cgs count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

    dbGroup *cg = [self.cgs objectAtIndex:indexPath.row];
    cell.textLabel.text = cg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld waypoints", (long)[cg countWaypoints]];
    cell.userInteractionEnabled = (self.showUsers == YES);

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    dbGroup *cg = [self.cgs objectAtIndex:indexPath.row];
    return cg.deletable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbGroup *cg = [self.cgs objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete && cg.deletable == YES) {
        [self groupDelete:cg forceReload:NO];
        [self refreshGroupData];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbGroup *cg = [self.cgs objectAtIndex:indexPath.row];

    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:cg.name
                               message:_(@"groupstemplateviewcontroller-Select your choice")
                               preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *empty = [UIAlertAction
                            actionWithTitle:_(@"Empty")
                            style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction * action)
                            {
                                //Do some thing here
                                [self groupEmpty:cg reload:YES];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];

    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:_(@"Rename")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupRename:cg];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:_(@"Delete")
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupDelete:cg forceReload:YES];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel")
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
    [self.cgs enumerateObjectsUsingBlock:^(dbGroup * _Nonnull cg, NSUInteger idx, BOOL * _Nonnull stop) {
        [self groupEmpty:cg reload:NO];
    }];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)groupEmpty:(dbGroup *)cg reload:(BOOL)reload
{
    [cg emptyGroup];
    [db cleanupAfterDelete];
    [waypointManager needsRefreshAll];
    if (reload == YES) {
        [self refreshGroupData];
        [self.tableView reloadData];
    }
}

- (void)groupDelete:(dbGroup *)cg forceReload:(BOOL)forceReload
{
    [cg dbDelete];
    [db cleanupAfterDelete];
    [waypointManager needsRefreshAll];
    [dbc Group_delete:cg];
    [self refreshGroupData];
    if (forceReload == YES)
        [self.tableView reloadData];
}

- (void)groupRename:(dbGroup *)cg
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"groupstemplateviewcontroller-Rename group")
                                message:[NSString stringWithFormat:_(@"groupstemplateviewcontroller-Rename %@ to"), cg.name]
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
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
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

- (void)newGroup
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"groupstemplateviewcontroller-Add a group")
                                message:_(@"groupstemplateviewcontroller-Name of the new group")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;
                             NSString *newgroup = tf.text;

                             NSLog(@"Creating new group '%@'", newgroup);
                             dbGroup *group = [[dbGroup alloc] init];
                             group.name = newgroup;
                             group.usergroup = YES;
                             group.deletable = YES;
                             [group dbCreate];
                             [dbc Group_add:group];
                             [self refreshGroupData];
                             [self.tableView reloadData];
                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"groupstemplateviewcontroller-Name of the new group");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

@end
