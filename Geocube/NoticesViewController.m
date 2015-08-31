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

    UIColor *bg = (n.seen == YES) ? [UIColor whiteColor] : [UIColor yellowColor];
    cell.noteLabel.backgroundColor = bg;
    cell.senderLabel.backgroundColor = bg;
    cell.dateLabel.backgroundColor = bg;

    n.cellHeight = cell.noteLabel.frame.size.height + cell.senderLabel.frame.size.height + 10;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbNotice *n = [notices objectAtIndex:indexPath.row];
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

#pragma random stuff

+ (void)AccountsNeedToBeInitialized
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyy-MM-dd"];

    dbNotice *n = [[dbNotice alloc] init];
    n.sender = @"System";
    n.seen = NO;
    n.date = [fmt stringFromDate:[NSDate date]];
    n.note = @"Welcome! It seems this is the first time you run Geocube.\n\nTo initialize the initial notices, please tap on the menu on the top right and select 'Download notices information'.\n\nOnce this has been loaded, you will have more notices which will help you configure everything.";
    [n dbCreate];
}

@end
