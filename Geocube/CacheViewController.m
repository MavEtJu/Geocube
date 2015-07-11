//
//  CacheViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 9/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL @"cachetablecell"

@implementation CacheViewController

- (id)initWithStyle:(NSInteger)_style wayPoint:(dbWaypoint *)_wp;
{
    self = [super initWithStyle:_style];
    wp = _wp;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:THISCELL];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THISCELL forIndexPath:indexPath];

    // Cache header
    if (indexPath.section == 0) {
        return cell;
    }
    
    // Cache data
    if (indexPath.section == 1) {
        cell.textLabel.text = [cacheItems objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIColor *tc = [UIColor blackColor];
        switch (indexPath.row) {
            case 0: /* Description */
                if ([wp.gc_short_desc compare:@""] == NSOrderedSame && [wp.gc_long_desc compare:@""] == NSOrderedSame)
                    tc = [UIColor lightGrayColor];
                break;
            case 1: /* Hint */
//                if (wp.gc_hint == nil || [wp.gc_hint compare:@""] == NSOrderedSame)
                if ([wp.gc_hint compare:@""] == NSOrderedSame)
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
            case 4: /* Logs */
                if ([wp hasLogs] == 0)
                    tc = [UIColor lightGrayColor];
                else
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [cacheItems objectAtIndex:indexPath.row], [wp hasLogs]];
                break;
            case 5: /* Attributes Note */
                if ([wp hasAttributes] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
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
            case 9: /* Group Membership */
                if ([wp hasGroups] == FALSE)
                    tc = [UIColor lightGrayColor];
                break;
        }
        cell.textLabel.textColor = tc;
        cell.imageView.image = nil;
        return cell;
    }
    
    // Cache commands
    if (indexPath.section == 2) {
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
    
    return cell;
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
        return;
    }

    if (indexPath.section == 2) {
        return;
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
