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

@interface NotesPersonalNotesViewController ()
{
    NSArray *pns;
    NSMutableArray *notes;
}

@end

@implementation NotesPersonalNotesViewController

#define THISCELL @"NotesPersonalNotesViewcell"

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[PersonalNoteTableViewCell class] forCellReuseIdentifier:THISCELL];
    lmi = nil;

    pns = [dbPersonalNote dbAll];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    notes = [NSMutableArray arrayWithCapacity:100];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    notes = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    pns = [dbPersonalNote dbAll];
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
    return [pns count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonalNoteTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbPersonalNote *pn = [pns objectAtIndex:indexPath.row];

    cell.nameLabel.text = pn.wp_name;

    [cell setLogString:pn.note];

    CGRect f = cell.frame;
    f.size.height = cell.logLabel.frame.size.height + cell.nameLabel.frame.size.height + 10;
    cell.frame = f;

    pn.cellHeight = f.size.height;

    cell.personalNote = pn;

    [cell viewWillTransitionToSize];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dbPersonalNote *pn = [pns objectAtIndex:indexPath.row];
    if (pn == nil)
        return 0;
    return pn.cellHeight;
}

@end
