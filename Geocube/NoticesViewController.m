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

@interface NoticesViewController ()
{
    NSArray *notices;
}

@end

@implementation NoticesViewController

#define THISCELL @"NoticesViewControllerCell"

enum {
    menuDownloadNotices,
    menuMax
};

- (instancetype)init
{
    self = [super init];

    lmi = [[LocalMenuItems alloc] init:menuMax];
    [lmi addItem:menuDownloadNotices label:@"Download notices"];

    [self.tableView registerClass:[NoticeTableViewCell class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    notices = [dbNotice dbAll];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([notices count] > 1)
        return;

    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:@"Initialize notices"
                               message:@"Currently no notices details have been download. Normally you update them by tapping on the local menu button at the top left and select 'Download notices'. But for now you can update them by pressing the 'Import' button"
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *import = [UIAlertAction
                             actionWithTitle:@"Import"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction *action) {
                                 [self downloadNotices];
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                    [self.tableView reloadData];
                                 }
    ];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 1;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [notices count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    dbNotice *n = [notices objectAtIndex:indexPath.row];
    cell.senderLabel.text = n.sender;
    cell.dateLabel.text = n.date;
    cell.seen = n.seen;

    [cell setNote:n.note];
    if (n.url != nil && [n.url isEqualToString:@""] == NO)
        [cell setURL:n.url];
    [cell.noteLabel bold:(n.seen == NO)];

    cell.userInteractionEnabled = YES;
    cell.notice = n;

    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbNotice *n = [notices objectAtIndex:indexPath.row];
    if (n.cellHeight == 0)
        return 40;
    return n.cellHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbNotice *n = [notices objectAtIndex:indexPath.row];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (n.seen == NO) {
        n.seen = YES;
        [n dbUpdate];
        [self.tableView reloadData];
    }

    if (n.url != nil && [n.url isEqualToString:@""] == NO) {
        [browserViewController showBrowser];
        [browserViewController loadURL:n.url];
    }
}

#pragma mark - Local menu related functions

- (void)performLocalMenuAction:(NSInteger)index
{
    switch (index) {
        case menuDownloadNotices:
            [self downloadNotices];
            return;
    }

    [super performLocalMenuAction:index];
}

- (void)downloadNotices
{
    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:@"url_notices"] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [downloadManager downloadSynchronous:urlRequest returningResponse:&response error:&error];

    if (data != nil && error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        if ([ImportGeocube parse:data] == YES)
            [MyTools messageBox:self header:@"Notices download" text:[NSString stringWithFormat:@"Successful downloaded (revision %@)", [[dbConfig dbGetByKey:@"notices_revision"] value]]];
        else
            [MyTools messageBox:self header:@"Notices download" text:@"There was a failure in parsing the downloaded notices file"];

        notices = [dbNotice dbAll];
        [self.tableView reloadData];
    } else {
        NSLog(@"%@: Failed! %@", [self class], error);

        NSString *err;
        if (error != nil) {
            err = error.description;
        } else {
            err = [NSString stringWithFormat:@"HTTP status %ld", (long)response.statusCode];
        }

        [MyTools messageBox:self header:@"Notices download" text:[NSString stringWithFormat:@"Failed to download: %@", err]];
    }
}

#pragma random stuff

+ (void)AccountsNeedToBeInitialized
{
    // If there are already notices then don't post this one.

    if ([dbNotice dbCount] != 0)
        return;

    dbNotice *n = [[dbNotice alloc] init];
    n.sender = @"System";
    n.seen = NO;
    n.date = @"2015-08-01";
    n.geocube_id = 0;
    n.note = @"Welcome! It seems this is the first time you run Geocube.\n\nTo initialize the initial notices, please tap on the local menu button on the top right and select 'Download notices information'.\n\nOnce this has been loaded, you will have more notices which will help you configure everything.\n\nIf you tap on this note, the text will from bold to normal, indicating you have seen it.";
    n.url = @"https://geocube.mavetju.org/";
    [n dbCreate];
}

@end
