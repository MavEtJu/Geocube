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

@interface SettingsAccountsViewController ()
{
    NSArray<dbAccount *> *accounts;
    NSInteger accountsCount;
}

@end

@implementation SettingsAccountsViewController

enum {
    menuUpdate,
    menuMax
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE bundle:nil] forCellReuseIdentifier:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuUpdate label:_(@"settingsaccountsviewcontroller-Update Config")];
}

- (void)refreshAccountData
{
    /*
     * First show the accounts which are enabled and have an username.
     * First show the accounts which are not enabled and have an username.
     * Then show the accounts which are enabled and do not have an username.
     * Then show the accounts which are not enabled and do not have an username.
     */
    NSArray<dbAccount *> *as = dbc.accounts;
    NSMutableArray<dbAccount *> *bs = [NSMutableArray arrayWithCapacity:[as count]];

    [as enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == YES && IS_EMPTY(a.accountname.name) == NO)
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == NO && IS_EMPTY(a.accountname.name) == NO)
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == YES && IS_EMPTY(a.accountname.name) == YES)
            [bs addObject:a];
    }];
    [as enumerateObjectsUsingBlock:^(dbAccount * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        if (a.enabled == NO && IS_EMPTY(a.accountname.name) == YES)
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

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsaccountsviewcontroller-Initialize site details")
                                message:_(@"settingsaccountsviewcontroller-Currently no site details have been initialized. Normally you update them by tapping on the local menu button at the top right and select 'Update config'. But for now you can update them by pressing the 'Import' button")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *import = [UIAlertAction
                             actionWithTitle:_(@"Import")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 BACKGROUND(downloadFiles, nil);
                             }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
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
    GCTableViewCellSubtitleRightImage *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELLSUBTITLERIGHTIMAGE forIndexPath:indexPath];

    dbAccount *a = [accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = a.site;
    cell.detailTextLabel.text = a.accountname.name;
    if (a.enabled == NO) {
        cell.imageView.image = [imageManager get:Image_Nil];
    } else {
        if (a.accountname == nil) {
            cell.imageView.image = [imageManager get:ImageIcon_Dead];
        } else {
            if (a.canDoRemoteStuff == YES)
                cell.imageView.image = [imageManager get:ImageIcon_Smiley];
            else
                cell.imageView.image = [imageManager get:ImageIcon_Sad];
        }
    }

    cell.userInteractionEnabled = YES;

    return cell;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbAccount *account = [accounts objectAtIndex:indexPath.row];

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:_(@"settingsaccountsviewcontroller-Update account details")
                                message:_(@"settingsaccountsviewcontroller-Enter your account name")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:_(@"OK")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             //Do Some action
                             UITextField *tf = [alert.textFields objectAtIndex:0];
                             NSString *geocachingname = tf.text;
                             NSString *authenticatename = nil;
                             NSString *authenticatepassword = nil;

                             if (account.protocol._id == PROTOCOL_GCA2) {
                                 tf = [alert.textFields objectAtIndex:1];
                                 authenticatename = tf.text;
                                 if ([authenticatename isEqualToString:@""] == YES)
                                     authenticatename = geocachingname;
                                 tf = [alert.textFields objectAtIndex:2];
                                 authenticatepassword = tf.text;
                             }

                             dbName *n = [dbName dbGetByName:geocachingname account:account];
                             if (n == nil) {
                                 n = [[dbName alloc] init];
                                 n.name = geocachingname;
                                 n.code = nil;
                                 n.account = account;
                                 [n dbCreate];
                             }

                             account.accountname = n;
                             account.authentictation_name = authenticatename;
                             account.authentictation_password = authenticatepassword;
                             [account dbUpdateAccount];

                             [self refreshAccountData];
                             [self.tableView reloadData];

                             if (account.enabled == NO)
                                 return;

                             account.remoteAPI.authenticationDelegate = self;
                             if ([account.remoteAPI Authenticate] == NO)
                                 [MyTools messageBox:self header:_(@"settingsaccountsviewcontroller-Unable to authenticate") text:account.remoteAccessFailureReason];
                         }];

    UIAlertAction *forget = nil;
    if (IS_EMPTY(account.accountname.name) == NO)
        forget = [UIAlertAction
                  actionWithTitle:_(@"Forget") style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action) {
                      account.accountname = nil;
                      account.authentictation_password = nil;
                      account.authentictation_name = nil;
                      [account dbUpdateAccount];
                      [account dbClearAuthentication];
                      [self refreshAccountData];
                      [self.tableView reloadData];
                  }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:_(@"Cancel") style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];

    [alert addAction:ok];
    if (forget != nil)
        [alert addAction:forget];
    [alert addAction:cancel];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = account.accountname.name;
        textField.placeholder = _(@"settingsaccountsviewcontroller-Geocaching name");
    }];
    if (account.protocol._id == PROTOCOL_GCA2) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = account.authentictation_name;
            textField.placeholder = _(@"settingsaccountsviewcontroller-Authentication Name (if different)");
        }];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = account.authentictation_password;
            textField.secureTextEntry = YES;
            textField.placeholder = _(@"settingsaccountsviewcontroller-Authentication Password");
        }];
    }

    [ALERT_VC_RVC(self) presentViewController:alert animated:YES completion:nil];
}

