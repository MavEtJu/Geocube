/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016 Edwin Groothuis
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

@interface SettingsAccountsViewController ()
{
    NSArray *accounts;
    NSInteger accountsCount;
}

@end

#define THISCELL @"SettingsAccountsViewControllerCell"

@implementation SettingsAccountsViewController

enum {
    menuUpdate,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCellSubtitleRightImage class] forCellReuseIdentifier:THISCELL];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUpdate label:@"Update config"];
}

- (void)refreshAccountData
{
    /*
     * First show the accounts which are enabled and have an username.
     * First show the accounts which are not enabled and have an username.
     * Then show the accounts which are enabled and do not have an username.
     * Then show the accounts which are not enabled and do not have an username.
     */
    NSArray *as = [dbc Accounts];
    NSMutableArray *bs = [NSMutableArray arrayWithCapacity:[as count]];

    [as enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == YES && (a.accountname_string != nil && [a.accountname_string isEqualToString:@""] == NO))
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == NO && (a.accountname_string != nil && [a.accountname_string isEqualToString:@""] == NO))
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == YES && (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES))
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount *a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == NO && (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES))
            [bs addObject:a];
    }];

    accounts = bs;
    accountsCount = [accounts count];
    [self reloadDataMainQueue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAccountData];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([accounts count] != 0)
        return;

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Initialize site details"
                               message:@"Currently no site details have been initialized. Normally you update them by tapping on the local menu button at the top right and select 'Update config'. But for now you can update them by pressing the 'Import' button"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *import = [UIAlertAction
                             actionWithTitle:@"Import"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [self downloadFiles];
                             }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:import];
    [alert addAction:cancel];
    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return accountsCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellSubtitleRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbAccount *a = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = a.site;
    cell.detailTextLabel.text = a.accountname_string;
    cell.userInteractionEnabled = YES;
    if (a.enabled == NO) {
        cell.imageView.image = [imageLibrary get:Image_Nil];
    } else {
        if (a.accountname_string == nil || [a.accountname_string isEqualToString:@""] == YES) {
            cell.imageView.image = [imageLibrary get:ImageIcon_Dead];
        } else {
            if (a.canDoRemoteStuff == YES)
                cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
            else
                cell.imageView.image = [imageLibrary get:ImageIcon_Sad];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbAccount *account = [accounts objectAtIndex:indexPath.row];

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Update account details"
                               message:@"Enter your account name"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *geocachingname = tf.text;
                             NSString *authenticatename = nil;
                             NSString *authenticatepassword = nil;

                             if (account.protocol_id == PROTOCOL_GCA2) {
                                 tf = [alert.textFields objectAtIndex:1];
                                 authenticatename = tf.text;
                                 tf = [alert.textFields objectAtIndex:2];
                                 authenticatepassword = tf.text;
                             }

                             account.accountname_string = geocachingname;

                             dbName *n = [dbName dbGetByName:geocachingname account:account];
                             if (n == nil) {
                                 n = [[dbName alloc] init:0 name:geocachingname code:nil account:account];
                                 [n dbCreate];
                             }

                             account.accountname = n;
                             account.accountname_id = n._id;
                             account.authentictation_name = authenticatename;
                             account.authentictation_password = authenticatepassword;
                             [account dbUpdateAccount];

                             [self refreshAccountData];
                             [self.tableView reloadData];

                             if (account.enabled == NO)
                                 return;

                             account.remoteAPI.authenticationDelegate = self;
                             if ([account.remoteAPI Authenticate] == NO)
                                 [MyTools messageBox:self header:@"Unable to authenticate" text:account.remoteAccessFailureReason];
                         }];

    UIAlertAction *forget = nil;
    if (account.accountname_string != nil && [account.accountname_string length] != 0)
        forget = [UIAlertAction
                  actionWithTitle:@"Forget" style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action) {
                      account.accountname_string = nil;
                      account.accountname_id = 0;
                      account.accountname = nil;
                      account.authentictation_password = nil;
                      account.authentictation_name = nil;
                      [account dbUpdateAccount];
                      [account dbClearAuthentication];
                      [self refreshAccountData];
                      [self.tableView reloadData];
                  }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    if (forget != nil)
        [alert addAction:forget];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = account.accountname_string;
        textField.placeholder = @"Geocaching name";
    }];
    if (account.protocol_id == PROTOCOL_GCA2) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = account.authentictation_name;
            textField.placeholder = @"Authentication Name";
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = account.authentictation_password;
            textField.secureTextEntry = YES;
            textField.placeholder = @"Authentication Password";
        }];
    }

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)remoteAPI:(RemoteAPITemplate *)api failure:(NSString *)failure error:(NSError *)error
{
    NSMutableString *msg = [NSMutableString stringWithString:failure];
    [msg appendString:@" This means that you cannot obtain information for this account."];

    if (error != nil)
        [msg appendFormat:@" (%@)", [error description] ];

    NSLog(@"failure: %@", msg);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MyTools messageBox:self header:@"Authentication failed" text:msg];
    }];

    [self refreshAccountData];
    [self.tableView reloadData];
}

- (void)remoteAPI:(RemoteAPITemplate *)api success:(NSString *)success;
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MyTools messageBox:self header:@"Authentication sucessful" text:@"Yay!"];
    }];

    [self refreshAccountData];
    [self.tableView reloadData];
}


#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuUpdate:
            [self performSelectorInBackground:@selector(downloadFiles) withObject:nil];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)downloadFiles
{
    [menuGlobal enableMenus:NO];
    [MHTabBarController enableMenus:NO controllerFrom:self];

    [bezelManager showBezel:self];

    [self downloadFile:@"url_sites" header:@"site information" revision:KEY_REVISION_SITES];
    [self downloadFile:@"url_externalmaps" header:@"external maps" revision:KEY_REVISION_EXTERNALMAPS];
    [self downloadFile:@"url_attributes" header:@"attributes" revision:KEY_REVISION_ATTRIBUTES];
    [self downloadFile:@"url_countries" header:@"countries" revision:KEY_REVISION_COUNTRIES];
    [self downloadFile:@"url_states" header:@"states" revision:KEY_REVISION_STATES];
    [self downloadFile:@"url_keys" header:@"keys" revision:KEY_REVISION_KEYS];
    [self downloadFile:@"url_types" header:@"types" revision:KEY_REVISION_TYPES];
    [self downloadFile:@"url_pins" header:@"pins" revision:KEY_REVISION_PINS];
    [self downloadFile:@"url_bookmarks" header:@"bookmarks" revision:KEY_REVISION_BOOKMARKS];
    [self downloadFile:@"url_containers" header:@"containers" revision:KEY_REVISION_CONTAINERS];
    [self downloadFile:@"url_logstrings" header:@"log strings" revision:KEY_REVISION_LOGSTRINGS];

    [bezelManager removeBezel];

    [dbc AccountsReload];
    [self refreshAccountData];

    [self reloadDataMainQueue];
    [menuGlobal enableMenus:YES];
    [MHTabBarController enableMenus:YES controllerFrom:self];
}

- (void)downloadFile:(NSString *)key_url header:(NSString *)header revision:(NSString *)key_revision
{
    [bezelManager setText:[NSString stringWithFormat:@"Downloading %@", header]];

    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:key_url] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoViewer:nil ivi:0];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        [ImportGeocube parse:data];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        NSString *err;
        if (error != nil) {
            err = error.description;
        } else {
            err = [NSString stringWithFormat:@"HTTP status %ld", (long)response.statusCode];
        }

        [MyTools messageBox:self header:header text:[NSString stringWithFormat:@"Failed to download: %@", err]];
    }
}

@end
