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

#define THISCELL @"HelpImagesCells"

@implementation HelpImagesViewController

- (id)init
{
    self = [super init];
    menuItems = nil;
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
    [self.tableView registerClass:[GCTableViewCell class] forCellReuseIdentifier:THISCELL];
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 3;
}

// Rows per section
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 25;
    if (section == 1)
        return 11;
    if (section == 2)
        return imgCount;
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"pins:";
    if (section == 1)
        return @"getRating:";
    if (section == 2)
        return @"get:";
    return nil;
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];
    if (cell == nil)
        cell = [[GCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL];

    if (indexPath.section == 0) {
        switch (indexPath.row) {

            case 0:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:NO archived:NO highlight:NO];
                cell.textLabel.text = @"Pin";
                break;
            case 1:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:NO archived:NO highlight:NO];
                cell.textLabel.text = @"Pin - found";
                break;
            case 2:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:NO archived:NO highlight:NO];
                cell.textLabel.text = @"Pin - not found";
                break;

            case 3:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadBlack found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:NO];
                cell.textLabel.text = @"Pin - disabled";
                break;
            case 4:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadBlack found:LOGSTATUS_FOUND disabled:YES archived:NO highlight:NO];
                cell.textLabel.text = @"Pin - found - disabled";
                break;
            case 5:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadBlack found:LOGSTATUS_NOTFOUND disabled:YES archived:NO highlight:NO];
                cell.textLabel.text = @"Pin - not found - disabled";
                break;

            case 6:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - archived";
                break;
            case 7:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:NO archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - found - archived";
                break;
            case 8:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:NO archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - not found - archived";
                break;

            case 9:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:YES archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - disabled - archived";
                break;
            case 10:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:YES archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - found - disabled - archived";
                break;
            case 11:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:YES archived:YES highlight:NO];
                cell.textLabel.text = @"Pin - not found - disabled - archived";
                break;

            case 12:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:YES archived:NO highlight:YES];
                cell.textLabel.text = @"Pin - disabled - highlight";
                break;
            case 13:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:YES archived:NO highlight:YES];
                cell.textLabel.text = @"Pin - found - disabled - highlight";
                break;
            case 14:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:YES archived:NO highlight:YES];
                cell.textLabel.text = @"Pin - not found - disabled - highlight";
                break;

            case 15:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:NO archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - archived - highlight";
                break;
            case 16:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:NO archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - found - archived - highlight";
                break;
            case 17:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:NO archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - not found - archived - highlight";
                break;

            case 18:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTLOGGED disabled:YES archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - disabled - highlight";
                break;
            case 19:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_FOUND disabled:YES archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - found - disabled - highlight";
                break;
            case 20:
                cell.imageView.image = [imageLibrary getPin:ImageMap_pinheadRed found:LOGSTATUS_NOTFOUND disabled:YES archived:YES highlight:YES];
                cell.textLabel.text = @"Pin - not found - disabled - highlight";
                break;

            default:
                cell.imageView.image = nil;
                cell.textLabel.text = @"None";
                break;

        }
        return cell;
    }

    if (indexPath.section == 1) {
        cell.imageView.image = [imageLibrary getRating:indexPath.row / 2.0];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld (%0.1f)", (long)indexPath.row, indexPath.row / 2.0];
        cell.detailTextLabel.text = nil;

        return cell;
    }

    if (indexPath.section == 2) {
        cell.imageView.image = [imgs objectAtIndex:indexPath.row];
        cell.textLabel.text = [names objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [[numbers objectAtIndex:indexPath.row] stringValue];
    
        return cell;
    }
    return nil;
}

@end