- (void)remoteAPI:(RemoteAPITemplate *)api failure:(NSString *)failure error:(NSError *)error
{
    NSMutableString *msg = [NSMutableString stringWithString:failure];
    [msg appendString:_(@"settingsaccountsviewcontroller-This means that you cannot obtain information for this account.")];

    if (error != nil)
        [msg appendFormat:@" (%@)", [error description]];

    NSLog(@"failure: %@", msg);
    MAINQUEUE(
        [MyTools messageBox:self header:_(@"settingsaccountsviewcontroller-Authentication failed") text:msg];
    )

    [self refreshAccountData];
    [self.tableView reloadData];
}

- (void)remoteAPI:(RemoteAPITemplate *)api success:(NSString *)success;
{
    MAINQUEUE(
        [MyTools messageBox:self header:_(@"settingsaccountsviewcontroller-Authentication sucessful") text:_(@"settingsaccountsviewcontroller-Yay!")];
    )

    [self refreshAccountData];
    [self.tableView reloadData];
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuUpdate:
            BACKGROUND(downloadFiles, nil);
            return;
    }

    [super performLocalMenuAction:index];
}

+ (void)needsToDownloadFiles
{
    NSString *lastVersion = configManager.configUpdateLastVersion;
    if ([lastVersion isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] == NO) {
        [MyTools messageBox:[MyTools topMostController] header:_(@"settingsaccountsviewcontroller-Configuration Update") text:_(@"settingsaccountsviewcontroller-You haven't updated the configuration since the last code update. Please go to the Settings -> Accounts menu and update the configuration")];
        return;
    }

    NSMutableDictionary *versions = [NSMutableDictionary dictionaryWithCapacity:20];
    [self downloadVersions:versions fail:NO];
    if ([versions count] == 0)
        return;

    BOOL needsDownload = NO;

#define COMPARE(__url__, __key__) { \
        dbConfig *curl = [dbConfig dbGetByKey:__url__]; \
        NSArray<NSString *> *ws = [curl.value componentsSeparatedByString:@"/"]; \
        NSString *versionKnown = [versions objectForKey:[ws lastObject]]; \
        dbConfig *cold = [dbConfig dbGetByKey:__key__]; \
        NSLog(@"%@: current: %@ seen: %@", [ws lastObject], cold.value, versionKnown); \
        if ([cold.value isEqualToString:versionKnown] == NO) \
            needsDownload = YES; \
    }

    COMPARE(@"url_sites", KEY_REVISION_SITES);
    COMPARE(@"url_externalmaps", KEY_REVISION_EXTERNALMAPS);
    COMPARE(@"url_attributes", KEY_REVISION_ATTRIBUTES);
    COMPARE(@"url_countries", KEY_REVISION_COUNTRIES);
    COMPARE(@"url_states", KEY_REVISION_STATES);
    COMPARE(@"url_pins", KEY_REVISION_PINS);
    COMPARE(@"url_types", KEY_REVISION_TYPES);
    COMPARE(@"url_bookmarks", KEY_REVISION_BOOKMARKS);
    COMPARE(@"url_containers", KEY_REVISION_CONTAINERS);
    COMPARE(@"url_logstrings", KEY_REVISION_LOGSTRINGS);

    if (needsDownload)
        [MyTools messageBox:[MyTools topMostController] header:_(@"settingsaccountsviewcontroller-Configuration Update") text:_(@"settingsaccountsviewcontroller-A configuration update is available. Please go to the Settings -> Accounts menu and update the configuration.")];
}

