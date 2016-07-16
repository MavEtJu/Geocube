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

@interface BrowserUserViewController ()
{
    NSArray *bms;
}

@end

#define THISCELL @"BookmarksUserTableViewCell"

@implementation BrowserUserViewController

enum {
    menuAddBookmark,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuAddBookmark label:@"Add bookmark"];

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    bms = [dbBookmark dbAll];
    [self.tableView reloadData];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [bms count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbBookmark *a = [bms objectAtIndex:indexPath.row];
    cell.textLabel.text = a.name;
    cell.detailTextLabel.text = a.url;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete

        dbBookmark *a = [bms objectAtIndex:indexPath.row];
        [a dbDelete];
        bms = [dbBookmark dbAll];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbBookmark *bm = [bms objectAtIndex:indexPath.row];

    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:bm.name
                               message:@"Select you choice"
                               preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:@"Delete"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [bm dbDelete];
                                 bms = [dbBookmark dbAll];
                                 [self.tableView reloadData];

                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *edit = [UIAlertAction
                           actionWithTitle:@"Edit"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here
                               [self bookmarkEdit:bm];
                               [view dismissViewControllerAnimated:YES completion:nil];
                           }];
    UIAlertAction *open = [UIAlertAction
                           actionWithTitle:@"Open"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here

                               [browserTabController setSelectedIndex:VC_BROWSER_BROWSER animated:YES];
                               [browserViewController loadURL:bm.url];
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

    [view addAction:open];
    [view addAction:edit];
    [view addAction:delete];
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)bookmarkEdit:(dbBookmark *)bm
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update bookmark"
                               message:@"Enter the bookmark"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *name = tf.text;
                             tf = [alert.textFields objectAtIndex:1];
                             NSString *url = tf.text;

                             bm.name = name;
                             bm.url = url;
                             [bm dbUpdate];
                             bms = [dbBookmark dbAll];

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
        textField.text = bm.name;
        textField.placeholder = @"Name";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = bm.url;
        textField.placeholder = @"URL";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)addBookmark
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Create bookmark"
                               message:@"Enter the bookmark details"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             // Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *name = tf.text;
                             tf = [alert.textFields objectAtIndex:1];
                             NSString *url = tf.text;

                             dbBookmark *bm = [[dbBookmark alloc] init];
                             bm.name = name;
                             bm.url = url;

                             [dbBookmark dbCreate:bm];
                             bms = [dbBookmark dbAll];
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
        textField.placeholder = @"Name";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"URL";
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)performLocalMenuAction:(NSInteger)index
{
    // Go back home
    switch (index) {
        case menuAddBookmark:
            [self addBookmark];
            return;
    }

    [super performLocalMenuAction:index];
}

@end
