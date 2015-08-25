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

    [self.tableView registerClass:[GCTableViewCellWithSubtitle class] forCellReuseIdentifier:THISCELL];
    menuItems = [NSMutableArray arrayWithArray:@[@"Download licenses"]];
}

- (void)refreshAccountData
{
    accounts = [dbAccount dbAll];
    accountsCount = [accounts count];
    [self refreshControl];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCellWithSubtitle alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];

    dbAccount *a = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = a.site;
    cell.detailTextLabel.text = a.account;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    oauth_account = [accounts objectAtIndex:indexPath.row];

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

                             oauth_account.account = username;
                             [oauth_account dbUpdateAccount];

                             [self.tableView reloadData];

                             oabb = [[GCOAuthBlackbox alloc] init];

                             [oabb URLRequestToken:oauth_account.oauth_request_url];
                             [oabb URLAuthorize:oauth_account.oauth_authorize_url];
                             [oabb URLAccessToken:oauth_account.oauth_access_url];
                             [oabb consumerKey:oauth_account.oauth_consumer_public];
                             [oabb consumerSecret:oauth_account.oauth_consumer_private];

                             [oabb obtainRequestToken];
                             oabb.delegate = self;
                             NSString *url = [NSString stringWithFormat:@"%@?oauth_token=%@", oauth_account.oauth_authorize_url, oabb.token];

                             //

                             BHTabsViewController *btc = [_AppDelegate.tabBars objectAtIndex:RC_BOOKMARKS];
                             UINavigationController *nvc = [btc.viewControllers objectAtIndex:VC_BOOKMARKS_BROWSER];
                             BookmarksBrowserViewController *bbvc = [nvc.viewControllers objectAtIndex:0];

                             [_AppDelegate switchController:RC_BOOKMARKS];

                             [btc makeTabViewCurrent:VC_BOOKMARKS_BROWSER];
                             [bbvc prepare_oauth:oabb];
                             [bbvc loadURL:url];

                             //

                             //[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];

                         }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = oauth_account.account;
        textField.placeholder = @"Username";
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)oauthdanced:(NSString *)token secret:(NSString *)secret
{
    oauth_account.oauth_token = token;
    oauth_account.oauth_token_secret = secret;
    [oauth_account dbUpdateOAuthToken];
    oauth_account = nil;
    oabb = nil;

    [_AppDelegate switchController:RC_SETTINGS];
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
    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:@"url_licenses"] value]];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        [ImportLicenses parse:data];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Licenses download"
                                   message:[NSString stringWithFormat:@"Successful downloaded (revision %@)", [[dbConfig dbGetByKey:@"licenses_revision"] value]]
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                            ];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        NSString *err;
        if (error != nil) {
            err = error.description;
        } else {
            err = [NSString stringWithFormat:@"HTTP status %ld", response.statusCode];
        }

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Licenses download"
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
