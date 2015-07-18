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
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "Geocube-Prefix.pch"

#define THISCELL @"GroupsViewControllerCell"

@implementation GroupsViewController

- (id)init:(BOOL)_showUsers
{
    self = [super init];
    showUsers = _showUsers;

    [self refreshGroupData];

    // Local menu
    if (showUsers == YES)
        menuItems = [NSMutableArray arrayWithArray:@[@"Empty groups", @"Add a group"]];
    else
        menuItems = nil;

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshGroupData];
    [self.tableView reloadData];

    if (showUsers == YES)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)refreshGroupData
{
    NSMutableArray *ws = [[NSMutableArray alloc] initWithCapacity:20];
    NSEnumerator *e = [dbc.CacheGroups objectEnumerator];
    dbCacheGroup *wpg;

    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == showUsers)
            [ws addObject:wpg];
    }
    wpgs = ws;
    wpgCount = [wpgs count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return wpgCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    cell = [cell initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    dbCacheGroup *wpg = [wpgs objectAtIndex:indexPath.row];
    cell.textLabel.text = wpg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld caches", [db CacheGroups_count_caches:wpg._id]];

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showUsers == NO) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    dbCacheGroup *wpg = [wpgs objectAtIndex:indexPath.row];

    UIAlertController *view=   [UIAlertController
                                alertControllerWithTitle:wpg.name
                                message:@"Select you choice"
                                preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *empty = [UIAlertAction
                            actionWithTitle:@"Empty"
                            style:UIAlertActionStyleDestructive
                            handler:^(UIAlertAction * action)
                            {
                                //Do some thing here
                                [self groupEmpty:wpg reload:YES];
                                [view dismissViewControllerAnimated:YES completion:nil];
                            }];

    UIAlertAction *rename = [UIAlertAction
                             actionWithTitle:@"Rename"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupRename:wpg];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 //Do some thing here
                                 [self groupDelete:wpg];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    [view addAction:empty];
    [view addAction:rename];
    [view addAction:delete];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)emptyGroups
{
    NSEnumerator *e = [wpgs objectEnumerator];
    dbCacheGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        [self groupEmpty:wpg reload:NO];
    }
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)groupEmpty:(dbCacheGroup *)wpg reload:(BOOL)reload
{
    [db CacheGroups_empty:wpg._id];
    [dbc loadCacheData];
    if (reload == YES) {
        [self refreshGroupData];
        [self.tableView reloadData];
    }
}

- (void)groupDelete:(dbCacheGroup *)wpg
{
    [db CacheGroups_delete:wpg._id];
    [dbc loadCacheData];
    [self refreshGroupData];
    [self.tableView reloadData];
}

- (void)groupRename:(dbCacheGroup *)wpg
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Rename group"
                               message:[NSString stringWithFormat:@"Rename %@ to", wpg.name]
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = alert.textFields.firstObject;

                             NSLog(@"Renaming group '%ld' to '%@'", wpg._id, tf.text);
                             [db CacheGroups_rename:wpg._id newName:tf.text];
                             [dbc loadCacheData];
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
        textField.placeholder = wpg.name;
    }];

    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index {
    if (menu != self.tab_menu) {
        [menuGlobal didSelectedMenu:menu atIndex:index];
        return;
    }

    // Add a group
    if (showUsers == YES) {
        if (index == 0) {
            [self emptyGroups];
            return;
        }
        if (index == 1) {
            [self newGroup];
            return;
        }
    } else {
        if (index == 0) {
            [self emptyGroups];
            return;
        }
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
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
                             [db CacheGroups_new:newgroup isUser:YES];
                             [dbc loadCacheData];
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

    [self presentViewController:alert animated:YES completion:nil];
}




@end
