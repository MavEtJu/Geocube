//
//  CacheGroupsViewController.m
//  Geocube
//
//  Created by Edwin Groothuis on 11/07/2015.
//  Copyright (c) 2015 Edwin Groothuis. All rights reserved.
//

#import "Geocube-Prefix.pch"

#define THISCELL @"CacheGroupsViewControllerCell"

@implementation CacheGroupsViewController

- (id)init:(dbCache *)_wp
{
    self = [super init];
    wp = _wp;
    
    ugs = [NSMutableArray arrayWithCapacity:5];
    sgs = [NSMutableArray arrayWithCapacity:5];
    
    NSArray *gs = [db CacheGroups_all_byCacheId:wp._id];
    NSEnumerator *e = [gs objectEnumerator];
    dbCacheGroup *wpg;
    while ((wpg = [e nextObject]) != nil) {
        if (wpg.usergroup == TRUE)
            [ugs addObject:wpg];
        else
            [sgs addObject:wpg];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[LogTableViewCell class] forCellReuseIdentifier:THISCELL];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - TableViewController related functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [ugs count];
    return [sgs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"User groups";
    return @"System groups";
}

// Return a cell for the index path
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:THISCELL];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:THISCELL];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSEnumerator *e;
    if (indexPath.section == 0)
        e = [ugs objectEnumerator];
    else
        e = [sgs objectEnumerator];
    
    dbCacheGroup *wpg;
    NSInteger c = 0;
    while ((wpg = [e nextObject]) != nil) {
        if (c == indexPath.row)
            break;
        c++;
    }
    cell.textLabel.text = wpg.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld caches", [db CacheGroups_count_caches:wpg._id]];
    cell.imageView.image = nil;
    
    return cell;
}


@end
