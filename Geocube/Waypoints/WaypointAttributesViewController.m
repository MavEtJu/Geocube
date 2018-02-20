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

@interface WaypointAttributesViewController ()

@property (nonatomic, retain) NSMutableArray<dbAttribute *> *attrs;

@end

@implementation WaypointAttributesViewController

- (instancetype)init:(dbWaypoint *)wp
{
    self = [super init];

    self.attrs = [NSMutableArray arrayWithCapacity:5];

    NSArray<dbAttribute *> *as = [dbAttribute dbAllByWaypoint:wp];
    [as enumerateObjectsUsingBlock:^(dbAttribute * _Nonnull a, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.attrs addObject:a];
    }];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];

    self.lmi = nil;

    return self;
}

- (void)viewDidLoad
{
    self.hasCloseButton = YES;
    [super viewDidLoad];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attrs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _(@"waypointattributesviewcontroller-Attributes");
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCTableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;

    dbAttribute *a = [self.attrs objectAtIndex:indexPath.row];

    cell.textLabel.text = _(([NSString stringWithFormat:@"attributes-%@", a.label]));
    cell.imageView.image = [imageManager get:a.icon];
    cell.userInteractionEnabled = NO;

    return cell;
}

@end