- (void)downloadFiles
{
    [menuGlobal enableMenus:NO];
    [MHTabBarController enableMenus:NO controllerFrom:self];

    [bezelManager showBezel:self];
    BOOL needsFullReload = ([dbc.accounts count] == 0);

    NSMutableDictionary *versions = [NSMutableDictionary dictionaryWithCapacity:20];
    [[self class] downloadVersions:versions fail:YES];

    if ([versions count] != 0) {
        [self downloadFile:versions url:@"url_sites" header:@"site information" revision:KEY_REVISION_SITES];
        [self downloadFile:versions url:@"url_externalmaps" header:@"external maps" revision:KEY_REVISION_EXTERNALMAPS];
        [self downloadFile:versions url:@"url_attributes" header:@"attributes" revision:KEY_REVISION_ATTRIBUTES];
        [self downloadFile:versions url:@"url_countries" header:@"countries" revision:KEY_REVISION_COUNTRIES];
        [self downloadFile:versions url:@"url_states" header:@"states" revision:KEY_REVISION_STATES];
        [self downloadFile:versions url:@"url_pins" header:@"pins" revision:KEY_REVISION_PINS];
        [self downloadFile:versions url:@"url_types" header:@"types" revision:KEY_REVISION_TYPES];      // after pins
        [self downloadFile:versions url:@"url_bookmarks" header:@"bookmarks" revision:KEY_REVISION_BOOKMARKS];
        [self downloadFile:versions url:@"url_containers" header:@"containers" revision:KEY_REVISION_CONTAINERS];
        [self downloadFile:versions url:@"url_logstrings" header:@"log strings" revision:KEY_REVISION_LOGSTRINGS];
    }

    [configManager configUpdateLastTimeUpdate:time(NULL)];
    [configManager configUpdateLastVersionUpdate:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];

    [bezelManager removeBezel];

    if (needsFullReload == YES)
        [dbc loadCachableData];
    [dbc accountsReload];
    [self refreshAccountData];

    [self reloadDataMainQueue];
    [menuGlobal enableMenus:YES];
    [MHTabBarController enableMenus:YES controllerFrom:self];
}

+ (void)downloadVersions:(NSMutableDictionary *)versions fail:(BOOL)showFail
{
    if (showFail == YES)
        [bezelManager setText:_(@"settingsaccountsviewcontroller-Downloading versions")];

    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:@"url_versions"] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoViewer:nil iiDownload:0];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        NSDictionary *xml = [XMLReader dictionaryForXMLData:data error:&error];
        [[xml objectForKey:@"geocube_versions"] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] == NO)
                return;
            NSString *revision = [obj objectForKey:@"revision"];
            [versions setObject:revision forKey:key];
        }];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        if (showFail == YES) {
            NSString *err;
            if (error != nil) {
                err = error.description;
            } else {
                err = [NSString stringWithFormat:_(@"settingsaccountsviewcontroller-HTTP status %ld"), (long)response.statusCode];
            }

            [MyTools messageBox:[MyTools topMostController] header:_(@"settingsaccountsviewcontroller-Versions") text:[NSString stringWithFormat:@"%@: %@", _(@"settingsaccountsviewcontroller-Failed to download"), err]];
        }
    }
}

- (void)downloadFile:(NSDictionary *)versions url:(NSString *)key_url header:(NSString *)header revision:(NSString *)key_revision
{
    __block NSInteger versionFound = 0;
    dbConfig *c = [dbConfig dbGetByKey:key_url];
    [versions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
        if ([c.value containsString:key] == YES) {
            versionFound = [value integerValue];
            *stop = YES;
        }
    }];

    c = [dbConfig dbGetByKey:key_revision];
    if (c != nil && [[c value] integerValue] == versionFound)
        return;

    [bezelManager setText:[NSString stringWithFormat:@"%@ %@", _(@"Downloading"), header]];

    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:key_url] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error infoViewer:nil iiDownload:0];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        [ImportGeocube parse:data];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        NSString *err;
        if (error != nil) {
            err = error.description;
        } else {
            err = [NSString stringWithFormat:_(@"settingsaccountsviewcontroller-HTTP status %ld"), (long)response.statusCode];
        }

        [MyTools messageBox:self header:header text:[NSString stringWithFormat:_(@"settingsaccountsviewcontroller-Failed to download: %@"), err]];
    }
}

@end
