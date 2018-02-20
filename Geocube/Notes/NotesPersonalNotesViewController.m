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

@interface NotesPersonalNotesViewController ()

@property (nonatomic, retain) NSArray<dbPersonalNote *> *pns;
@property (nonatomic, retain) NSMutableArray<NSString *> *notes;

@end

@implementation NotesPersonalNotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerNib:[UINib nibWithNibName:XIB_PERSONALNOTETABLEVIEWCELL bundle:nil] forCellReuseIdentifier:XIB_PERSONALNOTETABLEVIEWCELL];

    self.lmi = nil;

    self.pns = [dbPersonalNote dbAll];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.notes = [NSMutableArray arrayWithCapacity:100];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.notes = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.pns = [dbPersonalNote dbAll];
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
    return [self.pns count];
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonalNoteTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_PERSONALNOTETABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbPersonalNote *pn = [self.pns objectAtIndex:indexPath.row];
    [cell setNote:pn];

    return cell;
}

@end
