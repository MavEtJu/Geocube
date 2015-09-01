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

@implementation NoticesViewController

#define THISCELL @"NoticesViewControllerCell"

- (id)init
{
    self = [super init];

    menuItems = [NSMutableArray arrayWithArray:@[@"Download notices"]];

    [self.tableView registerClass:[NoticeTableViewCell class] forCellReuseIdentifier:THISCELL];

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    notices = [dbNotice dbAll];
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
    return [notices count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoticeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[NoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    dbNotice *n = [notices objectAtIndex:indexPath.row];
    cell.noteLabel.text = n.note;
    cell.senderLabel.text = n.sender;
    cell.dateLabel.text = n.date;
    cell.seen = n.seen;
    [cell.noteLabel sizeToFit];
    [cell sizeToFit];
    cell.userInteractionEnabled = YES;

    UIColor *bg = [UIColor whiteColor];
    if (n.seen == NO)
        bg = [UIColor yellowColor];

    cell.noteLabel.backgroundColor = bg;
    cell.senderLabel.backgroundColor = bg;
    cell.dateLabel.backgroundColor = bg;
    cell.backgroundColor = bg;

    n.cellHeight = cell.noteLabel.frame.size.height + cell.senderLabel.frame.size.height;

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
    if (n.seen == YES)
        return;
    n.seen = YES;
    [n dbUpdate];
    [self.tableView reloadData];
}

#pragma mark - Local menu related functions

- (void)didSelectedMenu:(DOPNavbarMenu *)menu atIndex:(NSInteger)index
{
    if (index == 0) {      // Reload
        [self downloadNotices];
        return;
    }

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"you picked" message:[NSString stringWithFormat:@"number %@", @(index+1)] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void)downloadNotices
{
    NSURL *url = [NSURL URLWithString:[[dbConfig dbGetByKey:@"url_notices"] value]];

    GCURLRequest *urlRequest = [GCURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];

    if (error == nil && response.statusCode == 200) {
        NSLog(@"%@: Downloaded %@ (%ld bytes)", [self class], url, (unsigned long)[data length]);
        [ImportNotices parse:data];

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Notices Download"
                                   message:[NSString stringWithFormat:@"Successful downloaded (revision %@)", [[dbConfig dbGetByKey:@"notices_revision"] value]]
                                   preferredStyle:UIAlertControllerStyleAlert
                                   ];

        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil
                             ];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
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

        UIAlertController *alert= [UIAlertController
                                   alertControllerWithTitle:@"Notices download"
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

#pragma random stuff

+ (void)AccountsNeedToBeInitialized
{
    // If there are already notices then don't post this one.

    if ([dbNotice dbCount] != 0)
        return;

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];

    dbNotice *n = [[dbNotice alloc] init];
    n.sender = @"System";
    n.seen = NO;
    n.date = [fmt stringFromDate:[NSDate date]];
    n.geocube_id = 0;
    n.note = @"Welcome! It seems this is the first time you run Geocube.\n\nTo initialize the initial notices, please tap on the menu on the top right and select 'Download notices information'.\n\nOnce this has been loaded, you will have more notices which will help you configure everything.\n\nIf you tap on this note, the background will change, indicating you have seen it.";
    [n dbCreate];
}

@end
