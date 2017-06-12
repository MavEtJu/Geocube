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

@interface HelpImagesViewController ()
{
    NSMutableArray<UIImage *> *imgs;
    NSMutableArray<NSString *> *names;
    NSMutableArray<NSNumber *> *numbers;
    NSInteger imgCount;
}

@end

enum {
    IMAGES_TYPES_ONE = 0,
    IMAGES_PINS_ONE,
    IMAGES_PINS_ALL,
    IMAGES_TYPES_ALL,
    IMAGES_RATING,
    IMAGES_IMAGES,
    IMAGES_MAX
};

@implementation HelpImagesViewController

- (instancetype)init
{
    self = [super init];
    lmi = nil;
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshImages];
    [self.tableView reloadData];
}

- (void)refreshImages
{
    imgs = [[NSMutableArray alloc] initWithCapacity:20];
    names = [[NSMutableArray alloc] initWithCapacity:20];
    numbers = [[NSMutableArray alloc] initWithCapacity:20];
    UIImage *img;
    NSString *name;

    for (NSInteger i = 0; i < ImageLibraryImagesMax ;i++) {
        if ((img = [imageLibrary get:i]) == nil)
            continue;
        [numbers addObject:[NSNumber numberWithInteger:i]];
        [imgs addObject:img];
        if ((name = [imageLibrary getName:i]) == nil)
            continue;
        [names addObject:name];
    }
    imgCount = [imgs count];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:XIB_GCTABLEVIEWCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return IMAGES_MAX;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == IMAGES_PINS_ALL)
        return [[dbc Pins] count];
    if (section == IMAGES_TYPES_ALL)
        return [[dbc Types] count];
    if (section == IMAGES_PINS_ONE && [[dbc Pins] count] != 0)
        return 10;
    if (section == IMAGES_TYPES_ONE)
        return 10;
    if (section == IMAGES_RATING)
        return 11;
    if (section == IMAGES_IMAGES)
        return imgCount;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == IMAGES_PINS_ONE)
        return @"Pins:";
    if (section == IMAGES_TYPES_ONE)
        return @"Types:";
    if (section == IMAGES_PINS_ALL)
        return @"Pins all:";
    if (section == IMAGES_TYPES_ALL)
        return @"Types all:";
    if (section == IMAGES_RATING)
        return @"getRating:";
    if (section == IMAGES_IMAGES)
        return @"get:";
    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];

    if (indexPath.section == IMAGES_PINS_ONE) {
        NSArray<dbPin *> *pins = [dbc Pins];
        dbPin *pin = [pins objectAtIndex:1];

        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Not logged";
                break;
            case 1:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Found";
                break;
            case 2:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Not Found";
                break;

            case 3:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Disabled";
                break;
            case 4:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Archived";
                break;
            case 5:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:YES owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Highlight";
                break;
            case 6:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Owner";
                break;
            case 7:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:YES inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Pin - Marked Found";
                break;
            case 8:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:YES markedDNF:NO];
                cell.textLabel.text = @"Pin - Marked In Progress";
                break;
            case 9:
                cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:YES];
                cell.textLabel.text = @"Pin - Marked DNF";
                break;

        }
        return cell;
    }

    if (indexPath.section == IMAGES_TYPES_ONE) {
        dbType *type = [dbc Type_get_byminor:@"Traditional"];

        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Not Logged";
                break;
            case 1:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Found";
                break;
            case 2:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Not Found";
                break;

            case 3:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Disabled";
                break;
            case 4:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type Archived";
                break;
            case 5:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:YES owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Highlight";
                break;
            case 6:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Marked Found";
                break;
            case 7:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:YES inProgress:NO markedDNF:NO];
                cell.textLabel.text = @"Type - Marked Found";
                break;
            case 8:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:YES markedDNF:NO];
                cell.textLabel.text = @"Type - Marked In Progress";
                break;
            case 9:
                cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:YES];
                cell.textLabel.text = @"Type - Marked DNF";
                break;
        }

        return cell;
    }

    if (indexPath.section == IMAGES_PINS_ALL) {
        NSArray<dbPin *> *pins = [dbc Pins];
        dbPin *pin = [pins objectAtIndex:indexPath.row];

        cell.imageView.image = [imageLibrary getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
        cell.textLabel.text = @"Pin";
        return cell;
    }

    if (indexPath.section == IMAGES_TYPES_ALL) {
        NSArray<dbType *> *types = [dbc Types];
        dbType *type = [types objectAtIndex:indexPath.row];

        cell.imageView.image = [imageLibrary getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
        cell.textLabel.text = @"Type";
        return cell;
    }

    if (indexPath.section == IMAGES_RATING) {
        cell.imageView.image = [imageLibrary getRating:indexPath.row / 2.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld (%0.1f)", (long)indexPath.row, indexPath.row / 2.0];
        cell.detailTextLabel.text = nil;

        return cell;
    }

    if (indexPath.section == IMAGES_IMAGES) {
        cell.imageView.image = [imgs objectAtIndex:indexPath.row];
        cell.textLabel.text = [names objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[numbers objectAtIndex:indexPath.row] stringValue];

        return cell;
    }

    // Not reached
    abort();
}

@end
