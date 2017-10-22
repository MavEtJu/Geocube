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

@interface DeveloperImagesViewController ()

@property (nonatomic, retain) NSMutableArray<UIImage *> *imgs;
@property (nonatomic, retain) NSMutableArray<NSString *> *names;
@property (nonatomic, retain) NSMutableArray<NSNumber *> *numbers;

@end

enum {
    IMAGES_TYPES_ONE = 0,
    IMAGES_PINS_ONE,
    IMAGES_PINS_ALL,
    IMAGES_TYPES_ALL,
    IMAGES_IMAGES,
    IMAGES_MAX
};

@implementation DeveloperImagesViewController

- (instancetype)init
{
    self = [super init];
    self.lmi = nil;
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
    self.imgs = [[NSMutableArray alloc] initWithCapacity:20];
    self.names = [[NSMutableArray alloc] initWithCapacity:20];
    self.numbers = [[NSMutableArray alloc] initWithCapacity:20];
    UIImage *img;
    NSString *name;

    for (NSInteger i = 0; i < ImageLibraryImagesMax ;i++) {
        img = [imageManager get:i];
        if (img == nil || [img isKindOfClass:[NSNull class]] == YES)
            continue;
        [self.numbers addObject:[NSNumber numberWithInteger:i]];
        [self.imgs addObject:img];
        if ((name = [imageManager getName:i]) == nil)
            continue;
        [self.names addObject:name];
    }
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
        return [dbc.pins count];
    if (section == IMAGES_TYPES_ALL)
        return [dbc.types count];
    if (section == IMAGES_PINS_ONE && [dbc.pins count] != 0)
        return 10;
    if (section == IMAGES_TYPES_ONE)
        return 10;
    if (section == IMAGES_IMAGES)
        return [self.imgs count];
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
    if (section == IMAGES_IMAGES)
        return @"get:";
    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:XIB_GCTABLEVIEWCELL forIndexPath:indexPath];

    if (indexPath.section == IMAGES_PINS_ONE) {
        NSArray<dbPin *> *pins = dbc.pins;
        dbPin *pin = [pins objectAtIndex:1];

        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Not logged");
                break;
            case 1:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Found");
                break;
            case 2:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Not Found");
                break;

            case 3:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Disabled");
                break;
            case 4:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Archived");
                break;
            case 5:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:YES owner:NO markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Highlight");
                break;
            case 6:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Owner");
                break;
            case 7:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:YES inProgress:NO markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Marked Found");
                break;
            case 8:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:YES markedDNF:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Marked In Progress");
                break;
            case 9:
                cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:YES];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Pin - Marked DNF");
                break;

        }
        return cell;
    }

    if (indexPath.section == IMAGES_TYPES_ONE) {
        dbType *type = [dbc typeGetByMinor:@"Traditional"];

        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Not Logged");
                break;
            case 1:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Found");
                break;
            case 2:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Not Found");
                break;

            case 3:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Disabled");
                break;
            case 4:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Archived");
                break;
            case 5:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:YES owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Highlight");
                break;
            case 6:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:YES markedFound:NO inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Marked Found");
                break;
            case 7:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:YES inProgress:NO markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Marked Found");
                break;
            case 8:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:YES markedDNF:NO planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Marked In Progress");
                break;
            case 9:
                cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:YES planned:NO];
                cell.textLabel.text = _(@"developerimagesviewcontroller-Type - Marked DNF");
                break;
        }

        return cell;
    }

    if (indexPath.section == IMAGES_PINS_ALL) {
        NSArray<dbPin *> *pins = dbc.pins;
        dbPin *pin = [pins objectAtIndex:indexPath.row];

        cell.imageView.image = [imageManager getPin:pin found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO];
        cell.textLabel.text = pin.desc;
        return cell;
    }

    if (indexPath.section == IMAGES_TYPES_ALL) {
        NSArray<dbType *> *types = dbc.types;
        dbType *type = [types objectAtIndex:indexPath.row];

        cell.imageView.image = [imageManager getType:type found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO owner:NO markedFound:NO inProgress:NO markedDNF:NO planned:NO];
        cell.textLabel.text = type.type_full;
        return cell;
    }

    if (indexPath.section == IMAGES_IMAGES) {
        if ([[self.imgs objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]] == NO) {
            cell.imageView.image = [self.imgs objectAtIndex:indexPath.row];
            cell.textLabel.text = [self.names objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [[self.numbers objectAtIndex:indexPath.row] stringValue];
        }
        return cell;
    }

    // Not reached
    abort();
}

@end
