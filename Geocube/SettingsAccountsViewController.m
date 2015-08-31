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

#define THISCELL @"SettingsAccountsViewControllerCell"

@implementation SettingsAccountsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[GCTableViewCellRightImage class] forCellReuseIdentifier:THISCELL];
    menuItems = [NSMutableArray arrayWithArray:@[@"Download site info"]];
}

- (void)refreshAccountData
{
    accounts = [dbc Accounts];
    accountsCount = [accounts count];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshAccountData];
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
    return accountsCount;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCellRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCellRightImage alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    dbAccount *a = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = a.site;
    cell.detailTextLabel.text = a.accountname;
    if (a.accountname == nil || [a.accountname isEqualToString:@""] == YES)
        cell.imageView.image = [imageLibrary get:ImageIcon_Target];
    else {
        if (a.canDoRemoteStuff == YES)
            cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
        else
            cell.imageView.image = [imageLibrary get:ImageIcon_Sad];
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
                             NSString *username = tf.text;

                             account.accountname = username;
                             [account dbUpdateAccount];

                             [self.tableView reloadData];

                             account.remoteAPI.authenticationDelegate = self;
                             [account.remoteAPI Authenticate];
                         }];

    UIAlertAction *forget = [UIAlertAction
                             actionWithTitle:@"Forget" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
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
    [alert addAction:forget];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = account.accountname;
        textField.placeholder = @"Username";
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)remoteAPI:(RemoteAPI *)api failure:(NSString *)failure error:(NSError *)error
{
    NSMutableString *msg = [NSMutableString stringWithString:failure];
    [msg appendString:@" This means that you cannot obtain information for this account."];
    
    if (error != nil)
        [msg appendFormat:@" (%@)", [error description] ];

    NSLog(@"failure: %@", msg);
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Authentication failed"
                               message:msg
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:ok];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alert animated:YES completion:nil];
    }];

    [self refreshAccountData];
    [self.tableView reloadData];
}

- (void)remoteAPI:(RemoteAPI *)api success:(NSString *)success;
{
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Authentication successful"
                               message:@"Yay!"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];

    [alert addAction:ok];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self presentViewController:alert animated:YES completion:nil];
    }];

    [self refreshAccountData];
    [self.tableView reloadData];
}


#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    if (index == 0) {
        [self downloadLicenses];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)downloadLicenses
{
    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:@"url_sites"] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        [ImportSites parse:data];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Site information download"
                                   message:[NSString stringWithFormat:@"Successful downloaded (revision %@)", [[dbConfig dbGetByKey:@"sites_revision"] value]]
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                            ];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        [dbc AccountsReload];
        [self refreshAccountData];
        [self.tableView reloadData];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        NSString *err;
        if (error != nil) {
            err = error.description;
        } else {
            err = [NSString stringWithFormat:@"HTTP status %ld", (long)response.statusCode];
        }

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Site Information Download"
                                   message:[NSString stringWithFormat:@"Failed to download: %@", err]
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                            ];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
