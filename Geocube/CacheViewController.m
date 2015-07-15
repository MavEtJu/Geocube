//
//  CacheViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL_HEADER @"cachetablecell_header"
#define THISCELL_DATA @"cachetablecell_data"
#define THISCELL_ACTIONS @"cachetablecell_actions"

@implementation CacheViewController

- (id)initWithStyle:(NSInteger)_style cache:(dbCache *)_wp;
{
    self = [super initWithStyle:_style];
    [self setCache:_wp];
    return self;
}

- (void)setCache:(dbCache *)_cache
{
    wp = _cache;
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.tableView registerClass:[CacheHeaderTableViewCell class] forCellReuseIdentifier:THISCELL_HEADER];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL_DATA];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL_ACTIONS];

    cacheItems = @[@"Description", @"Hint", @"Personal Note", @"Field Note", @"Logs", @"Attributes", @"Related Waypoints", @"Inventory", @"Images", @"Group Members"];
    actionItems = @[@"Set as Target", @"Mark as Found"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    if (section == 1)
        return [cacheItems count];
    if (section == 2)
        return [actionItems count];
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"Cache data";
    if (section == 2)
        return @"Cache actions";
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Cache header
    if (indexPath.section == 0) {
        CacheHeaderTableViewCell *cell = [[CacheHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THISCELL_HEADER];
        cell.accessoryType = UITableViewCellAccessoryNone;
        Coordinates *c = [[Coordinates alloc] init:wp.lat_float lon:wp.lon_float];
        cell.lat.text = [c lat_degreesDecimalMinutes];
        cell.lon.text = [c lon_degreesDecimalMinutes];
        [cell setRatings:wp.gc_favourites terrain:wp.gc_rating_terrain difficulty:wp.gc_rating_difficulty];

        cell.size.image = [imageLibrary get:wp.gc_containerSize.icon];
        cell.icon.image = [imageLibrary get:wp.cache_type.icon];
        return cell;
    }

    // Cache data
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_DATA forIndexPath:indexPath];
        cell.textLabel.text = [cacheItems objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0: /* Description */
                if ([wp.gc_short_desc compare:@""] == NSOrderedSame && [wp.gc_long_desc compare:@""] == NSOrderedSame)
                    tc = [UIColor lightGrayColor];
                break;
            case 1: /* Hint */
                //                if (wp.gc_hint ==b nil || [wp.gc_hint compare:@""] == NSOrderedSame)
                if ([wp.gc_hint compare:@""] == NSOrderedSame || [wp.gc_hint compare:@" "] == NSOrderedSame)
                    tc = [UIColor lightGrayColor];
                break;
            case 2: /* Personal note */
                if ([wp.gc_personal_note compare:@""] == NSOrderedSame)
                    tc = [UIColor lightGrayColor];
                break;
            case 3: /* Field Note */
                if ([wp hasFieldNotes] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
            case 4: { /* Logs */
                NSInteger c = [wp hasLogs];
                if (c == 0)
                    tc = [UIColor lightGrayColor];
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [cacheItems objectAtIndex:indexPath.row], c];
                break;
            }
            case 5: { /* Attributes */
                NSInteger c = [wp hasAttributes];
                if (c == 0)
                    tc = [UIColor lightGrayColor];
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [cacheItems objectAtIndex:indexPath.row], c];
                break;
            }
            case 6: /* Related Waypoints */
                if ([wp hasWaypoints] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
            case 7: /* Inventory */
                if ([wp hasInventory] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
            case 8: /* Images */
                if ([wp hasImages] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
        }
        cell.textLabel.textColor = tc;
        cell.imageView.image = nil;
        return cell;
    }

    // Cache commands
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL_ACTIONS forIndexPath:indexPath];
        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [imageLibrary get:ImageIcon_Target];
                break;
            case 1:
                cell.imageView.image = [imageLibrary get:ImageIcon_Smiley];
                break;
        }
        cell.textLabel.text = [actionItems objectAtIndex:indexPath.row];
        cell.textLabel.textColor = tc;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return;
    }

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {   /* Description */
            UIViewController *newController = [[CacheDescriptionViewController alloc] init:wp];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 1) {   /* Hint */
            UIViewController *newController = [[CacheHintViewController alloc] init:wp];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 4) {   /* Logs */
            UITableViewController *newController = [[CacheLogsViewController alloc] init:wp];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 5) {   /* Attributes */
            UITableViewController *newController = [[CacheAttributesViewController alloc] init:wp];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        if (indexPath.row == 9) {    /* Groups */
            UITableViewController *newController = [[CacheGroupsViewController alloc] init:wp];
            newController.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:newController animated:YES];
            return;
        }
        return;
    }

    if (indexPath.section == 2) {
        if (indexPath.row == 0) {   /* Set a target */
            currentCache = wp;
            [[[[_AppDelegate.tabBars objectAtIndex:RC_NAVIGATE] viewControllers] objectAtIndex:VC_NAVIGATE_DETAILS] setCache:currentCache];
            [_AppDelegate switchController:RC_NAVIGATE];
            return;
        }
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [CacheTableViewCell cellHeight];
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
