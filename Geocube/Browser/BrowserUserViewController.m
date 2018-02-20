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

@interface BrowserUserViewController ()

@property (nonatomic, retain) NSArray<dbBookmark *> *bms;

@end

@implementation BrowserUserViewController

enum {
    menuAddBookmark,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    self.lmi = [[LocalMenuItems alloc] init:menuMax];
    [self.lmi addItem:menuAddBookmark label:_(@"browseruserviewcontroller-Add bookmark")];

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLWITHSUBTITLE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bms = [dbBookmark dbAll];
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
    return [self.bms count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLWITHSUBTITLE forIndexPath:indexPath];

    dbBookmark *a = [self.bms objectAtIndex:indexPath.row];
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

        dbBookmark *a = [self.bms objectAtIndex:indexPath.row];
        [a dbDelete];
        self.bms = [dbBookmark dbAll];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbBookmark *bm = [self.bms objectAtIndex:indexPath.row];

    UIAlertController *view = [UIAlertController
                               alertControllerWithTitle:bm.name
                               message:_(@"browseruserviewcontroller-Select your choice")
                               preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *delete = [UIAlertAction
                             actionWithTitle:_(@"Delete")
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [bm dbDelete];
                                 self.bms = [dbBookmark dbAll];
                                 [self.tableView reloadData];

                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];

    UIAlertAction *edit = [UIAlertAction
                           actionWithTitle:_(@"Edit")
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here
                               [self bookmarkEdit:bm];
                               [view dismissViewControllerAnimated:YES completion:nil];
                           }];
    UIAlertAction *open = [UIAlertAction
                           actionWithTitle:_(@"Open")
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               //Do some thing here

                               [browserViewController showBrowser];
                               [browserViewController loadURL:bm.url];
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

    [view addAction:open];
    [view addAction:edit];
    [view addAction:delete];
    [view addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:view animated:YES completion:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)bookmarkEdit:(dbBookmark *)bm
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"browseruserviewcontroller-Update bookmark")
                                message:_(@"browseruserviewcontroller-Enter the bookmark")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
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
                             self.bms = [dbBookmark dbAll];

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
        textField.text = bm.name;
        textField.placeholder = _(@"browseruserviewcontroller-Name");
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = bm.url;
        textField.placeholder = _(@"URL");
    }];

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Local menu related functions

- (void)addBookmark
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"browseruserviewcontroller-Create bookmark")
                                message:_(@"browseruserviewcontroller-Enter the bookmark details")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
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

                             [bm dbCreate];
                             self.bms = [dbBookmark dbAll];
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
        textField.placeholder = _(@"browseruserviewcontroller-Name");
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = _(@"browseruserviewcontroller-URL");
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
